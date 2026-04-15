import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/core/theme/opus_text_styles.dart';
import 'package:opus_mobile/features/gombo/models/gombo_model.dart';
import 'package:opus_mobile/features/gombo/services/gombo_service.dart';
import 'package:opus_mobile/features/gombo/widgets/gombo_card.dart';

const List<String> _kCategories = [
  'Plomberie',
  'Electricité',
  'Maçonnerie',
  'Jardinage',
  'Peinture',
  'Autre',
];

const List<String> _kSortOptions = ['Distance', 'Budget', 'Date', 'Match'];

const Map<String, String> _kSortValues = {
  'Distance': 'distance',
  'Budget': 'budget',
  'Date': 'date',
  'Match': 'match',
};

class GomboListScreen extends StatefulWidget {
  const GomboListScreen({super.key});

  @override
  State<GomboListScreen> createState() => _GomboListScreenState();
}

class _GomboListScreenState extends State<GomboListScreen> {
  final GomboService _service = GomboService();
  final ScrollController _scrollController = ScrollController();

  // State
  List<GomboModel> _gombos = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _hasReachedEnd = false;
  int _currentPage = 1;

  // Filters
  String? _selectedCategory;
  double _radius = 25.0;
  double? _minBudget;
  double? _maxBudget;
  String _selectedSort = 'Distance';

  // Temp filters (modal draft before applying)
  String? _draftCategory;
  double _draftRadius = 25.0;
  double? _draftMinBudget;
  double? _draftMaxBudget;
  String _draftSort = 'Distance';

  final TextEditingController _minBudgetCtrl = TextEditingController();
  final TextEditingController _maxBudgetCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGombos(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && !_hasReachedEnd && !_isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadGombos({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 1;
        _hasReachedEnd = false;
      });
    }

