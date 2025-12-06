// lib/screens/defaults/camera_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/services/ia_service.dart';
import '/services/blockchain_service.dart';
import '../../models/defaut.dart';
import '../../providers/defauts_provider.dart';
import 'liste_defauts_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  String? _predictionResult;
  bool _isLoading = false;
  Map<String, dynamic>? _predictionData;
  final AIService _aiService = AIService();
  late BlockchainService _blockchainService;

  @override
  void initState() {
    super.initState();
    // Initialiser le BlockchainService avec l'URL RPC
    _blockchainService = BlockchainService('https://d01548b2a8bb.ngrok-free.app');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _predictionResult = null;
          _predictionData = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _predictDefect() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _predictionResult = 'Prédiction en cours...';
    });

    try {
      var result = await _aiService.predictDefect(_image!);
      setState(() {
        _isLoading = false;
        if (result!['success']) {
          _predictionData = json.decode(result['data']);
          _predictionResult = null;
        } else {
          _predictionResult = 'Erreur: ${result['error']}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _predictionResult = 'Erreur inattendue: $e';
      });
    }
  }

  Future<void> _saveDefaut() async {
    if (_predictionData == null || _image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final defaut = Defaut(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _predictionData!['description'],
        imageUrl: _image!.path,
        localisation: _predictionData!['localisation'] ?? 'Localisation inconnue',
        date: DateTime.now(),
      );

      // Enregistrer dans la blockchain
      await _blockchainService.ajouterDefaut(defaut);

      // Enregistrer dans la liste locale
      Provider.of<DefautsProvider>(context, listen: false).ajouterDefaut(defaut);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Défaut enregistré avec succès dans la blockchain et localement!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement dans la blockchain: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détecter un défaut',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF9800),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _image == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Aucune image sélectionnée',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Sélectionnez une source pour l\'image :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Prendre une photo',
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Télécharger une image',
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 30),
              if (_image != null)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _predictDefect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF9800),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Analyser avec l\'IA',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                    SizedBox(height: 20),
                    if (_predictionData != null)
                      _buildPredictionCard(),
                    if (_predictionResult != null)
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _predictionResult!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListeDefautsScreen()),
          );
        },
        backgroundColor: Color(0xFFFF9800),
        child: Icon(Icons.list),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résultat de la Prédiction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Divider(),
            SizedBox(height: 10),
            _buildPredictionRow('Classe:', _predictionData!['class']),
            _buildPredictionRow('Action:', _predictionData!['action']),
            _buildPredictionRow('Description:', _predictionData!['description']),
            _buildPredictionRow('Confiance:', '${(_predictionData!['confidence'] * 100).toStringAsFixed(2)}%'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDefaut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9800),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'Enregistrer le défaut',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(icon, color: Color(0xFFFF9800), size: 30),
              onPressed: onPressed,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
