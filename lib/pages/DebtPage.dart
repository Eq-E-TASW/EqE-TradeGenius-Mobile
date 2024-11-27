import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trading_app/pages/CustomAppBar.dart';
import 'package:trading_app/config.dart'; // Asegúrate de que esté definida apiBaseUrl

class DebtPage extends StatefulWidget {
  static const String routename = '/debt';

  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  List<Map<String, dynamic>> productData = []; // Se conectará al backend
  final TextEditingController _actionController = TextEditingController();
  String? _statusMessage;
  bool _isSuccess = false; // Para manejar si el mensaje es exitoso
  int _selectedQuantity = 0;
  int _selectedAction = 0;

  @override
  void initState() {
    super.initState();
    fetchAssets(); // Llama al backend al inicializar
  }

  Future<void> fetchAssets() async {
    final url = "$apiBaseUrl/api/trading/get_assets/123";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          productData = List<Map<String, dynamic>>.from(data["Assets"]);
        });
      } else {
        setState(() {
          _statusMessage = "Error al cargar los activos. Código: ${response.statusCode}";
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error al cargar los activos: $e";
        _isSuccess = false;
      });
    }
  }

  Future<void> tradeAsset() async {
    final symbol = _actionController.text.trim();
    final quantity = _selectedAction == 0 ? _selectedQuantity : -_selectedQuantity;

    if (symbol.isEmpty || quantity == 0) {
      setState(() {
        _statusMessage = "Por favor, llena los campos correctamente.";
        _isSuccess = false;
      });
      return;
    }

    final url = "$apiBaseUrl/api/trading/trade";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": 123,
          "symbol": symbol,
          "quantity": quantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          _statusMessage = data["message"];
          _isSuccess = true;
        });

        // Actualizar la tabla después de la operación
        await fetchAssets();
      } else {
        setState(() {
          _statusMessage = "Error al realizar la operación. Código: ${response.statusCode}";
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error al realizar la operación: $e";
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = productData.fold(
      0.0,
          (sum, product) => sum + (product['Subtotal'] ?? 0),
    );

    return Scaffold(
      appBar: const CustomAppBar(title: 'TRADEGENIUS'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis acciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 30.0,
                    columns: const [
                      DataColumn(label: CenteredText('Nombre')),
                      DataColumn(label: CenteredText('Cantidad')),
                      DataColumn(label: CenteredText('P. Unit.')),
                      DataColumn(label: CenteredText('Subtotal')),
                    ],
                    rows: productData.map((product) {
                      return DataRow(
                        cells: [
                          CenteredCell(product['Nombre']),
                          CenteredCell(product['Cantidad'].toString()),
                          CenteredCell('\$${product['P. Unit.'].toStringAsFixed(2)}'),
                          CenteredCell('\$${product['Subtotal'].toStringAsFixed(2)}'),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 220.0),
                    child: Text(
                      'Total: ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text(
                'Operaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Text(
                    'Acción: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: TextField(
                      controller: _actionController,
                      decoration: const InputDecoration(
                        labelText: 'Ingresa una acción',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Cantidad: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: _selectedQuantity.toString(),
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedQuantity = int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedQuantity++;
                                  });
                                },
                                child: const Icon(Icons.arrow_drop_up, size: 20),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (_selectedQuantity > 0) {
                                      _selectedQuantity--;
                                    }
                                  });
                                },
                                child: const Icon(Icons.arrow_drop_down, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Text(
                    'Trámite: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 40),
                  ToggleButtons(
                    isSelected: [_selectedAction == 0, _selectedAction == 1],
                    onPressed: (int index) {
                      setState(() {
                        _selectedAction = index;
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Comprar', style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Vender', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                    borderColor: Colors.grey,
                    selectedBorderColor: Color(0xFF20344C),
                    selectedColor: Colors.white,
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                    fillColor: Color(0xFF20344C),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: tradeAsset,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF20344C),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Trading'),
              ),

              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSuccess)
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _statusMessage!,
                          style: TextStyle(
                            fontSize: 16,
                            color: _isSuccess ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CenteredText extends StatelessWidget {
  final String text;

  const CenteredText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}

class CenteredCell extends DataCell {
  CenteredCell(String text)
      : super(CenteredText(text));
}