    try {
      final results = await _service.getGombos(
        page: 1,
        limit: 20,
        category: _selectedCategory,
        maxRadiusKm: _radius,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        sort: _kSortValues[_selectedSort] ?? 'distance',
      );

      if (!mounted) return;
      setState(() {
        _gombos = results;
        _isLoading = false;
        _currentPage = 1;
        _hasReachedEnd = results.length < 20;
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

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    try {
      final results = await _service.getGombos(
        page: nextPage,
        limit: 20,
        category: _selectedCategory,
        maxRadiusKm: _radius,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        sort: _kSortValues[_selectedSort] ?? 'distance',
      );

      if (!mounted) return;
      setState(() {
        _gombos = [..._gombos, ...results];
        _currentPage = nextPage;
        _isLoadingMore = false;
        _hasReachedEnd = results.length < 20;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _openFilters() {
    // Copy current filters into draft
    _draftCategory = _selectedCategory;
    _draftRadius = _radius;
    _draftMinBudget = _minBudget;
    _draftMaxBudget = _maxBudget;
    _draftSort = _selectedSort;
    _minBudgetCtrl.text = _minBudget?.toStringAsFixed(0) ?? '';
    _maxBudgetCtrl.text = _maxBudget?.toStringAsFixed(0) ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FiltersSheet(
        initialCategory: _draftCategory,
        initialRadius: _draftRadius,
        initialMinBudget: _draftMinBudget,
        initialMaxBudget: _draftMaxBudget,
        initialSort: _draftSort,
        minBudgetCtrl: _minBudgetCtrl,
        maxBudgetCtrl: _maxBudgetCtrl,
        onApply: (category, radius, minBudget, maxBudget, sort) {
          setState(() {
            _selectedCategory = category;
            _radius = radius;
            _minBudget = minBudget;
            _maxBudget = maxBudget;
            _selectedSort = sort;
          });
          _loadGombos(refresh: true);
        },
        onReset: () {
          setState(() {
            _selectedCategory = null;
            _radius = 25.0;
            _minBudget = null;
            _maxBudget = null;
            _selectedSort = 'Distance';
          });
          _loadGombos(refresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpusColors.blancChaux,
      appBar: AppBar(
        backgroundColor: OpusColors.indigoBache,
        elevation: 0,
        title: Text(
          'OPUS',
          style: OpusTextStyles.h2.copyWith(
            color: OpusColors.blancChaux,
            letterSpacing: 2,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: OpusColors.blancChaux),
                tooltip: 'Filtres',
                onPressed: _openFilters,
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: OpusColors.jauneTaxi,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _radius != 25.0 ||
      _minBudget != null ||
      _maxBudget != null ||
      _selectedSort != 'Distance';

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();

    if (_hasError && _gombos.isEmpty) {
      return _buildError();
    }

    if (!_isLoading && _gombos.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: OpusColors.rougeEnseigne,
      onRefresh: () => _loadGombos(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: OpusSpacing.sm, bottom: OpusSpacing.xl),
        itemCount: _gombos.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _gombos.length) {
            return const Padding(
              padding: EdgeInsets.all(OpusSpacing.md),
              child: Center(
                child: CircularProgressIndicator(
                  color: OpusColors.rougeEnseigne,
                ),
              ),
            );
          }
          return GomboCard(gombo: _gombos[index]);
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: OpusSpacing.sm),
        itemCount: 5,
        itemBuilder: (context, index) => const _ShimmerCard(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 72,
            color: OpusColors.grisPoussiere,
          ),
          const SizedBox(height: OpusSpacing.md),
          Text(
            'Aucun gombo trouvé',
            style: OpusTextStyles.h3.copyWith(color: OpusColors.grisPoussiere),
          ),
          const SizedBox(height: OpusSpacing.sm),
          Text(
            'Essayez de modifier vos filtres',
            style: OpusTextStyles.caption,
          ),
          const SizedBox(height: OpusSpacing.lg),
          ElevatedButton.icon(
            onPressed: _openFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: OpusColors.rougeEnseigne,
              foregroundColor: OpusColors.blancChaux,
              padding: const EdgeInsets.symmetric(
                horizontal: OpusSpacing.lg,
                vertical: OpusSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.tune),
            label: const Text('Modifier les filtres'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OpusSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: OpusColors.grisPoussiere,
            ),
            const SizedBox(height: OpusSpacing.md),
            Text(
              'Une erreur est survenue',
              style: OpusTextStyles.h3.copyWith(color: OpusColors.noirGoudron),
            ),
            const SizedBox(height: OpusSpacing.sm),
            Text(
              _errorMessage ?? '',
              style: OpusTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OpusSpacing.lg),
            ElevatedButton(
              onPressed: () => _loadGombos(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: OpusColors.rougeEnseigne,
                foregroundColor: OpusColors.blancChaux,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer placeholder card
// ---------------------------------------------------------------------------

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: OpusSpacing.md,
        vertical: OpusSpacing.sm,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(OpusSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmerBox(width: 48, height: 48, radius: 24),
                const SizedBox(width: OpusSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(width: double.infinity, height: 16),
                      const SizedBox(height: 6),
                      _shimmerBox(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: OpusSpacing.md),
            _shimmerBox(width: double.infinity, height: 12),
            const SizedBox(height: 6),
            _shimmerBox(width: 200, height: 12),
            const SizedBox(height: OpusSpacing.sm),
            Row(
              children: [
                _shimmerBox(width: 60, height: 24, radius: 20),
                const SizedBox(width: 8),
                _shimmerBox(width: 60, height: 24, radius: 20),
                const SizedBox(width: 8),
                _shimmerBox(width: 40, height: 24, radius: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filters bottom sheet
// ---------------------------------------------------------------------------

class _FiltersSheet extends StatefulWidget {
  final String? initialCategory;
  final double initialRadius;
  final double? initialMinBudget;
  final double? initialMaxBudget;
  final String initialSort;
  final TextEditingController minBudgetCtrl;
  final TextEditingController maxBudgetCtrl;
  final void Function(
    String? category,
    double radius,
    double? minBudget,
    double? maxBudget,
    String sort,
  ) onApply;
  final VoidCallback onReset;

  const _FiltersSheet({
    required this.initialCategory,
    required this.initialRadius,
    required this.initialMinBudget,
    required this.initialMaxBudget,
    required this.initialSort,
    required this.minBudgetCtrl,
    required this.maxBudgetCtrl,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? _category;
  late double _radius;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _radius = widget.initialRadius;
    _sort = widget.initialSort;
  }

  void _apply() {
    final minBudget = double.tryParse(widget.minBudgetCtrl.text);
    final maxBudget = double.tryParse(widget.maxBudgetCtrl.text);
    Navigator.of(context).pop();
    widget.onApply(_category, _radius, minBudget, maxBudget, _sort);
  }

  void _reset() {
    widget.minBudgetCtrl.clear();
    widget.maxBudgetCtrl.clear();
    Navigator.of(context).pop();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: OpusColors.blancChaux,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: OpusSpacing.lg,
        right: OpusSpacing.lg,
        top: OpusSpacing.md,
        bottom: mediaQuery.viewInsets.bottom + OpusSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpusColors.grisPoussiere,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: OpusSpacing.md),
            Text('Filtres', style: OpusTextStyles.h2),
            const SizedBox(height: OpusSpacing.lg),

            // Category
            Text('Catégorie', style: OpusTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: OpusSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: OpusSpacing.md,
                  vertical: OpusSpacing.sm,
                ),
                hintText: 'Toutes les catégories',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Toutes les catégories'),
                ),
                ..._kCategories.map(
                  (cat) => DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _category = val),
            ),
            const SizedBox(height: OpusSpacing.lg),

            // Radius
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rayon', style: OpusTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${_radius.toStringAsFixed(0)} km',
                  style: OpusTextStyles.body.copyWith(color: OpusColors.rougeEnseigne),
                ),
              ],
            ),
            Slider(
              value: _radius,
              min: 5,
              max: 100,
              divisions: 19,
              activeColor: OpusColors.rougeEnseigne,
              inactiveColor: OpusColors.grisPoussiere.withValues(alpha: 0.4),
              label: '${_radius.toStringAsFixed(0)} km',
              onChanged: (val) => setState(() => _radius = val),
            ),
            const SizedBox(height: OpusSpacing.md),

            // Budget
            Text('Budget', style: OpusTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: OpusSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.minBudgetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min (FCFA)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: OpusSpacing.md,
                        vertical: OpusSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: OpusSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: widget.maxBudgetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max (FCFA)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: OpusSpacing.md,
                        vertical: OpusSpacing.sm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: OpusSpacing.lg),

            // Sort
            Text('Trier par', style: OpusTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: OpusSpacing.sm),
            Wrap(
              spacing: OpusSpacing.sm,
              children: _kSortOptions.map((option) {
                final selected = _sort == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  selectedColor: OpusColors.rougeEnseigne,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : OpusColors.noirGoudron,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _sort = option),
                );
              }).toList(),
            ),
            const SizedBox(height: OpusSpacing.xl),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpusColors.rougeEnseigne,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: OpusSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Appliquer', style: OpusTextStyles.button),
              ),
            ),
            const SizedBox(height: OpusSpacing.md),
            Center(
              child: TextButton(
                onPressed: _reset,
                child: Text(
                  'Réinitialiser',
                  style: OpusTextStyles.body.copyWith(
                    color: OpusColors.grisPoussiere,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
