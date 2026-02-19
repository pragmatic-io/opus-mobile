# OPUS Mobile - Charte Graphique Finale v3.0
## "Béton & Latérite" - L'Afrique Urbaine Informelle

---

## 🎨 CONCEPT & PHILOSOPHIE

### Vision
OPUS capture l'**authenticité brute de l'économie informelle urbaine** d'Afrique de l'Ouest. 
Notre design s'inspire directement des éléments visuels qu'on voit en marchant dans les 
quartiers populaires d'Abidjan, Dakar ou Lagos.

### Inspirations Concrètes

**🪧 Enseignes Peintes à la Main**
Les boutiques informelles affichent leurs services avec des lettres **rouge vif** peintes 
au pinceau sur murs blancs. C'est notre couleur signature.

**🛖 Bâches Bleues des Marchés**
Les stands de marché protégés par des toiles **indigo délavées**. Cette couleur 
représente la structure informelle mais organisée.

**🚕 Taxis Wôrô-Wôrô**
Les taxis communaux **jaune-orange** qui incarnent la mobilité et l'opportunité urbaine.

**🏗️ Béton Brut** 
Les constructions inachevées, **murs en ciment gris** omniprésents dans les quartiers 
en développement.

**🏜️ Poussière de Latérite**
La terre **rouge-ocre** des rues non-pavées, cette couleur qu'on retrouve partout.

---

## 🌈 PALETTE DE COULEURS COMPLÈTE

### Couleurs Primaires

```css
/* 🪧 ROUGE ENSEIGNE - Couleur Signature */
--rouge-enseigne: #E63946;
--rgb-rouge: 230, 57, 70;

Usage: CTAs principaux, actions urgentes, badges importants
Gradient: linear-gradient(135deg, #E63946 0%, #A8402F 100%);
Symbolique: Énergie des enseignes peintes, urgence constructive
```

```css
/* 🛖 INDIGO BÂCHE - Structure */
--indigo-bache: #1D3557;
--rgb-indigo: 29, 53, 87;

Usage: Headers, navigation, éléments structurels
Gradient: linear-gradient(135deg, #1D3557 0%, #457B9D 100%);
Symbolique: Bâches des marchés, structure informelle
```

```css
/* 🚕 JAUNE TAXI - Opportunité */
--jaune-taxi: #F4A261;
--rgb-jaune: 244, 162, 97;

Usage: Badges "Nouveau", highlights, pricing
Gradient: linear-gradient(135deg, #F4A261 0%, #E76F51 100%);
Symbolique: Mobilité urbaine, opportunités, optimisme
```

```css
/* 🏜️ OCRE LATÉRITE - Chaleur */
--ocre-laterite: #E76F51;
--rgb-ocre: 231, 111, 81;

Usage: Accents secondaires, illustrations, éléments chaleureux
Symbolique: Terre rouge africaine, poussière omniprésente
```

### Couleurs Secondaires

```css
--beton-brut: #6C757D;      /* Constructions, fond industriel */
--gris-asphalte: #495057;   /* Routes, textes foncés */
--bleu-bache: #457B9D;      /* Version claire Indigo */
--terre-rouge: #A8402F;     /* Version foncée Latérite */
```

### Couleurs Neutres

```css
--noir-goudron: #212529;    /* Titres, textes principaux */
--gris-mur: #343A40;        /* Textes secondaires */
--gris-poussiere: #ADB5BD;  /* Labels, timestamps */
--blanc-chaux: #F8F9FA;     /* Backgrounds */
--blanc-pur: #FFFFFF;       /* Cards, modals */
```

### Couleurs Sémantiques

```css
--success: #10B981;   /* Vert émeraude */
--warning: #F4A261;   /* Utilise Jaune Taxi */
--error: #EF4444;     /* Rouge vif */
--info: #457B9D;      /* Utilise Bleu Bâche */
```

---

## 📝 TYPOGRAPHIE

### Police Principale: Inter

**Pourquoi Inter ?**
- Lisibilité parfaite sur mobile
- Graisse variable (100-900)
- Support français complet
- Open source (Google Fonts)
- Rendering optimal 12-72px

### Hiérarchie

```css
/* H1 - Titres de Pages */
font-family: Inter;
font-weight: 800 (ExtraBold);
font-size: 32px;
line-height: 38px;
letter-spacing: -0.5px;
color: #212529;

/* H2 - Sections */
font-weight: 800;
font-size: 19px;
line-height: 24px;
letter-spacing: -0.3px;
color: #212529;

/* H3 - Cards Titles */
font-weight: 700 (Bold);
font-size: 17px;
line-height: 22px;
color: #212529;

/* Body Regular */
font-weight: 500 (Medium);
font-size: 15-16px;
line-height: 24px;
color: #343A40;

/* Body Small */
font-weight: 500;
font-size: 14px;
line-height: 20px;
color: #495057;

/* Caption/Labels */
font-weight: 600-700;
font-size: 11-12px;
line-height: 16px;
letter-spacing: 0.5px;
text-transform: uppercase (parfois);
color: #6C757D;

/* Button Text */
font-weight: 700-800;
font-size: 17-18px;
letter-spacing: -0.3px;
color: #FFFFFF;
```

