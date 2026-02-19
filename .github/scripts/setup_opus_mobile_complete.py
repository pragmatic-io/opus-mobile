#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script COMPLET de création du projet OPUS Mobile sur GitHub

Crée dans l'ordre:
1. Labels personnalisés
2. Milestones (MVP v1.0, Post-MVP v1.1)
3. Issue Design System (charte graphique)
4. Issue Theme Setup (opus_colors.dart)
5. 20 issues de développement avec références au design

Usage:
    python3 setup_opus_mobile_complete.py
    python3 setup_opus_mobile_complete.py --test    # Mode test (3 issues seulement)

Auteur: Ange (OPUS Founder)
Date: Février 2025
"""

import os
import sys
import argparse
from github import Github, GithubException
from dotenv import load_dotenv

# Force UTF-8
if sys.version_info[0] >= 3:
    sys.stdout.reconfigure(encoding='utf-8')

load_dotenv()

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GITHUB_REPO = os.getenv('GITHUB_REPO')

# ============================================================================
# CONFIGURATION
# ============================================================================

LABELS_CONFIG = {
    'feature': {'color': '0E8A16', 'description': 'Nouvelle fonctionnalite'},
    'bug': {'color': 'D73A4A', 'description': 'Correction anomalie'},
    'spike': {'color': '8B4789', 'description': 'Recherche technique'},
    'refactor': {'color': 'FEF2C0', 'description': 'Amelioration code'},
    'docs': {'color': '0075CA', 'description': 'Documentation'},
    'design': {'color': 'E63946', 'description': 'Design & UX'},
    'P0-critical': {'color': 'B60205', 'description': 'Bloquant MVP'},
    'P1-high': {'color': 'D93F0B', 'description': 'Important MVP'},
    'P2-medium': {'color': 'FBCA04', 'description': 'Post-MVP'},
    'P3-low': {'color': 'FEF2C0', 'description': 'Nice-to-have'},
    'module:auth': {'color': '5319E7', 'description': 'Authentification'},
    'module:profile': {'color': '1D76DB', 'description': 'Profils'},
    'module:gombo': {'color': 'C5DEF5', 'description': 'Offres/Demandes'},
    'module:commerce': {'color': '006B75', 'description': 'Commerces'},
    'module:chat': {'color': 'BFD4F2', 'description': 'Messagerie'},
    'module:payment': {'color': 'D4C5F9', 'description': 'Paiements'},
    'module:core': {'color': '000000', 'description': 'Core'},
    'module:notification': {'color': 'FFA500', 'description': 'Notifications'},
    'status:blocked': {'color': 'D73A4A', 'description': 'Bloque'},
    'good-first-issue': {'color': '7057FF', 'description': 'Debutant'},
}

MILESTONES_CONFIG = [
    {
        'title': 'MVP v1.0',
        'description': 'Fonctionnalites essentielles pour lancement pilote Abidjan',
        'due_on': '2025-08-15T00:00:00Z',
    },
    {
        'title': 'Post-MVP v1.1',
        'description': 'Ameliorations apres feedback utilisateurs',
        'due_on': '2025-11-15T00:00:00Z',
    }
]

# ============================================================================
# UTILITAIRES
# ============================================================================

def validate_config():
    """Valide la configuration"""
    print("🔍 Validation configuration...\n")
    
    if not GITHUB_TOKEN:
        print("❌ GITHUB_TOKEN non défini dans .env")
        sys.exit(1)
    
    if not GITHUB_REPO:
        print("❌ GITHUB_REPO non défini dans .env")
        sys.exit(1)
    
    if '/' not in GITHUB_REPO:
        print("❌ GITHUB_REPO doit être 'username/repo-name'")
        sys.exit(1)
    
    print("✅ Configuration valide\n")

def connect_github():
    """Connexion à GitHub"""
    print("🔌 Connexion GitHub...\n")
    
    try:
        g = Github(GITHUB_TOKEN)
        user = g.get_user()
        repo = g.get_repo(GITHUB_REPO)
        
        print(f"✅ Authentifié: {user.login}")
        print(f"✅ Repo: {repo.full_name}")
        print(f"✅ Permissions: {'Écriture' if repo.permissions.push else 'Lecture'}\n")
        
        if not repo.permissions.push:
            print("❌ Permissions insuffisantes")
            sys.exit(1)
        
        return g, repo
    except GithubException as e:
        print(f"❌ Erreur: {e.status} - {e.data.get('message', 'Unknown')}\n")
        sys.exit(1)

# ============================================================================
# ÉTAPE 1: LABELS
# ============================================================================

def create_labels(repo):
    """Crée les labels"""
    print("="*70)
    print("ÉTAPE 1/5 : Création Labels")
    print("="*70 + "\n")
    
    existing = {label.name: label for label in repo.get_labels()}
    created = 0
    skipped = 0
    
    for name, config in LABELS_CONFIG.items():
        if name in existing:
            skipped += 1
        else:
            try:
                repo.create_label(
                    name=name,
                    color=config['color'],
                    description=config['description']
                )
                print(f"   ✅ '{name}'")
                created += 1
            except Exception as e:
                print(f"   ❌ '{name}': {e}")
    
    print(f"\n📊 {created} créés, {skipped} existants\n")

# ============================================================================
# ÉTAPE 2: MILESTONES
# ============================================================================

def create_milestones(repo):
    """Crée les milestones"""
    print("="*70)
    print("ÉTAPE 2/5 : Création Milestones")
    print("="*70 + "\n")
    
    existing = {m.title: m for m in repo.get_milestones(state='open')}
    milestones = {}
    
    for config in MILESTONES_CONFIG:
        title = config['title']
        if title in existing:
            milestones[title] = existing[title]
            print(f"   ⏭️  '{title}' existe")
        else:
            try:
                m = repo.create_milestone(
                    title=title,
                    description=config['description'],
                    due_on=config.get('due_on')
                )
                milestones[title] = m
                print(f"   ✅ '{title}'")
            except Exception as e:
                print(f"   ❌ '{title}': {e}")
    
    print()
    return milestones

# ============================================================================
# ÉTAPE 3: ISSUE DESIGN SYSTEM
# ============================================================================

def create_design_system_issue(repo):
    """Crée l'issue Design System"""
    print("="*70)
    print("ÉTAPE 3/5 : Création Issue Design System")
    print("="*70 + "\n")
    
    title = '[DESIGN] Charte Graphique OPUS Mobile v3.0 - "Béton & Latérite"'
    
    body = '''## 🎨 Charte Graphique OPUS Mobile - Version Finale

Cette issue centralise **toute la documentation design** pour le développement mobile OPUS.

---

## 📋 CONCEPT : "Béton & Latérite"

L'identité visuelle OPUS s'inspire de l'**authenticité brute des quartiers populaires** d'Afrique de l'Ouest.

### Inspirations Visuelles

| Élément | Couleur | Usage |
|---------|---------|-------|
| 🪧 **Enseignes peintes** | Rouge #E63946 | CTAs, urgence |
| 🛖 **Bâches marchés** | Indigo #1D3557 | Headers, navigation |
| 🚕 **Taxis wôrô-wôrô** | Jaune #F4A261 | Highlights, badges |
| 🏗️ **Béton brut** | Gris #6C757D | Neutres |
| 🏜️ **Latérite** | Ocre #E76F51 | Accents chaleureux |

---

## 🌈 PALETTE COULEURS

```dart
// Primaires
rougeEnseigne:  #E63946
indigoBache:    #1D3557
jauneTaxi:      #F4A261
ocreLaterite:   #E76F51

// Secondaires
betonBrut:      #6C757D
grisAsphalte:   #495057
bleuBache:      #457B9D
terreRouge:     #A8402F

// Neutres
noirGoudron:    #212529
grisMur:        #343A40
grisPoussiere:  #ADB5BD
blancChaux:     #F8F9FA

// Sémantiques
success:        #10B981
warning:        #F4A261
error:          #EF4444
info:           #457B9D
```

---

## 📝 TYPOGRAPHIE

**Police:** Inter (Google Fonts)

```
H1: ExtraBold 800, 32px, -0.5px
H2: ExtraBold 800, 19px, -0.3px
H3: Bold 700, 17px
Body: Medium 500, 16px
Caption: SemiBold 600, 12px, uppercase
Button: Bold 700-800, 18px
```

---

## 📐 SPACING

**Système 4px:** Tous spacing multiples de 4.

```
xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, xxxl=32
```

---

## 📱 MAQUETTES

Fichiers dans `design/mockups/`:
- `opus_palette_beton_laterite.html` - Palette complète
- `mockup_onboarding_beton.html` - Onboarding
- `mockup_gombos_beton.html` - Liste Gombos
- `mockup_profile_beton.html` - Profil
- `mockup_gombo_detail.html` - Détail Gombo
- `mockup_carte_commerces.html` - Carte
- `mockup_messages.html` - Messages

---

## 📚 DOCUMENTATION

`design/OPUS_Charte_Graphique_Final_v3.md` - 40+ pages complètes

---

## ⚠️ RÈGLES

1. **NE PAS inventer de couleurs** - utiliser uniquement OpusColors
2. **NE PAS modifier spacing** - système 4px strict
3. **NE PAS changer fonts** - Inter uniquement
4. **TOUJOURS vérifier maquettes** avant de coder

---

**Référence pour TOUS les développements UI d'OPUS Mobile 🎨**
'''
    
    try:
        issue = repo.create_issue(
            title=title,
            body=body,
            labels=['design', 'docs', 'P0-critical']
        )
        print(f"✅ Issue #{issue.number}: {title[:50]}...")
        print(f"   {issue.html_url}\n")
        return issue
    except Exception as e:
        print(f"❌ Erreur: {e}\n")
        return None

