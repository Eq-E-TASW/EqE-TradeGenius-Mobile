import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trading_app/pages/CustomAppBar.dart';
import 'package:trading_app/config.dart';

class HomePage extends StatefulWidget {
  static const String routename = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> stockData = []; // Lista para almacenar los datos del backend
  bool isLoading = true; // Para mostrar un indicador de carga
  double totalBalance = 0.0; // Almacena el balance total del usuario

  @override
  void initState() {
    super.initState();
    fetchStockData(false); // Carga inicial con all=false
    fetchTotalBalance(); // Obtiene el balance total
  }

  // Función para obtener el balance total
  Future<void> fetchTotalBalance() async {
    const url =
        '$apiBaseUrl/api/trading/get_assets/123';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalBalance = (data['Total'] as num).toDouble(); // Convierte el total a double
        });
      } else {
        throw Exception('Error al obtener el balance total: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el balance total: $e')),
        );
      });
    }
  }

  // Función para obtener datos de las acciones
  Future<void> fetchStockData(bool all) async {
    setState(() {
      isLoading = true; // Activa el indicador de carga
    });

    final url =
        '$apiBaseUrl/api/data_ingestion/tickers?all=$all';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Mapea los datos obtenidos a la estructura usada en la UI
        setState(() {
          stockData = data
              .map((item) => {
            'name': item['name'] ?? 'Unknown',
            'price': item['price'] is int
                ? (item['price'] as int).toDouble()
                : item['price'], // Asegura que el precio sea double
            'change': item['change'] is int
                ? (item['change'] as int).toDouble()
                : item['change'], // Asegura que el cambio sea double
          })
              .toList();
        });
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        stockData = []; // Limpia los datos si hay error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      });
    } finally {
      setState(() {
        isLoading = false; // Desactiva el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'TRADEGENIUS'), // Usa CustomAppBar
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Bienvenido',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            // Contenedor de Balance Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF20344C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '\$${totalBalance.toStringAsFixed(2)}', // Balance total dinámico
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Balance Total',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Principales Acciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    // Al hacer clic en "See All", carga todos los datos
                    fetchStockData(true);
                  },
                  child: const Text(
                    'Ver Todas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 4, 4, 4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Mostrar indicador de carga mientras se obtienen los datos
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
            // Lista de Acciones obtenidas del backend
              Expanded(
                child: ListView.builder(
                  itemCount: stockData.length,
                  itemBuilder: (context, index) {
                    final stock = stockData[index];
                    final double change = stock['change'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stock['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Mostrar icono de tendencia
                          change > 0
                              ? const Icon(Icons.trending_up,
                              color: Colors.green)
                              : change < 0
                              ? const Icon(Icons.trending_down,
                              color: Colors.red)
                              : const Icon(Icons.trending_flat,
                              color: Colors.grey),
                          // Mostrar precio y cambio porcentual
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${stock['price'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: change > 0
                                      ? Colors.green
                                      : change < 0
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
