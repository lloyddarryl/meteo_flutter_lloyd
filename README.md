# Météo Flutter Lloyd

Application météo moderne développée en Flutter - Projet L3 DAR/ESMT 2025

## Équipe de Développement

- **NGUIDJOL OBIANG Lloyd Darryl** - Développeur Principal


## Description du Projet

Météo Flutter Lloyd est une application mobile qui propose une expérience météorologique complète avec interface moderne, animations fluides et visualisation cartographique. L'application récupère des données météorologiques en temps réel pour 5 villes internationales et les présente dans une interface adaptive supportant les modes sombre et clair.

## Fonctionnalités Principales

### Écran d'Accueil
- Interface d'accueil avec animations thématiques
- Basculeur de thème intégré (mode jour/nuit)
- Bouton de lancement de l'expérience météo
- Animations de particules différenciées selon le thème sélectionné(avec possibilté de cliquer sur les objets volants en mode jour)

### Écran de Chargement
- Jauge de progression circulaire animée
- Messages de chargement rotatifs dynamiques
- Appels API météo asynchrones pour les 5 villes cibles
- Indicateurs de statut en temps réel par ville
- Animation de la terre avec icônes météo en orbite

### Tableau de Bord
- Cartes météo compactes avec effet glassmorphism
- Affichage des données principales : température, humidité, vitesse du vent
- Icônes météo dynamiques provenant de l'API OpenWeatherMap
- Gestion des états de chargement et d'erreur
- Navigation tactile vers les détails de chaque ville

### Écran Détail Ville
L'écran de détail constitue la fonctionnalité la plus avancée de l'application avec deux modes d'affichage :

#### Mode Détail (par défaut)
- Carte météo principale avec température et description
- Grille d'informations détaillées (humidité, vent, pression, visibilité)
- Informations sur le lever/coucher du soleil
- Animations d'étoiles et particules flottantes en arrière-plan

#### Mode Carte Interactive
**Activation :** Bouton de basculement situé en haut à droite de l'écran (icône carte/liste)

**Fonctionnalités cartographiques :**
- Carte interactive utilisant OpenStreetMap via Flutter Map
- Marqueur personnalisé avec température affichée
- Contrôles de zoom et navigation tactile
- Overlay d'informations météo en bas de carte
- Animation de transition fluide entre les modes


La carte utilise le widget FlutterMap avec les caractéristiques suivantes :
- Tuiles OpenStreetMap pour l'affichage cartographique
- Marqueur centré sur les coordonnées de la ville
- Zoom initial à 11.0 avec limites configurables (3.0 - 18.0)
- Container d'informations superposé avec données météo

## Architecture Technique

### Structure du Projet
```
lib/
├── app/                    # Point d'entrée application
│   └── app_meteo.dart     # Configuration MaterialApp
├── core/                   # Éléments transversaux
│   ├── constants/         # Configuration globale
│   └── theme/             # Design system et thèmes
├── data/                   # Couche données
│   ├── models/            # Modèles métier
│   └── services/          # Services API
└── presentation/           # Interface utilisateur
    ├── providers/         # State management Riverpod
    ├── screens/           # Écrans de l'application
    └── widgets/           # Composants réutilisables
```

### Technologies et Dépendances

**Framework et State Management**
- Flutter SDK 3.0+
- Riverpod 2.4.0 pour la gestion d'état réactive
- Dart 3.0+ avec null safety

**Réseau et API**
- Dio 5.3.2 pour les appels HTTP
- API OpenWeatherMap avec unités métriques
- Gestion des timeouts et intercepteurs d'erreur

**Interface et Animations**
- Animate Do 3.1.2 pour les animations prédéfinies
- Flutter Staggered Animations 1.1.1 pour les animations en cascade
- Cached Network Image 3.3.0 pour l'optimisation des images

**Cartographie**
- Flutter Map 8.1.1 pour l'affichage cartographique
- LatLng2 0.9.1 pour la gestion des coordonnées géographiques
- OpenStreetMap comme fournisseur de tuiles

