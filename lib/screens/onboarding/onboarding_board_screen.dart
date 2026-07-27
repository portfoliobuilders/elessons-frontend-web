import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/onboarding_header.dart';
import '../../widgets/inputs/primary_button.dart';

const Map<String, Map<String, List<String>>> _countryStateCities = {
  'India': {
    'Kerala': [
      'Kochi',
      'Thiruvananthapuram',
      'Kozhikode',
      'Thrissur',
      'Kollam',
      'Kannur',
      'Alappuzha',
      'Kottayam',
      'Palakkad',
      'Malappuram',
      'Pathanamthitta',
      'Idukki',
      'Kasaragod',
      'Wayanad'
    ],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
      'Tirunelveli',
      'Erode',
      'Vellore',
      'Thanjavur',
      'Tuticorin'
    ],
    'Karnataka': [
      'Bengaluru',
      'Mysuru',
      'Hubballi',
      'Mangaluru',
      'Belagavi',
      'Davanagere',
      'Ballari',
      'Shivamogga',
      'Tumakuru',
      'Udupi'
    ],
    'Maharashtra': [
      'Mumbai',
      'Pune',
      'Nagpur',
      'Thane',
      'Nashik',
      'Aurangabad',
      'Solapur',
      'Navi Mumbai',
      'Kolhapur',
      'Amravati'
    ],
    'Delhi': [
      'New Delhi',
      'North Delhi',
      'South Delhi',
      'East Delhi',
      'West Delhi',
      'Central Delhi'
    ],
    'Telangana': [
      'Hyderabad',
      'Warangal',
      'Nizamabad',
      'Karimnagar',
      'Khammam'
    ],
    'Andhra Pradesh': [
      'Visakhapatnam',
      'Vijayawada',
      'Guntur',
      'Nellore',
      'Kurnool',
      'Tirupati',
      'Rajahmundry',
      'Kakinada'
    ],
    'West Bengal': [
      'Kolkata',
      'Howrah',
      'Durgapur',
      'Asansol',
      'Siliguri',
      'Kharagpur'
    ],
    'Gujarat': [
      'Ahmedabad',
      'Surat',
      'Vadodara',
      'Rajkot',
      'Bhavnagar',
      'Jamnagar',
      'Gandhinagar'
    ],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur',
      'Ghaziabad',
      'Agra',
      'Varanasi',
      'Meerut',
      'Prayagraj',
      'Noida',
      'Bareilly',
      'Aligarh'
    ],
    'Rajasthan': [
      'Jaipur',
      'Jodhpur',
      'Kota',
      'Bikaner',
      'Ajmer',
      'Udaipur',
      'Bhilwara'
    ],
    'Punjab': [
      'Ludhiana',
      'Amritsar',
      'Jalandhar',
      'Patiala',
      'Bathinda',
      'Mohali'
    ],
    'Haryana': [
      'Gurugram',
      'Faridabad',
      'Panipat',
      'Ambala',
      'Karnal',
      'Hisar'
    ],
    'Madhya Pradesh': [
      'Indore',
      'Bhopal',
      'Jabalpur',
      'Gwalior',
      'Ujjain'
    ],
    'Bihar': [
      'Patna',
      'Gaya',
      'Bhagalpur',
      'Muzaffarpur',
      'Purnia'
    ],
    'Odisha': [
      'Bhubaneswar',
      'Cuttack',
      'Rourkela',
      'Puri',
      'Sambalpur'
    ],
    'Assam': [
      'Guwahati',
      'Silchar',
      'Dibrugarh',
      'Jorhat',
      'Nagaon'
    ],
    'Jammu & Kashmir': [
      'Srinagar',
      'Jammu',
      'Anantnag'
    ],
    'Himachal Pradesh': [
      'Shimla',
      'Dharamshala',
      'Mandi',
      'Solan'
    ],
    'Uttarakhand': [
      'Dehradun',
      'Haridwar',
      'Roorkee',
      'Haldwani'
    ],
    'Goa': [
      'Panaji',
      'Margao',
      'Vasco da Gama'
    ],
  },
  'UAE': {
    'Dubai': [
      'Dubai Marina',
      'Downtown Dubai',
      'Deira',
      'Bur Dubai',
      'Jumeirah',
      'Business Bay',
      'Al Barsha',
      'Silicon Oasis',
      'Mirdif'
    ],
    'Abu Dhabi': [
      'Abu Dhabi City',
      'Al Ain',
      'Al Dhafra',
      'Yas Island',
      'Saadiyat Island',
      'Reem Island'
    ],
    'Sharjah': [
      'Sharjah City',
      'Al Majaz',
      'Al Nahda Sharjah',
      'Khorfakkan',
      'Kalba'
    ],
    'Ajman': [
      'Ajman City',
      'Al Nuaimia',
      'Al Rashidiya'
    ],
    'Ras Al Khaimah': [
      'RAK City',
      'Al Hamra',
      'Al Nakheel'
    ],
    'Fujairah': [
      'Fujairah City',
      'Dibba Al-Fujairah'
    ],
    'Umm Al Quwain': [
      'UAQ City',
      'Al Salama'
    ],
  },
};

