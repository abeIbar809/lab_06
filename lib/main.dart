import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() async {
  final WeatherService weatherService = WeatherService();
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => WeatherProvider(weatherService: weatherService)),
    ],child: MyApp(),)
  );
}

class WeatherService { 

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final apiKey = dotenv.env['API_KEY'];
    
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final double feelsLike;
  final String humidity;
  final String windSpeed;
  final String pressure;
  final String icon;
  final String dt;
  final String country;


  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.feelsLike,
    required this.humidity, required this.windSpeed, required this.pressure, required this.icon, required this.dt, required this.country,
  });



  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'].toString(), 
      windSpeed: json['wind']['speed'].toString(),
      pressure: json['main']['pressure'].toString(),
      icon: json['weather'][0]['icon'],
      dt: json['dt'].toString(),
      country: json['sys']['country'].toString(),
    );
  }
}


class WeatherProvider extends ChangeNotifier { 

  final WeatherService _weatherService;
  WeatherData? weatherData;

  WeatherProvider({required this._weatherService});

  Future<void> fetchWeather(String city) async {
    try {
      final data = await _weatherService.fetchWeather(city);
      weatherData = WeatherData.fromJson(data);
      notifyListeners();
    } catch (e) {
      weatherData = null;
      print(e);
      
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {

  final TextEditingController _controller = TextEditingController();
  @override
  initState() { 
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WeatherProvider weatherProvider = Provider.of<WeatherProvider>(context);
    double width = MediaQuery.of(context).size.width;
    

    return Align(
      alignment: .center,
      child: Card(
        child: Container(
          height: 350,
          width: width * 0.85,

          decoration: BoxDecoration(),
          child: Column(
            children: [

              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          "Today ${weatherProvider.weatherData?.temperature}°",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Image.network(
                            "https://openweathermap.org/payload/api/media/file/${weatherProvider.weatherData?.icon == null ? "10d" : weatherProvider.weatherData!.icon }.png",
                            scale: 1.3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Feels like ${weatherProvider.weatherData?.feelsLike} °",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "4:00 AM ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${weatherProvider.weatherData?.cityName}, ${weatherProvider.weatherData?.country}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: .center,
                    spacing: 50,
                    children: [
                     
                        Column(
                          crossAxisAlignment: .center,
                          mainAxisAlignment: .center,
                          children: [
                            Text(
                              "Pressure",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            Text("${weatherProvider.weatherData?.pressure} hPa"),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: .center,
                          mainAxisAlignment: .center,
                          children: [
                            Text(
                              "Humidity",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            Text("${weatherProvider.weatherData?.humidity}%"),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: .center,
                          mainAxisAlignment: .center,
                          children: [
                            Text(
                              "Wind speed",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            Text("${weatherProvider.weatherData?.windSpeed} m/s"),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search City",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (value) => {
                    _controller.text = value
                  },
                 
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    minimumSize: Size(width, 40),
                  ),
                  onPressed: () {
                    weatherProvider.fetchWeather(_controller.text);
                  },
                  child: Text("Search", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: ListView(children: [WeatherCard()]),
    );
  }
}
