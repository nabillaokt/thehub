import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: ListView(
        children: const <Widget>[
          ExpansionTile(
            title: Text('Apa itu aplikasi The HUB'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'Aplikasi The HUB adalah platform digital yang memungkinkan pengguna untuk melakukan reservasi tanggal, waktu dan posisi target panahan untuk olahraga panahan secara online.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Bagaimana cara mendaftar di aplikasi\nThe HUB ini?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'Untuk mendaftar, pengguna perlu mengikuti langkah-langkah pendaftaran dengan mengisi informasi yang diminta, seperti nama, email, dan nomor telepon.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Bagaimana cara melakukan reservasi?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Setelah mendaftar dan login ke aplikasi, pengguna dapat memilih lapangan panahan, melihat jadwal yang tersedia, dan memilih waktu yang diinginkan untuk reservasi.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
