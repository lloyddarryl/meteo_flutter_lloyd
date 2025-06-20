class ConstantesApp {
  // Configuration API
  static const String cleApi = 'ed653a868c18d71970b19199261ffd4a';
  static const String urlBase = 'https://api.openweathermap.org/data/2.5';
  static const String urlIconesBase = 'https://openweathermap.org/img/wn';

  // Villes par défaut
  static const List<Map<String, dynamic>> villesParDefaut = [
    {
      'nom': 'Paris',
      'pays': 'FR',
      'lat': 48.8566,
      'lon': 2.3522,
    },
    {
      'nom': 'New York',
      'pays': 'US',
      'lat': 40.7128,
      'lon': -74.0060,
    },
    {
      'nom': 'Tokyo',
      'pays': 'JP',
      'lat': 35.6762,
      'lon': 139.6503,
    },
    {
      'nom': 'Londres',
      'pays': 'GB',
      'lat': 51.5074,
      'lon': -0.1278,
    },
    {
      'nom': 'Dakar',
      'pays': 'SN',
      'lat': 14.6937,
      'lon': -17.4441,
    },
  ];

  // Durées des animations
  static const Duration animationCourte = Duration(milliseconds: 300);
  static const Duration animationMoyenne = Duration(milliseconds: 600);
  static const Duration animationLongue = Duration(milliseconds: 1000);

  // Messages de chargement
  static const List<String> messagesChargement = [
    'Nous téléchargeons les données…',
    'C\'est presque fini…',
    'Plus que quelques secondes avant d\'avoir le résultat…',
    'Analyse des conditions météorologiques…',
    'Synchronisation avec les satellites…',
    'Finalisation des prévisions…',
  ];

  // Infos de l'app
  static const String nomApp = 'Météo Flutter Lloyd';
  static const String versionApp = '1.0.0';

  // Réseau
  static const int timeoutConnexion = 30000; // 30 secondes
  static const int timeoutReception = 30000; // 30 secondes
}