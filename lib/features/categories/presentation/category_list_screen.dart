import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/main_navigation_screen.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _expandedParentIds = {};
  String? _selectedParentFilter; // For subcategories tab

  final List<Color> _palette = const [
    Color(0xFF5356FB), // Royal Indigo
    Color(0xFF00B894), // Mint Emerald
    Color(0xFF6C5CE7), // Soft Violet
    Color(0xFF0984E3), // Sky Blue
    Color(0xFFE17055), // Coral Terracotta
    Color(0xFFFD79A8), // Blush Pink
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getColorForIndex(int index) => _palette[index % _palette.length];

  void _showAddOrEditCategoryDialog({
    Category? categoryToEdit,
    String? initialParentId,
    bool forceSubcategory = false,
  }) {
    final categories = ref.read(categoryRepositoryProvider).currentCategories;
    final mainCategories = categories.where((c) => c.parentId == null).toList();

    final isEditing = categoryToEdit != null;
    bool isSubcategory = forceSubcategory ||
        (isEditing ? categoryToEdit.parentId != null : initialParentId != null);

    String? selectedParentId = isEditing
        ? categoryToEdit.parentId
        : (initialParentId ?? (mainCategories.isNotEmpty ? mainCategories.first.id : null));

    final nameController = TextEditingController(text: categoryToEdit?.name ?? '');
    final descController = TextEditingController(text: categoryToEdit?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isEditing
                        ? Icons.edit_note_rounded
                        : (isSubcategory ? Icons.subdirectory_arrow_right_rounded : Icons.create_new_folder_rounded),
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing
                            ? 'Edit ${isSubcategory ? "Subcategory" : "Category"}'
                            : 'New ${isSubcategory ? "Subcategory" : "Category"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF1E2243),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEditing ? 'Update details below' : 'Add to inventory catalog',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8A90A6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isEditing && !forceSubcategory) ...[
                      const Text(
                        'Category Level',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF636A88),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    isSubcategory = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isSubcategory ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !isSubcategory
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Main Category',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: !isSubcategory ? FontWeight.w800 : FontWeight.w600,
                                        color: !isSubcategory ? AppTheme.primaryColor : const Color(0xFF7A809B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (mainCategories.isEmpty) {
                                    AppToast.showWarning(context, 'Please create a Main Category first');
                                    return;
                                  }
                                  setDialogState(() {
                                    isSubcategory = true;
                                    selectedParentId ??= mainCategories.first.id;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSubcategory ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isSubcategory
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Subcategory',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSubcategory ? FontWeight.w800 : FontWeight.w600,
                                        color: isSubcategory ? AppTheme.primaryColor : const Color(0xFF7A809B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Parent Category Selector (Only for subcategories)
                    if (isSubcategory) ...[
                      const Text(
                        'Parent Main Category *',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF636A88),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedParentId,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.folder_rounded, color: AppTheme.primaryColor),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: mainCategories.map((mc) {
                          return DropdownMenuItem(
                            value: mc.id,
                            child: Text(
                              mc.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E2243)),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedParentId = val;
                          });
                        },
                        validator: (val) => val == null ? 'Parent category is required' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Name
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '${isSubcategory ? "Subcategory" : "Category"} Name *',
                        prefixIcon: Icon(
                          isSubcategory ? Icons.label_outline_rounded : Icons.folder_outlined,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Description
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: Icon(Icons.notes_rounded, color: Color(0xFF8A90A6)),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A90A6), fontWeight: FontWeight.w700)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final repo = ref.read(categoryRepositoryProvider);

                  final parent = isSubcategory ? selectedParentId : null;

                  if (isEditing) {
                    await repo.updateCategory(
                      categoryToEdit.copyWith(
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                        parentId: parent,
                      ),
                    );
                  } else {
                    await repo.addCategory(
                      Category(
                        id: '',
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                        parentId: parent,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) {
                    AppToast.showSuccess(
                      context,
                      '${isSubcategory ? "Subcategory" : "Category"} ${isEditing ? "updated" : "created"} successfully',
                    );
                  }
                },
                child: Text(
                  isEditing ? 'Save Changes' : (isSubcategory ? 'Create Subcategory' : 'Create Category'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(Category category, {int subcategoryCount = 0}) {
    final isMain = category.parentId == null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7675).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF7675), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete ${isMain ? "Category" : "Subcategory"}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E2243), fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${category.name}"?',
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E2243), fontWeight: FontWeight.w600),
            ),
            if (isMain && subcategoryCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7675).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFF7675).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF7675), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will also delete $subcategoryCount nested subcategories under it.',
                        style: const TextStyle(
                          color: Color(0xFFFF7675),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A90A6), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
              if (mounted) {
                AppToast.showInfo(
                  context,
                  '${isMain ? "Category" : "Subcategory"} "${category.name}" removed',
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Categories & Hierarchy'),
        actions: [
          IconButton(
            tooltip: 'Add Main Category',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: AppTheme.primaryColor),
            ),
            onPressed: () => _showAddOrEditCategoryDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _showAddOrEditCategoryDialog(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Category',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: categoriesAsync.when(
        data: (allCategories) {
          final mainCategories = allCategories.where((c) => c.parentId == null).toList();
          final subcategories = allCategories.where((c) => c.parentId != null).toList();

          // Initialize expanded state for all parent categories on first load
          if (_expandedParentIds.isEmpty && mainCategories.isNotEmpty) {
            for (final mc in mainCategories) {
              _expandedParentIds.add(mc.id);
            }
          }

          // Search filter
          final query = _searchQuery.toLowerCase().trim();
          final filteredMainCategories = mainCategories.where((mc) {
            if (query.isEmpty) return true;
            final matchesSelf = mc.name.toLowerCase().contains(query) ||
                mc.description.toLowerCase().contains(query);
            final hasMatchingSub = subcategories
                .where((s) => s.parentId == mc.id)
                .any((s) => s.name.toLowerCase().contains(query) || s.description.toLowerCase().contains(query));
            return matchesSelf || hasMatchingSub;
          }).toList();

          final filteredSubcategories = subcategories.where((s) {
            final matchesParentFilter = _selectedParentFilter == null || s.parentId == _selectedParentFilter;
            if (!matchesParentFilter) return false;
            if (query.isEmpty) return true;
            final parentObj = mainCategories.where((m) => m.id == s.parentId).firstOrNull;
            return s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query) ||
                (parentObj != null && parentObj.name.toLowerCase().contains(query));
          }).toList();

          return Column(
            children: [
              // Top Stats Card & Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    // Metric Summary Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricPill(
                            title: 'Main Categories',
                            count: mainCategories.length,
                            icon: Icons.folder_special_rounded,
                            color: const Color(0xFF5356FB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricPill(
                            title: 'Subcategories',
                            count: subcategories.length,
                            icon: Icons.subdirectory_arrow_right_rounded,
                            color: const Color(0xFF00B894),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search categories or subcategories...',
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8A90A6)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF8A90A6), size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: const Color(0xFF7A809B),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_tree_rounded, size: 18),
                          const SizedBox(width: 6),
                          const Text('Hierarchy'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text('Main (${mainCategories.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.subdirectory_arrow_right_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text('Subs (${subcategories.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Hierarchy Tree View
                    _buildHierarchyView(
                      filteredMainCategories,
                      subcategories,
                    ),

                    // Tab 2: Main Categories Only
                    _buildMainCategoriesView(
                      filteredMainCategories,
                      subcategories,
                    ),

                    // Tab 3: Subcategories View
                    _buildSubcategoriesView(
                      mainCategories,
                      filteredSubcategories,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading categories: $err')),
      ),
    );
  }

  Widget _buildMetricPill({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E2243),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A90A6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 1: Hierarchy Accordion View
  Widget _buildHierarchyView(
    List<Category> mainCategories,
    List<Category> allSubcategories,
  ) {
    if (mainCategories.isEmpty) {
      return _buildEmptyState(
        'No matching categories found',
        'Add a new main category or clear your search filter.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: mainCategories.length,
      itemBuilder: (context, index) {
        final mainCat = mainCategories[index];
        final subs = allSubcategories.where((s) => s.parentId == mainCat.id).toList();
        final isExpanded = _expandedParentIds.contains(mainCat.id);
        final accent = _getColorForIndex(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color: isExpanded ? accent.withValues(alpha: 0.3) : const Color(0xFFEAEBF4),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // Main Category Header Tile
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedParentIds.remove(mainCat.id);
                      } else {
                        _expandedParentIds.add(mainCat.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Folder Icon Badge
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent, accent.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.folder_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),

                        // Title & Sub count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      mainCat.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1E2243),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${subs.length} subs',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mainCat.description.isNotEmpty
                                    ? mainCat.description
                                    : 'Parent catalog category',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF636A88),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        IconButton(
                          tooltip: 'Add Subcategory',
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add_rounded, color: accent, size: 18),
                          ),
                          onPressed: () {
                            _showAddOrEditCategoryDialog(
                              initialParentId: mainCat.id,
                              forceSubcategory: true,
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'View Products',
                          icon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF5356FB), size: 19),
                          onPressed: () {
                            ref.read(selectedCategoryNavigationProvider.notifier).state = mainCat.id;
                            ref.read(appNavIndexProvider.notifier).state = 1;
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Edit Category',
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF8A90A6), size: 19),
                          onPressed: () {
                            _showAddOrEditCategoryDialog(categoryToEdit: mainCat);
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete Category',
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7675), size: 19),
                          onPressed: () {
                            _confirmDeleteCategory(mainCat, subcategoryCount: subs.length);
                          },
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF8A90A6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Nested Subcategories Container
              if (isExpanded) ...[
                const Divider(height: 1, color: Color(0xFFF0F2F8)),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBFE),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  child: subs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF8A90A6)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'No subcategories created under this parent yet.',
                                  style: TextStyle(fontSize: 12.5, color: Color(0xFF8A90A6)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _showAddOrEditCategoryDialog(
                                    initialParentId: mainCat.id,
                                    forceSubcategory: true,
                                  );
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Sub', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            for (int sIdx = 0; sIdx < subs.length; sIdx++) ...[
                              _buildSubcategoryItemRow(subs[sIdx], accent),
                              if (sIdx < subs.length - 1)
                                const Divider(height: 12, color: Color(0xFFEEF0F8)),
                            ],
                          ],
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubcategoryItemRow(Category sub, Color parentAccent) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: parentAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: parentAccent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sub.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2243),
                ),
              ),
              if (sub.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sub.description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF636A88)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: 'View Products',
          icon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF00B894), size: 17),
          onPressed: () {
            ref.read(selectedCategoryNavigationProvider.notifier).state = sub.parentId;
            ref.read(appNavIndexProvider.notifier).state = 1;
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        IconButton(
          tooltip: 'Edit Subcategory',
          icon: const Icon(Icons.edit_outlined, color: Color(0xFF8A90A6), size: 17),
          onPressed: () => _showAddOrEditCategoryDialog(categoryToEdit: sub),
        ),
        IconButton(
          tooltip: 'Delete Subcategory',
          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7675), size: 17),
          onPressed: () => _confirmDeleteCategory(sub),
        ),
      ],
    );
  }

  // TAB 2: Main Categories List View
  Widget _buildMainCategoriesView(
    List<Category> mainCategories,
    List<Category> allSubcategories,
  ) {
    if (mainCategories.isEmpty) {
      return _buildEmptyState('No main categories found', 'Create a main category to organize items.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: mainCategories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cat = mainCategories[index];
        final subs = allSubcategories.where((s) => s.parentId == cat.id).toList();
        final accent = _getColorForIndex(index);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.softShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.folder_rounded, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cat.name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E2243),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${subs.length} subcategories',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat.description.isNotEmpty ? cat.description : 'Root category item',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF636A88)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Add Subcategory',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add_rounded, color: accent, size: 18),
                ),
                onPressed: () {
                  _showAddOrEditCategoryDialog(initialParentId: cat.id, forceSubcategory: true);
                },
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF8A90A6), size: 19),
                onPressed: () => _showAddOrEditCategoryDialog(categoryToEdit: cat),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7675), size: 19),
                onPressed: () => _confirmDeleteCategory(cat, subcategoryCount: subs.length),
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 3: Subcategories List View
  Widget _buildSubcategoriesView(
    List<Category> mainCategories,
    List<Category> filteredSubcategories,
  ) {
    return Column(
      children: [
        // Horizontal Parent Category Filter Chips
        if (mainCategories.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Parents'),
                  selected: _selectedParentFilter == null,
                  onSelected: (val) {
                    setState(() => _selectedParentFilter = null);
                  },
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _selectedParentFilter == null ? AppTheme.primaryColor : const Color(0xFF636A88),
                  ),
                ),
                const SizedBox(width: 8),
                for (final mc in mainCategories) ...[
                  ChoiceChip(
                    label: Text(mc.name),
                    selected: _selectedParentFilter == mc.id,
                    onSelected: (val) {
                      setState(() => _selectedParentFilter = val ? mc.id : null);
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _selectedParentFilter == mc.id ? AppTheme.primaryColor : const Color(0xFF636A88),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),

        Expanded(
          child: filteredSubcategories.isEmpty
              ? _buildEmptyState(
                  'No subcategories found',
                  'Select another parent or tap "Add Subcategory" to create one.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                  itemCount: filteredSubcategories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sub = filteredSubcategories[index];
                    final parentObj = mainCategories.where((m) => m.id == sub.parentId).firstOrNull;
                    final parentIndex = parentObj != null ? mainCategories.indexOf(parentObj) : 0;
                    final accent = _getColorForIndex(parentIndex);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppTheme.softShadow,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.subdirectory_arrow_right_rounded, color: accent, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        sub.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E2243),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        parentObj?.name ?? 'Parent',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sub.description.isNotEmpty ? sub.description : 'Subcategory item',
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF636A88)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit Subcategory',
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF8A90A6), size: 19),
                            onPressed: () => _showAddOrEditCategoryDialog(categoryToEdit: sub),
                          ),
                          IconButton(
                            tooltip: 'Delete Subcategory',
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7675), size: 19),
                            onPressed: () => _confirmDeleteCategory(sub),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.category_outlined, size: 48, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF1E2243)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8A90A6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