/// 07 · Onboarding — Where you study (Searchable Floating Dropdown Menu).
class OnboardingBoardScreen extends StatefulWidget {
  const OnboardingBoardScreen({super.key});

  @override
  State<OnboardingBoardScreen> createState() => _OnboardingBoardScreenState();
}

class _OnboardingBoardScreenState extends State<OnboardingBoardScreen> {
  late final TextEditingController _schoolController;
  String _selectedCountry = 'India';
  String _selectedState = 'Kerala';
  String _selectedCity = 'Kochi';

  @override
  void initState() {
    super.initState();
    _schoolController = TextEditingController(text: "St. Xavier's High School");
  }

  @override
  void dispose() {
    _schoolController.dispose();
    super.dispose();
  }

  Map<String, List<String>> get _currentStates {
    return _countryStateCities[_selectedCountry] ?? _countryStateCities['India']!;
  }

  List<String> get _currentCities {
    return _currentStates[_selectedState] ?? ['Kochi', 'Thiruvananthapuram', 'Kozhikode'];
  }

  void _onCountrySelected(String newCountry) {
    setState(() {
      _selectedCountry = newCountry;
      final statesMap = _countryStateCities[newCountry] ?? _countryStateCities['India']!;
      final firstState = statesMap.keys.first;
      _selectedState = firstState;
      final cities = statesMap[firstState];
      _selectedCity = (cities != null && cities.isNotEmpty) ? cities.first : 'City';
    });
  }

  void _onStateSelected(String newState) {
    setState(() {
      _selectedState = newState;
      final cities = _currentStates[newState];
      if (cities != null && cities.isNotEmpty) {
        _selectedCity = cities.first;
      } else {
        _selectedCity = 'City';
      }
    });
  }

