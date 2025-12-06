import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AIService {
  static const String _apiUrl = 'https://unheavy-tiara-unforgetfully.ngrok-free.dev/predict/';

  Future<Map<String, dynamic>?> predictDefect(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      // Ajouter l'image au formulaire
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Le nom du champ attendu par l'API
          imageFile.path,
        ),
      );

      // Envoyer la requête
      var response = await request.send();

      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        // Lire et retourner la réponse
        var responseData = await response.stream.bytesToString();
        return {'success': true, 'data': responseData};
      } else {
        print('Erreur lors de la prédiction: ${response.statusCode}');
        return {'success': false, 'error': 'Erreur lors de la prédiction: ${response.statusCode}'};
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'image: $e');
      return {'success': false, 'error': 'Erreur lors de l\'envoi de l\'image: $e'};
    }
  }
}
