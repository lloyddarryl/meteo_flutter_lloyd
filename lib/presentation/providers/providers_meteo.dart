import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/models/modeles_meteo.dart';
import '../../data/services/service_meteo.dart';
import '../../core/constants/constantes_app.dart';

// Provider pour le dépôt météo
final providerDepotMeteo = Provider<DepotMeteo>((ref) {
  return DepotMeteo();
});

// Provider pour le mode thème
final providerModeTheme = StateNotifierProvider<NotificateurModeTheme, ThemeMode>((ref) {
  return NotificateurModeTheme();
});

class NotificateurModeTheme extends StateNotifier<ThemeMode> {
  NotificateurModeTheme() : super(ThemeMode.system);

  void basculerTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void definirTheme(ThemeMode modeTheme) {
    state = modeTheme;
  }
}

// Provider pour le progrès de chargement
final providerProgresChargement = StateNotifierProvider<NotificateurProgresChargement, ProgresChargement>((ref) {
  return NotificateurProgresChargement();
});

class ProgresChargement {
  final double progres;
  final String message;
  final bool estComplete;

  ProgresChargement({
    required this.progres,
    required this.message,
    required this.estComplete,
  });

  ProgresChargement copierAvec({
    double? progres,
    String? message,
    bool? estComplete,
  }) {
    return ProgresChargement(
      progres: progres ?? this.progres,
      message: message ?? this.message,
      estComplete: estComplete ?? this.estComplete,
    );
  }
}

class NotificateurProgresChargement extends StateNotifier<ProgresChargement> {
  Timer? _minuteur;
  Timer? _minuteurMessage;
  int _indexMessage = 0;

  NotificateurProgresChargement()
      : super(ProgresChargement(
    progres: 0.0,
    message: ConstantesApp.messagesChargement[0],
    estComplete: false,
  ));

  void demarrerChargement() {
    _indexMessage = 0;
    state = ProgresChargement(
      progres: 0.0,
      message: ConstantesApp.messagesChargement[0],
      estComplete: false,
    );

    // Mise à jour progressive du progrès
    _minuteur = Timer.periodic(const Duration(milliseconds: 100), (minuteur) {
      if (state.progres >= 1.0) {
        minuteur.cancel();
        state = state.copierAvec(estComplete: true);
        return;
      }

      // Simulation d'un chargement réaliste avec randomisation
      double increment = 0.015 + (Random().nextDouble() * 0.01);
      double nouveauProgres = (state.progres + increment).clamp(0.0, 1.0);

      state = state.copierAvec(progres: nouveauProgres);
    });

    // Mise à jour des messages de chargement
    _minuteurMessage = Timer.periodic(const Duration(seconds: 2), (minuteur) {
      if (state.estComplete) {
        minuteur.cancel();
        return;
      }

      _indexMessage = (_indexMessage + 1) % ConstantesApp.messagesChargement.length;
      state = state.copierAvec(message: ConstantesApp.messagesChargement[_indexMessage]);
    });
  }

  void terminerChargement() {
    _minuteur?.cancel();
    _minuteurMessage?.cancel();
    state = ProgresChargement(
      progres: 1.0,
      message: 'Terminé !',
      estComplete: true,
    );
  }

  void reinitialiserChargement() {
    _minuteur?.cancel();
    _minuteurMessage?.cancel();
    _indexMessage = 0;
    state = ProgresChargement(
      progres: 0.0,
      message: ConstantesApp.messagesChargement[0],
      estComplete: false,
    );
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _minuteurMessage?.cancel();
    super.dispose();
  }
}

// Provider pour les villes météo
final providerVillesMeteo = StateNotifierProvider<NotificateurVillesMeteo, List<VilleMeteo>>((ref) {
  final depot = ref.watch(providerDepotMeteo);
  return NotificateurVillesMeteo(depot);
});

class NotificateurVillesMeteo extends StateNotifier<List<VilleMeteo>> {
  final DepotMeteo _depot;
  Timer? _minuteurActualisation;

  NotificateurVillesMeteo(this._depot) : super([]) {
    _initialiserVilles();
  }

  void _initialiserVilles() {
    // Initialisation avec les villes par défaut
    state = ConstantesApp.villesParDefaut.map((donneesVille) {
      return VilleMeteo(
        id: '${donneesVille['nom']}_${donneesVille['pays']}',
        nom: donneesVille['nom'] as String,
        pays: donneesVille['pays'] as String,
        latitude: donneesVille['lat'] as double,
        longitude: donneesVille['lon'] as double,
        enChargement: false,
      );
    }).toList();
  }