# ============================================================================
# ÉTAPE 4: ISSUE THEME SETUP
# ============================================================================

def create_theme_setup_issue(repo, design_issue_number):
    """Crée l'issue Theme Setup"""
    print("="*70)
    print("ÉTAPE 4/5 : Création Issue Theme Setup")
    print("="*70 + "\n")
    
    title = '[CORE] Setup Theme OPUS - Couleurs, Typographie & Composants'
    
    body = f'''## 🎨 Objectif

Créer les fichiers theme Flutter implémentant la charte "Béton & Latérite".

**Référence:** Issue #{design_issue_number} (Design System)

---

## 📋 Fichiers à Créer

### 1. `lib/core/theme/opus_colors.dart`

Toutes les couleurs de la charte (voir issue #{design_issue_number} pour code complet).

### 2. `lib/core/theme/opus_spacing.dart`

Système spacing 4px.

### 3. `lib/core/theme/opus_text_styles.dart`

Hiérarchie typographique Inter.

### 4. `lib/core/theme/opus_theme.dart`

ThemeData Flutter complet.

### 5. `lib/core/theme/theme.dart`

Export de tous les fichiers.

---

## ✅ Critères d'Acceptation

- [ ] 5 fichiers créés dans `lib/core/theme/`
- [ ] Code exact depuis issue #{design_issue_number}
- [ ] Compilation sans erreur
- [ ] Documentation inline présente
- [ ] Export configuré

---

## 📚 Référence

- Issue #{design_issue_number} - Charte complète avec code
- `design/OPUS_Charte_Graphique_Final_v3.md`

---

## 🎯 Utilisation

```dart
import 'package:opus_mobile/core/theme/theme.dart';

Container(
  color: OpusColors.rougeEnseigne,
  padding: EdgeInsets.all(OpusSpacing.lg),
  child: Text('Titre', style: OpusTextStyles.h1),
)
```

---

**À développer EN PREMIER - tous les écrans en dépendent.**

**Estimation:** 3 points (~6-8h)
'''
    
    try:
        issue = repo.create_issue(
            title=title,
            body=body,
            labels=['feature', 'module:core', 'design', 'P0-critical', 'good-first-issue']
        )
        print(f"✅ Issue #{issue.number}: {title[:50]}...")
        print(f"   {issue.html_url}\n")
        return issue
    except Exception as e:
        print(f"❌ Erreur: {e}\n")
        return None

