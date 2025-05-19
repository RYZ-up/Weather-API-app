// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:train2/services/weather_service.dart';
import 'package:train2/weather/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService("4d210bd37ee1e0ba62675177cdd03a0a");
  Weather? _weather;

  Future<void> _fetchWeather() async {
    try {
      // Demande permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // Obtenir position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Obtenir la ville
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String cityName = placemarks.first.locality ?? "Unknown";
      debugPrint("City name: $cityName");

      // Récupérer météo
      final weather = await _weatherService.getWeather(cityName);
      debugPrint("Weather data: $weather");

      setState(() {
        _weather = weather;
      });
    } catch (e) {
      debugPrint("Erreur: $e");
    }
  }

  String getWeatherAnimation(String? mainCondition){
    if (mainCondition  == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()){
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return "assets/cloudly.json";
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return "assets/rainy.json";
      case 'thunderstorm':
        return "assets/thunder.json";
      case 'clear':
        return "assets/sunny.json";
      default:
        return "assets/sunny.json";
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Welcome back Rayane !"),
        titleTextStyle: TextStyle(
          fontFamily: "Arial",
          color :Colors.black,
          fontSize: 20,
        ),
      ),
      body: Container(
        color : Colors.white,

        child: Center(
          child: _weather == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_weather!.cityName),
                    Lottie.asset(getWeatherAnimation(_weather ?.mainCondition)),
        
        
                    Text("${_weather!.temperature.round()}°C"),
                    Text(_weather?.mainCondition ??""),
        
                  ],
                ),
        ),
      ),
    );
  }
}
