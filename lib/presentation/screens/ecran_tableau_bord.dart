import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers_meteo.dart';
import '../widgets/container_verre.dart';
import '../../data/models/modeles_meteo.dart';
import '../../core/theme/theme_app.dart';
import '../../core/constants/constantes_app.dart';
import 'dart:math' as math;

class EcranTableauBord extends ConsumerStatefulWidget {
  const EcranTableauBord({super.key});

  @override
  ConsumerState<EcranTableauBord> createState() => _EtatEcranTableauBord();
}

class _EtatEcranTableauBord extends ConsumerState<EcranTableauBord>
    with TickerProviderStateMixin {
  late AnimationController _controleurActualisation;
  late AnimationController _controleurFlottement;
  late AnimationController _controleurParticules;
  late Animation<double> _animationActualisation;
  late Animation<double> _animationFlottement;
  late Animation<double> _animationParticules;

  @override
  void initState() {
    super.initState();
    _configurerAnimations();
  }

  void _configurerAnimations() {
    _controleurActualisation = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _controleurFlottement = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _controleurParticules = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _animationActualisation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurActualisation,
      curve: Curves.elasticOut,
    ));

    _animationFlottement = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _controleurFlottement,
      curve: Curves.easeInOut,
    ));

    _animationParticules = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurParticules,
      curve: Curves.linear,
    ));

    _controleurFlottement.repeat(reverse: true);
    _controleurParticules.repeat();
  }

  @override
  void dispose() {
    _controleurActualisation.dispose();
    _controleurFlottement.dispose();
    _controleurParticules.dispose();
    super.dispose();
  }

  Future<void> _actualiserDonneesMeteo() async {
    _controleurActualisation.forward().then((_) {
      _controleurActualisation.reset();
    });

    await ref.read(providerVillesMeteo.notifier).actualiserDonneesMeteo();
  }

  void _naviguerVersAccueil() {
    ref.read(providerEtatApp.notifier).naviguerVersEcran(EtatEcranApp.accueil);
    ref.read(providerProgresChargement.notifier).reinitialiserChargement();
  }

  void _naviguerVersDetailVille(VilleMeteo ville) {
    ref.read(providerVilleSelectionnee.notifier).state = ville;
    ref.read(providerEtatApp.notifier).naviguerVersEcran(EtatEcranApp.detailVille);
  }

  @override
  Widget build(BuildContext context) {
    final villes = ref.watch(providerVillesMeteo);
    final estSombre = Theme.of(context).brightness == Brightness.dark;
    final progresChargement = ref.watch(providerProgresChargement);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: estSombre
                ? [
              const Color(0xFF0D1B2A),
              const Color(0xFF1B263B),
              const Color(0xFF415A77),
            ]
                : [
              const Color(0xFF4A90E2),
              const Color(0xFF7B68EE),
              const Color(0xFF50C878),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particules d'arrière-plan
            _construireParticulesArrierePlan(estSombre),

            SafeArea(
              child: Column(
                children: [
                  // En-tête moderne
                  _construireEnteteModerne(estSombre, progresChargement),

                  // Cartes météo améliorées
                  Expanded(
                    child: _construireCartesMeteoAmeliorees(villes),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireParticulesArrierePlan(bool estSombre) {
    return AnimatedBuilder(
      animation: _animationParticules,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final double progres = (_animationParticules.value + index * 0.1) % 1.0;
            final double taille = 2.0 + (index % 3);
            final double gauche = (index * 45.0) % MediaQuery.of(context).size.width;
            final double haut = MediaQuery.of(context).size.height * progres;
            final double opacite = (1.0 - progres) * 0.3;

            return Positioned(
              left: gauche,
              top: haut,
              child: Opacity(
                opacity: opacite,
                child: Container(
                  width: taille,
                  height: taille,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: estSombre ? Colors.white : Colors.white.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: (estSombre ? Colors.white : Colors.white).withOpacity(0.3),
                        blurRadius: taille * 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _construireEnteteModerne(bool estSombre, ProgresChargement progresChargement) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ContainerVerre(
        height: progresChargement.estComplete ? 120 : 80, // Hauteur réduite
        width: double.infinity,
        borderRadius: BorderRadius.circular(25),
        opacite: 0.15,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding réduit
          child: Column(
            children: [
              // Barre supérieure
              Row(
                children: [
                  // Bouton retour stylé
                  GestureDetector(
                    onTap: _naviguerVersAccueil,
                    child: Container(
                      padding: const EdgeInsets.all(8), // Padding réduit
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 14, // Taille réduite
                      ),
                    ),
                  ),

                  // Titre central
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Tableau de Bord',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16, // Taille réduite
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Météo Mondiale',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10, // Taille réduite
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Boutons d'action
                  Row(
                    children: [
                      // Basculeur de thème
                      GestureDetector(
                        onTap: () {
                          ref.read(providerModeTheme.notifier).basculerTheme();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8), // Padding réduit
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Icon(
                            estSombre ? Icons.light_mode : Icons.dark_mode,
                            color: Colors.white,
                            size: 14, // Taille réduite
                          ),
                        ),
                      ),

                      const SizedBox(width: 6), // Espace réduit

                      // Bouton d'actualisation
                      GestureDetector(
                        onTap: _actualiserDonneesMeteo,
                        child: AnimatedBuilder(
                          animation: _animationActualisation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animationActualisation.value * 2 * math.pi,
                              child: Container(
                                padding: const EdgeInsets.all(8), // Padding réduit
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 14, // Taille réduite
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Bouton recommencer (si nécessaire)
              if (progresChargement.estComplete) ...[
                const SizedBox(height: 8), // Espace réduit
                Expanded(
                  child: FadeInUp(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(providerEtatApp.notifier).naviguerVersEcran(EtatEcranApp.chargement);
                          ref.read(providerProgresChargement.notifier).demarrerChargement();
                          ref.read(providerVillesMeteo.notifier).recupererToutesDonneesMeteo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6), // Padding réduit
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 12), // Taille réduite
                            const SizedBox(width: 4),
                            Text(
                              'Actualiser les données',
                              style: TextStyle(
                                fontSize: 10, // Taille réduite
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireCartesMeteoAmeliorees(List<VilleMeteo> villes) {
    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 6, // Encore moins d'espace
            childAspectRatio: 3.5, // Encore plus plat
          ),
          itemCount: villes.length,
          itemBuilder: (context, index) {
            final ville = villes[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600), // Animation plus rapide
              columnCount: 1,
              child: FadeInAnimation( // Animation simple
                child: _construireCarteMeteoModerne(ville, index),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construireCarteMeteoModerne(VilleMeteo ville, int index) {
    final aDonnees = ville.aDonnees;
    final aErreur = ville.aErreur;
    final enChargement = ville.enChargement;

    return GestureDetector(
      onTap: aDonnees ? () => _naviguerVersDetailVille(ville) : null,
      child: ContainerVerre(
        height: double.infinity,
        width: double.infinity,
        borderRadius: BorderRadius.circular(20),
        opacite: 0.1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: aDonnees
                ? ThemeApp.obtenirDegradeMeteo(ville.conditionActuelle ?? 'clear')
                : LinearGradient(
              colors: [
                Colors.grey.shade400,
                Colors.grey.shade600,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Contenu principal avec padding ultra-précis pour éviter le débordement
              Padding(
                padding: const EdgeInsets.only(
                    left: 14, // Réduit de 16 à 14
                    right: 64, // Augmenté de 60 à 64 pour plus de sécurité
                    top: 8,
                    bottom: 8
                ),
                child: aErreur
                    ? _construireContenuErreur(ville)
                    : enChargement
                    ? _construireContenuChargement(ville)
                    : aDonnees
                    ? _construireContenuMeteoModerne(ville)
                    : _construireContenuPlaceholder(ville),
              ),

              // Badge de statut repositionné
              Positioned(
                top: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: aDonnees
                              ? Colors.green
                              : enChargement
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        aDonnees
                            ? 'En ligne'
                            : enChargement
                            ? 'Chargement'
                            : 'Hors ligne',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Indicateur interactif repositionné pour éviter tout chevauchement
              if (aDonnees)
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Container(
                    width: 24, // Taille fixe pour éviter le débordement
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireContenuMeteoModerne(VilleMeteo ville) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul précis de l'espace disponible
        final double largeurDisponible = constraints.maxWidth;
        final double largeurPartieGauche = largeurDisponible * 0.65; // 65% pour la partie gauche
        final double largeurPartieDroite = largeurDisponible * 0.30; // 30% pour la partie droite
        final double largeurDescription = largeurPartieGauche - 40; // Marge de sécurité
        final double largeurStatistiques = largeurPartieDroite - 16; // Marge de sécurité

        return Row(
          children: [
            // Partie gauche - Informations principales
            SizedBox(
              width: largeurPartieGauche,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nom de la ville avec style moderne - très compact
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: largeurPartieGauche - 10,
                        child: Text(
                          ville.nom,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        width: largeurPartieGauche - 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white.withOpacity(0.8),
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                ville.pays,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Température principale avec style - très compact
                  SizedBox(
                    width: largeurPartieGauche - 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${ville.temperature}°',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 0.9,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            'C',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description météo très compacte avec largeur calculée
                  SizedBox(
                    width: largeurDescription.clamp(60.0, 120.0), // Entre 60 et 120 pixels max
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ville.descriptionMeteo?.toUpperCase() ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Espacement minimal
            const SizedBox(width: 4),

            // Partie droite - Icône et statistiques
            SizedBox(
              width: largeurPartieDroite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône météo avec effet - taille adaptative
                  if (ville.iconeMeteo != null)
                    Container(
                      width: 32, // Taille réduite
                      height: 32,
                      padding: const EdgeInsets.all(4), // Padding réduit
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: CachedNetworkImage(
                        imageUrl: ville.donneesMeteo!.meteo.urlIcone,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Statistiques compactes avec largeur calculée
                  SizedBox(
                    width: largeurStatistiques.clamp(60.0, 75.0), // Entre 60 et 75 pixels max
                    height: 42, // Hauteur fixe réduite
                    child: ContainerVerre(
                      height: 42,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(6),
                      opacite: 0.2,
                      child: Padding(
                        padding: const EdgeInsets.all(2), // Padding très réduit
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _construireStatistiqueModerne(
                              Icons.water_drop,
                              '${ville.humidite}%',
                              '',
                            ),
                            _construireStatistiqueModerne(
                              Icons.air,
                              '${ville.vitesseVent?.toInt() ?? 0}km/h',
                              '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _construireStatistiqueModerne(IconData icone, String valeur, String label) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone,
            color: Colors.white.withOpacity(0.9),
            size: 7, // Encore plus réduit
          ),
          const SizedBox(width: 1), // Espace très réduit
          Flexible(
            child: Text(
              valeur,
              style: TextStyle(
                color: Colors.white,
                fontSize: 7, // Encore plus réduit
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireContenuChargement(VilleMeteo ville) {
    return Row(
      children: [
        CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ville.nom,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Chargement...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construireContenuErreur(VilleMeteo ville) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ville.nom,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Erreur de connexion',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(providerVillesMeteo.notifier).recupererMeteoPourVille(ville.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text('Retry', style: TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  Widget _construireContenuPlaceholder(VilleMeteo ville) {
    return Row(
      children: [
        Icon(
          Icons.location_city,
          color: Colors.white.withOpacity(0.6),
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ville.nom,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'En attente...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}