**Utilitaires**
- Intl 0.18.1 pour la formatage des dates
- Math pour les calculs trigonométriques d'animation

## Données Météorologiques

### Villes Couvertes
1. **Paris, France** (48.8566°N, 2.3522°E)
2. **New York, États-Unis** (40.7128°N, -74.0060°W)
3. **Tokyo, Japon** (35.6762°N, 139.6503°E)
4. **Londres, Royaume-Uni** (51.5074°N, -0.1278°W)
5. **Dakar, Sénégal** (14.6937°N, -17.4441°W)

### Modèle de Données
```dart
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
}
```

Les données récupérées incluent :
- Température actuelle et ressentie (°C)
- Conditions météorologiques avec icônes
- Humidité relative (%)
- Vitesse et direction du vent (km/h)
- Pression atmosphérique (hPa)
- Visibilité (km)
- Heures de lever/coucher du soleil

## Installation et Configuration

### Prérequis
- Flutter SDK (version 3.0.0 minimum)
- Dart SDK (version 3.0.0 minimum)
- IDE compatible (VS Code, Android Studio, IntelliJ)
- Émulateur Android/iOS ou device physique

### Procédure d'Installation
```bash
# Cloner le repository
git clone https://github.com/lloyddarryl/meteo_flutter_lloyd.git
cd meteo_flutter_lloyd

# Installer les dépendances
flutter pub get

# Vérifier la configuration Flutter
flutter doctor

# Lancer l'application
flutter run
```

### Configuration API
L'application utilise une clé API OpenWeatherMap intégrée dans le fichier `constantes_app.dart`. Aucune configuration supplémentaire n'est requise pour le fonctionnement de base.

## Optimisations Techniques

### Gestion de l'État
- Architecture Riverpod avec providers typés
- State management réactif pour les données météo
- Gestion centralisée des erreurs et états de chargement

### Performance et Responsivité
- Utilisation de `LayoutBuilder` pour les contraintes dynamiques
- Résolution précise des débordements de pixels
- Optimisation des animations avec `TickerProviderStateMixin`
- Cache automatique des images météo

### Gestion d'Erreurs
- Intercepteurs Dio pour les erreurs réseau
- Messages d'erreur contextuels
- Système de retry automatique
- Fallback UI pour les états d'erreur

## Structure des Animations

### Contrôleurs d'Animation Principaux
```dart
// Écran détail ville
late AnimationController _controleurCarte;      // Transition vue carte
late AnimationController _controleurDetail;     // Animations d'entrée
late AnimationController _controleurEtoiles;    // Particules d'arrière-plan
late AnimationController _controleurOndulation; // Effets flottants
```

### Animations Thématiques
- **Mode jour :** Nuages, soleil central, oiseaux animés
- **Mode nuit :** Système solaire, étoiles, satellites en orbite


### Standards de Code
- Architecture Clean respectée
- Séparation des responsabilités
- Nommage cohérent en français
- Documentation inline pour les fonctions complexes

## Dépannage

### Problèmes Courants
1. **Erreur de réseau :** Vérifier la connexion internet et la validité de la clé API
2. **Animations saccadées :** S'assurer que le mode debug est désactivé en production
3. **Problèmes de carte :** Vérifier les permissions de géolocalisation 


## Roadmap et Améliorations Futures

### Fonctionnalités Envisagées
- Géolocalisation automatique
- Notifications push pour les alertes météo
- Prévisions sur 7 jours
- Widgets pour l'écran d'accueil

### Optimisations Techniques
- Implémentation de tests unitaires
- Integration continue CI/CD
- Optimisation des performances pour les anciens devices
- Support des tablettes

---

## Contact et Support

Pour toute question technique ou demande d'assistance concernant ce projet :

**Email :** [lloyddarrylobg@gmail.com]  

---

**Projet réalisé par Lloyd Darryl dans le cadre de l'examen L3 DAR/ESMT 2025**