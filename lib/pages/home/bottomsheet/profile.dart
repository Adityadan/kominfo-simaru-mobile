import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:simaru/data/config.dart';
import 'package:simaru/provider/auth_provider.dart';
import 'package:simaru/themes.dart';
import '../../../widget/simaru_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loggingOut = false;
  bool _uploadingPhoto = false;

  Future<void> _choosePhoto(ImageSource source) async {
    try {
      final selected = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (selected == null || !mounted) return;
      setState(() => _uploadingPhoto = true);
      final bytes = await selected.readAsBytes();
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await auth.uploadProfilePhoto(
        bytes: bytes,
        filename: selected.name,
      );
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Foto profil berhasil diperbarui'
            : auth.profilePhotoError ??
                'Foto profil gagal diunggah. Coba lagi.'),
        duration: const Duration(seconds: 6),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Foto profil gagal dipilih. Coba lagi.'),
      ));
    }
  }

  void _showPhotoOptions() {
    if (_uploadingPhoto) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Pilih dari galeri'),
            onTap: () {
              Navigator.pop(sheetContext);
              _choosePhoto(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Ambil foto'),
            onTap: () {
              Navigator.pop(sheetContext);
              _choosePhoto(ImageSource.camera);
            },
          ),
        ]),
      ),
    );
  }

  String? _photoUrl(String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    final uri = Uri.tryParse(photo);
    if (uri == null) return null;
    if (uri.hasScheme) return photo;
    final origin = Uri.parse(baseUrl).origin;
    return '$origin/${photo.replaceFirst(RegExp(r'^/+'), '')}';
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    final auth = context.read<AuthProvider>();
    try {
      await auth.logout(token: auth.user?.token);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (_) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Belum berhasil keluar. Silakan coba lagi.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final name = _value(user?.name, 'Pengguna SIMARU');
    final photo = _photoUrl(user?.photo);
    return Scaffold(
      backgroundColor: bgColor1,
      body: Stack(children: [
        Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(gradient: simaruHeaderGradient()))),
        const Positioned(top: -70, right: -65, child: _Bubble(size: 240)),
        const Positioned(top: 190, left: -90, child: _Bubble(size: 210)),
        const Positioned(bottom: 70, right: -35, child: _Bubble(size: 160)),
        SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Akun Saya',
                            style: simaruTitle(size: 28, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Profil dan informasi akun SIMARU',
                            style: simaruBody(
                                size: 13, color: const Color(0xffDEECFF))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                      children: [
                        _GlassCard(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap:
                                    _uploadingPhoto ? null : _showPhotoOptions,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Colors.white, Color(0xffC1DAFA)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              bgColor1.withValues(alpha: .15),
                                          blurRadius: 22,
                                          offset: const Offset(0, 8))
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _uploadingPhoto
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : auth.profilePhotoBytes != null
                                            ? Image.memory(
                                                auth.profilePhotoBytes!,
                                                fit: BoxFit.cover)
                                            : photo != null
                                                ? Image.network(photo,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                            child, progress) =>
                                                        progress == null
                                                            ? child
                                                            : const Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                    errorBuilder:
                                                        (_, error, stack) =>
                                                            _avatar())
                                                : _avatar(),
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed:
                                    _uploadingPhoto ? null : _showPhotoOptions,
                                icon: const Icon(Icons.camera_alt_outlined,
                                    size: 18),
                                label: Text(_uploadingPhoto
                                    ? 'Mengunggah...'
                                    : 'Ubah foto profil'),
                              ),
                              const SizedBox(height: 8),
                              Text(name,
                                  textAlign: TextAlign.center,
                                  style: simaruTitle(size: 23)),
                              const SizedBox(height: 8),
                              Text(_value(user?.email, 'Email belum tersedia'),
                                  textAlign: TextAlign.center,
                                  style: simaruBody(
                                      size: 13,
                                      color: const Color(0xff526783))),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .65),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Text('Akun SIMARU',
                                    style: simaruBody(
                                        size: 11,
                                        color: bgColor1,
                                        weight: semibold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Informasi Akun',
                                  style: simaruTitle(size: 18)),
                              const SizedBox(height: 20),
                              _info(Icons.person_outline_rounded,
                                  'Nama lengkap', name),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                    height: 1, color: Color(0xffDCE6F2)),
                              ),
                              _info(Icons.mail_outline_rounded, 'Email',
                                  _value(user?.email)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                    height: 1, color: Color(0xffDCE6F2)),
                              ),
                              _info(Icons.phone_outlined, 'Nomor telepon',
                                  _value(user?.phone)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _GlassCard(
                          padding: EdgeInsets.zero,
                          child: TextButton(
                            onPressed: _loggingOut ? null : _logout,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xffB43B52),
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffFCEBF0),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: _loggingOut
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Icon(Icons.logout_rounded,
                                          size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                    child: Text(
                                        _loggingOut
                                            ? 'Sedang keluar...'
                                            : 'Keluar Akun',
                                        style: simaruBody(
                                            size: 15,
                                            color: const Color(0xffB43B52),
                                            weight: semibold))),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 22),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }

  String _value(String? value, [String fallback = 'Belum tersedia']) =>
      value == null || value.trim().isEmpty ? fallback : value;

  Widget _avatar() => ColoredBox(
        color: const Color(0xffDCEBFF),
        child: Icon(Icons.person_rounded, size: 58, color: bgColor1),
      );

  Widget _info(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xffE5EFFB),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white),
            ),
            child: Icon(icon, color: bgColor1, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: simaruBody(size: 11, color: const Color(0xff667B95))),
              const SizedBox(height: 3),
              Text(value,
                  style: simaruBody(size: 14, color: bgColor1, weight: medium)),
            ],
          )),
        ],
      );
}

class _GlassCard extends StatelessWidget {
  const _GlassCard(
      {required this.child, this.padding = const EdgeInsets.all(24)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: const Color(0xff123D70).withValues(alpha: .08),
                blurRadius: 24,
                offset: const Offset(0, 10))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: double.infinity,
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: .92),
                    Colors.white.withValues(alpha: .72)
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: Colors.white.withValues(alpha: .9), width: 1.2),
              ),
              child: child,
            ),
          ),
        ),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: .23),
                Colors.white.withValues(alpha: .02)
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: .24)),
          ),
        ),
      );
}
