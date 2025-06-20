// Version simplifiée sans json_serializable - TEMPÉRATURES CORRIGÉES

class ReponseMeteo {
  final Meteo meteo;
  final Principal principal;
  final Vent vent;
  final Nuages nuages;
  final Systeme systeme;
  final String nom;
  final Coordonnees coordonnees;
  final int visibilite;
  final int dt;
  final int fuseau_horaire;

  ReponseMeteo({
    required this.meteo,
    required this.principal,
    required this.vent,
    required this.nuages,
    required this.systeme,
    required this.nom,
    required this.coordonnees,
    required this.visibilite,
    required this.dt,
    required this.fuseau_horaire,
  });

  factory ReponseMeteo.fromJson(Map<String, dynamic> json) {
    return ReponseMeteo(
      meteo: Meteo.fromJson(json['weather'][0]),
      principal: Principal.fromJson(json['main']),
      vent: Vent.fromJson(json['wind']),
      nuages: Nuages.fromJson(json['clouds']),
      systeme: Systeme.fromJson(json['sys']),
      nom: json['name'],
      coordonnees: Coordonnees.fromJson(json['coord']),
      visibilite: json['visibility'],
      dt: json['dt'],
      fuseau_horaire: json['timezone'],
    );
  }
}

class Meteo {
  final int id;
  final String principal;
  final String description;
  final String icone;

  Meteo({
    required this.id,
    required this.principal,
    required this.description,
    required this.icone,
  });

  factory Meteo.fromJson(Map<String, dynamic> json) {
    return Meteo(
      id: json['id'],
      principal: json['main'],
      description: json['description'],
      icone: json['icon'],
    );
  }

  String get urlIcone => 'https://openweathermap.org/img/wn/$icone@2x.png';
}

class Principal {
  final double temperature;
  final double ressenti;
  final double tempMin;
  final double tempMax;
  final int pression;
  final int humidite;
  final int? niveauMer;
  final int? niveauSol;

  Principal({
    required this.temperature,
    required this.ressenti,
    required this.tempMin,
    required this.tempMax,
    required this.pression,
    required this.humidite,
    this.niveauMer,
    this.niveauSol,
  });

  factory Principal.fromJson(Map<String, dynamic> json) {
    return Principal(
      temperature: json['temp'].toDouble(),
      ressenti: json['feels_like'].toDouble(),
      tempMin: json['temp_min'].toDouble(),
      tempMax: json['temp_max'].toDouble(),
      pression: json['pressure'],
      humidite: json['humidity'],
      niveauMer: json['sea_level'],
      niveauSol: json['grnd_level'],
    );
  }

  // CORRECTION : Comme on utilise units=metric, les températures arrivent déjà en Celsius !
  int get tempCelsius => temperature.round(); // Pas de conversion !
  int get tempFahrenheit => (temperature * 9 / 5 + 32).round(); // Celsius vers Fahrenheit
  int get ressentiCelsius => ressenti.round(); // Pas de conversion !
  int get tempMinCelsius => tempMin.round(); // Pas de conversion !
  int get tempMaxCelsius => tempMax.round(); // Pas de conversion !

  // Pour debug, on peut vérifier
  String get debugInfo => 'Temp brute: $temperature°C, Convertie: ${tempCelsius}°C';
}

class Vent {
  final double vitesse;
  final int degres;
  final double? rafales;

  Vent({
    required this.vitesse,
    required this.degres,
    this.rafales,
  });

  factory Vent.fromJson(Map<String, dynamic> json) {
    return Vent(
      vitesse: json['speed'].toDouble(),
      degres: json['deg'],
      rafales: json['gust']?.toDouble(),
    );
  }

