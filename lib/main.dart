import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ConsultaSaldoApp());
}

class ConsultaSaldoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta Saldo Transcaribe',
      debugShowCheckedModeBanner: false,
      home: ConsultaSaldoPage(),
    );
  }
}

class ConsultaSaldoPage extends StatefulWidget {
  @override
  _ConsultaSaldoPageState createState() => _ConsultaSaldoPageState();
}

class _ConsultaSaldoPageState extends State<ConsultaSaldoPage> {
  final TextEditingController _ctr = TextEditingController();

  Future<void> consultarSaldo(String numTarjeta) async {
    final url = Uri.parse(
      'https://recaudo.sondapay.com/recaudowsrest/producto/consultaTrx',
    );

    // Cabeceras idénticas a las de la web
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': '*/*',
      'Origin': 'https://transcaribe.gov.co',
    };

    // Payload tal cual se ve en DevTools de TransCaribe
    final body = jsonEncode({
      'nivelConsulta': 1,
      'tipoConsulta': 2,
      'numExterno': numTarjeta,
    });

    try {
      final resp = await http.post(url, headers: headers, body: body);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        print('Respuesta cruda: $data');

        if (data['estado'] == 0 && data['saldo'] != null) {
          print('Saldo disponible: ${data['saldo']}');
        } else {
          print('Error del servicio: ${data['mensaje']}');
        }
      } else {
        print('Error HTTP: ${resp.statusCode}');
      }
    } catch (e) {
      print('Excepción: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta tu Saldo'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctr,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de tarjeta',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () {
                final num = _ctr.text.trim();
                if (num.isEmpty) {
                  print('Ingresa un número de tarjeta.');
                } else {
                  consultarSaldo(num);
                }
              },
              child: Text('Consultar Saldo'),
            ),
          ],
        ),
      ),
    );
  }
}
