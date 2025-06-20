import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../data/models/modeles_meteo.dart';
import '../providers/providers_meteo.dart';
import '../widgets/container_verre.dart';
import '../../core/theme/theme_app.dart';
import 'dart:math' as math;

class EcranChargement extends ConsumerStatefulWidget {
  const EcranChargement({super.key});

  @override
  ConsumerState<EcranChargement> createState() => _EtatEcranChargement();
}

class _EtatEcranChargement extends ConsumerState<EcranChargement>
    with TickerProviderStateMixin {
  late AnimationController _controleurPulsation;
  late AnimationController _controleurRotationTerre;
  late AnimationController _controleurIconesMeteo;
  late AnimationController _controleurParticules;
  late Animation<double> _animationPulsation;
  late Animation<double> _animationRotationTerre;
  late Animation<double> _animationIconesMeteo;
  late Animation<double> _animationParticules;

  @override
  void initState() {
    super.initState();
    _configurerAnimations();
  }

  void _configurerAnimations() {
    _controleurPulsation = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _controleurRotationTerre = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _controleurIconesMeteo = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _controleurParticules = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animationPulsation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controleurPulsation,
      curve: Curves.easeInOut,
    ));

    _animationRotationTerre = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurRotationTerre,
      curve: Curves.linear,
    ));

    _animationIconesMeteo = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurIconesMeteo,
      curve: Curves.linear,
    ));

    _animationParticules = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurParticules,
      curve: Curves.easeInOut,
    ));

    _controleurPulsation.repeat(reverse: true);
    _controleurRotationTerre.repeat();
    _controleurIconesMeteo.repeat();
    _controleurParticules.repeat();
  }

  @override
  void dispose() {
    _controleurPulsation.dispose();
    _controleurRotationTerre.dispose();
    _controleurIconesMeteo.dispose();
    _controleurParticules.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progresChargement = ref.watch(providerProgresChargement);
    final villesMeteo = ref.watch(providerVillesMeteo);
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    // Vérifier si le chargement est terminé et naviguer vers le tableau de bord
    ref.listen<ProgresChargement>(providerProgresChargement, (precedent, suivant) {
      if (suivant.estComplete && villesMeteo.every((ville) => ville.aDonnees || ville.aErreur)) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.read(providerEtatApp.notifier).naviguerVersEcran(EtatEcranApp.tableauBord);
        });
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: estSombre
                ? [
              const Color(0xFF0F0F23),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
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
            // Particules animées en arrière-plan
            _construireParticulesAnimees(),

            // Contenu principal
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Espace flexible du haut
                    const Flexible(flex: 2, child: SizedBox()),

                    // Titre de chargement
                    FadeInDown(
                      child: Text(
                        'Chargement des données météo',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Animation de la terre avec icônes météo qui tournent autour
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: AnimatedBuilder(
                        animation: _animationPulsation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animationPulsation.value,
                            child: _construireAnimationTerre(progresChargement.progres),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Texte de progression
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        '${(progresChargement.progres * 100).toInt()}%',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Message de chargement
                    FadeInUp(
                      delay: const Duration(milliseconds: 900),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          progresChargement.message,
                          key: ValueKey(progresChargement.message),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Espace flexible du milieu
                    const Flexible(flex: 2, child: SizedBox()),

                    // Statut des villes
                    FadeInUp(
                      delay: const Duration(milliseconds: 1200),
                      child: _construireStatutVilles(villesMeteo),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireAnimationTerre(double progres) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Icônes météo qui tournent autour de la terre
          ..._construireIconesMeteoTournantes(),

          // Cercle de progression
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: progres,
              strokeWidth: 6,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          // Terre qui tourne au centre
          AnimatedBuilder(
            animation: _animationRotationTerre,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationRotationTerre.value * 2 * math.pi,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF4A90E2),
                        Color(0xFF2E5266),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Continents stylisés
                      Positioned(
                        top: 15,
                        left: 20,
                        child: Container(
                          width: 25,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(0xFF228B22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 15,
                        child: Container(
                          width: 20,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Color(0xFF228B22),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 35,
                        right: 25,
                        child: Container(
                          width: 15,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Color(0xFF228B22),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _construireIconesMeteoTournantes() {
    final icones = [
      Icons.wb_sunny,      // Soleil
      Icons.cloud,         // Nuage
      Icons.flash_on,      // Éclair
      Icons.grain,         // Pluie
      Icons.ac_unit,       // Neige
      Icons.nights_stay,   // Lune
      Icons.star,          // Étoile
      Icons.air,           // Vent
    ];

    final couleurs = [
      Colors.orange,       // Soleil
      Colors.grey.shade300, // Nuage
      Colors.yellow,       // Éclair
      Colors.blue,         // Pluie
      Colors.white,        // Neige
      Colors.yellow.shade200, // Lune
      Colors.yellow,       // Étoile
      Colors.lightBlue,    // Vent
    ];

    return List.generate(icones.length, (index) {
      return AnimatedBuilder(
        animation: _animationIconesMeteo,
        builder: (context, child) {
          final angle = (_animationIconesMeteo.value * 2 * math.pi) +
              (index * 2 * math.pi / icones.length);
          final radius = 90.0;

          return Positioned(
            left: 100 + math.cos(angle) * radius - 15,
            top: 100 + math.sin(angle) * radius - 15,
            child: Transform.rotate(
              angle: angle + math.pi / 2,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: couleurs[index].withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: couleurs[index].withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  icones[index],
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _construireStatutVilles(List<VilleMeteo> villes) {
    return ContainerVerre(
      height: 80,
      width: double.infinity,
      borderRadius: BorderRadius.circular(16),
      opacite: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'Villes en cours de traitement',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: villes.length,
                itemBuilder: (context, index) {
                  final ville = villes[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _construirePuceStatutVille(ville),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirePuceStatutVille(VilleMeteo ville) {
    Color couleurPuce;
    IconData iconePuce;

    if (ville.aDonnees) {
      couleurPuce = ThemeApp.vertPrimaire;
      iconePuce = Icons.check_circle;
    } else if (ville.aErreur) {
      couleurPuce = ThemeApp.rougePrimaire;
      iconePuce = Icons.error;
    } else {
      couleurPuce = ThemeApp.orangePrimaire;
      iconePuce = Icons.hourglass_empty;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: couleurPuce.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: couleurPuce.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconePuce,
            color: Colors.white,
            size: 10,
          ),
          const SizedBox(width: 3),
          Text(
            ville.nom,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireParticulesAnimees() {
    return AnimatedBuilder(
      animation: _animationParticules,
      builder: (context, child) {
        return Stack(
          children: List.generate(25, (index) {
            final double progres = (_animationParticules.value + index * 0.08) % 1.0;
            final double taille = 1.5 + (index % 4);
            final double gauche = (index * 28.0) % MediaQuery.of(context).size.width;
            final double haut = MediaQuery.of(context).size.height * progres;
            final double opacite = (1.0 - progres) * 0.6;

            // Différents types de particules
            final particules = [
              Icons.star,
              Icons.circle,
              Icons.grain,
              Icons.brightness_1,
            ];

            final couleurs = [
              Colors.yellow,
              Colors.white,
              Colors.lightBlue,
              Colors.orange,
            ];

            return Positioned(
              left: gauche,
              top: haut,
              child: Opacity(
                opacity: opacite,
                child: Transform.rotate(
                  angle: progres * 2 * math.pi,
                  child: Icon(
                    particules[index % particules.length],
                    size: taille,
                    color: couleurs[index % couleurs.length],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}