import 'package:dio/dio.dart';
import '../models/modeles_meteo.dart';
import '../../core/constants/constantes_app.dart';


class DepotMeteo {
  late final Dio _dio;

  DepotMeteo() {
    _dio = Dio();
    _configurerDio();
  }

  void _configurerDio() {
    _dio.options = BaseOptions(
      baseUrl: ConstantesApp.urlBase,
      connectTimeout: const Duration(milliseconds: ConstantesApp.timeoutConnexion),
      receiveTimeout: const Duration(milliseconds: ConstantesApp.timeoutReception),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Intercepteur pour les logs en développement
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          print('🌐 API Météo: $object');
        },
      ),
    );

    // Intercepteur pour gestion des erreurs
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('❌ Erreur API Météo: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<ReponseMeteo> obtenirMeteoParCoordonnees({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('🔍 Récupération météo pour: $latitude, $longitude');

      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': ConstantesApp.cleApi,
          'units': 'metric', // IMPORTANT: Celsius directement !
        },
      );

      // DEBUG: Afficher les données brutes de température
      if (response.data != null && response.data['main'] != null) {
        final tempBrute = response.data['main']['temp'];
        final nomVille = response.data['name'];
        print('🌡️ DEBUG - $nomVille: température brute = $tempBrute°C');
        print('📊 DEBUG - Données main complètes: ${response.data['main']}');
      }

      final reponseMeteo = ReponseMeteo.fromJson(response.data);

      // DEBUG: Vérifier après parsing
      print('✅ DEBUG - Après parsing: ${reponseMeteo.principal.debugInfo}');

      return reponseMeteo;
    } catch (e) {
      print('Erreur lors de la récupération météo par coordonnées: $e');
      rethrow;
    }
  }

  Future<ReponseMeteo> obtenirMeteoParNomVille({
    required String nomVille,
  }) async {
    try {
      print('🔍 Récupération météo pour ville: $nomVille');

      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': nomVille,
          'appid': ConstantesApp.cleApi,
          'units': 'metric', // IMPORTANT: Celsius directement !
        },
      );

      // DEBUG: Afficher les données brutes
      if (response.data != null && response.data['main'] != null) {
        final tempBrute = response.data['main']['temp'];
        print('🌡️ DEBUG - $nomVille: température brute = $tempBrute°C');
      }

      return ReponseMeteo.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la récupération météo par ville: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> obtenirPrevisions({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': ConstantesApp.cleApi,
          'units': 'metric',
        },
      );

      return response.data;
    } catch (e) {
      print('Erreur lors de la récupération des prévisions: $e');
      rethrow;
    }
  }

  // Récupération en lot pour plusieurs villes
  Future<List<ReponseMeteo>> obtenirMeteoPourVilles({
    required List<Map<String, dynamic>> villes,
  }) async {
    try {
      print('🔍 Récupération météo pour ${villes.length} villes');

      final List<Future<ReponseMeteo>> futures = villes.map((ville) {
        return obtenirMeteoParCoordonnees(
          latitude: ville['lat'] as double,
          longitude: ville['lon'] as double,
        );
      }).toList();

      final resultats = await Future.wait(futures);

      // DEBUG: Résumé des températures
      for (int i = 0; i < resultats.length; i++) {
        final ville = villes[i];
        final meteo = resultats[i];
        print('📋 RÉSUMÉ - ${ville['nom']}: ${meteo.principal.tempCelsius}°C');
      }

      return resultats;
    } catch (e) {
      print('Erreur lors de la récupération météo pour plusieurs villes: $e');
      rethrow;
    }
  }

  // Méthode pour gérer les erreurs API proprement
  String _obtenirMessageErreur(DioException erreur) {
    switch (erreur.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connexion timeout. Vérifiez votre connexion internet.';
      case DioExceptionType.badResponse:
        if (erreur.response?.statusCode == 401) {
          return 'Clé API invalide.';
        } else if (erreur.response?.statusCode == 404) {
          return 'Ville non trouvée.';
        } else {
          return 'Erreur serveur: ${erreur.response?.statusCode}';
        }
      case DioExceptionType.cancel:
        return 'Requête annulée.';
      case DioExceptionType.unknown:
      default:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }

  Future<ReponseMeteo?> obtenirMeteoSecurise({
    double? latitude,
    double? longitude,
    String? nomVille,
  }) async {
    try {
      if (latitude != null && longitude != null) {
        return await obtenirMeteoParCoordonnees(
          latitude: latitude,
          longitude: longitude,
        );
      } else if (nomVille != null) {
        return await obtenirMeteoParNomVille(nomVille: nomVille);
      } else {
        throw ArgumentError('Coordonnées ou nom de ville requis');
      }
    } on DioException catch (e) {
      print('Erreur API Météo: ${_obtenirMessageErreur(e)}');
      return null;
    } catch (e) {
      print('Erreur inattendue: $e');
      return null;
    }
  }
}