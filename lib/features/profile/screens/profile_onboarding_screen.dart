import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/core/theme/opus_text_styles.dart';
import 'package:opus_mobile/features/profile/models/profile_model.dart';
import 'package:opus_mobile/features/profile/services/profile_service.dart';

// ---------------------------------------------------------------------------
// Entry point widget
// ---------------------------------------------------------------------------

class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  State<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  static const int _totalSteps = 3;

  final PageController _pageController = PageController();
  int _currentStep = 0;

  // ── Step 1 state ──────────────────────────────────────────────────────────
  final _step1Key = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  File? _photo;

  // ── Step 2 state ──────────────────────────────────────────────────────────
  final _step2Key = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  final _skillInputCtrl = TextEditingController();
  final List<String> _skills = [];

  // ── Step 3 state ──────────────────────────────────────────────────────────
  final _step3Key = GlobalKey<FormState>();
  final _cityCtrl = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;

  // ── Submission ────────────────────────────────────────────────────────────
  bool _submitting = false;
  final ProfileService _profileService = ProfileService();

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
    _skillInputCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  Future<void> _goNext() async {
    final valid = switch (_currentStep) {
      0 => _step1Key.currentState?.validate() ?? false,
      1 => _validateStep2(),
      _ => _step3Key.currentState?.validate() ?? false,
    };

    if (!valid) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _submit();
    }
  }

  void _goPrev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateStep2() {
    final formValid = _step2Key.currentState?.validate() ?? false;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une compétence.'),
          backgroundColor: OpusColors.rougeEnseigne,
        ),
      );
      return false;
    }
    return formValid;
  }

  // ── Photo picker ──────────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _photo = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'accéder à la photo : $e')),
        );
      }
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: OpusColors.indigoBache),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: OpusColors.indigoBache),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Geolocator ────────────────────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La localisation est désactivée de façon permanente. '
                'Activez-la dans les réglages.',
              ),
              backgroundColor: OpusColors.rougeEnseigne,
            ),
          );
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission de localisation refusée.'),
              backgroundColor: OpusColors.rougeEnseigne,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de localisation : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  // ── Submission ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Validate step 3
    final hasLocation = _latitude != null && _longitude != null;
    final hasCity = _cityCtrl.text.trim().isNotEmpty;
    if (!hasLocation && !hasCity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez utiliser votre position GPS ou saisir une ville.'),
          backgroundColor: OpusColors.rougeEnseigne,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final profile = ProfileModel(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        skills: List.unmodifiable(_skills),
        latitude: _latitude,
        longitude: _longitude,
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      );

      await _profileService.createProfile(
        profile,
        localPhotoPath: _photo?.path,
      );

      if (mounted) context.go('/gombos');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création du profil : $e'),
            backgroundColor: OpusColors.rougeEnseigne,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpusColors.blancChaux,
      body: SafeArea(
        child: Column(
          children: [
            _TopStepper(currentStep: _currentStep, totalSteps: _totalSteps),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1PhotoName(
                    formKey: _step1Key,
                    photo: _photo,
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                    onPickPhoto: _showPhotoSourceSheet,
                  ),
                  _Step2SkillsBio(
                    formKey: _step2Key,
                    bioCtrl: _bioCtrl,
                    skillInputCtrl: _skillInputCtrl,
                    skills: _skills,
                    onAddSkill: () {
                      final skill = _skillInputCtrl.text.trim();
                      if (skill.isNotEmpty && !_skills.contains(skill)) {
                        setState(() {
                          _skills.add(skill);
                          _skillInputCtrl.clear();
                        });
                      }
                    },
                    onRemoveSkill: (s) => setState(() => _skills.remove(s)),
                  ),
                  _Step3Location(
                    formKey: _step3Key,
                    cityCtrl: _cityCtrl,
                    latitude: _latitude,
                    longitude: _longitude,
                    fetchingLocation: _fetchingLocation,
                    onFetchLocation: _fetchLocation,
                  ),
                ],
              ),
            ),
            _BottomNav(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              submitting: _submitting,
              onPrev: _goPrev,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top stepper
// ---------------------------------------------------------------------------

class _TopStepper extends StatelessWidget {
  const _TopStepper({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  static const _labels = ['Photo & Nom', 'Compétences', 'Localisation'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OpusColors.indigoBache,
      padding: const EdgeInsets.symmetric(
        horizontal: OpusSpacing.md,
        vertical: OpusSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(totalSteps, (i) {
              final isActive = i <= currentStep;
              final isLast = i == totalSteps - 1;
              return Expanded(
                child: Row(
                  children: [
                    // Circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? OpusColors.rougeEnseigne
                            : OpusColors.grisPoussiere,
                        border: Border.all(
                          color: isActive
                              ? OpusColors.rougeEnseigne
                              : OpusColors.grisPoussiere,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: i < currentStep
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    // Connector
                    if (!isLast)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 2,
                          color: i < currentStep
                              ? OpusColors.rougeEnseigne
                              : OpusColors.grisPoussiere,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: OpusSpacing.sm),
          Text(
            _labels[currentStep],
            style: OpusTextStyles.caption.copyWith(
              color: OpusColors.blancChaux,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation bar
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentStep,
    required this.totalSteps,
    required this.submitting,
    required this.onPrev,
    required this.onNext,
  });

  final int currentStep;
  final int totalSteps;
  final bool submitting;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(OpusSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            OutlinedButton(
              onPressed: submitting ? null : onPrev,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: OpusColors.indigoBache),
                foregroundColor: OpusColors.indigoBache,
                padding: const EdgeInsets.symmetric(
                  horizontal: OpusSpacing.lg,
                  vertical: OpusSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Précédent'),
            ),
            const SizedBox(width: OpusSpacing.md),
          ],
          Expanded(
            child: FilledButton(
              onPressed: submitting ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: OpusColors.rougeEnseigne,
                padding: const EdgeInsets.symmetric(vertical: OpusSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: submitting && isLast
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLast ? 'Terminer' : 'Suivant',
                      style: OpusTextStyles.button,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 – Photo & Name
// ---------------------------------------------------------------------------

class _Step1PhotoName extends StatelessWidget {
  const _Step1PhotoName({
    required this.formKey,
    required this.photo,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.onPickPhoto,
  });

  final GlobalKey<FormState> formKey;
  final File? photo;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OpusSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: OpusSpacing.md),
            Text('Qui êtes-vous ?', style: OpusTextStyles.h2),
            const SizedBox(height: OpusSpacing.xs),
            Text(
              'Ajoutez une photo et votre nom pour commencer.',
              style: OpusTextStyles.body
                  .copyWith(color: OpusColors.betonBrut, fontSize: 14),
            ),
            const SizedBox(height: OpusSpacing.xl),

            // Avatar
            Center(
              child: GestureDetector(
                onTap: onPickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: OpusColors.grisPoussiere,
                      backgroundImage:
                          photo != null ? FileImage(photo!) : null,
                      child: photo == null
                          ? const Icon(
                              Icons.person_outline,
                              size: 48,
                              color: OpusColors.indigoBache,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: OpusColors.rougeEnseigne,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OpusSpacing.xs),
            Center(
              child: Text(
                'Appuyez pour ajouter une photo',
                style: OpusTextStyles.caption,
              ),
            ),

            const SizedBox(height: OpusSpacing.xl),

            // First name
            _OpusTextField(
              controller: firstNameCtrl,
              label: 'Prénom',
              hint: 'Votre prénom',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le prénom est requis.' : null,
            ),
            const SizedBox(height: OpusSpacing.md),

            // Last name
            _OpusTextField(
              controller: lastNameCtrl,
              label: 'Nom',
              hint: 'Votre nom de famille',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le nom est requis.' : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 – Skills & Bio
// ---------------------------------------------------------------------------

class _Step2SkillsBio extends StatelessWidget {
  const _Step2SkillsBio({
    required this.formKey,
    required this.bioCtrl,
    required this.skillInputCtrl,
    required this.skills,
    required this.onAddSkill,
    required this.onRemoveSkill,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController bioCtrl;
  final TextEditingController skillInputCtrl;
  final List<String> skills;
  final VoidCallback onAddSkill;
  final void Function(String) onRemoveSkill;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OpusSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: OpusSpacing.md),
            Text('Vos compétences', style: OpusTextStyles.h2),
            const SizedBox(height: OpusSpacing.xs),
            Text(
              'Décrivez-vous et listez ce que vous savez faire.',
              style: OpusTextStyles.body
                  .copyWith(color: OpusColors.betonBrut, fontSize: 14),
            ),
            const SizedBox(height: OpusSpacing.xl),

            // Bio
            _OpusTextField(
              controller: bioCtrl,
              label: 'À propos de vous',
              hint: 'Décrivez votre parcours, vos expériences… (min. 50 caractères)',
              maxLines: 5,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'La description est requise.';
                }
                if (v.trim().length < 50) {
                  return 'Minimum 50 caractères (actuellement ${v.trim().length}).';
                }
                return null;
              },
            ),
            const SizedBox(height: OpusSpacing.xl),

            // Skills input
            Text('Compétences', style: OpusTextStyles.h3),
            const SizedBox(height: OpusSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: skillInputCtrl,
                    decoration: _inputDecoration('Ex : Plomberie, Peinture…'),
                    onFieldSubmitted: (_) => onAddSkill(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: OpusSpacing.sm),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: onAddSkill,
                    style: FilledButton.styleFrom(
                      backgroundColor: OpusColors.indigoBache,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ajouter'),
                  ),
                ),
              ],
            ),

            if (skills.isNotEmpty) ...[
              const SizedBox(height: OpusSpacing.md),
              Wrap(
                spacing: OpusSpacing.sm,
                runSpacing: OpusSpacing.sm,
                children: skills
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        labelStyle: OpusTextStyles.caption.copyWith(
                          color: OpusColors.indigoBache,
                          letterSpacing: 0,
                        ),
                        backgroundColor: OpusColors.blancChaux,
                        side: const BorderSide(color: OpusColors.indigoBache),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        deleteIconColor: OpusColors.rougeEnseigne,
                        onDeleted: () => onRemoveSkill(s),
                      ),
                    )
                    .toList(),
              ),
            ] else ...[
              const SizedBox(height: OpusSpacing.sm),
              Text(
                'Aucune compétence ajoutée.',
                style:
                    OpusTextStyles.caption.copyWith(color: OpusColors.betonBrut),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 – GPS Location
// ---------------------------------------------------------------------------

class _Step3Location extends StatelessWidget {
  const _Step3Location({
    required this.formKey,
    required this.cityCtrl,
    required this.latitude,
    required this.longitude,
    required this.fetchingLocation,
    required this.onFetchLocation,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cityCtrl;
  final double? latitude;
  final double? longitude;
  final bool fetchingLocation;
  final VoidCallback onFetchLocation;

  @override
  Widget build(BuildContext context) {
    final hasCoords = latitude != null && longitude != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OpusSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: OpusSpacing.md),
            Text('Votre localisation', style: OpusTextStyles.h2),
            const SizedBox(height: OpusSpacing.xs),
            Text(
              'Permettez aux clients près de vous de vous trouver.',
              style: OpusTextStyles.body
                  .copyWith(color: OpusColors.betonBrut, fontSize: 14),
            ),
            const SizedBox(height: OpusSpacing.xl),

            // GPS card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OpusSpacing.md),
              decoration: BoxDecoration(
                color: hasCoords
                    ? OpusColors.indigoBache.withAlpha(20)
                    : Colors.white,
                border: Border.all(
                  color: hasCoords
                      ? OpusColors.indigoBache
                      : OpusColors.grisPoussiere,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: hasCoords
                            ? OpusColors.indigoBache
                            : OpusColors.grisPoussiere,
                      ),
                      const SizedBox(width: OpusSpacing.sm),
                      Text(
                        hasCoords
                            ? 'Position récupérée'
                            : 'Position non récupérée',
                        style: OpusTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasCoords
                              ? OpusColors.indigoBache
                              : OpusColors.betonBrut,
                        ),
                      ),
                    ],
                  ),
                  if (hasCoords) ...[
                    const SizedBox(height: OpusSpacing.xs),
                    Text(
                      'Lat: ${latitude!.toStringAsFixed(5)}  '
                      'Lng: ${longitude!.toStringAsFixed(5)}',
                      style: OpusTextStyles.caption,
                    ),
                  ],
                  const SizedBox(height: OpusSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: fetchingLocation ? null : onFetchLocation,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: OpusColors.indigoBache),
                        foregroundColor: OpusColors.indigoBache,
                        padding: const EdgeInsets.symmetric(
                          vertical: OpusSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: fetchingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: OpusColors.indigoBache,
                              ),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(
                        fetchingLocation
                            ? 'Récupération en cours…'
                            : 'Utiliser ma position actuelle',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: OpusSpacing.xl),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OpusSpacing.sm),
                  child: Text(
                    'ou saisir manuellement',
                    style: OpusTextStyles.caption,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: OpusSpacing.lg),

            _OpusTextField(
              controller: cityCtrl,
              label: 'Ville',
              hint: 'Ex : Abidjan, Dakar, Paris…',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

InputDecoration _inputDecoration(String hint, {String? label}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: const TextStyle(color: OpusColors.grisPoussiere),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: OpusSpacing.md,
      vertical: OpusSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: OpusColors.grisPoussiere),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: OpusColors.grisPoussiere),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          const BorderSide(color: OpusColors.indigoBache, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          const BorderSide(color: OpusColors.rougeEnseigne, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          const BorderSide(color: OpusColors.rougeEnseigne, width: 2),
    ),
  );
}

class _OpusTextField extends StatelessWidget {
  const _OpusTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(hint, label: label),
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
