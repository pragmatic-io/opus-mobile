import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/core/theme/opus_text_styles.dart';
import 'package:opus_mobile/features/gombo/models/gombo_model.dart';
import 'package:opus_mobile/features/gombo/services/gombo_service.dart';

class GomboDetailScreen extends StatefulWidget {
  final String id;

  const GomboDetailScreen({super.key, required this.id});

  @override
  State<GomboDetailScreen> createState() => _GomboDetailScreenState();
}

class _GomboDetailScreenState extends State<GomboDetailScreen> {
  final GomboService _service = GomboService();

  GomboModel? _gombo;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  bool _hasApplied = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _loadGombo();
  }

  Future<void> _loadGombo() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final gombo = await _service.getGomboById(widget.id);
      if (!mounted) return;
      setState(() {
        _gombo = gombo;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _confirmApply() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Confirmer la candidature',
          style: OpusTextStyles.h3,
        ),
        content: Text(
          'Voulez-vous postuler à ce gombo ?',
          style: OpusTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Annuler',
              style: OpusTextStyles.body.copyWith(
                color: OpusColors.grisPoussiere,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Confirmer',
              style: OpusTextStyles.body.copyWith(
                color: OpusColors.rougeEnseigne,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isApplying = true);

    try {
      await _service.applyToGombo(widget.id);
      if (!mounted) return;
      setState(() {
        _hasApplied = true;
        _isApplying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Candidature envoyée !'),
          backgroundColor: OpusColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isApplying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la candidature : ${e.toString()}',
          ),
          backgroundColor: OpusColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpusColors.blancChaux,
      appBar: AppBar(
        backgroundColor: OpusColors.indigoBache,
        foregroundColor: OpusColors.blancChaux,
        elevation: 0,
        title: Text(
          'Détail du gombo',
          style: OpusTextStyles.h3.copyWith(color: OpusColors.blancChaux),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: OpusColors.rougeEnseigne),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(OpusSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: OpusColors.grisPoussiere,
              ),
              const SizedBox(height: OpusSpacing.md),
              Text(
                'Impossible de charger ce gombo',
                style: OpusTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OpusSpacing.sm),
              Text(
                _errorMessage ?? '',
                style: OpusTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OpusSpacing.lg),
              ElevatedButton(
                onPressed: _loadGombo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpusColors.rougeEnseigne,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final gombo = _gombo!;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(gombo),
          _buildInfoCards(gombo),
          _buildDescriptionSection(gombo),
          _buildSkillsSection(gombo),
        ],
      ),
    );
  }

  Widget _buildHeroSection(GomboModel gombo) {
    return Container(
      color: OpusColors.indigoBache,
      padding: const EdgeInsets.fromLTRB(
        OpusSpacing.lg,
        OpusSpacing.lg,
        OpusSpacing.lg,
        OpusSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildEmployerAvatar(gombo),
              const SizedBox(width: OpusSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gombo.employerName,
                      style: OpusTextStyles.body.copyWith(
                        color: OpusColors.blancChaux.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      gombo.title,
                      style: OpusTextStyles.h2.copyWith(
                        color: OpusColors.blancChaux,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: OpusSpacing.md),
          _CategoryBadge(category: gombo.category),
          if (gombo.isNew) ...[
            const SizedBox(height: OpusSpacing.sm),
            _NouveauBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployerAvatar(GomboModel gombo) {
    final initials = _initials(gombo.employerName);

    if (gombo.employerPhotoUrl != null && gombo.employerPhotoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: gombo.employerPhotoUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _initialsAvatar(initials),
          placeholder: (context, url) => _initialsAvatar(initials),
        ),
      );
    }
    return _initialsAvatar(initials);
  }

  Widget _initialsAvatar(String initials) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: OpusColors.ocreLaterite.withValues(alpha: 0.8),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildInfoCards(GomboModel gombo) {
    return Padding(
      padding: const EdgeInsets.all(OpusSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _InfoCard(
              icon: Icons.payments_outlined,
              label: 'Budget',
              value: NumberFormat.currency(
                locale: 'fr_FR',
                symbol: 'FCFA',
                decimalDigits: 0,
              ).format(gombo.budget),
              valueColor: OpusColors.rougeEnseigne,
              valueBold: true,
            ),
          ),
          const SizedBox(width: OpusSpacing.sm),
          Expanded(
            child: _InfoCard(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: DateFormat('dd MMM yyyy', 'fr_FR').format(gombo.date),
            ),
          ),
          const SizedBox(width: OpusSpacing.sm),
          Expanded(
            child: _InfoCard(
              icon: Icons.location_on_outlined,
              label: 'Lieu',
              value: gombo.location,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(GomboModel gombo) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OpusSpacing.lg,
        vertical: OpusSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: OpusTextStyles.h3.copyWith(color: OpusColors.indigoBache),
          ),
          const SizedBox(height: OpusSpacing.sm),
          Text(
            gombo.description,
            style: OpusTextStyles.body.copyWith(
              color: OpusColors.noirGoudron,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(GomboModel gombo) {
    if (gombo.skills.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OpusSpacing.lg,
        OpusSpacing.lg,
        OpusSpacing.lg,
        OpusSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compétences requises',
            style: OpusTextStyles.h3.copyWith(color: OpusColors.indigoBache),
          ),
          const SizedBox(height: OpusSpacing.sm),
          Wrap(
            spacing: OpusSpacing.sm,
            runSpacing: OpusSpacing.sm,
            children: gombo.skills
                .map(
                  (skill) => Chip(
                    label: Text(
                      skill,
                      style: OpusTextStyles.caption.copyWith(
                        color: OpusColors.indigoBache,
                      ),
                    ),
                    backgroundColor: OpusColors.indigoBache.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: OpusColors.indigoBache.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: OpusSpacing.sm,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomBar() {
    if (_isLoading || _hasError || _gombo == null) return null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        OpusSpacing.lg,
        OpusSpacing.md,
        OpusSpacing.lg,
        MediaQuery.of(context).padding.bottom + OpusSpacing.md,
      ),
      decoration: BoxDecoration(
        color: OpusColors.blancChaux,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: _hasApplied
            ? ElevatedButton.icon(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpusColors.success,
                  disabledBackgroundColor: OpusColors.success,
                  padding: const EdgeInsets.symmetric(vertical: OpusSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  'Candidature envoyée',
                  style: OpusTextStyles.button,
                ),
              )
            : ElevatedButton(
                onPressed: _isApplying ? null : _confirmApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpusColors.rougeEnseigne,
                  disabledBackgroundColor: OpusColors.rougeEnseigne.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: OpusSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isApplying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Postuler', style: OpusTextStyles.button),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OpusSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: OpusColors.ocreLaterite.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NouveauBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OpusSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: OpusColors.jauneTaxi,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NOUVEAU',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OpusSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: OpusColors.grisPoussiere.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: OpusColors.grisPoussiere),
          const SizedBox(height: OpusSpacing.xs),
          Text(
            label,
            style: OpusTextStyles.caption.copyWith(
              color: OpusColors.grisPoussiere,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: OpusTextStyles.caption.copyWith(
              color: valueColor ?? OpusColors.noirGoudron,
              fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
