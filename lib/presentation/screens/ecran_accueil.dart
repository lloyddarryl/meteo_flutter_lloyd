import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/providers_meteo.dart';
import '../widgets/container_verre.dart';
import '../../core/theme/theme_app.dart';
import 'dart:math' as math;

class EcranAccueil extends ConsumerStatefulWidget {
  const EcranAccueil({super.key});

  @override
  ConsumerState<EcranAccueil> createState() => _EtatEcranAccueil();
}

class _EtatEcranAccueil extends ConsumerState<EcranAccueil>
    with TickerProviderStateMixin {
  late AnimationController _controleurFond;
  late AnimationController _controleurNuages;
  late AnimationController _controleurSystemeSolaire;
  late AnimationController _controleurSatellites;
  late AnimationController _controleurOiseaux;
  late Animation<double> _animationFond;
  late Animation<double> _animationNuages;
  late Animation<double> _animationSystemeSolaire;
  late Animation<double> _animationSatellites;
  late Animation<double> _animationOiseaux;

  List<bool> _planetesSelectionnees = List.filled(8, false);
  List<bool> _oiseauxTombes = List.filled(8, false);
  List<double> _oiseauxPositionsY = List.filled(8, 0);

  @override
  void initState() {
    super.initState();
    _configurerAnimations();
    // Initialiser les positions Y des oiseaux
    for (int i = 0; i < _oiseauxPositionsY.length; i++) {
      _oiseauxPositionsY[i] = 100.0 + (i * 80.0);
    }
  }

  void _configurerAnimations() {
    _controleurFond = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _controleurNuages = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

    _controleurSystemeSolaire = AnimationController(
      duration: const Duration(seconds: 15), // Plus rapide : 40s -> 15s
      vsync: this,
    );

    _controleurSatellites = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _controleurOiseaux = AnimationController(
      duration: const Duration(seconds: 20), // Plus lent : 8s -> 20s
      vsync: this,
    );

    _animationFond = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurFond,
      curve: Curves.easeInOut,
    ));

    _animationNuages = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controleurNuages,
      curve: Curves.linear,
    ));

    _animationSystemeSolaire = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurSystemeSolaire,
      curve: Curves.linear,
    ));

    _animationSatellites = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurSatellites,
      curve: Curves.linear,
    ));

    _animationOiseaux = Tween<double>(
      begin: 0.0, // Commence à 0 au lieu de -1
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurOiseaux,
      curve: Curves.linear, // Linear au lieu de easeInOut
    ));

    _controleurFond.repeat(reverse: true);
    _controleurNuages.repeat();
    _controleurSystemeSolaire.repeat();
    _controleurSatellites.repeat();
    _controleurOiseaux.repeat();
  }

  @override
  void dispose() {
    _controleurFond.dispose();
    _controleurNuages.dispose();
    _controleurSystemeSolaire.dispose();
    _controleurSatellites.dispose();
    _controleurOiseaux.dispose();
    super.dispose();
  }

  void _demarrerExperienceMeteo() {
    ref.read(providerEtatApp.notifier).naviguerVersEcran(EtatEcranApp.chargement);
    ref.read(providerProgresChargement.notifier).demarrerChargement();
    ref.read(providerVillesMeteo.notifier).recupererToutesDonneesMeteo();
  }

  void _secouerPlanete(int index) {
    setState(() {
      _planetesSelectionnees[index] = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _planetesSelectionnees[index] = false;
        });
      }
    });
  }

  void _faireChuter(int index) {
    if (index < _oiseauxTombes.length) {
      setState(() {
        _oiseauxTombes[index] = true;
      });

      // Animation de chute
      AnimationController chute = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      Animation<double> animationChute = Tween<double>(
        begin: _oiseauxPositionsY[index],
        end: MediaQuery.of(context).size.height + 50,
      ).animate(CurvedAnimation(
        parent: chute,
        curve: Curves.bounceIn,
      ));

      chute.addListener(() {
        if (mounted && index < _oiseauxPositionsY.length) {
          setState(() {
            _oiseauxPositionsY[index] = animationChute.value;
          });
        }
      });

      chute.forward().then((_) {
        // Remettre l'oiseau à sa position initiale après 2 secondes
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _oiseauxTombes[index] = false;
              _oiseauxPositionsY[index] = 100.0 + (index * 80.0);
            });
          }
        });
        chute.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationFond,
        builder: (context, child) {
          return Container(
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
                  Color.lerp(
                    const Color(0xFF87CEEB),
                    const Color(0xFF98D8E8),
                    _animationFond.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFB8E6B8),
                    const Color(0xFFFFE5B4),
                    _animationFond.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFFFE5B4),
                    const Color(0xFFFFB347),
                    _animationFond.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Arrière-plan animé selon le mode - PARTOUT SUR L'ÉCRAN
                if (estSombre) ...[
                  _construireEtoilesEspace(),
                  _construireSatellitesEspacePartout(),
                ] else ...[
                  _construireNuagesJour(),
                  _construireSoleilCentral(),
                  _construireOiseauxPartout(),
                ],

                // Système solaire juste en bas du mode toggle (mode nuit uniquement)
                if (estSombre)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20, // Plus haut, juste sous le contenu
                    height: 180, // Hauteur réduite pour être responsive
                    child: _construireSystemeSolaire(),
                  ),

                // Contenu principal
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const Flexible(flex: 2, child: SizedBox()),

                        // Titre avec icône
                        FadeInDown(
                          duration: const Duration(milliseconds: 1000),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: estSombre
                                      ? RadialGradient(
                                    colors: [
                                      Color(0xFF4A90E2),
                                      Color(0xFF2E5266),
                                    ],
                                  )
                                      : ThemeApp.degradeEnsoleille,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (estSombre ? Colors.blue : Colors.orange).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  estSombre ? Icons.language : Icons.wb_sunny_outlined,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Météo Flutter Lloyd',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 26,
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Message d'accueil corrigé et centré
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 300),
                          child: Center(
                            child: ContainerVerre(
                              height: 120, // Encore plus compact
                              width: MediaQuery.of(context).size.width * 0.9, // 90% de la largeur
                              borderRadius: BorderRadius.circular(20),
                              opacite: 0.15,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      estSombre ? Icons.explore : Icons.location_on_outlined,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Découvrez la météo en temps réel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Explorez les conditions météorologiques de 5 villes.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        height: 1.2,
                                      ),
                                      maxLines: 1, // Une seule ligne
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Flexible(flex: 2, child: SizedBox()),

                        // Bouton principal
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 600),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _demarrerExperienceMeteo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: estSombre ? ThemeApp.bleuPrimaire : Colors.white,
                                foregroundColor: estSombre ? Colors.white : ThemeApp.bleuPrimaire,
                                elevation: 8,
                                shadowColor: (estSombre ? ThemeApp.bleuPrimaire : Colors.white).withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.explore_outlined, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Commencer l\'expérience',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Basculeur de thème
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 800),
                          child: GestureDetector(
                            onTap: () {
                              ref.read(providerModeTheme.notifier).basculerTheme();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    estSombre ? Icons.light_mode : Icons.dark_mode,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    estSombre ? 'Mode clair' : 'Mode sombre',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ANIMATIONS MODE NUIT (ESPACE) - partout sur l'écran
  Widget _construireEtoilesEspace() {
    return Stack(
      children: List.generate(50, (index) {
        final double gauche = (index * 31.0) % MediaQuery.of(context).size.width;
        final double haut = (index * 47.0) % MediaQuery.of(context).size.height;
        final double taille = 1.0 + (index % 4) * 0.5;

        return AnimatedBuilder(
          animation: _animationSystemeSolaire,
          builder: (context, child) {
            final double scintillement = math.sin((_animationSystemeSolaire.value * 6 + index) * math.pi);
            return Positioned(
              left: gauche,
              top: haut,
              child: Opacity(
                opacity: (scintillement * 0.3 + 0.5).clamp(0.2, 0.8),
                child: Icon(
                  Icons.star,
                  size: taille,
                  color: Colors.white,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _construireSystemeSolaire() {
    final List<Map<String, dynamic>> planetes = [
      {'nom': 'Mercure', 'couleur': Color(0xFF8C7853), 'taille': 6.0, 'vitesse': 2.0, 'rayon': 40.0},
      {'nom': 'Vénus', 'couleur': Color(0xFFFFC649), 'taille': 8.0, 'vitesse': 1.5, 'rayon': 55.0},
      {'nom': 'Terre', 'couleur': Color(0xFF4A90E2), 'taille': 9.0, 'vitesse': 1.0, 'rayon': 70.0},
      {'nom': 'Mars', 'couleur': Color(0xFFCD5C5C), 'taille': 7.0, 'vitesse': 0.8, 'rayon': 85.0},
      {'nom': 'Jupiter', 'couleur': Color(0xFFD2691E), 'taille': 16.0, 'vitesse': 0.5, 'rayon': 105.0},
      {'nom': 'Saturne', 'couleur': Color(0xFFFAD5A5), 'taille': 14.0, 'vitesse': 0.4, 'rayon': 125.0},
      {'nom': 'Uranus', 'couleur': Color(0xFF4FD0E7), 'taille': 11.0, 'vitesse': 0.3, 'rayon': 145.0},
      {'nom': 'Neptune', 'couleur': Color(0xFF4169E1), 'taille': 10.0, 'vitesse': 0.2, 'rayon': 165.0},
    ];

    return AnimatedBuilder(
      animation: _animationSystemeSolaire,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Orbites visibles (cercles transparents)
              ...planetes.map((planete) {
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 - planete['rayon'],
                  top: 90.0 - planete['rayon'], // Changé en double
                  child: Container(
                    width: planete['rayon'] * 2,
                    height: planete['rayon'] * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                );
              }),

              // Soleil central avec animation de pulsation
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 15,
                top: 75.0, // Changé en double
                child: AnimatedBuilder(
                  animation: _animationSystemeSolaire,
                  builder: (context, child) {
                    final pulsation = 1.0 + (math.sin(_animationSystemeSolaire.value * 6 * math.pi) * 0.1);
                    return Transform.scale(
                      scale: pulsation,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.yellow,
                              Colors.orange,
                              Colors.deepOrange,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Planètes en orbite avec animations fluides
              ...planetes.asMap().entries.map((entry) {
                final index = entry.key;
                final planete = entry.value;
                final angle = (_animationSystemeSolaire.value * planete['vitesse'] * 2 * math.pi) +
                    (index * 2 * math.pi / 8);

                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 +
                      math.cos(angle) * planete['rayon'] - planete['taille'] / 2,
                  top: 90.0 + math.sin(angle) * planete['rayon'] - planete['taille'] / 2, // Changé en double
                  child: GestureDetector(
                    onTap: () => _secouerPlanete(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      transform: Matrix4.identity()
                        ..scale(_planetesSelectionnees[index] ? 1.4 : 1.0),
                      child: Container(
                        width: planete['taille'],
                        height: planete['taille'],
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              planete['couleur'],
                              Color.lerp(planete['couleur'], Colors.black, 0.3)!,
                            ],
                            stops: [0.4, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: planete['couleur'].withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Anneaux pour Saturne
                            if (index == 5)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.brown.withOpacity(0.8),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            // Effet brillant sur la planète
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                width: planete['taille'] * 0.3,
                                height: planete['taille'] * 0.3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Étoiles filantes occasionnelles
              AnimatedBuilder(
                animation: _animationSystemeSolaire,
                builder: (context, child) {
                  if ((_animationSystemeSolaire.value % 0.3) < 0.05) {
                    return Positioned(
                      right: 20 + (_animationSystemeSolaire.value * 100) % 200,
                      top: 20 + (_animationSystemeSolaire.value * 80) % 100,
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow.withOpacity(0.8),
                          size: 8,
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construireSatellitesEspacePartout() {
    return AnimatedBuilder(
      animation: _animationSatellites,
      builder: (context, child) {
        return Stack(
          children: List.generate(6, (index) {
            // Orbites variées partout sur l'écran
            final rayonX = 150.0 + (index * 40.0);
            final rayonY = 100.0 + (index * 30.0);
            final centreX = (index % 3) * MediaQuery.of(context).size.width / 2;
            final centreY = (index % 4) * MediaQuery.of(context).size.height / 3;
            final angle = (_animationSatellites.value * (1 + index * 0.3) * 2 * math.pi);

            return Positioned(
              left: centreX + math.cos(angle) * rayonX - 25,
              top: centreY + math.sin(angle) * rayonY - 25,
              child: Transform.rotate(
                angle: angle,
                child: Icon(
                  Icons.satellite_alt,
                  size: 50,
                  color: Colors.white.withOpacity(0.7),
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ANIMATIONS MODE JOUR - partout sur l'écran
  Widget _construireNuagesJour() {
    return AnimatedBuilder(
      animation: _animationNuages,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final vitesse = 1.0 + (index * 0.3);
            final taille = 30.0 + (index * 10.0);
            final hauteur = (index * MediaQuery.of(context).size.height / 8) + 50;

            return Positioned(
              top: hauteur,
              left: MediaQuery.of(context).size.width * (_animationNuages.value / vitesse),
              child: Opacity(
                opacity: 0.6 - (index * 0.05),
                child: Icon(
                  Icons.cloud,
                  size: taille,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _construireSoleilCentral() {
    return AnimatedBuilder(
      animation: _animationSystemeSolaire,
      builder: (context, child) {
        return Positioned(
          right: 30,
          top: 50,
          child: Transform.rotate(
            angle: _animationSystemeSolaire.value * 2 * math.pi,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.yellow, Colors.orange, Colors.deepOrange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construireOiseauxPartout() {
    return AnimatedBuilder(
      animation: _animationOiseaux,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final tailleEmoji = 20.0 + (index * 3);

            // Différents types de mouvements pour chaque oiseau
            double positionX, positionY;

            switch (index % 4) {
              case 0: // Horizontal de gauche à droite
                positionX = MediaQuery.of(context).size.width * _animationOiseaux.value;
                positionY = _oiseauxPositionsY[index];
                break;
              case 1: // Horizontal de droite à gauche
                positionX = MediaQuery.of(context).size.width * (1 - _animationOiseaux.value);
                positionY = _oiseauxPositionsY[index];
                break;
              case 2: // Diagonal descendant
                positionX = MediaQuery.of(context).size.width * _animationOiseaux.value;
                positionY = _oiseauxPositionsY[index] + (MediaQuery.of(context).size.height * 0.3 * _animationOiseaux.value);
                break;
              case 3: // Mouvement en arc
                final angle = _animationOiseaux.value * math.pi;
                positionX = MediaQuery.of(context).size.width * _animationOiseaux.value;
                positionY = _oiseauxPositionsY[index] + math.sin(angle) * 100;
                break;
              default:
                positionX = MediaQuery.of(context).size.width * _animationOiseaux.value;
                positionY = _oiseauxPositionsY[index];
            }

            return Positioned(
              top: positionY.clamp(0.0, MediaQuery.of(context).size.height - 50),
              left: positionX.clamp(-50.0, MediaQuery.of(context).size.width + 50),
              child: GestureDetector(
                onTap: () => _faireChuter(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(_oiseauxTombes[index] ? 1.5 : 1.0)
                    ..rotateZ(_oiseauxTombes[index] ? math.pi : 0),
                  child: Transform.rotate(
                    angle: math.sin(_animationOiseaux.value * 3 + index) * 0.2, // Battement d'ailes plus lent
                    child: Text(
                      _oiseauxTombes[index] ? '💫' : '🕊️',
                      style: TextStyle(fontSize: tailleEmoji),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _construireSatellitesJourPartout() {
    return AnimatedBuilder(
      animation: _animationSatellites,
      builder: (context, child) {
        return Stack(
          children: List.generate(5, (index) {
            // Mouvements variés dans tout l'écran
            final rayonX = 120.0 + (index * 50.0);
            final rayonY = 80.0 + (index * 40.0);
            final centreX = (index % 2) * MediaQuery.of(context).size.width * 0.7;
            final centreY = (index % 3) * MediaQuery.of(context).size.height * 0.4;
            final angle = (_animationSatellites.value * (0.8 + index * 0.4) * 2 * math.pi);

            return Positioned(
              left: centreX + math.cos(angle) * rayonX - 30,
              top: centreY + math.sin(angle) * rayonY - 30,
              child: Transform.rotate(
                angle: angle * 2,
                child: Icon(
                  Icons.satellite_alt,
                  size: 60,
                  color: Colors.white.withOpacity(0.8),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}