**Principe:** Contrastes forts (800 pour titres, 500 pour body) = 
hiérarchie très claire, lisible outdoor.

---

## 🔲 COMPOSANTS UI

### Boutons

#### Primary CTA (Rouge Enseigne)
```css
background: linear-gradient(135deg, #E63946 0%, #A8402F 100%);
color: #FFFFFF;
padding: 18px 24px;
border-radius: 14-16px;
font-weight: 800;
font-size: 18px;
letter-spacing: -0.3px;
box-shadow: 0 8px 20px rgba(230, 57, 70, 0.3);
border: none;

/* Hover */
transform: translateY(-2px);
box-shadow: 0 10px 24px rgba(230, 57, 70, 0.4);

/* Active */
transform: translateY(0);
```

#### Secondary Button (Indigo)
```css
background: linear-gradient(135deg, #1D3557 0%, #457B9D 100%);
/* Reste identique au Primary */
```

#### Ghost Button
```css
background: transparent;
color: #E63946;
border: 2px solid #E63946;
padding: 16px 22px;

/* Hover */
background: rgba(230, 57, 70, 0.05);
```

---

### Cards

#### Standard Card (Gombo, Commerce, etc.)
```css
background: #FFFFFF;
border-radius: 14-16px;
padding: 18px;
box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
border: 2px solid #F8F9FA;
border-left: 4px solid #E2E8F0; /* Ou couleur sémantique */

/* Hover */
transform: translateX(4px); /* Slide légèrement vers droite */
box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
```

**Variantes Border-Left:**
- Urgent: `#E63946` (Rouge)
- Nouveau: `#F4A261` (Jaune)
- Vérifié: `#F4A261` (Jaune Or)
- Normal: `#E2E8F0` (Gris clair)

---

### Badges

```css
/* Badge Urgent */
background: #E63946;
color: #FFFFFF;
padding: 5px 10px;
border-radius: 6px;
font-size: 10px;
font-weight: 700;
text-transform: uppercase;
letter-spacing: 0.5px;

/* Badge Nouveau */
background: #F4A261;
color: #FFFFFF;

/* Badge Vérifié */
background: linear-gradient(135deg, #FFF8E1 0%, #FFE0B2 100%);
color: #E76F51;
border: 2px solid #F4A261;
```

---

### Input Fields

```css
background: rgba(255, 255, 255, 0.15); /* Si sur fond coloré */
background: #F8F9FA; /* Si sur fond blanc */
border: 2px solid #E2E8F0;
border-radius: 14px;
padding: 14px 16px;
font-size: 15px;
font-weight: 500;
color: #212529;

/* Placeholder */
color: rgba(0, 0, 0, 0.4);

/* Focus */
border-color: #E63946;
background: #FFFFFF;
outline: none;

/* Error */
border-color: #EF4444;

/* Success */
border-color: #10B981;
```

---

## 📐 GRILLE & SPACING

### Système 4px

```
4px   → xs
8px   → sm
12px  → md
16px  → lg (Default)
20px  → xl
24px  → 2xl
32px  → 3xl
40px  → 4xl
48px  → 5xl
```

**Règle:** Tous les spacing/padding/margin doivent être multiples de 4px.

### Mobile Grid

- Base width: 375px (iPhone SE)
- Content margins: 20px (left/right)
- Content width: 335px
- Card spacing: 12-14px
- Section spacing: 20-28px

---

## 🎨 DÉGRADÉS SIGNATURE

### 1. Enseigne Vibrante (CTAs Rouges)
```css
linear-gradient(135deg, #E63946 0%, #A8402F 100%);
```

### 2. Nuit Urbaine (Headers Indigo)
```css
linear-gradient(135deg, #1D3557 0%, #457B9D 100%);
```

### 3. Coucher Soleil (Badges Premium)
```css
linear-gradient(135deg, #F4A261 0%, #E76F51 100%);
```

### 4. Béton Urbain (Backgrounds Sombres)
```css
linear-gradient(135deg, #495057 0%, #212529 100%);
```

---

## 🖼️ ICONOGRAPHIE

### Style
- **Source:** Lucide Icons (lucide.dev)
- **Type:** Outlined (ligne)
- **Stroke width:** 2px
- **Tailles:** 20px, 24px, 32px
- **Couleur défaut:** #343A40

### Icons OPUS
```
🏠 Home
💼 Gombos (Briefcase)
🏪 Commerces (Store)
💬 Chat (MessageCircle)
👤 Profil (User)
📍 Location (MapPin)
⭐ Rating (Star)
🔔 Notifications (Bell)
⚙️ Settings (Settings)
🔍 Search (Search)
```

