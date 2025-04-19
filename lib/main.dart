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
  bool _loading = false;
  String? _saldo;
  String? _error;

  Future<void> consultarSaldo(String numTarjeta) async {
    setState(() {
      _loading = true;
      _saldo = null;
      _error = null;
    });

    final url = Uri.parse(
        'https://recaudo.sondapay.com/recaudowsrest/producto/consultaTrx');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': '*/*',
      'Origin': 'https://transcaribe.gov.co',
    };

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
          setState(() {
            _saldo = data['saldo'].toString();
          });
        } else {
          setState(() {
            _error = data['mensaje'] ?? 'Error desconocido';
          });
        }
      } else {
        setState(() {
          _error = 'Error HTTP: ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Excepción: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF1F9),
      appBar: AppBar(
        title: Text('Consulta tu Saldo'),
        backgroundColor: Color(0xFFFF6F00),
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
                backgroundColor: Color(0xFFFF6F00),
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _loading
                  ? null
                  : () {
                final num = _ctr.text.trim();
                if (num.isEmpty) {
                  setState(() {
                    _error = 'Ingresa un número de tarjeta.';
                  });
                } else {
                  consultarSaldo(num);
                }
              },
              child: _loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Consultar Saldo'),
            ),
            if (_error != null) ...[
              SizedBox(height: 20),
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            ],
            if (_saldo != null)
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6F00),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(4, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo_trasca.png',
                        height: 60,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Saldo disponible',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '\$$_saldo',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
