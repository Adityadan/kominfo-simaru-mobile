import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../themes.dart';

const double simaruRadius = 24;

BoxShadow simaruShadow([double opacity = .10]) => BoxShadow(
      color: Colors.black.withOpacity(opacity),
      blurRadius: 18,
      offset: const Offset(0, 8),
    );

LinearGradient simaruHeaderGradient() => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [deepNavyColor, bgColor1, bgColor2],
    );

TextStyle simaruTitle({Color? color, double size = 26}) =>
    blueTextStyle.copyWith(
      color: color ?? bgColor1,
      fontSize: size.sp,
      fontWeight: bold,
      height: 1.15,
    );

TextStyle simaruBody({Color? color, double size = 14, FontWeight? weight}) =>
    blackTextStyle.copyWith(
      color: color ?? const Color(0xff344054),
      fontSize: size.sp,
      fontWeight: weight ?? reguler,
      height: 1.5,
    );

class SimaruGradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double height;
  final bool showLogo;
  final bool showBack;
  final Widget? action;
  final EdgeInsets padding;
  final double subtitleSize;
  final double titleSize;

  const SimaruGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 210,
    this.showLogo = false,
    this.showBack = false,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(24, 46, 24, 28),
    this.subtitleSize = 14,
    this.titleSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(gradient: simaruHeaderGradient()),
      child: Stack(
        children: [
          const Positioned(
            top: -70,
            right: -65,
            child: _HeaderBubble(size: 240),
          ),
          const Positioned(
            bottom: -115,
            left: -90,
            child: _HeaderBubble(size: 210),
          ),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLogo) _BrandMark(compact: height < 230),
                if (!showLogo)
                  Row(
                    children: [
                      if (showBack)
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 30),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (showBack) const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: simaruTitle(
                                    color: Colors.white,
                                    size: titleSize == 28 ? 25 : titleSize)),
                            if (subtitle != null) ...[
                              const SizedBox(height: 6),
                              Text(subtitle!,
                                  style: simaruBody(
                                      color: Colors.white.withOpacity(.82),
                                      size: subtitleSize)),
                            ],
                          ],
                        ),
                      ),
                      if (action != null) action!,
                    ],
                  ),
                if (showLogo) ...[
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: simaruTitle(color: Colors.white, size: titleSize),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(subtitle!,
                        style: simaruTitle(
                          color: Colors.white.withOpacity(.88),
                          size: subtitleSize,
                        ).copyWith(fontWeight: bold)),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final bool compact;
  const _BrandMark({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset('assets/logoKominfo.png',
              width: compact ? 52 : 68,
              height: compact ? 52 : 68,
              fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIMARU',
                  style:
                      simaruTitle(color: Colors.white, size: compact ? 26 : 34)
                          .copyWith(letterSpacing: 1.5)),
              Text('Sistem Informasi Manajemen Ruang',
                  style: simaruBody(
                      color: Colors.white,
                      size: compact ? 10 : 13,
                      weight: medium)),
              Text('Kominfo Jatim',
                  style: simaruBody(
                      color: Colors.white,
                      size: compact ? 10 : 13,
                      weight: medium)),
            ],
          ),
        ),
      ],
    );
  }
}

class SimaruCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const SimaruCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20),
      this.margin = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(simaruRadius),
        boxShadow: [simaruShadow(.09)],
        border: Border.all(color: const Color(0xffEEF2F7)),
      ),
      child: child,
    );
  }
}

class SimaruPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool outlined;

  const SimaruPrimaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 56.r.clamp(48.0, 64.0)),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: icon == null
            ? const SizedBox.shrink()
            : Icon(icon, size: 22, color: outlined ? bgColor1 : Colors.white),
        label: Text(label,
            style: (outlined ? blueTextStyle : whiteTextStyle)
                .copyWith(fontSize: 16.sp, fontWeight: semibold)),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 12.r),
          backgroundColor: outlined ? Colors.white : bgColor1,
          foregroundColor: outlined ? bgColor1 : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: bgColor1)),
        ),
      ),
    );
  }
}

InputDecoration simaruInputDecoration(
    {required String hint, required IconData icon, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: simaruBody(color: const Color(0xff98A2B3), size: 15),
    prefixIcon: Icon(icon, color: const Color(0xff91A0B8)),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderBlueColor)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: bgColor1, width: 1.4)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class SimaruBottomCurve extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const SimaruBottomCurve(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.fromLTRB(18, 28, 18, 24)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: child,
    );
  }
}

class _HeaderBubble extends StatelessWidget {
  const _HeaderBubble({required this.size});
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
