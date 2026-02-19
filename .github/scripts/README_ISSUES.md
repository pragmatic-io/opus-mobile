# Système de Création d'Issues OPUS Mobile

## 📁 Fichiers

```
opus-mobile-scripts/
├── .env                          # Configuration (TOKEN, REPO)
├── .env.example                  # Template configuration
├── opus_issues_data.py           # ⭐ DONNÉES: 20 issues définies
├── create_opus_issues_final.py   # Script principal
├── delete_opus_issues.py         # Script suppression
└── README.md                     # Ce fichier
```

## 🚀 Quick Start

### 1. Configuration (une fois)

```bash
# Copier template
cp .env.example .env

# Éditer .env avec tes valeurs
nano .env
```

Contenu `.env`:
```bash
GITHUB_TOKEN=ghp_ton_token_ici
GITHUB_REPO=pragmatic-io/opus-mobile
```

### 2. Créer TOUTES les issues

```bash
python3 create_opus_issues_final.py --all
```

### 3. Créer SEULEMENT issues MVP

```bash
python3 create_opus_issues_final.py --mvp-only
```

### 4. Mode test (3 issues)

```bash
python3 create_opus_issues_final.py --test
```

---

## 📊 Statistiques Issues

Execute `opus_issues_data.py` directement pour voir les stats:

```bash
python3 opus_issues_data.py
```

Output:
```
📊 Statistiques Issues OPUS Mobile

Total issues: 20
MVP (P0/P1): 15
Post-MVP (P2/P3): 5

Estimation totale: ~320 heures

Repartition par Epic:
  - Fondations: 4 issues
  - Auth: 3 issues
  - Profils: 2 issues
  - Gombos: 3 issues
  - Commerces: 2 issues
  - Chat & Notifs: 3 issues
  - Paiements: 2 issues
  - Recherche: 1 issue
```

---

## 📝 Détail des Issues

### EPIC 1: Fondations & Infrastructure (4 issues)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 1 | [INFRA] Initialiser projet Flutter | P0 | 3 |
| 2 | [INFRA] Setup CI/CD GitHub Actions | P1 | 3 |
| 3 | [CORE] Service API client | P0 | 5 |
| 4 | [CORE] Cache offline Hive | P0 | 5 |

### EPIC 2: Authentification (3 issues)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 5 | [AUTH] Onboarding + splash | P1 | 2 |
| 6 | [AUTH] Inscription téléphone | P0 | 5 |
| 7 | [AUTH] Vérification OTP + JWT | P0 | 5 |

### EPIC 3: Profils (2 issues)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 8 | [PROFILE] Completion profil onboarding | P0 | 8 |
| 9 | [PROFILE] Visualisation profil public | P1 | 5 |

### EPIC 4: Gombos (3 issues)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 10 | [GOMBO] Liste avec filtres géolocalisés | P0 | 8 |
| 11 | [GOMBO] Détail + candidature | P0 | 5 |
| 12 | [GOMBO] Création gombo employeurs | P1 | 8 |

### EPIC 5: Commerces (2 issues)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 13 | [COMMERCE] Carte interactive clustering | P1 | 8 |
| 14 | [COMMERCE] Détail + navigation hybride | P1 | 5 |

### EPIC 6: Chat & Notifications (3 issues)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 15 | [CHAT] Liste conversations + badges | P1 | 5 |
| 16 | [CHAT] Thread + envoi messages | P0 | 8 |
| 17 | [NOTIF] Firebase Cloud Messaging | P1 | 5 |

### EPIC 7: Paiements (2 issues)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 18 | [PAYMENT] Sélection méthode | P2 | 3 |
| 19 | [PAYMENT] Flow Orange Money | P2 | 8 |

### EPIC 8: Recherche (1 issue)

| # | Titre | Priorité | Points |
|---|-------|----------|--------|
| 20 | [SEARCH] Recherche unifiée | P2 | 8 |

---

## 🎨 Modifier les Issues

### Ajouter une nouvelle issue

Édite `opus_issues_data.py` et ajoute dans la liste `return [...]`:

```python
{
    'title': '[MODULE] Titre de ta nouvelle issue',
    'body': '''## Contexte
Description...

## Criteres d'acceptation
- [ ] Critère 1
- [ ] Critère 2

## Estimation
X points
''',
    'labels': ['feature', 'P1-high', 'module:nom'],
    'milestone': mvp_milestone,  # ou post_mvp_milestone
},
```

