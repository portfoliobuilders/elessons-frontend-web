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
import '../../widgets/common/app_scaffold.dart';

/// 29 · Edit Profile — bound to PATCH /me/profile. Editable fields (name,
/// state, city, parent name & mobile) are persisted; email, verified mobile and
/// class/board are shown read-only (class/board are set during onboarding).
/// Layout and field styling are unchanged from the design.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _seeded = false;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _parentName = TextEditingController();
  final TextEditingController _parentPhone = TextEditingController();

  String _email = '';
  String _phone = '';
  String _grade = '';
  String _board = '';
  String _initials = 'GT';

  String _iName = '', _iState = '', _iCity = '', _iParentName = '', _iParentPhone = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final AuthProvider auth = context.read<AuthProvider>();
    final UserProfile? u = auth.user;
    final StudentProfile? p = u?.profile;

    _iName = u?.name ?? '';
    _iState = p?.state ?? '';
    _iCity = p?.city ?? '';
    _iParentName = p?.parentName ?? '';
    _iParentPhone = p?.parentPhone ?? '';

    _name.text = _iName;
    _state.text = _iState;
    _city.text = _iCity;
    _parentName.text = _iParentName;
    _parentPhone.text = _stripCc(_iParentPhone);

    _email = auth.displayEmail;
    _phone = auth.phone ?? '';
    _grade = p?.gradeName ?? '';
    _board = p?.board ?? '';
    _initials = auth.initials;
  }

  @override
  void dispose() {
    _name.dispose();
    _state.dispose();
    _city.dispose();
    _parentName.dispose();
    _parentPhone.dispose();
    super.dispose();
  }

  String _stripCc(String v) =>
      v.replaceFirst(RegExp(r'^\s*\+?91\s*'), '').trim();

  void _snack(String message, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.signalRed : AppColors.navy,
    ));
  }

  Future<void> _save() async {
    final Map<String, dynamic> fields = <String, dynamic>{};
    if (_name.text.trim() != _iName) fields['name'] = _name.text.trim();
    if (_state.text.trim() != _iState) fields['state'] = _state.text.trim();
    if (_city.text.trim() != _iCity) fields['city'] = _city.text.trim();
    if (_parentName.text.trim() != _iParentName) {
      fields['parentName'] = _parentName.text.trim();
    }
    final String pp = _parentPhone.text.trim();
    if (pp != _stripCc(_iParentPhone)) {
      fields['parentPhone'] = pp.isEmpty ? '' : '+91 $pp';
    }

    if (fields.isEmpty) {
      Navigator.maybePop(context);
      return;
    }

    final UserProfile? updated =
        await context.read<ProfileProvider>().updateProfile(fields);
    if (!mounted) return;
    if (updated != null) {
      await context.read<AuthProvider>().refreshProfile();
      if (!mounted) return;
      _snack('Profile updated.', error: false);
      Navigator.maybePop(context);
    } else {
      _snack(context.read<ProfileProvider>().error ?? 'Couldn\'t save changes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool saving = context.watch<ProfileProvider>().isSaving;

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
                    Text('Edit Profile',
                        style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: saving ? null : _save,
                  child: const Text('Save',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        HatchTile(
                          width: 96,
                          height: 96,
                          radius: 28,
                          child: Text(_initials,
                              style: AppTextStyles.mono.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9AA6BE))),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () =>
                                _snack('Photo upload isn\'t available yet.'),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color: AppColors.surface, width: 3),
                              ),
                              child: const Icon(Icons.edit_outlined,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _snack('Photo upload isn\'t available yet.'),
                      child: const Text('Change photo',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy)),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const _Section('Personal'),
                _EditField(label: 'Full name', controller: _name),
                const SizedBox(height: 14),
                _ReadField(
                    label: 'Email address',
                    value: _email.isEmpty ? '—' : _email,
                    locked: true),
                const SizedBox(height: 14),
                _ReadField(
                  label: 'Mobile number',
                  value: _phone.isEmpty ? '—' : _phone,
                  locked: true,
                  verified: _phone.isNotEmpty,
                ),
                const SizedBox(height: 24),
                const _Section('School & class'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _ReadField(
                          label: 'Class',
                          value: _grade.isEmpty ? '—' : _grade,
                          locked: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReadField(
                          label: 'Board',
                          value: _board.isEmpty ? '—' : _board,
                          locked: true),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: _EditField(label: 'State', controller: _state)),
                    const SizedBox(width: 12),
                    Expanded(child: _EditField(label: 'City', controller: _city)),
                  ],
                ),
                const SizedBox(height: 24),
                const _Section('Parent / Guardian'),
                _EditField(
                    label: 'Parent name',
                    controller: _parentName,
                    leading: Icons.people_alt_outlined),
                const SizedBox(height: 14),
                _PhoneField(label: 'Parent mobile', controller: _parentPhone),
                const SizedBox(height: 24),
                GestureDetector(
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
                        : const Text('Save changes',
                            style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
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

class _Section extends StatelessWidget {
  const _Section(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 11),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.muted)),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.leading,
  });

  final String label;
  final TextEditingController controller;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedAlt)),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                Icon(leading, size: 18, color: AppColors.muted),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  cursorColor: AppColors.navy,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadField extends StatelessWidget {
  const _ReadField({
    required this.label,
    required this.value,
    this.locked = false,
    this.verified = false,
  });

  final String label;
  final String value;
  final bool locked;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedAlt)),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: locked ? const Color(0xFFF1F3F7) : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: locked ? AppColors.muted : AppColors.ink)),
              ),
              if (verified)
                const Row(
                  children: <Widget>[
                    Icon(Icons.check_rounded,
                        size: 13, color: AppColors.success),
                    SizedBox(width: 5),
                    Text('Verified',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success)),
                  ],
                )
              else if (locked)
                const Icon(Icons.lock_outline_rounded,
                    size: 14, color: AppColors.muted),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedAlt)),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Row(
              children: <Widget>[
                Container(
                  width: 58,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceAlt,
                    border: Border(
                        right: BorderSide(color: AppColors.border, width: 1.5)),
                  ),
                  child: const Text('+91',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    cursorColor: AppColors.navy,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '00000 00000',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
