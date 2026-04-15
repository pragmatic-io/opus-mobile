import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/core/theme/opus_text_styles.dart';
import 'package:opus_mobile/features/gombo/models/gombo_model.dart';

class GomboCard extends StatelessWidget {
  final GomboModel gombo;

  const GomboCard({super.key, required this.gombo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: OpusSpacing.md,
        vertical: OpusSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: OpusColors.blancChaux,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/gombos/${gombo.id}'),
        child: Padding(
          padding: const EdgeInsets.all(OpusSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: OpusSpacing.sm),
              _buildMeta(),
              const SizedBox(height: OpusSpacing.sm),
              _buildSkillsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EmployerAvatar(
          name: gombo.employerName,
          photoUrl: gombo.employerPhotoUrl,
        ),
        const SizedBox(width: OpusSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gombo.title,
                      style: OpusTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (gombo.isNew) ...[
                    const SizedBox(width: OpusSpacing.sm),
                    _NouveauBadge(),
                  ],
                ],
              ),
              const SizedBox(height: OpusSpacing.xs),
              Text(
                gombo.employerName,
                style: OpusTextStyles.caption.copyWith(
                  color: OpusColors.grisPoussiere,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeta() {
    final distanceText = gombo.distanceKm != null
        ? '${gombo.distanceKm!.toStringAsFixed(1)} km'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.work_outline,
              size: 14,
              color: OpusColors.grisPoussiere,
            ),
            const SizedBox(width: OpusSpacing.xs),
            Text(
              gombo.category,
              style: OpusTextStyles.caption,
            ),
            const SizedBox(width: OpusSpacing.sm),
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: OpusColors.grisPoussiere,
            ),
            const SizedBox(width: OpusSpacing.xs),
            Expanded(
              child: Text(
                distanceText != null
                    ? '${gombo.location} · $distanceText'
                    : gombo.location,
                style: OpusTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: OpusSpacing.xs),
        Row(
          children: [
            Text(
              NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0).format(gombo.budget),
              style: OpusTextStyles.body.copyWith(
                color: OpusColors.rougeEnseigne,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: OpusColors.grisPoussiere,
            ),
            const SizedBox(width: OpusSpacing.xs),
            Text(
              DateFormat('dd/MM/yyyy', 'fr_FR').format(gombo.date),
              style: OpusTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsRow() {
    if (gombo.skills.isEmpty) return const SizedBox.shrink();

    const maxVisible = 3;
    final visibleSkills = gombo.skills.take(maxVisible).toList();
    final overflow = gombo.skills.length - maxVisible;

    return Wrap(
      spacing: OpusSpacing.xs,
      runSpacing: OpusSpacing.xs,
      children: [
        ...visibleSkills.map((skill) => _SkillChip(label: skill)),
        if (overflow > 0)
          _SkillChip(
            label: '+$overflow',
            isOverflow: true,
          ),
      ],
    );
  }
}

class _EmployerAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const _EmployerAvatar({required this.name, this.photoUrl});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _buildInitialsAvatar(),
          placeholder: (context, url) => _buildInitialsAvatar(),
        ),
      );
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: OpusColors.indigoBache,
      ),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: OpusColors.blancChaux,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: OpusColors.jauneTaxi,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NOUVEAU',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final bool isOverflow;

  const _SkillChip({required this.label, this.isOverflow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OpusSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isOverflow
            ? OpusColors.grisPoussiere.withValues(alpha: 0.15)
            : OpusColors.indigoBache.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverflow
              ? OpusColors.grisPoussiere.withValues(alpha: 0.4)
              : OpusColors.indigoBache.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOverflow ? OpusColors.grisPoussiere : OpusColors.indigoBache,
        ),
      ),
    );
  }
}
