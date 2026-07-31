import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/progress_track.dart';

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// 19 · Complete Profile (KYC) — bound to PATCH /me/profile. Captures the KYC
/// fields the backend uses to mark the profile complete (dob, address, pincode,
/// parent contact) plus gender/city/state. Layout is unchanged from the design.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  bool _seeded = false;

  final TextEditingController _address = TextEditingController();
  final TextEditingController _cityState = TextEditingController();
  final TextEditingController _pincode = TextEditingController();
  final TextEditingController _parentName = TextEditingController();
  final TextEditingController _parentPhone = TextEditingController();
  DateTime? _dob;
  String? _gender;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final StudentProfile? p = context.read<AuthProvider>().user?.profile;
    if (p != null) {
      _address.text = p.addressLine ?? '';
      _cityState.text = <String>[
        if ((p.city ?? '').isNotEmpty) p.city!,
        if ((p.state ?? '').isNotEmpty) p.state!,
      ].join(', ');
      _pincode.text = p.pincode ?? '';
      _parentName.text = p.parentName ?? '';
      _parentPhone.text = _stripCc(p.parentPhone ?? '');
      _dob = p.dob;
      _gender = p.gender;
    }
    _address.addListener(_refresh);
    _cityState.addListener(_refresh);
    _pincode.addListener(_refresh);
    _parentName.addListener(_refresh);
    _parentPhone.addListener(_refresh);
  }

  @override
  void dispose() {
    _address.dispose();
    _cityState.dispose();
    _pincode.dispose();
    _parentName.dispose();
    _parentPhone.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  String _stripCc(String v) =>
      v.replaceFirst(RegExp(r'^\s*\+?91\s*'), '').trim();

  ({String city, String state}) _splitCityState() {
    final String raw = _cityState.text.trim();
    if (raw.isEmpty) return (city: '', state: '');
    final int comma = raw.indexOf(',');
    if (comma < 0) return (city: raw, state: '');
    return (
      city: raw.substring(0, comma).trim(),
      state: raw.substring(comma + 1).trim(),
    );
  }

  int get _percent {
    final ({String city, String state}) cs = _splitCityState();
    final List<bool> filled = <bool>[
      _dob != null,
      (_gender ?? '').isNotEmpty,
      _address.text.trim().isNotEmpty,
      cs.city.isNotEmpty,
      cs.state.isNotEmpty,
      _pincode.text.trim().isNotEmpty,
      _parentName.text.trim().isNotEmpty,
      _parentPhone.text.trim().isNotEmpty,
    ];
    final int done = filled.where((bool b) => b).length;
    return ((done / filled.length) * 100).round();
  }

  String get _dobLabel {
    final DateTime? d = _dob;
    if (d == null) return '';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  void _finish() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  void _snack(String message, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.signalRed : AppColors.navy,
    ));
  }

  Future<void> _pickDob() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 15, 1, 1),
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickGender() async {
    final String? g = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <String>['Male', 'Female', 'Other']
              .map((String g) => ListTile(
                    title: Text(g,
                        style: AppTextStyles.body.copyWith(color: AppColors.ink)),
                    trailing: _gender == g
                        ? const Icon(Icons.check_rounded, color: AppColors.navy)
                        : null,
                    onTap: () => Navigator.pop(ctx, g),
                  ))
              .toList(),
        ),
      ),
    );
    if (g != null) setState(() => _gender = g);
  }

  Future<void> _save() async {
    final ({String city, String state}) cs = _splitCityState();
    final Map<String, dynamic> fields = <String, dynamic>{
      if (_dob != null)
        'dob':
            '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
      if ((_gender ?? '').isNotEmpty) 'gender': _gender,
      if (_address.text.trim().isNotEmpty) 'addressLine': _address.text.trim(),
      if (cs.city.isNotEmpty) 'city': cs.city,
      if (cs.state.isNotEmpty) 'state': cs.state,
      if (_pincode.text.trim().isNotEmpty) 'pincode': _pincode.text.trim(),
      if (_parentName.text.trim().isNotEmpty)
        'parentName': _parentName.text.trim(),
      if (_parentPhone.text.trim().isNotEmpty)
        'parentPhone': '+91 ${_parentPhone.text.trim()}',
    };

    if (fields.isEmpty) {
      _finish();
      return;
    }

    final UserProfile? updated =
        await context.read<ProfileProvider>().updateProfile(fields);
    if (!mounted) return;
    if (updated != null) {
      await context.read<AuthProvider>().refreshProfile();
      if (!mounted) return;
      _finish();
    } else {
      _snack(context.read<ProfileProvider>().error ?? 'Couldn\'t save details.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool saving = context.watch<ProfileProvider>().isSaving;
    final int percent = _percent;

    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFE7EAF0), width: 1.5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.chevron_left_rounded,
                            size: 20, color: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Complete profile',
                        style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: _finish,
                  child: Text('Skip',
                      style: AppTextStyles.heading
                          .copyWith(fontSize: 13, color: AppColors.muted)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.verified_outlined,
                              size: 17, color: AppColors.navy),
                          const SizedBox(width: 9),
                          Text('Just one quick step',
                              style: AppTextStyles.cardTitle
                                  .copyWith(color: AppColors.navy)),
                        ],
                      ),
                      const SizedBox(height: 11),
                      const Text.rich(
                        TextSpan(
                          text: 'Add a few details to unlock ',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: AppColors.bodyText),
                          children: <InlineSpan>[
                            TextSpan(
                                text: 'course certificates',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            TextSpan(text: ' and '),
                            TextSpan(
                                text: 'mentor doubt support',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            TextSpan(text: '. Takes about 2 minutes.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ProgressTrack(
                              value: percent / 100.0,
                              height: 7,
                              trackColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('$percent%',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _KycSection('Student details'),
                _Card(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () =>
                                _snack('Photo upload isn\'t available yet.'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                const HatchTile(
                                  width: 58,
                                  height: 58,
                                  radius: 16,
                                  child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 22,
                                      color: Color(0xFF9AA6BE)),
                                ),
                                Positioned(
                                  bottom: -3,
                                  right: -3,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.navy,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                        Icons.file_upload_outlined,
                                        size: 12,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Add a photo',
                                  style: AppTextStyles.cardTitle),
                              const SizedBox(height: 1),
                              const Text('For your ID & certificate',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.muted)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _TapBox(
                              label: 'Date of birth',
                              value: _dobLabel,
                              hint: 'Select date',
                              icon: Icons.calendar_today_outlined,
                              onTap: _pickDob,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TapBox(
                              label: 'Gender',
                              value: _gender ?? '',
                              hint: 'Select',
                              trailingChevron: true,
                              onTap: _pickGender,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _KycSection('Address'),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _InputBox(
                          label: 'Address line',
                          controller: _address,
                          hint: 'House, street, area'),
                      const SizedBox(height: 13),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 14,
                            child: _InputBox(
                                label: 'City · State',
                                controller: _cityState,
                                hint: 'City, State'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 10,
                            child: _InputBox(
                                label: 'Pincode',
                                controller: _pincode,
                                hint: '000000',
                                keyboardType: TextInputType.number),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _KycSection('Parent / Guardian'),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _InputBox(
                          label: 'Parent / guardian name',
                          controller: _parentName,
                          hint: 'Full name'),
                      const SizedBox(height: 13),
                      _InputBox(
                          label: 'Parent mobile',
                          controller: _parentPhone,
                          hint: '+91 00000 00000',
                          keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 14, 20, 22 + MediaQuery.of(context).padding.bottom),
            child: GestureDetector(
              onTap: saving ? null : _save,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  boxShadow: AppShadows.primaryButton,
                ),
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Save & finish',
                              style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          SizedBox(width: 9),
                          Icon(Icons.check_rounded,
                              size: 18, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KycSection extends StatelessWidget {
  const _KycSection(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 11),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.muted)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedAlt)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              cursorColor: AppColors.navy,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedAlt),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TapBox extends StatelessWidget {
  const _TapBox({
    required this.label,
    required this.value,
    required this.onTap,
    this.hint,
    this.icon,
    this.trailingChevron = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? hint;
  final IconData? icon;
  final bool trailingChevron;

  @override
  Widget build(BuildContext context) {
    final bool empty = value.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedAlt)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 15, color: AppColors.muted),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(empty ? (hint ?? '') : value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: empty ? AppColors.mutedAlt : AppColors.ink)),
                ),
                if (trailingChevron)
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