  String get direction {
    if (degres >= 337.5 || degres < 22.5) return 'N';
    if (degres >= 22.5 && degres < 67.5) return 'NE';
    if (degres >= 67.5 && degres < 112.5) return 'E';
    if (degres >= 112.5 && degres < 157.5) return 'SE';
    if (degres >= 157.5 && degres < 202.5) return 'S';
    if (degres >= 202.5 && degres < 247.5) return 'SO';
    if (degres >= 247.5 && degres < 292.5) return 'O';
    if (degres >= 292.5 && degres < 337.5) return 'NO';
    return 'N';
  }

  // Vitesse du vent : l'API retourne en m/s avec units=metric
  double get vitesseKmh => vitesse * 3.6; // m/s vers km/h
  double get vitesseMph => vitesse * 2.237; // m/s vers mph
}

class Nuages {
  final int tous;

  Nuages({required this.tous});

  factory Nuages.fromJson(Map<String, dynamic> json) {
    return Nuages(tous: json['all']);
  }
}

class Systeme {
  final int type;
  final int id;
  final String pays;
  final int leverSoleil;
  final int coucherSoleil;

  Systeme({
    required this.type,
    required this.id,
    required this.pays,
    required this.leverSoleil,
    required this.coucherSoleil,
  });

  factory Systeme.fromJson(Map<String, dynamic> json) {
    return Systeme(
      type: json['type'],
      id: json['id'],
      pays: json['country'],
      leverSoleil: json['sunrise'],
      coucherSoleil: json['sunset'],
    );
  }

  DateTime get heureLeverSoleil =>
      DateTime.fromMillisecondsSinceEpoch(leverSoleil * 1000);
  DateTime get heureCoucherSoleil =>
      DateTime.fromMillisecondsSinceEpoch(coucherSoleil * 1000);
}

class Coordonnees {
  final double longitude;
  final double latitude;

  Coordonnees({
    required this.longitude,
    required this.latitude,
  });

  factory Coordonnees.fromJson(Map<String, dynamic> json) {
    return Coordonnees(
      longitude: json['lon'].toDouble(),
      latitude: json['lat'].toDouble(),
    );
  }
}

class VilleMeteo {
  final String id;
  final String nom;
  final String pays;
  final double latitude;
  final double longitude;
  final ReponseMeteo? donneesMeteo;
  final DateTime? derniereMiseAJour;
  final bool enChargement;
  final String? erreur;

  VilleMeteo({
    required this.id,
    required this.nom,
    required this.pays,
    required this.latitude,
    required this.longitude,
    this.donneesMeteo,
    this.derniereMiseAJour,
    this.enChargement = false,
    this.erreur,
  });

  VilleMeteo copierAvec({
    String? id,
    String? nom,
    String? pays,
    double? latitude,
    double? longitude,
    ReponseMeteo? donneesMeteo,
    DateTime? derniereMiseAJour,
    bool? enChargement,
    String? erreur,
  }) {
    return VilleMeteo(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      pays: pays ?? this.pays,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      donneesMeteo: donneesMeteo ?? this.donneesMeteo,
      derniereMiseAJour: derniereMiseAJour ?? this.derniereMiseAJour,
      enChargement: enChargement ?? this.enChargement,
      erreur: erreur ?? this.erreur,
    );
  }

  bool get aDonnees => donneesMeteo != null && erreur == null;
  bool get aErreur => erreur != null;

  String get nomAffiche => '$nom, $pays';

  String? get conditionActuelle => donneesMeteo?.meteo.principal;
  String? get descriptionMeteo => donneesMeteo?.meteo.description;
  String? get iconeMeteo => donneesMeteo?.meteo.icone;
  int? get temperature => donneesMeteo?.principal.tempCelsius;
  int? get ressenti => donneesMeteo?.principal.ressentiCelsius;
  int? get humidite => donneesMeteo?.principal.humidite;
  double? get vitesseVent => donneesMeteo?.vent.vitesseKmh;
  String? get directionVent => donneesMeteo?.vent.direction;

  // Pour debug
  String? get debugTemp => donneesMeteo?.principal.debugInfo;
}