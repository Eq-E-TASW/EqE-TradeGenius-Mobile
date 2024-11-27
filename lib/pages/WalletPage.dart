import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trading_app/pages/CustomAppBar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trading_app/config.dart'; // Importa el archivo donde definiste apiBaseUrl

class WalletPage extends StatefulWidget {
  static const String routename = '/wallet';

  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<String> _selectedItems = []; // Items seleccionados (tickers)
  String selectedButton = 'Semana'; // Botón seleccionado (tiempo)
  String? _selectedPrecio; // Tipo de precio
  String? pricesGraphUrl; // URL del gráfico de precios
  String? volumeGraphUrl; // URL del gráfico de volumen
  List<String> tickers = []; // Lista de tickers obtenidos del backend
  bool isFetchingPricesGraph = false; // Estado de carga para el gráfico de precios
  bool isFetchingVolumeGraph = false; // Estado de carga para el gráfico de volumen

  final List<String> _precio = ['Apertura', 'Más bajo', 'Más alto', 'Cierre'];

  @override
  void initState() {
    super.initState();
    fetchTickers(); // Cargar tickers al iniciar la pantalla
  }

  // Función para obtener la lista de tickers
  Future<void> fetchTickers() async {
    final url = "$apiBaseUrl/api/data_ingestion/tickers?all=true";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          tickers = data.map((item) => item['name'] as String).toList();
        });
      }
    } catch (_) {
      // Silenciar excepciones al obtener los tickers
    }
  }

  // Función para obtener el gráfico de precios
  Future<void> fetchPricesGraph() async {
    if (_selectedItems.isEmpty || _selectedPrecio == null) return;

    setState(() {
      isFetchingPricesGraph = true; // Inicia el estado de carga para precios
    });

    // Transforma los valores para la API
    final unit = selectedButton == 'Semana'
        ? 'weeks'
        : selectedButton == 'Mes'
        ? 'months'
        : 'years';
    final priceType = _selectedPrecio == 'Apertura'
        ? 'open'
        : _selectedPrecio == 'Más bajo'
        ? 'low'
        : _selectedPrecio == 'Más alto'
        ? 'high'
        : 'close';

    final tickersQuery = _selectedItems.map((e) => 'tickers=$e').join('&');
    final url =
        "$apiBaseUrl/api/data_ingestion/plot/?$tickersQuery&amount=1&unit=$unit&price_type=$priceType";

    print("Llamando al endpoint del gráfico de precios: $url"); // Depuración

    try {
      final response = await http.get(Uri.parse(url));
      print("Respuesta del endpoint de precios: ${response.statusCode}"); // Depuración
      if (response.statusCode == 200) {
        setState(() {
          pricesGraphUrl = "$url&timestamp=${DateTime.now().millisecondsSinceEpoch}";
          print("URL del gráfico de precios actualizada: $pricesGraphUrl"); // Depuración
        });
      }
    } catch (e) {
      print("Excepción al obtener el gráfico de precios: $e"); // Depuración
    } finally {
      setState(() {
        isFetchingPricesGraph = false; // Finaliza el estado de carga para precios
      });
    }
  }


  // Función para obtener el gráfico de volumen
  Future<void> fetchVolumeGraph() async {
    if (_selectedItems.isEmpty) return;

    setState(() {
      isFetchingVolumeGraph = true; // Inicia el estado de carga para volumen
    });

    final tickersQuery = _selectedItems.map((e) => 'tickers=$e').join('&');
    final url = "$apiBaseUrl/api/data_ingestion/plot_last_volume?$tickersQuery";

    print("Llamando al endpoint del gráfico de volumen: $url"); // Depuración

    try {
      final response = await http.get(Uri.parse(url));
      print("Respuesta del endpoint de volumen: ${response.statusCode}"); // Depuración
      if (true) {
        setState(() {
          volumeGraphUrl = "$url&timestamp=${DateTime.now().millisecondsSinceEpoch}";
          print("URL del gráfico de volumen actualizada: $volumeGraphUrl"); // Depuración
        });
      }
    } catch (e) {
      print("Excepción al obtener el gráfico de volumen: $e"); // Depuración
    } finally {
      setState(() {
        isFetchingVolumeGraph = false; // Finaliza el estado de carga para volumen
      });
    }
  }

  // Función para actualizar ambas gráficas
  Future<void> updateGraphs() async {
    await fetchPricesGraph();
    await Future.delayed(const Duration(milliseconds: 100));
    await fetchVolumeGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'TRADEGENIUS'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final List<String>? results = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MultiSelect(
                              items: tickers,
                              initiallySelected: _selectedItems,
                            );
                          },
                        );

                        if (results != null) {
                          setState(() {
                            _selectedItems = results;
                          });
                          updateGraphs(); // Actualiza las gráficas
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Acciones'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Tipo de Precio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        items: _precio
                            .map(
                              (precio) => DropdownMenuItem<String>(
                            value: precio,
                            child: Text(
                              precio,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                        value: _selectedPrecio,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPrecio = newValue;
                          });
                          updateGraphs(); // Actualiza las gráficas
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            color: Colors.grey[50],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 20,
                          iconEnabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 210,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Botones de Semana, Mes y Año
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSelectableButton('Semana'),
                  const SizedBox(width: 10),
                  _buildSelectableButton('Mes'),
                  const SizedBox(width: 10),
                  _buildSelectableButton('Año'),
                ],
              ),

              const SizedBox(height: 20),

              // Gráfico de Precios
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF20344C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Evolución de precios de acciones',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isFetchingPricesGraph
                    ? const Center(child: CircularProgressIndicator())
                    : pricesGraphUrl != null
                    ? Image.network(pricesGraphUrl!)
                    : const Center(child: Text("Seleccione opciones para el gráfico de precios")),
              ),

              const SizedBox(height: 20),

              // Gráfico de Volumen
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF20344C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Último volumen de acciones',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isFetchingVolumeGraph
                    ? const Center(child: CircularProgressIndicator())
                    : volumeGraphUrl != null
                    ? Image.network(volumeGraphUrl!)
                    : const Center(child: Text("Seleccione opciones para el gráfico de volumen")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botones seleccionados
  Widget _buildSelectableButton(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedButton = label;
          });
          updateGraphs(); // Actualiza las gráficas
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedButton == label
              ? const Color(0xFF58A6FF)
              : Colors.grey[50],
          side: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
            selectedButton == label ? Colors.white : Colors.black, // Texto blanco solo en el botón seleccionado
          ),
        ),
      ),
    );
  }
}

// Lista de seleccionar acciones
class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> initiallySelected;

  const MultiSelect({Key? key, required this.items, required this.initiallySelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initiallySelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar acciones'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(item),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? isChecked) {
                setState(() {
                  isChecked == true
                      ? _selectedItems.add(item)
                      : _selectedItems.remove(item);
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCELAR'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(_selectedItems);
          },
        ),
      ],
    );
  }
}