  Future<void> recupererToutesDonneesMeteo() async {
    // Mettre toutes les villes en état de chargement
    state = state.map((ville) => ville.copierAvec(enChargement: true, erreur: null)).toList();

    try {
      // Récupérer les données météo pour toutes les villes en parallèle
      final futures = state.map((ville) async {
        try {
          final donneesMeteo = await _depot.obtenirMeteoParCoordonnees(
            latitude: ville.latitude,
            longitude: ville.longitude,
          );
          return ville.copierAvec(
            donneesMeteo: donneesMeteo,
            derniereMiseAJour: DateTime.now(),
            enChargement: false,
            erreur: null,
          );
        } catch (e) {
          return ville.copierAvec(
            enChargement: false,
            erreur: 'Erreur de chargement: ${e.toString()}',
          );
        }
      }).toList();

      final resultats = await Future.wait(futures);
      state = resultats;
    } catch (e) {
      // Gestion d'erreur générale
      state = state.map((ville) => ville.copierAvec(
        enChargement: false,
        erreur: 'Erreur générale: ${e.toString()}',
      )).toList();
    }
  }

  Future<void> actualiserDonneesMeteo() async {
    await recupererToutesDonneesMeteo();
  }

  Future<void> recupererMeteoPourVille(String idVille) async {
    final indexVille = state.indexWhere((ville) => ville.id == idVille);
    if (indexVille == -1) return;

    final ville = state[indexVille];
    final villeModifiee = ville.copierAvec(enChargement: true, erreur: null);

    // Mettre à jour l'état avec la ville en chargement
    state = [
      ...state.sublist(0, indexVille),
      villeModifiee,
      ...state.sublist(indexVille + 1),
    ];

    try {
      final donneesMeteo = await _depot.obtenirMeteoParCoordonnees(
        latitude: ville.latitude,
        longitude: ville.longitude,
      );

      final villeFinale = ville.copierAvec(
        donneesMeteo: donneesMeteo,
        derniereMiseAJour: DateTime.now(),
        enChargement: false,
        erreur: null,
      );

      // Mettre à jour l'état avec les données finales
      state = [
        ...state.sublist(0, indexVille),
        villeFinale,
        ...state.sublist(indexVille + 1),
      ];
    } catch (e) {
      final villeErreur = ville.copierAvec(
        enChargement: false,
        erreur: 'Erreur: ${e.toString()}',
      );

      // Mettre à jour l'état avec l'erreur
      state = [
        ...state.sublist(0, indexVille),
        villeErreur,
        ...state.sublist(indexVille + 1),
      ];
    }
  }

  void demarrerActualisationAuto() {
    _minuteurActualisation = Timer.periodic(const Duration(minutes: 5), (minuteur) {
      actualiserDonneesMeteo();
    });
  }

  void arreterActualisationAuto() {
    _minuteurActualisation?.cancel();
    _minuteurActualisation = null;
  }

  void ajouterVille(VilleMeteo ville) {
    state = [...state, ville];
  }

  void supprimerVille(String idVille) {
    state = state.where((ville) => ville.id != idVille).toList();
  }

  VilleMeteo? obtenirVilleParId(String idVille) {
    try {
      return state.firstWhere((ville) => ville.id == idVille);
    } catch (e) {
      return null;
    }
  }

  List<VilleMeteo> get villesChargees {
    return state.where((ville) => ville.aDonnees).toList();
  }

  List<VilleMeteo> get villesEnChargement {
    return state.where((ville) => ville.enChargement).toList();
  }

  List<VilleMeteo> get villesAvecErreur {
    return state.where((ville) => ville.aErreur).toList();
  }

  bool get toutesVillesChargees {
    return state.every((ville) => ville.aDonnees);
  }

  bool get aDesErreurs {
    return state.any((ville) => ville.aErreur);
  }

  @override
  void dispose() {
    _minuteurActualisation?.cancel();
    super.dispose();
  }
}

// Provider pour la ville sélectionnée (écran de détail)
final providerVilleSelectionnee = StateProvider<VilleMeteo?>((ref) => null);

// Provider pour l'état de l'application
final providerEtatApp = StateNotifierProvider<NotificateurEtatApp, EtatApp>((ref) {
  return NotificateurEtatApp();
});

enum EtatEcranApp {
  accueil,
  chargement,
  tableauBord,
  detailVille,
}

class EtatApp {
  final EtatEcranApp ecranActuel;
  final bool estPremierLancement;

  EtatApp({
    required this.ecranActuel,
    required this.estPremierLancement,
  });

  EtatApp copierAvec({
    EtatEcranApp? ecranActuel,
    bool? estPremierLancement,
  }) {
    return EtatApp(
      ecranActuel: ecranActuel ?? this.ecranActuel,
      estPremierLancement: estPremierLancement ?? this.estPremierLancement,
    );
  }
}

class NotificateurEtatApp extends StateNotifier<EtatApp> {
  NotificateurEtatApp()
      : super(EtatApp(
    ecranActuel: EtatEcranApp.accueil,
    estPremierLancement: true,
  ));

  void naviguerVersEcran(EtatEcranApp ecran) {
    state = state.copierAvec(ecranActuel: ecran);
  }

  void marquerPremierLancementTermine() {
    state = state.copierAvec(estPremierLancement: false);
  }
}