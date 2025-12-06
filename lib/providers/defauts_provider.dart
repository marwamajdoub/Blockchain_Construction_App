// lib/providers/defauts_provider.dart
import 'package:flutter/material.dart';
import '../models/defaut.dart';

class DefautsProvider with ChangeNotifier {
  List<Defaut> _defauts = [];

  List<Defaut> get defauts => _defauts;

  void ajouterDefaut(Defaut defaut) {
    _defauts.add(defaut);
    notifyListeners();
  }
}
