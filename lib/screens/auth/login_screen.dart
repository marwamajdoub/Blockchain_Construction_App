import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool _obscurePassword = true;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SizedBox.expand(
          // <-- Utilisez SizedBox.expand pour remplir tout l'espace
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/construction_logo.png'),
                fit:
                    BoxFit.cover, // <-- BoxFit.cover pour couvrir tout l'espace
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(
                      context,
                    ).size.height, // <-- Prend toute la hauteur de l'écran
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 100),
                            Text(
                              'Bienvenue',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Connectez-vous pour accéder à votre espace',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              style: TextStyle(color: Color(0xFFFF9800)),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Color(0xFFFF9800)),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Color(0xFFFF9800),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                              ),
                              validator: (val) =>
                                  val!.isEmpty ? 'Entrez un email' : null,
                              onChanged: (val) => setState(() => email = val),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              style: TextStyle(color: Color(0xFFFF9800)),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                labelStyle: TextStyle(color: Color(0xFFFF9800)),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFFFF9800),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                              ),
                              obscureText: _obscurePassword,
                              validator: (val) => val!.length < 6
                                  ? 'Mot de passe trop court'
                                  : null,
                              onChanged: (val) =>
                                  setState(() => password = val),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF9800),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    // Tentative de connexion avec Firebase
                                    UserCredential userCredential =
                                        await FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                              email: email,
                                              password: password,
                                            );
                                    // Si la connexion réussit, rediriger vers HomeScreen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    // Gérer les erreurs de connexion
                                    String errorMessage;
                                    if (e.code == 'user-not-found') {
                                      errorMessage =
                                          "Aucun utilisateur trouvé pour cet email.";
                                    } else if (e.code == 'wrong-password') {
                                      errorMessage = "Mot de passe incorrect.";
                                    } else {
                                      errorMessage =
                                          e.message ??
                                          "Une erreur s'est produite.";
                                    }
                                    setState(() {
                                      error = errorMessage;
                                    });
                                  }
                                }
                              },
                            ),

                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Pas encore de compte ? ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  child: Text(
                                    "S'inscrire",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
