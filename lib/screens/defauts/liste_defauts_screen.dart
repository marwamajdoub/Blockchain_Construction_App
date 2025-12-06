// lib/screens/defaults/liste_defauts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/defauts_provider.dart';
import '../../models/defaut.dart';

class ListeDefautsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final defauts = Provider.of<DefautsProvider>(context).defauts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Défauts'),
        backgroundColor: Color(0xFFFF9800),
      ),
      body: defauts.isEmpty
          ? Center(
              child: Text(
                'Aucun défaut enregistré',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: defauts.length,
              itemBuilder: (context, index) {
                final defaut = defauts[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFFF9800),
                      child: Icon(
                        Icons.warning,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      defaut.description,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Localisation: ${defaut.localisation}'),
                        Text('Date: ${defaut.date.day}/${defaut.date.month}/${defaut.date.year}'),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Naviguer vers les détails du défaut
                    },
                  ),
                );
              },
            ),
    );
  }
}