---

## 📱 PRINCIPES MOBILE-FIRST

### 1. Touch Targets
- **Minimum:** 44x44px (WCAG)
- **Recommandé:** 48px hauteur boutons
- **Spacing:** 8px minimum entre éléments tapables

### 2. Contraste (Outdoor Africa)
- **Ratio minimum:** 4.5:1 (AA)
- **Préféré:** 7:1 (AAA)
- **Test:** Textes lisibles en plein soleil

### 3. Hiérarchie Visuelle Claire
```
1. CTAs Rouges (gradient) → Action principale
2. Titres Bold 800 → Structure
3. Border-left colorés → Catégorisation
4. Texte 500 Medium → Contenu
5. Labels 600-700 Uppercase → Metadata
```

### 4. Headers Immersifs
```css
/* Header avec gradient + texture béton */
background: linear-gradient(135deg, #1D3557 0%, #457B9D 100%);
position: relative;

/* Texture subtile (optionnelle) */
&::before {
  content: '';
  opacity: 0.05;
  background-image: repeating-linear-gradient(...);
}
```

### 5. Bottom Navigation
```css
height: 56px + 24px safe area;
background: #FFFFFF;
border-top: 2px solid #F8F9FA;
box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.08);

/* Active state */
color: #E63946;

/* Inactive */
color: #ADB5BD;
```

---

## 🌍 OPTIMISATIONS AFRIQUE

### 1. Performance (Data-Conscious)
```
- Images: WebP < 100KB
- Icons: SVG inline
- Fonts: Inter subset (Latin + French)
- Total assets/screen: < 200KB
```

### 2. Offline States
```css
/* Badge Hors Ligne */
background: #FFF8E1;
color: #F4A261;
border: 2px solid #F4A261;

/* Contenu Cached */
opacity: 0.75;
border: 2px dashed #E2E8F0;
```

### 3. Skeleton Loading
```css
background: linear-gradient(
  90deg,
  #F8F9FA 25%,
  #E2E8F0 50%,
  #F8F9FA 75%
);
animation: shimmer 2s infinite;
```

---

## ✅ CHECKLIST DESIGN

Avant de valider un écran:

**Visuel**
- [ ] Contraste texte/bg ≥ 4.5:1
- [ ] Touch targets ≥ 44px
- [ ] Spacing multiples de 4px
- [ ] Border-radius cohérents (14-16px cards, 20-24px modals)

**Interactions**
- [ ] États hover définis
- [ ] États active définis
- [ ] États disabled (opacity 0.5)
- [ ] Loading states (skeleton)

**Contenus**
- [ ] Error states avec messages clairs
- [ ] Empty states avec illustrations
- [ ] Success states avec feedback visuel

**Performance**
- [ ] Assets optimisés < 200KB
- [ ] Textes accessibles (labels)
- [ ] Testé iPhone SE (375px min)

---

## 🚀 EXPORT FLUTTER

### colors.dart

```dart
import 'package:flutter/material.dart';

class OpusColors {
  // Primary
  static const rougeEnseigne = Color(0xFFE63946);
  static const indigoBache = Color(0xFF1D3557);
  static const jauneTaxi = Color(0xFFF4A261);
  static const ocreLaterite = Color(0xFFE76F51);
  
  // Secondary
  static const betonBrut = Color(0xFF6C757D);
  static const grisAsphalte = Color(0xFF495057);
  static const bleuBache = Color(0xFF457B9D);
  static const terreRouge = Color(0xFFA8402F);
  
  // Neutrals
  static const noirGoudron = Color(0xFF212529);
  static const grisMur = Color(0xFF343A40);
  static const grisPoussiere = Color(0xFFADB5BD);
  static const blancChaux = Color(0xFFF8F9FA);
  
  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF4A261);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF457B9D);
  
  // Gradients
  static const enseigneGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rougeEnseigne, terreRouge],
  );
  
  static const nuitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigoBache, bleuBache],
  );
}
```

---

## 📚 ASSETS NÉCESSAIRES

### Logo OPUS
- **Format:** SVG + PNG (1024x1024)
- **Couleurs:** Monochrome adaptable ou Rouge/Indigo
- **Style:** Bold, géométrique, motifs africains subtils

### Illustrations
- **Source:** unDraw.co ou Humaaans
- **Customisation:** Couleur primaire → #E63946
- **Style:** Flat, diversifié, urbain

### Photos/Textures
- Murs en béton (backgrounds optionnels)
- Enseignes peintes (inspiration)
- Marchés urbains (about/marketing)

---

**Version:** 3.0 - Finale "Béton & Latérite"  
**Date:** Février 2025  
**Auteur:** OPUS Design Team  
**Licence:** Propriétaire OPUS
