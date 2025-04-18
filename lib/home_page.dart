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

  final Map<String, String> weatherImageMap = {
    "Clear": "assets/images/sunny.jpeg",
    "Clouds": "assets/images/cloudy.jpeg",
    "Rain": "assets/images/rainy.jpeg",
    "Snow": "assets/images/snowy.jpeg",
    "Thunderstorm": "assets/images/thunderstorm.jpeg",
    "Drizzle": "assets/images/drizzle.jpeg",
    "Mist": "assets/images/mist.jpeg",
    "Haze": "assets/images/hazy.jpeg",
    "Fog": "assets/images/mist.jpeg",
  };

  final Map<String, IconData> weatherIconMap = {
    "Clear": WeatherIcons.day_sunny,
    "Clouds": WeatherIcons.cloud,
    "Rain": WeatherIcons.rain,
    "Snow": WeatherIcons.snow,
    "Thunderstorm": WeatherIcons.thunderstorm,
    "Drizzle": WeatherIcons.showers,
    "Mist": WeatherIcons.fog,
    "Haze": WeatherIcons.day_cloudy,
    "Fog": WeatherIcons.fog,
  };

  Weather? _weather;
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
    final screenSize = MediaQuery.sizeOf(context);

    final String condition = _weather?.weatherMain ?? "Clear";
    final String? backgroundImage = weatherImageMap[condition];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with opacity
          if (backgroundImage != null)
            Opacity(
              opacity: 0.6, // Adjust the opacity here
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              color: Colors.blueGrey.shade800,
            ),

          // Transparent overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, keyBoardSpace + 16),
              child: Column(
                children: [
                  _buildAppBar(),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildInputField(),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildUI(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.3),
      centerTitle: true,
      title: const Text(
        'Weather App',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      toolbarHeight: 50.0,
      elevation: 0,
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _locationHeader(),
        const SizedBox(height: 20),
        _dateTimeInfo(),
        const SizedBox(height: 20),
        _weatherIcon(),
        const SizedBox(height: 20),
        _currentTemp(),
        const SizedBox(height: 20),
        _extraInfo(),
        const SizedBox(height: 20),
        _weatherTipCard(),
      ],
    );
  }

  // 🏙️ City Name Header
  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "City",
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(blurRadius: 5, color: Colors.black26)],
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(fontSize: 35, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.white),
            ),
            Text(
              "  ${DateFormat("d/MM/y").format(now)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    IconData? iconData = weatherIconMap[_weather?.weatherMain];
    return Column(
      children: [
        Icon(iconData ?? WeatherIcons.na, size: 110, color: Colors.white),
        const SizedBox(height: 10),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 22,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: const TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 3))
        ],
      ),
    );
  }

  Widget _extraInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(
                  "Max",
                  "${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                  WeatherIcons.hot),
              _infoTile(
                  "Min",
                  "${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                  WeatherIcons.snowflake_cold),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(
                  "Wind",
                  "${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
                  WeatherIcons.strong_wind),
              _infoTile(
                  "Humidity",
                  "${_weather?.humidity?.toStringAsFixed(0)}%",
                  WeatherIcons.humidity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.white),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _weatherTipCard() {
    final double? temp = _weather?.temperature?.celsius;
    final String? condition = _weather?.weatherMain;
    String tip = "Stay safe and hydrated!";

    if (temp != null) {
      if (temp > 35) {
        tip = "It's very hot! Stay indoors and drink plenty of water.";
      } else if (temp < 10) {
        tip = "It's quite cold! Dress warmly and stay cozy.";
      } else if (condition == "Rain") {
        tip = "Don't forget your umbrella! It's raining out.";
      } else if (condition == "Snow") {
        tip = "Snowy day! Bundle up and watch your step.";
      } else if (condition == "Thunderstorm") {
        tip = "Thunderstorm ahead! Stay indoors if possible.";
      } else if (condition == "Clear") {
        tip = "Perfect weather for a walk or outdoor activity!";
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) => _updateWeather(value),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _updateWeather(_cityController.text),
          ),
        ],
      ),
    );
  }
}