# ============================================================================
# ÉTAPE 5: 20 ISSUES DÉVELOPPEMENT
# ============================================================================

def get_dev_issues_data(milestones, design_issue_num, theme_issue_num):
    """Retourne les 20 issues de développement avec références design"""
    
    mvp = milestones.get('MVP v1.0')
    post_mvp = milestones.get('Post-MVP v1.1')
    
    # Référence design à ajouter aux issues UI
    design_ref = f'''

---

## 🎨 Design

**IMPORTANT:** Consulter issues #{design_issue_num} (Charte) et #{theme_issue_num} (Theme).

Maquettes: `design/mockups/`

**Utiliser EXACTEMENT:**
- Couleurs: OpusColors
- Typographie: OpusTextStyles  
- Spacing: multiples de 4px
'''
    
    return [
        # EPIC 1: FONDATIONS
        {
            'title': '[INFRA] Initialiser projet Flutter architecture modulaire',
            'body': '''## Contexte
Structure de base OPUS Mobile.

## Critères d'acceptation
- [ ] Projet Flutter créé (3.19.x stable)
- [ ] Structure dossiers (core/, features/)
- [ ] Multi-environnement (dev, staging, prod)
- [ ] README avec setup instructions
- [ ] .env.example

## Dépendances
flutter_riverpod, go_router, dio, retrofit, hive_flutter, freezed

## Estimation
3 points (~6-8h)
''',
            'labels': ['feature', 'P0-critical', 'good-first-issue'],
            'milestone': mvp,
        },
        
        {
            'title': '[INFRA] Setup CI/CD GitHub Actions',
            'body': '''## Contexte
Automatiser build & tests.

## Critères d'acceptation
- [ ] Workflow .github/workflows/flutter-ci.yml
- [ ] Build auto sur push/PR
- [ ] Tests unitaires
- [ ] Analyze code
- [ ] Badge README

## Estimation
3 points (~6-8h)
''',
            'labels': ['feature', 'P1-high'],
            'milestone': mvp,
        },
        
        {
            'title': '[CORE] Service API client avec gestion erreurs',
            'body': '''## Contexte
Couche API pour backend Spring Boot.

## Critères d'acceptation
- [ ] ApiClient singleton Dio
- [ ] Gestion erreurs centralisée
- [ ] Interceptor logs
- [ ] JWT refresh auto
- [ ] Retry logic (connexion instable)
- [ ] Tests avec mocks

## Estimation
5 points (~16h)
''',
            'labels': ['feature', 'P0-critical', 'module:core'],
            'milestone': mvp,
        },
        
        {
            'title': '[CORE] Cache offline Hive',
            'body': '''## Contexte
Cache local pour mode offline.

## Critères d'acceptation
- [ ] Hive initialisé
- [ ] CacheService CRUD générique
- [ ] Cache-first pour données non-critiques
- [ ] Network-first pour temps-réel
- [ ] TTL configurable
- [ ] Tests invalidation

## Estimation
5 points (~16h)
''',
            'labels': ['feature', 'P0-critical', 'module:core'],
            'milestone': mvp,
        },
        
        # EPIC 2: AUTH
        {
            'title': '[AUTH] Écran Onboarding splash screen',
            'body': '''## Contexte
Premier écran avec 3 slides.

## Critères d'acceptation
- [ ] Splash OPUS 2s
- [ ] 3 slides PageView
- [ ] Skip après slide 1
- [ ] Flag Hive (affiche une fois)
- [ ] CTAs inscription/connexion
''' + design_ref,
            'labels': ['feature', 'P1-high', 'module:auth'],
            'milestone': mvp,
        },
        
        {
            'title': '[AUTH] Inscription validation téléphone',
            'body': '''## Contexte
Formulaire inscription téléphone.

## Critères d'acceptation
- [ ] Input numéro +225 auto
- [ ] Validation format
- [ ] Call API /auth/send-otp
- [ ] Loading state
- [ ] Gestion erreurs
- [ ] Navigation OTP
''' + design_ref,
            'labels': ['feature', 'P0-critical', 'module:auth'],
            'milestone': mvp,
        },
        
        {
            'title': '[AUTH] Vérification OTP stockage JWT',
            'body': '''## Contexte
Saisie OTP + stockage token.

## Critères d'acceptation
- [ ] 6 champs OTP auto-focus
- [ ] API /auth/verify-otp
- [ ] JWT dans FlutterSecureStorage
- [ ] Navigation profil/home
- [ ] Renvoyer code (cooldown 60s)
- [ ] Gestion erreurs
''' + design_ref,
            'labels': ['feature', 'P0-critical', 'module:auth'],
            'milestone': mvp,
        },
        
        # EPIC 3: PROFILS
        {
            'title': '[PROFILE] Completion profil onboarding',
            'body': '''## Contexte
Formulaire multi-étapes nouveau user.

## Critères d'acceptation
- [ ] Étape 1: Photo + Nom
- [ ] Étape 2: Compétences + Description
- [ ] Étape 3: Localisation GPS
- [ ] Stepper progression
- [ ] Sauvegarde auto draft
- [ ] POST /profiles
''' + design_ref,
            'labels': ['feature', 'P0-critical', 'module:profile'],
            'milestone': mvp,
        },
        
        {
            'title': '[PROFILE] Visualisation profil public',
            'body': '''## Contexte
Affichage profil vu par autres.

## Critères d'acceptation
- [ ] Photo + nom + rating
- [ ] Compétences tags
- [ ] Description
- [ ] Localisation carte
- [ ] Reviews (5 dernières)
- [ ] CTA contextuel
- [ ] Skeleton loading
''' + design_ref,
            'labels': ['feature', 'P1-high', 'module:profile'],
            'milestone': mvp,
        },
        
        # EPIC 4: GOMBOS
        {
            'title': '[GOMBO] Liste avec filtres géolocalisés',
            'body': '''## Contexte
Feed principal opportunités.

## Critères d'acceptation
- [ ] Liste pull-to-refresh
- [ ] Pagination infinie
- [ ] Filtres: Catégorie, Rayon, Budget, Date
- [ ] Tri: Distance, Budget, Date, Match
- [ ] Badge Nouveau <24h
- [ ] Empty state
''' + design_ref,
            'labels': ['feature', 'P0-critical', 'module:gombo'],
            'milestone': mvp,
        },
        
        {
            'title': '[GOMBO] Détail avec candidature',
            'body': '''## Contexte
Vue complète + postuler.

## Critères d'acceptation
- [ ] Header employeur
- [ ] Infos: Budget, Date, Localisation
- [ ] Description détaillée
- [ ] Compétences requises
- [ ] Bouton Postuler (si eligible)
- [ ] Modal confirmation
- [ ] POST /gombos/:id/applications
''' + design_ref,
            'labels': ['feature', 'P0-critical', 'module:gombo'],
            'milestone': mvp,
        },
        
        {
            'title': '[GOMBO] Création gombo employeurs',
            'body': '''## Contexte
Formulaire publication opportunité.

## Critères d'acceptation
- [ ] Champs: Titre, Description, Catégorie
- [ ] Compétences requises multi-select
- [ ] Budget input FCFA
- [ ] Localisation GPS/recherche
- [ ] Toggle Urgent
- [ ] Preview modal
- [ ] POST /gombos
- [ ] Validation client
''' + design_ref,
            'labels': ['feature', 'P1-high', 'module:gombo'],
            'milestone': mvp,
        },
        
        # EPIC 5: COMMERCES
        {
            'title': '[COMMERCE] Carte interactive clustering',
            'body': '''## Contexte
Map commerces autour utilisateur.

## Critères d'acceptation
- [ ] Google Maps centrée GPS
- [ ] Pins rayon 5km
- [ ] Clustering si >50 pins
- [ ] Tap pin → Bottom sheet
- [ ] Slider rayon 1-20km
- [ ] Filtres catégorie
- [ ] Bouton centrer
''' + design_ref,
            'labels': ['feature', 'P1-high', 'module:commerce'],
            'milestone': mvp,
        },
        
        {
            'title': '[COMMERCE] Détail navigation hybride',
            'body': '''## Contexte
Fiche commerce + navigation.

## Critères d'acceptation
- [ ] Photo carousel
- [ ] Nom, catégorie, rating, distance
- [ ] Comment y aller: GPS + description locale
- [ ] Horaires
- [ ] Contact (tel cliquable)
- [ ] Signaler erreur
- [ ] Google Maps waypoint
''' + design_ref,
            'labels': ['feature', 'P1-high', 'module:commerce'],
            'milestone': mvp,
        },
        
        # EPIC 6: CHAT
        {
            'title': '[CHAT] Liste conversations unread badges',
            'body': '''## Contexte
Inbox conversations actives.

## Critères d'acceptation
- [ ] Liste triée dernière activité
- [ ] Card: Avatar, nom, preview, timestamp
- [ ] Badge unread count
- [ ] Tap → Thread
- [ ] Swipe-to-delete
- [ ] Pull-to-refresh
- [ ] Empty state
''' + design_ref,
            'labels': ['feature', 'P1-high', 'module:chat'],
            'milestone': mvp,
        },
        
        {
            'title': '[CHAT] Thread envoi messages',
            'body': '''## Contexte
Chat 1-to-1 style WhatsApp.

## Critères d'acceptation
- [ ] Messages bulles (sent=droite, received=gauche)
- [ ] Timestamp groupé
- [ ] Input + send button
- [ ] "En train d'écrire..."
- [ ] Scroll auto dernier message
- [ ] Load more pagination
- [ ] Support images (Phase 2)
''' + design_ref,
            'labels': ['feature', 'P0-critical', 'module:chat'],
            'milestone': mvp,
        },
        
        {
            'title': '[NOTIF] Firebase Cloud Messaging',
            'body': '''## Contexte
Push notifications.

## Critères d'acceptation
- [ ] Firebase configuré
- [ ] Permissions handling
- [ ] Token FCM → backend
- [ ] Foreground: toast in-app
- [ ] Background: system notif
- [ ] Deep linking navigation
- [ ] Types: Gombo, Message, Candidature
''' + design_ref,
            'labels': ['feature', 'P1-high', 'module:notification'],
            'milestone': mvp,
        },
        
        # EPIC 7: PAIEMENTS
        {
            'title': '[PAYMENT] Sélection méthode',
            'body': '''## Contexte
Choix provider Mobile Money.

## Critères d'acceptation
- [ ] Liste: Orange Money, MTN, Wave
- [ ] Cards avec logos
- [ ] Sauvegarde préférence Hive
- [ ] Navigation paiement

## Estimation
3 points (~6-8h)
''',
            'labels': ['feature', 'P2-medium', 'module:payment'],
            'milestone': post_mvp,
        },
        
        {
            'title': '[PAYMENT] Flow Orange Money',
            'body': '''## Contexte
Intégration API Orange Money.

## Critères d'acceptation
- [ ] Recap: Montant, Frais, Total
- [ ] Input numéro validation
- [ ] POST /payments/initiate
- [ ] Instructions USSD
- [ ] Polling status (5s, 2min)
- [ ] Écran confirmation
- [ ] Retry si échec

## Estimation
8 points (~32h)
''',
            'labels': ['feature', 'P2-medium', 'module:payment'],
            'milestone': post_mvp,
        },
        
        # EPIC 8: RECHERCHE
        {
            'title': '[SEARCH] Recherche unifiée',
            'body': '''## Contexte
Search global multi-types.

## Critères d'acceptation
- [ ] Input debounce 300ms
- [ ] Recherche: Gombos, Profils, Commerces
- [ ] Groupes par type
- [ ] Filtres rapides
- [ ] Historique Hive
- [ ] Autocomplete API
- [ ] Empty state

## Estimation
8 points (~32h)
''',
            'labels': ['feature', 'P2-medium'],
            'milestone': post_mvp,
        },
    ]