  void _onCitySelected(String newCity) {
    setState(() {
      _selectedCity = newCity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const OnboardingHeader(step: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Where do you\nstudy?', style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Text(
                    'Just a couple of quick details so we can tailor your classes.',
                    style: AppTextStyles.bodyLg,
                  ),
                  const SizedBox(height: 24),

                  // ── Country Field ──
                  const _FieldLabel('Country'),
                  const SizedBox(height: 7),
                  _SearchableDropdownField(
                    title: 'Select Country',
                    value: _selectedCountry,
                    items: _countryStateCities.keys.toList(),
                    onSelected: _onCountrySelected,
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7ECF6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.public_rounded,
                        size: 16,
                        color: AppColors.navy,
                      ),
                    ),
                    bold: true,
                  ),
                  const SizedBox(height: 15),

                  // ── Searchable State & City Floating Dropdowns ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCountry == 'UAE' ? 'Emirate' : 'State',
                              style: AppTextStyles.label.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 7),
                            _SearchableDropdownField(
                              title: _selectedCountry == 'UAE' ? 'Select Emirate' : 'Select State',
                              value: _selectedState,
                              items: _currentStates.keys.toList(),
                              onSelected: _onStateSelected,
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('City'),
                            const SizedBox(height: 7),
                            _SearchableDropdownField(
                              title: 'Select City',
                              value: _selectedCity,
                              items: _currentCities,
                              onSelected: _onCitySelected,
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // ── School / College Name Field ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _FieldLabel('School / College name'),
                      Text(
                        'Optional',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          letterSpacing: 0,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _EditableField(
                    controller: _schoolController,
                    hintText: 'Enter school or college name',
                    leadingIcon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 9),

                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          "Helps us bring your school's batches & offers.",
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5,
                            letterSpacing: 0,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Continue Action Button ──
                  PrimaryButton(
                    label: 'Continue',
                    trailingArrow: true,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.onboardClass,
                      arguments: {
                        'country': _selectedCountry,
                        'state': _selectedState,
                        'city': _selectedCity,
                        'school': _schoolController.text.trim(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.label.copyWith(fontSize: 12));
}

/// Editable text field with design system borders and focus effects.
class _EditableField extends StatefulWidget {
  const _EditableField({
    required this.controller,
    required this.hintText,
    this.leadingIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? leadingIcon;

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: _isFocused ? AppColors.navy : AppColors.border,
            width: _isFocused ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ...[
              Icon(
                widget.leadingIcon,
                size: 19,
                color: _isFocused ? AppColors.navy : AppColors.muted,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                cursorColor: AppColors.navy,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.heading.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.muted,
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

/// Inline Searchable Dropdown Tile with Floating Popover Overlay (Matching Mockup).
class _SearchableDropdownField extends StatefulWidget {
  const _SearchableDropdownField({
    required this.title,
    required this.value,
    required this.items,
    required this.onSelected,
    this.leading,
    this.bold = false,
    this.compact = false,
  });

  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final Widget? leading;
  final bool bold;
  final bool compact;

  @override
  State<_SearchableDropdownField> createState() => _SearchableDropdownFieldState();
}

class _SearchableDropdownFieldState extends State<_SearchableDropdownField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(200, 52);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dismiss tap region outside popup
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 6),
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: _DropdownMenuPopup(
                  items: widget.items,
                  selectedValue: widget.value,
                  onSelected: (val) {
                    widget.onSelected(val);
                    _closeDropdown();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 52,
            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: _isOpen ? AppColors.navy : AppColors.border,
                width: _isOpen ? 2.0 : 1.5,
              ),
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.value.isNotEmpty ? widget.value : 'Select options',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: widget.compact ? 14 : 14.5,
                      fontWeight: widget.bold ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Icon(
                  _isOpen
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  size: 24,
                  color: AppColors.navy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating Dropdown Menu Popover with Light Grey Search Input & List Items.
class _DropdownMenuPopup extends StatefulWidget {
  const _DropdownMenuPopup({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<String> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  State<_DropdownMenuPopup> createState() => _DropdownMenuPopupState();
}

class _DropdownMenuPopupState extends State<_DropdownMenuPopup> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final bool showCustomOption = query.isNotEmpty &&
        !widget.items.any((item) => item.toLowerCase() == query.toLowerCase());

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E8EF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Light Grey Search Input Bar (Matching Image Mockup) ──
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              cursorColor: AppColors.navy,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                hintText: 'Search input',
                hintStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.muted),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Scrollable Option Items ──
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                if (showCustomOption)
                  _DropdownMenuItemTile(
                    label: 'Use "$query"',
                    isSelected: false,
                    isCustom: true,
                    onTap: () => widget.onSelected(query),
                  ),
                ..._filteredItems.map((item) {
                  final isSelected = item == widget.selectedValue;
                  return _DropdownMenuItemTile(
                    label: item,
                    isSelected: isSelected,
                    onTap: () => widget.onSelected(item),
                  );
                }),
                if (_filteredItems.isEmpty && !showCustomOption)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No options found',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownMenuItemTile extends StatefulWidget {
  const _DropdownMenuItemTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCustom = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCustom;

  @override
  State<_DropdownMenuItemTile> createState() => _DropdownMenuItemTileState();
}

class _DropdownMenuItemTileState extends State<_DropdownMenuItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.navy.withValues(alpha: 0.08)
                : (_isHovered ? const Color(0xFFF4F6FA) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Bullet Circle matching reference image mockup
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.navy
                      : const Color(0xFFE2E6EF),
                  shape: BoxShape.circle,
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                    color: widget.isSelected ? AppColors.navy : AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
