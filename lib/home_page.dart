

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/const.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});
  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Map<String, IconData> weatherIconMap = {
    "Clear": WeatherIcons.day_sunny,
    "Clouds": WeatherIcons.cloud,
    "Rain": WeatherIcons.rain,
    "Snow": WeatherIcons.snow,
    "Thunderstorm": WeatherIcons.thunderstorm,
    "Drizzle": WeatherIcons.showers,
    "Mist": WeatherIcons.fog,
    "haze": WeatherIcons.day_cloudy,
  };

  Weather? _weather;
  //This symbol makes the Weather type nullable. It means that the _weather variable
  // can either hold an instance of the Weather class or it can be null.
  //This is useful when the variable might not have a value at some point.
  final TextEditingController _cityController = TextEditingController();

  void _updateWeather(String cityName) async {
    final weather = await _wf.currentWeatherByCityName(cityName);
    setState(() {
      _weather = weather;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateWeather("Delhi");
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyBoardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7F7FD5),
            Color(0xFF86A8E7),
            Color(0xFF91EAE4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Make Scaffold background transparent to see the gradient
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(
              228, 13, 64, 140), // Make AppBar background transparent
          centerTitle: true,
          title: const Text(
            'Weather App',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: 50.0,
          elevation: 0, // Remove shadow to blend with gradient
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyBoardSpace + 16),
          child: Column(
            children: [
              _buildInputField(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.02,
              ),
              _buildUI(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _dateTimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTemp(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      //The ?? operator is called the "null-coalescing" operator.
      // It is used to provide a default value in case the expression on its left side evaluates to null.
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 35,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat("EEEE").format(now),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              Text(
                "  ${DateFormat("d/MM/y").format(now)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ])
      ],
    );
  }

  Widget _weatherIcon() {
    IconData? iconData = weatherIconMap[_weather?.weatherMain];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          iconData ??
              WeatherIcons
                  .na, // Fallback icon if weather condition is not found
          size: 100,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.02,
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.80,
      decoration: BoxDecoration(
        color: Color.fromARGB(227, 53, 105, 183),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      padding: const EdgeInsets.all(
        8.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _updateWeather(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _updateWeather(_cityController.text);
            },
          ),
        ],
      ),
    );
  }
}
