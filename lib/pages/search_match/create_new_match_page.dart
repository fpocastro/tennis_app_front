import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CreateNewMatchPage extends StatefulWidget {
  @override
  _CreateNewMatchPageState createState() => _CreateNewMatchPageState();
}

class _CreateNewMatchPageState extends State<CreateNewMatchPage> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'no-action';
  String _errorMessage;
  final _dateTextField = TextEditingController();
  final _timeTextField = TextEditingController();
  bool _useDefaultPlaces = true;
  List<String> _selectedPlaces = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Partida')),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      final DateTime _now = DateTime.now();
                      showDatePicker(
                        context: context,
                        initialDate: _now,
                        firstDate: _now,
                        lastDate: DateTime(_now.year + 1),
                      ).then((date) {
                        setState(() {
                          _dateTextField.text =
                              DateFormat('dd/MM/yyyy').format(date);
                        });
                      });
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _dateTextField,
                        // validator: () => return null,
                        decoration: InputDecoration(
                          icon: Icon(Icons.event),
                          hintText: ('Qual dia você quer jogar?'),
                          labelText: ('Data'),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showTimePicker(
                              context: context, initialTime: TimeOfDay.now())
                          .then((time) {
                        _timeTextField.text = time.format(context);
                      });
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _timeTextField,
                        readOnly: true,
                        // validator: _validatePassword,
                        decoration: InputDecoration(
                          icon: Icon(Icons.timer),
                          hintText: ('Qual horário você quer jogar?'),
                          labelText: ('Horário'),
                        ),
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value:
                        _selectedPlaces.isEmpty ? null : _selectedPlaces.last,
                    decoration: InputDecoration(
                        icon: Icon(Icons.place),
                        hintText: 'Locais',
                        helperText:
                            'Deixe em branco para utilizar locais favoritos.'),
                    items: <String>[
                      'Sociedade Libanesa',
                      'Grêmio Nautico União',
                      'Sogipa',
                      'Leopoldina Juvenil'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.check,
                              color: _selectedPlaces.contains(value)
                                  ? null
                                  : Colors.transparent,
                            ),
                            SizedBox(width: 16),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String value) {
                      setState(() {
                        if (_selectedPlaces.contains(value)) {
                          _selectedPlaces.remove(value);
                        } else {
                          print(value);
                          _selectedPlaces.add(value);
                        }
                      });
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, bottom: 16),
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        // setState(() => this._status = 'loading');
                        // if (_formKey.currentState.validate()) {
                        //   _login().then((result) {
                        //     if (result == 200) {
                        //       Navigator.of(context)
                        //           .pushReplacementNamed('/home');
                        //     } else {
                        //       setState(() => this._status = 'rejected');
                        //       Fluttertoast.showToast(
                        //         msg: _errorMessage,
                        //         toastLength: Toast.LENGTH_SHORT,
                        //         gravity: ToastGravity.CENTER,
                        //       );
                        //     }
                        //   });
                        // }
                      },
                      child: Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
