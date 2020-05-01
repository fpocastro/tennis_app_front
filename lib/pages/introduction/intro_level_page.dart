import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tennis_app_front/models/user.dart';
import 'package:tennis_app_front/services/auth.dart';
import 'package:tennis_app_front/shared/globals.dart' as globals;
import 'package:http/http.dart' as http;

class IntroLevelPage extends StatefulWidget {
  @override
  _IntroLevelPageState createState() => _IntroLevelPageState();
}

class Level {
  final double level;
  final String description;

  const Level({
    this.level,
    this.description,
  });
}

class _IntroLevelPageState extends State<IntroLevelPage> {
  bool _loading = false;
  final AuthService _auth = AuthService();
  int _index = 0;
  final List<Level> _levels = [
    Level(
        level: 1.5,
        description:
            'Você tem experiência limitada e está trabalhando principalmente para colocar a bola em jogo.'),
    Level(
        level: 2,
        description:
            'Você não tem experiência na quadra e seus golpes precisam ser desenvolvidos. Você está familiarizado com as posições básicas para jogos de simples e duplas.'),
    Level(
        level: 2.5,
        description:
            'Você está aprendendo a ler a bola, embora sua cobertura da quadra seja limitada. Você pode manter um rally curto de ritmo lento com outros jogadores da mesma habilidade.'),
    Level(
        level: 3,
        description:
            'Você é bastante consistente ao executar golpes de ritmo médio, mas não se sente confortável com todos os movimentos e falta-lhe execução ao tentar controle direcional, profundidade ou potência. A sua formação de duplas mais comum é um a frente, um atrás.'),
    Level(
        level: 3.5,
        description:
            'Você alcançou um bom controle de bola em golpes de ritmo moderado, mas precisa desenvolver profundidade e variedade. Você exibe um jogo mais agressivo, melhorou a cobertura da quadra e está desenvolvendo o trabalho em equipe em duplas.'),
    Level(
        level: 4,
        description:
            'Você tem movimentos confiáveis, incluindo controle direcional e profundidade nos lados do forehand e backhand em golpes de ritmo moderado. Você pode usar lobs, smashes, bolas de aproximação e voleios com algum sucesso e, ocasionalmente, consegue forçar erros ao sacar. Pontos podem ser perdidos devido à impaciência. O trabalho em equipe em duplas é evidente.'),
    Level(
        level: 4.5,
        description:
            'Você desenvolveu seu uso de potência e speen, e pode controlar o ritmo. Você tem um bom trabalho com os pés, pode controlar a profundidade dos golpes e tentar variar o plano de jogo de acordo com seus oponentes. Você pode atingir os primeiros saques com força e precisão e colocar o segundo saque. Você tende a exagerar a força em bolas difíceis. Joga agressivamente na rede em jogos de duplas.'),
    Level(
        level: 5,
        description:
            'Você tem uma boa antecipação de golpes e frequentemente tem um golpe ou atributo excelente em torno do qual seu jogo pode ser estruturado. Você pode acertar winners regularmente ou forçar erros em bolas curtas e arrumar voleios. Você pode executar com sucesso lobs, drop shots, voleios, golpes aéreos e ter boa profundidade e speen na maioria dos segundos saques.'),
    Level(
        level: 5.5,
        description:
            'Você dominou a potência e / ou a consistência como uma arma principal. Você pode variar estratégias e estilos de jogo em uma situação competitiva e acertar golpes confiáveis ​​em uma situação de estresse.'),
  ];

  Future<int> _updateUserLevel() async {
    setState(() {
      _loading = true;
    });
    final User user = await _auth.getCurrentUser();
    final String token = await _auth.getAuthorizationToken();

    final String requestUrl = globals.apiMainUrl + '/api/users/' + user.uid;

    var body = user.toJsonRequest();
    body['level'] = _levels[_index].level;
    body['introduction'] = true;

    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    http.Response response = await http.put(
      requestUrl,
      body: json.encode(body),
      headers: headers,
    );

    if (response.statusCode == 200) {
      await _auth.setCurrentUser(response.body);
    }

    setState(() {
      _loading = false;
    });

    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 16, right: 16, top: 64),
        color: Colors.orange[100],
        child: Column(
          children: <Widget>[
            Text(
              'Selecione seu nível base!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 32,
            ),
            Expanded(
              child: PageView.builder(
                itemCount: _levels.length,
                controller: PageController(viewportFraction: 0.8),
                onPageChanged: (int index) => setState(() => _index = index),
                itemBuilder: (_, i) {
                  return Transform.scale(
                    scale: i == _index ? 1 : 0.9,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 32),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange[200],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.3),
                                blurRadius: 3,
                                spreadRadius: 0.5,
                                offset: Offset(2, 2)),
                          ],
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Text(
                              _levels[i].level.toStringAsFixed(1),
                              style: TextStyle(fontSize: 32),
                            ),
                            Text(
                              _levels[i].description,
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            RaisedButton(
              child: Text(
                'Confirmar',
                style: TextStyle(fontSize: 16),
              ),
              color: Colors.orange[300],
              onPressed: () async {
                int status = await _updateUserLevel();
                if (status == 200) {
                  Navigator.of(context).pushReplacementNamed('/home');
                } else {
                  Fluttertoast.showToast(
                      msg: 'Erro',
                      backgroundColor: Colors.greenAccent,
                      toastLength: Toast.LENGTH_LONG);
                }
              },
            ),
            SizedBox(
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}
