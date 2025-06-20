import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/providers_meteo.dart';
import '../widgets/container_verre.dart';
import '../../data/models/modeles_meteo.dart';
import '../../core/theme/theme_app.dart';
import 'dart:math' as math;

class EcranDetailVille extends ConsumerStatefulWidget {
  const EcranDetailVille({super.key});

  @override
  ConsumerState<EcranDetailVille> createState() => _EtatEcranDetailVille();
}

class _EtatEcranDetailVille extends ConsumerState<EcranDetailVille>
    with TickerProviderStateMixin {
  late AnimationController _controleurCarte;
  late AnimationController _controleurDetail;
  late AnimationController _controleurEtoiles;
  late AnimationController _controleurOndulation;
  late Animation<double> _animationCarte;
  late Animation<double> _animationDetail;
  late Animation<double> _animationEtoiles;
  late Animation<double> _animationOndulation;

  MapController? _controleurFlutterMap;
  bool _afficherCarte = false;

  @override
  void initState() {
    super.initState();
    _configurerAnimations();
  }

  void _configurerAnimations() {
    _controleurCarte = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controleurDetail = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _controleurEtoiles = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _controleurOndulation = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animationCarte = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurCarte,
      curve: Curves.easeOutCubic,
    ));

    _animationDetail = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurDetail,
      curve: Curves.easeOutCubic,
    ));

    _animationEtoiles = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controleurEtoiles,
      curve: Curves.linear,
    ));

    _animationOndulation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controleurOndulation,
      curve: Curves.easeInOut,
    ));

    _controleurDetail.forward();
    _controleurEtoiles.repeat();
    _controleurOndulation.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controleurCarte.dispose();
    _controleurDetail.dispose();
    _controleurEtoiles.dispose();
    _controleurOndulation.dispose();
    super.dispose();
  }

  void _basculerCarte() {
    setState(() {
      _afficherCarte = !_afficherCarte;
      if (_afficherCarte) {
        _controleurCarte.forward();
      } else {
        _controleurCarte.reverse();
      }
    });
  }

  void _naviguerRetour() {
    ref.read(providerVilleSelectionnee.notifier).state = null;
    ref.read(providerEtatApp.notifier).naviguerVersEcran(EtatEcranApp.tableauBord);
  }

  @override
  Widget build(BuildContext context) {
    final villeSelectionnee = ref.watch(providerVilleSelectionnee);
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    if (villeSelectionnee == null) {
      return Scaffold(
        body: Center(
          child: Text('Aucune ville sélectionnée'),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeApp.obtenirDegradeMeteo(
            villeSelectionnee.conditionActuelle ?? 'clear',
          ),
        ),
        child: Stack(
          children: [
            // Étoiles et particules animées en arrière-plan
            _construireEtoilesAnimees(),
            _construireParticulesFlottantes(),

            SafeArea(
              child: AnimatedBuilder(
                animation: _animationDetail,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _animationDetail.value) * 30),
                    child: Opacity(
                      opacity: _animationDetail.value,
                      child: Column(
                        children: [
                          // En-tête compact
                          _construireEntete(villeSelectionnee),

                          // Contenu avec padding ajusté
                          Expanded(
                            child: _afficherCarte
                                ? _construireVueCarte(villeSelectionnee)
                                : _construireVueDetail(villeSelectionnee),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireEtoilesAnimees() {
    return AnimatedBuilder(
      animation: _animationEtoiles,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final double progres = (_animationEtoiles.value + index * 0.15) % 1.0;
            final double opacite = (math.sin(progres * 2 * math.pi) * 0.5 + 0.5) * 0.4;
            final double taille = 1.0 + (index % 3) * 0.5;
            final double gauche = (index * 47.0) % MediaQuery.of(context).size.width;
            final double haut = (index * 67.0) % MediaQuery.of(context).size.height;

            return Positioned(
              left: gauche,
              top: haut,
              child: Opacity(
                opacity: opacite,
                child: Transform.rotate(
                  angle: progres * 2 * math.pi,
                  child: Icon(
                    Icons.star,
                    size: taille,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _construireParticulesFlottantes() {
    return AnimatedBuilder(
      animation: _animationOndulation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final icones = [
              Icons.wb_sunny,
              Icons.cloud,
              Icons.grain,
              Icons.ac_unit,
              Icons.flash_on,
              Icons.air,
              Icons.nights_stay,
              Icons.star,
            ];

            return Positioned(
              top: 100.0 + (index * 80.0),
              right: 20 + _animationOndulation.value * (index % 2 == 0 ? 1 : -1),
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  icones[index],
                  size: 20 + (index % 3) * 5,
                  color: Colors.white,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _construireEntete(VilleMeteo ville) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Bouton retour
          GestureDetector(
            onTap: _naviguerRetour,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          // Nom de la ville - centré
          Expanded(
            child: Column(
              children: [
                Text(
                  ville.nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                Text(
                  ville.pays,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Bouton basculer carte
          GestureDetector(
            onTap: _basculerCarte,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _afficherCarte ? Icons.list : Icons.map,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireVueDetail(VilleMeteo ville) {
    if (!ville.aDonnees) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Données non disponibles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Carte météo principale - hauteur réduite
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: _construireCarteMeteoePrincipale(ville),
          ),

          const SizedBox(height: 16),

          // Grille de détails - plus compacte
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: _construireGrilleDetails(ville),
          ),

          const SizedBox(height: 16),

          // Informations supplémentaires - plus compactes
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: _construireInfosSupplementaires(ville),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _construireCarteMeteoePrincipale(VilleMeteo ville) {
    return ContainerVerre(
      height: 150, // Encore plus réduit
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
      opacite: 0.12,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Température et description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${ville.temperature}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48, // Réduit encore
                          fontWeight: FontWeight.bold,
                          height: 0.9,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'C',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ville.descriptionMeteo?.toUpperCase() ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Ressenti ${ville.ressenti}°C',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Icône météo
            if (ville.iconeMeteo != null)
              CachedNetworkImage(
                imageUrl: ville.donneesMeteo!.meteo.urlIcone,
                width: 70,
                height: 70,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 70,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construireGrilleDetails(VilleMeteo ville) {
    final meteo = ville.donneesMeteo!;

    final details = [
      {
        'icone': Icons.water_drop,
        'titre': 'Humidité',
        'valeur': '${meteo.principal.humidite}%',
        'sousTitre': 'Niveau d\'humidité',
      },
      {
        'icone': Icons.air,
        'titre': 'Vent',
        'valeur': '${meteo.vent.vitesseKmh.toInt()} km/h',
        'sousTitre': 'Direction ${meteo.vent.direction}',
      },
      {
        'icone': Icons.compress,
        'titre': 'Pression',
        'valeur': '${meteo.principal.pression} hPa',
        'sousTitre': 'Pression atm.',
      },
      {
        'icone': Icons.visibility,
        'titre': 'Visibilité',
        'valeur': '${(meteo.visibilite / 1000).toInt()} km',
        'sousTitre': 'Distance max',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4, // Plus compact
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return ContainerVerre(
          height: double.infinity,
          width: double.infinity,
          borderRadius: BorderRadius.circular(16),
          opacite: 0.12,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  detail['icone'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  detail['valeur'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail['titre'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  detail['sousTitre'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construireInfosSupplementaires(VilleMeteo ville) {
    final meteo = ville.donneesMeteo!;
    final leverSoleil = meteo.systeme.heureLeverSoleil;
    final coucherSoleil = meteo.systeme.heureCoucherSoleil;
    final formatHeure = DateFormat('HH:mm');

    return ContainerVerre(
      height: 80, // Encore plus réduit
      width: double.infinity,
      borderRadius: BorderRadius.circular(16),
      opacite: 0.12,
      child: Padding(
        padding: const EdgeInsets.all(12), // Padding réduit
        child: Row(
          children: [
            // Lever du soleil
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: Colors.orange,
                    size: 20, // Icône plus petite
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatHeure.format(leverSoleil),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Texte plus petit
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lever',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 8, // Encore plus petit
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur
            Container(
              height: 30, // Séparateur plus court
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),

            // Coucher du soleil
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_twilight,
                    color: Colors.deepOrange,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatHeure.format(coucherSoleil),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Coucher',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireVueCarte(VilleMeteo ville) {
    return AnimatedBuilder(
      animation: _animationCarte,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.85 + (_animationCarte.value * 0.15),
          child: Opacity(
            opacity: _animationCarte.value,
            child: Container(
              margin: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  mapController: _controleurFlutterMap,
                  options: MapOptions(
                    initialCenter: LatLng(ville.latitude, ville.longitude),
                    initialZoom: 11.0,
                    maxZoom: 18.0,
                    minZoom: 3.0,
                  ),
                  children: [
                    // Couche de tuiles OpenStreetMap
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.exemple.meteo_flutter_lloyd',
                      maxZoom: 19,
                    ),

                    // Marqueur de la ville
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(ville.latitude, ville.longitude),
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                if (ville.temperature != null)
                                  Text(
                                    '${ville.temperature}°',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Informations sur la carte
                    Positioned(
                      bottom: 14,
                      left: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ville.nomAffiche,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (ville.aDonnees) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${ville.temperature}°C - ${ville.descriptionMeteo}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}