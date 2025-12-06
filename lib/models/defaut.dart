class Defaut {
  final String id;
  final String description;
  final String? imageUrl;
  final String localisation;
  final DateTime date;

  Defaut({
    required this.id,
    required this.description,
    this.imageUrl,
    required this.localisation,
    required this.date, 
  });

  
}
