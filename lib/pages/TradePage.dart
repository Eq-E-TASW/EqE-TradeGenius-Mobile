import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trading_app/pages/CustomAppBar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trading_app/config.dart'; // Usa la variable apiBaseUrl

class TradePage extends StatefulWidget {
  static const String routename = '/trade';

  const TradePage({super.key});

  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final TextEditingController _accionController = TextEditingController();

  // Lista de opciones de modelos
  final List<String> _modelos = ['SVM', 'LSTM'];
  String? _selectedModelo;

  // Variables para los resultados
  String? _priceClose;
  String? _tendency;
  String? _imageUrl;
  bool _isLoading = false;

  // Función para realizar la predicción
  Future<void> fetchPrediction() async {
    if (_accionController.text.isEmpty || _selectedModelo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una acción y un modelo.')),
      );
      return;
    }

    final ticker = _accionController.text.trim();
    final model = _selectedModelo!;
    final predictionUrl = "$apiBaseUrl/api/prediction/predict/?ticker=$ticker&model=$model";

    setState(() {
      _isLoading = true;
      _priceClose = null;
      _tendency = null;
      _imageUrl = null;
    });

    try {
      final response = await http.post(Uri.parse(predictionUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final realValues = data['real_values'] as List<dynamic>;
        final predictedValues = data['predicted_values'] as List<dynamic>;
        final imageUrl = data['image_url'] as String;

        setState(() {
          _priceClose = predictedValues.isNotEmpty
              ? predictedValues[0].toStringAsFixed(2)
              : '--';
          _tendency = (predictedValues.isNotEmpty && realValues.isNotEmpty)
              ? (predictedValues[0] - realValues.last).toStringAsFixed(2)
              : '--';
          _imageUrl = "$apiBaseUrl/api/prediction$imageUrl";
        });
      } else {
        throw Exception('Error en la predicción: ${predictionUrl}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la predicción: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'TRADEGENIUS',
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Predicción de acciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Campo de ingresar acción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Acción: ',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _accionController,
                    decoration: InputDecoration(
                      hintText: 'Ingresar acción',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Selección para modelos con DropdownButton2
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Modelo: ',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: const Text(
                        'Ninguno seleccionado',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      items: _modelos
                          .map(
                            (modelo) => DropdownMenuItem<String>(
                          value: modelo,
                          child: Text(
                            modelo,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      value: _selectedModelo,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedModelo = newValue;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 20,
                        iconEnabledColor: Colors.grey,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 150,
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

            // Botón para generar gráfica
            ElevatedButton(
              onPressed: _isLoading ? null : fetchPrediction,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF20344C),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Generar Gráfica'),
            ),

            const SizedBox(height: 20),

            // Contenedor para la gráfica
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: _imageUrl != null
                  ? Image.network(_imageUrl!, fit: BoxFit.contain)
                  : const Center(
                child: Text(
                  '',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Precio de cierre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Precio de cierre:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 150,
                  height: 30,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      _priceClose ?? '--', // Si es null, muestra '--'
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (_tendency != null && double.tryParse(_tendency!) != null)
                            ? (double.parse(_tendency!) >= 0
                            ? Colors.green
                            : Colors.red)
                            : Colors.black54, // Predeterminado a negro/gris si no es válido
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tendencia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tendencia:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 150,
                  height: 30,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      _tendency ?? '--', // Si es null, muestra '--'
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (_tendency != null && double.tryParse(_tendency!) != null)
                            ? (double.parse(_tendency!) >= 0
                            ? Colors.green
                            : Colors.red)
                            : Colors.black54, // Predeterminado a negro/gris si no es válido
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
