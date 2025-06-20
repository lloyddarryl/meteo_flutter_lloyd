import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_app.dart';
import '../presentation/providers/providers_meteo.dart';
import '../presentation/screens/ecran_accueil.dart';
import '../presentation/screens/ecran_chargement.dart';
import '../presentation/screens/ecran_tableau_bord.dart';
import '../presentation/screens/ecran_detail_ville.dart';

class AppMeteo extends ConsumerWidget {
  const AppMeteo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeTheme = ref.watch(providerModeTheme);
    final etatApp = ref.watch(providerEtatApp);

    return MaterialApp(
      title: 'Météo Flutter Lloyd',
      debugShowCheckedModeBanner: false,
      themeMode: modeTheme,
      theme: ThemeApp.themeClair,
      darkTheme: ThemeApp.themeSombre,
      home: _construireEcranActuel(etatApp.ecranActuel),
    );
  }

  Widget _construireEcranActuel(EtatEcranApp etatEcran) {
    switch (etatEcran) {
      case EtatEcranApp.accueil:
        return const EcranAccueil();
      case EtatEcranApp.chargement:
        return const EcranChargement();
      case EtatEcranApp.tableauBord:
        return const EcranTableauBord();
      case EtatEcranApp.detailVille:
        return const EcranDetailVille();
      default:
        return const EcranAccueil();
    }
  }
}