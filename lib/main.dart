import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() async{
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(
            color: Colors.white)
        ),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(
            color: Colors.amber)
        ),
        hintStyle: TextStyle(color: Colors.amber),
      )
    ),
  ));
}

Future<Map> getData() async {
  const url = 'https://api.hgbrasil.com/finance?key=ace41055';
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

Widget buildMessageContainer(String message) {
  return Center(
    child: Text(
      message,
      style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0,
      ),
    ),
  );
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function handler) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.amber
        ),
        border: OutlineInputBorder(),
        prefixText: '$prefix '
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
    controller: controller,
    onChanged: handler,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double dollar;
  double euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '\$ Conversor \$',
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return buildMessageContainer('Carregando dados');
            default:
              if (snapshot.hasError) {
                return buildMessageContainer('Erro ao carregar dados');
              } else {

                dollar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];

                final realController = TextEditingController();
                final dollarController = TextEditingController();
                final euroController = TextEditingController();

                void _clearAll() {
                  realController.text = '';
                  dollarController.text = '';
                  euroController.text = '';
                }

                void _realChanged(String text){
                  if(text.isEmpty) {
                    _clearAll();
                    return;
                  }
                  var real = double.parse(text);
                  dollarController.text = (real / dollar).toStringAsFixed(2);
                  euroController.text = (real / euro).toStringAsFixed(2);
                }

                void _dollarChanged(String text){
                  if(text.isEmpty) {
                    _clearAll();
                    return;
                  }
                  var dollar = double.parse(text);
                  realController.text = (dollar * this.dollar).toStringAsFixed(2);
                  euroController.text = ((dollar * this.dollar) / euro).toStringAsFixed(2);
                }

                void _euroChanged(String text){
                  if(text.isEmpty) {
                    _clearAll();
                    return;
                  }
                  var euro = double.parse(text);
                  realController.text = (euro * this.euro).toStringAsFixed(2);
                  dollarController.text = ((euro * this.euro) / dollar).toStringAsFixed(2);
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber,),
                      Divider(),
                      buildTextField('Reais', 'R\$', realController, _realChanged),
                      Divider(),
                      buildTextField('Dólares', 'US\$', dollarController, _dollarChanged),
                      Divider(),
                      buildTextField('Euros', '€', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      )
    );
  }
}