def create_dev_issues(repo, milestones, design_issue, theme_issue, test_mode=False):
    """Crée les 20 issues de développement"""
    print("="*70)
    print("ÉTAPE 5/5 : Création Issues Développement")
    print("="*70 + "\n")
    
    issues_data = get_dev_issues_data(
        milestones,
        design_issue.number,
        theme_issue.number
    )
    
    if test_mode:
        print("MODE TEST: 3 issues seulement\n")
        issues_data = issues_data[:3]
    
    print(f"📝 {len(issues_data)} issues à créer\n")
    print("Continuer ? (y/n): ", end='')
    if input().lower() != 'y':
        print("❌ Annulé\n")
        return
    
    print()
    created = 0
    
    for i, data in enumerate(issues_data, 1):
        try:
            issue = repo.create_issue(
                title=data['title'],
                body=data['body'],
                labels=data.get('labels', []),
                milestone=data.get('milestone')
            )
            print(f"   ✅ [{i}/{len(issues_data)}] Issue #{issue.number}: {data['title'][:50]}...")
            created += 1
        except Exception as e:
            print(f"   ❌ [{i}/{len(issues_data)}] Erreur: {e}")
    
    print(f"\n📊 {created}/{len(issues_data)} issues créées\n")

# ============================================================================
# MAIN
# ============================================================================

