import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sobre o TennisApp')),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(
              'Bem vindo ao TennisApp!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 32,
            ),
            Text(
              'Nossa missão é auxiliar jogadores de Tênis ao redor do mundo, a encontrar parcerias para jogar. Através de nosso mecanismo de pareamento, é possível encontrar parceiros de nível semelhante em questão de minutos.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Além disso, você pode buscar diferentes locais selecionados, jogadores, eventos e muito mais, tudo a partir de sua localização geográfica. Assim, você fica por dentro de tudo sobre Tênis que acontece ao seu redor.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