### Modifier une issue existante

1. Trouve l'issue dans `opus_issues_data.py`
2. Modifie le contenu (titre, body, labels, etc.)
3. Relance le script (il skippe les issues existantes par titre)

### Supprimer une issue de la création

Commente l'issue dans `opus_issues_data.py`:

```python
# {
#     'title': '[MODULE] Issue à ne pas créer',
#     ...
# },
```

---

## 🗑️ Supprimer les Issues Créées

```bash
python3 delete_opus_issues.py
```

Menu interactif:
1. Fermer toutes les issues
2. Réouvrir les issues fermées
3. Supprimer labels personnalisés
4. Supprimer milestones
5. Nettoyage complet
6. Quitter

---

## 🔧 Fonctions Helper Disponibles

Dans `opus_issues_data.py`:

### Obtenir seulement issues MVP

```python
from opus_issues_data import get_mvp_issues_only

mvp_issues = get_mvp_issues_only(milestones)
# Retourne seulement P0-critical + P1-high
```

### Obtenir issues par module

```python
from opus_issues_data import get_issues_by_module

auth_issues = get_issues_by_module(milestones, 'auth')
gombo_issues = get_issues_by_module(milestones, 'gombo')
# etc.
```

### Obtenir statistiques

```python
from opus_issues_data import get_issues_stats

stats = get_issues_stats()
print(stats['total'])        # 20
print(stats['mvp'])          # 15
print(stats['by_epic'])      # Dict par Epic
```

---

## 🎯 Workflows Recommandés

### Workflow 1: Première création

```bash
# 1. Test avec 3 issues
python3 create_opus_issues_final.py --test

# 2. Vérifier sur GitHub
# https://github.com/ton-user/opus-mobile/issues

# 3. Si OK, créer tout
python3 delete_opus_issues.py  # Choix 1 (fermer test)
python3 create_opus_issues_final.py --all
```

### Workflow 2: Développement par phases

```bash
# Phase 1: MVP seulement
python3 create_opus_issues_final.py --mvp-only

# ... 6 mois plus tard ...

# Phase 2: Post-MVP
# Les issues Post-MVP seront créées automatiquement
# si tu relances --all (skip celles qui existent)
python3 create_opus_issues_final.py --all
```

### Workflow 3: Reset complet

```bash
# Nettoyer tout
python3 delete_opus_issues.py
# Choix: 5 (Nettoyage complet)
# Confirmation: OUI TOUT NETTOYER

# Recréer
python3 create_opus_issues_final.py --all
```

---

## ⚙️ Options Avancées

### Mode silencieux (sans confirmation)

Édite `create_opus_issues_final.py` et modifie la fonction `create_issues`:

```python
# Ligne ~180, commente:
# print("Continuer ? (y/n): ", end='')
# if input().lower() != 'y':
#     print("❌ Annulé\n")
#     return
```

### Créer issues dans un ordre spécifique

Dans `opus_issues_data.py`, réorganise l'ordre dans la liste `return [...]`.

Le script crée dans l'ordre de la liste.

---

## 🐛 Dépannage

### "Module opus_issues_data not found"

→ Assure-toi que `opus_issues_data.py` est dans le même dossier que `create_opus_issues_final.py`

### Les issues se créent en double

→ Le script vérifie par titre. Si le titre a changé, il crée un doublon.  
→ Solution: Ferme manuellement les doublons sur GitHub

### Erreur "Permission denied"

→ Token GitHub n'a pas scope `repo` complet  
→ Régénère token avec toutes les permissions `repo`

### Encodage UTF-8 errors

→ Le script gère déjà UTF-8  
→ Si persiste: `PYTHONIOENCODING=utf-8 python3 create_opus_issues_final.py`

---

## 📚 Ressources

- **GitHub API Docs**: https://docs.github.com/en/rest
- **PyGithub Docs**: https://pygithub.readthedocs.io
- **OPUS Business Plan**: `OPUS_Business_Plan_v1.0.md`

---

## ✨ Améliorations Futures

- [ ] Export issues en Markdown/CSV
- [ ] Import issues depuis CSV
- [ ] Sync bidirectionnel GitHub ↔ Fichier
- [ ] Templates customisables
- [ ] Assignation automatique issues
- [ ] Création Projects boards

---

**Questions ? Consulte ce README ou ouvre une issue ! 🚀**
