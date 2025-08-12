import 'package:flutter/material.dart';
import 'location_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weatherapp/services/weather.dart';
import 'city_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isLoading = true; // NEW: Tracks loading state
  bool hasError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  void getLocationData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = "";
    });

    try {
      var weatherData = await WeatherModel()
          .getLocationWeather()
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception("Location or network request timed out.");
      });

      if (weatherData == null) {
        throw Exception("Unable to retrieve weather data.");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(locationWeather: weatherData),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  void getCityWeather(String cityName) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      var weatherData = await WeatherModel().getCityWeather(cityName);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(locationWeather: weatherData),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Failed to get weather for $cityName: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Show loading screen while fetching
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: SpinKitRipple(
            color: Colors.white,
            size: 100.0,
          ),
        ),
      );
    }

    // 2️⃣ Show error screen only if GPS failed
    if (hasError) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
                SizedBox(height: 20),
                Text(
                  "Oops! Something went wrong.",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  errorMessage,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: getLocationData,
                      icon: Icon(Icons.gps_fixed),
                      label: Text("Retry GPS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                    SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: () async {
                        var typedName = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CityScreen(),
                          ),
                        );
                        if (typedName != null &&
                            typedName.toString().trim() != "") {
                          getCityWeather(typedName);
                        }
                      },
                      icon: Icon(Icons.location_city),
                      label: Text("Enter City"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3️⃣ Fallback in case something unexpected happens
    return Scaffold(
      body: Center(
        child: Text(
          "Unexpected state",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
