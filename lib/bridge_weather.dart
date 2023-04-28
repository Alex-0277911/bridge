// Патерн "міст" - це патерн проектування, що використовується в програмній
// інженерії, який має на меті "відокремити абстракцію від її реалізації, щоб
// вони могли змінюватися незалежно", введений "Бандою чотирьох". Міст
// використовує інкапсуляцію, агрегацію і може використовувати успадкування,
// щоб розділити обов'язки на різні класи.

// Коли клас часто змінюється, можливості об'єктно-орієнтованого програмування
// стають дуже корисними, оскільки зміни в код програми можна легко вносити з
// мінімальними попередніми знаннями про програму. Патерн "міст" корисний,
// коли і клас, і те, що він робить, часто змінюється. Сам клас можна розглядати
// як абстракцію, а те, що він може робити - як реалізацію. Патерн "міст" також
// можна розглядати як два шари абстракції.

// Паттерн міст часто плутають з паттерном адаптер, і його часто реалізують за
// допомогою паттерну об'єктний адаптер.

// Варіант: Реалізацію можна ще більше відокремити, відклавши наявність
// реалізації до того моменту, коли буде використано абстракцію.

// приклад використання шаблону "Міст" у Dart для отримання прогнозу погоди
// з декількох джерел:

// У цьому прикладі ми маємо абстрактний клас WeatherService і дві конкретні
// реалізації OpenMeteoService і OpenWeatherMapService. Клас WeatherService має
// посилання на екземпляр інтерфейсу WeatherApi, який виступає в ролі
// реалізатора. Ми маємо дві конкретні реалізації інтерфейсу WeatherApi:
// OpenMeteoApi та OpenWeatherMapApi.

// Клієнтський код створює екземпляри

import 'dart:convert';
import 'package:http/http.dart' as http;

// Abstraction class
abstract class WeatherService {
  Future<WeatherData> getWeatherData(String location);
}

// Concrete реалізація
class OpenMeteoService extends WeatherService {
  OpenMeteoApi openMeteoApi = OpenMeteoApi();
  //
  @override
  Future<WeatherData> getWeatherData(String location) =>
      openMeteoApi.getWeatherData(location);
}

// Concrete реалізація
class OpenWeatherMapService extends WeatherService {
  OpenWeatherMapApi openWeatherMapApi = OpenWeatherMapApi();
  @override
  Future<WeatherData> getWeatherData(String location) =>
      openWeatherMapApi.getWeatherData(location);
}

// Implementor class
abstract class WeatherApi {
  Future<WeatherData> getWeatherData(String location);
}

// Concrete Implementor class
class OpenMeteoApi implements WeatherApi {
  Future<Map<String, dynamic>> fetchWeather(String location) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=46.49&longitude=30.74&current_weather=true';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to retrieve weather data from OpenMeteo API');
    }
  }

  @override
  Future<WeatherData> getWeatherData(String location) async {
    final data = await fetchWeather(location);
    final temperature = data['current_weather']['temperature'];
    final windspeed = (data['current_weather']['windspeed']) / 3.6;
    final source = 'OpenMeteo';
    return WeatherData(
      location: location,
      temperature: temperature,
      windspeed: windspeed,
      source: source,
    );
  }
}

// Concrete Implementor class
class OpenWeatherMapApi implements WeatherApi {
  // Ось приклад того, як можна зробити виклик API до OpenWeatherMap і повернути
  // відповідь JSON за допомогою http-пакету в Dart:

  Future<Map<String, dynamic>> fetchWeather(String location) async {
    final lat = 46.48572;
    final lon = 30.74383;
    final appId =
        'd7f3fb73c94b0165061b6b96fc397852'; // Replace with your app ID
    final url =
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&units=metric&exclude=minutely,hourly,daily,alerts&appid=$appId';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  @override
  Future<WeatherData> getWeatherData(String location) async {
    final data = await fetchWeather(location);
    final temperature = data['current']['temp'];
    final windspeed = data['current']['wind_speed'];
    final source = 'OpenWeatherMap';
    return WeatherData(
      location: location,
      temperature: temperature,
      windspeed: windspeed,
      source: source,
    );
  }
}

// Data Transfer Object
class WeatherData {
  String? location;
  double? temperature;
  double? windspeed;
  String? source;
  WeatherData({this.location, this.temperature, this.windspeed, this.source});
}

// Client code
void main() async {
  final location = 'Odessa';

  final openMeteoService = OpenMeteoService();
  final openWeatherMapApiService = OpenWeatherMapService();

  final openMeteoData = await openMeteoService.getWeatherData(location);
  final openWeatherMapData =
      await openWeatherMapApiService.getWeatherData(location);

  print('Weather forecast for $location:');
  print(
      'Temperature ${openMeteoData.temperature}°C and wind speed ${openMeteoData.windspeed!.toStringAsFixed(2)} m/s (from ${openMeteoData.source})');
  print(
      'Temperature ${openWeatherMapData.temperature}°C and wind speed ${openWeatherMapData.windspeed} m/s (from ${openWeatherMapData.source})');
}