def main():
    """Fonction principale"""
    
    parser = argparse.ArgumentParser(
        description='Setup complet projet OPUS Mobile sur GitHub'
    )
    parser.add_argument(
        '--test',
        action='store_true',
        help='Mode test (3 issues dev seulement)'
    )
    args = parser.parse_args()
    
    print("\n" + "="*70)
    print("🚀 OPUS MOBILE - SETUP COMPLET GITHUB")
    print("="*70 + "\n")
    
    if args.test:
        print("⚠️  MODE TEST ACTIVÉ (3 issues dev seulement)\n")
    
    # Validation & Connexion
    validate_config()
    g, repo = connect_github()
    
    # Étape 1: Labels
    create_labels(repo)
    
    # Étape 2: Milestones
    milestones = create_milestones(repo)
    
    # Étape 3: Design System
    design_issue = create_design_system_issue(repo)
    if not design_issue:
        print("❌ Échec création Design System")
        sys.exit(1)
    
    # Étape 4: Theme Setup
    theme_issue = create_theme_setup_issue(repo, design_issue.number)
    if not theme_issue:
        print("❌ Échec création Theme Setup")
        sys.exit(1)
    
    # Étape 5: Issues développement
    create_dev_issues(repo, milestones, design_issue, theme_issue, args.test)
    
    # Résumé
    print("="*70)
    print("✅ SETUP COMPLET TERMINÉ !")
    print("="*70)
    print(f"\n📌 Issues Clés:")
    print(f"   #{design_issue.number} - Charte Graphique")
    print(f"   #{theme_issue.number} - Theme Setup")
    print(f"\n🔗 {repo.html_url}/issues")
    print(f"\n💡 Prochaines étapes:")
    print(f"   1. Ajoute dossier design/ dans le repo")
    print(f"   2. Commence par issue #{theme_issue.number} (Theme)")
    print(f"   3. Puis développe les écrans UI\n")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Annulé (Ctrl+C)\n")
        sys.exit(0)
