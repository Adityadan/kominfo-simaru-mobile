import 'package:simaru/widget/double_back_to_exit.dart';
import 'dart:ui';

import 'package:simaru/pages/home/bottomsheet/faq.dart';
import 'package:simaru/pages/home/bottomsheet/home_page.dart';
import 'package:simaru/pages/home/bottomsheet/profile.dart';
import 'package:simaru/pages/jadwal%20ruang/unvailable_room.dart';
import 'package:simaru/pages/pesan%20ruang%20baru/pesan_ruang_room.dart';
import 'package:simaru/pages/riwayat%20pemesanan/riwayat_page.dart';
import 'package:simaru/themes.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    PesanRuangPage(),
    UnvailbleRoomPage(),
    RiwayatPage(),
    FaqPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: whiteColor,
        body: _pages[_currentIndex],
        bottomNavigationBar: _GlassNavigationBar(
          selectedIndex: _currentIndex,
          onSelected: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class _GlassNavigationBar extends StatelessWidget {
  const _GlassNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _labels = [
    'Home',
    'Booking',
    'Jadwal',
    'Riwayat',
    'FAQ',
    'Akun'
  ];
  static const _icons = [
    Icons.home_outlined,
    Icons.event_available_outlined,
    Icons.calendar_month_outlined,
    Icons.history_rounded,
    Icons.help_outline_rounded,
    Icons.person_outline_rounded,
  ];
  static const _activeIcons = [
    Icons.home_rounded,
    Icons.event_available_rounded,
    Icons.calendar_month_rounded,
    Icons.history_rounded,
    Icons.help_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 320);
    final labelScale = MediaQuery.textScalerOf(context).scale(11) / 11;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffEDF4FF), Color(0xffF8FAFF), Color(0xffE5EDF8)],
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: bgColor1.withValues(alpha: .10),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: .90),
                          Colors.white.withValues(alpha: .55),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: .95)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / _labels.length;
                        final height =
                            66.0 + (labelScale - 1).clamp(0.0, 4.0) * 30;
                        return SizedBox(
                          height: height,
                          child: Stack(
                            children: [
                              AnimatedPositionedDirectional(
                                duration: duration,
                                curve: Curves.easeOutCubic,
                                start: selectedIndex * itemWidth,
                                top: 0,
                                bottom: 0,
                                width: itemWidth,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xffE6F1FF),
                                        Color(0xffC9DFF8)
                                      ],
                                    ),
                                    border: Border.all(color: Colors.white),
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children:
                                    List.generate(_labels.length, (index) {
                                  final selected = index == selectedIndex;
                                  final color = selected
                                      ? bgColor1
                                      : const Color(0xff66758A);
                                  return Expanded(
                                    child: Semantics(
                                      selected: selected,
                                      button: true,
                                      label: _labels[index],
                                      child: Tooltip(
                                        message: _labels[index],
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => onSelected(index),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            child: ExcludeSemantics(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  AnimatedScale(
                                                    scale: selected ? 1.08 : 1,
                                                    duration: duration,
                                                    curve: Curves.easeOutCubic,
                                                    child: Icon(
                                                      selected
                                                          ? _activeIcons[index]
                                                          : _icons[index],
                                                      color: color,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  AnimatedDefaultTextStyle(
                                                    duration: duration,
                                                    style:
                                                        blackTextStyle.copyWith(
                                                      color: color,
                                                      fontSize: 11,
                                                      fontWeight: selected
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      height: 1.2,
                                                    ),
                                                    child: Text(_labels[index],
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
