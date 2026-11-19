/*
MIT License

Copyright (c) 2018 Liu Yanbo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
// Renderer adapted from flutter_datetime_picker_plus 2.4.0.
// Preserve its wheel layout; add booking availability and automatic scrolling.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    show
        BasePickerModel,
        DatePickerModel,
        DateTimePickerModel,
        LocaleType,
        i18nObjInLocale;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker_theme;

typedef DateChangedCallback = void Function(DateTime time);
typedef DateCancelledCallback = void Function();
typedef StringAtIndexCallBack = String? Function(int index);

/// Builds a replacement for the default Cancel/Done title bar.
///
/// Call [onCancel] to dismiss the picker (also fires the `onCancel` callback);
/// call [onConfirm] to dismiss it returning the current selection (also fires
/// the `onConfirm` callback). [currentTime] is the value currently selected by
/// the wheels.
///
/// The returned widget is laid out within the theme's `titleHeight`, so keep
/// it within that height (or raise `titleHeight` on a custom `DatePickerTheme`).
/// Only used when `showTitleActions` is `true`.
typedef TitleActionsBuilder = Widget Function(
  BuildContext context,
  VoidCallback onCancel,
  VoidCallback onConfirm,
  DateTime currentTime,
);

class BookingDatePicker {
  static Future<DateTime?> showDateTimePicker(
    BuildContext context, {
    bool showTitleActions = true,
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    DateChangedCallback? onSelectionRequested,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    DateTime? currentTime,
    DateTime? initialTime,
    picker_theme.DatePickerTheme? theme,
    TitleActionsBuilder? titleActionsBuilder,
    bool Function(DateTime)? isTimeAvailable,
    DateTime? Function(DateTime)? nextAvailableTime,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onSelectionRequested: onSelectionRequested,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        titleActionsBuilder: titleActionsBuilder,
        isTimeAvailable: isTimeAvailable,
        nextAvailableTime: nextAvailableTime,
        initialTime: initialTime,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: DateTimePickerModel(
          currentTime: currentTime,
          minTime: minTime,
          maxTime: maxTime,
          locale: locale,
        ),
      ),
    );
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.showTitleActions,
    this.onChanged,
    this.onSelectionRequested,
    this.onConfirm,
    this.onCancel,
    picker_theme.DatePickerTheme? theme,
    this.barrierLabel,
    this.locale,
    this.titleActionsBuilder,
    this.isTimeAvailable,
    this.nextAvailableTime,
    this.initialTime,
    super.settings,
    BasePickerModel? pickerModel,
  })  : pickerModel = pickerModel ?? DatePickerModel(),
        theme = theme ?? const picker_theme.DatePickerTheme();

  final bool? showTitleActions;
  final DateChangedCallback? onChanged;
  final DateChangedCallback? onSelectionRequested;
  final DateChangedCallback? onConfirm;
  final DateCancelledCallback? onCancel;
  final LocaleType? locale;
  final picker_theme.DatePickerTheme theme;
  final BasePickerModel pickerModel;
  final TitleActionsBuilder? titleActionsBuilder;
  final bool Function(DateTime)? isTimeAvailable;
  final DateTime? Function(DateTime)? nextAvailableTime;
  final DateTime? initialTime;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(
        onChanged: onChanged,
        locale: locale,
        route: this,
        pickerModel: pickerModel,
      ),
    );
    return InheritedTheme.captureAll(context, bottomSheet);
  }
}

class _DatePickerComponent extends StatefulWidget {
  const _DatePickerComponent({
    required this.route,
    required this.pickerModel,
    this.onChanged,
    this.locale,
  });

  final DateChangedCallback? onChanged;

  final _DatePickerRoute route;

  final LocaleType? locale;

  final BasePickerModel pickerModel;

  @override
  State<StatefulWidget> createState() {
    return _DatePickerState();
  }
}

class _DatePickerState extends State<_DatePickerComponent> {
  late FixedExtentScrollController leftScrollCtrl,
      middleScrollCtrl,
      rightScrollCtrl;
  bool _adjusting = false;
  bool _confirming = false;
  final Map<DateTime, bool> _hourAvailability = {};
  final Map<DateTime, bool> _dayAvailability = {};

  @override
  void initState() {
    super.initState();
    if (widget.route.initialTime != null) _setTime(widget.route.initialTime!);
    refreshScrollOffset();
    WidgetsBinding.instance.addPostFrameCallback((_) => _settleSelection());
  }

  void refreshScrollOffset() {
    leftScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentLeftIndex());
    middleScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentMiddleIndex());
    rightScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentRightIndex());
  }

  @override
  void dispose() {
    leftScrollCtrl.dispose();
    middleScrollCtrl.dispose();
    rightScrollCtrl.dispose();
    super.dispose();
  }

  DateTime _candidate(int column, int index) {
    final model = widget.pickerModel as DateTimePickerModel;
    final copy = DateTimePickerModel(
        currentTime: model.currentTime,
        minTime: model.minTime,
        maxTime: model.maxTime,
        locale: model.locale);
    copy.setLeftIndex(model.currentLeftIndex());
    copy.setMiddleIndex(model.currentMiddleIndex());
    copy.setRightIndex(model.currentRightIndex());
    if (column == 0) copy.setLeftIndex(index);
    if (column == 1) copy.setMiddleIndex(index);
    if (column == 2) copy.setRightIndex(index);
    return copy.finalTime();
  }

  bool _available(DateTime time) =>
      widget.route.isTimeAvailable?.call(time) ?? true;

  bool _itemAvailable(int column, int index) {
    if (widget.route.isTimeAvailable == null) return true;
    final time = _candidate(column, index);
    if (column == 2) return _available(time);
    if (column == 1) {
      final hour = DateTime(time.year, time.month, time.day, time.hour);
      return _hourAvailability.putIfAbsent(
          hour,
          () => List.generate(60, (minute) => minute).any((minute) =>
              _available(DateTime(
                  time.year, time.month, time.day, time.hour, minute))));
    }
    // A date is grey only when every minute on that date is unavailable.
    final day = DateTime(time.year, time.month, time.day);
    return _dayAvailability.putIfAbsent(day, () {
      for (var hour = 0; hour < 24; hour++) {
        for (var minute = 0; minute < 60; minute++) {
          if (_available(
              DateTime(time.year, time.month, time.day, hour, minute))) {
            return true;
          }
        }
      }
      return false;
    });
  }

  void _setTime(DateTime time) {
    final model = widget.pickerModel as DateTimePickerModel;
    final origin = model.currentTime;
    final dayIndex = DateTime(time.year, time.month, time.day)
        .difference(DateTime(origin.year, origin.month, origin.day))
        .inDays;
    model.setLeftIndex(dayIndex);
    final hourIndex = List.generate(24, (index) => index).firstWhere((index) =>
        int.tryParse(model.middleStringAtIndex(index) ?? '') == time.hour);
    model.setMiddleIndex(hourIndex);
    final minuteIndex = List.generate(60, (index) => index).firstWhere(
        (index) =>
            int.tryParse(model.rightStringAtIndex(index) ?? '') == time.minute);
    model.setRightIndex(minuteIndex);
  }

  Future<void> _settleSelection() async {
    if (!mounted || _adjusting) return;
    final time = widget.pickerModel.finalTime()!;
    var target = time;
    if (!_available(time)) {
      final next = widget.route.nextAvailableTime?.call(time);
      if (next == null || !_available(next)) {
        setState(() {});
        return;
      }
      target = next;
    }
    if (leftScrollCtrl.selectedItem == widget.pickerModel.currentLeftIndex() &&
        middleScrollCtrl.selectedItem ==
            widget.pickerModel.currentMiddleIndex() &&
        rightScrollCtrl.selectedItem ==
            widget.pickerModel.currentRightIndex() &&
        target.isAtSameMomentAs(time)) {
      _notifyDateChanged();
      return;
    }
    _adjusting = true;
    setState(() => _setTime(target));
    try {
      await Future.wait([
        leftScrollCtrl.animateToItem(widget.pickerModel.currentLeftIndex(),
            duration: const Duration(milliseconds: 350), curve: Curves.easeOut),
        middleScrollCtrl.animateToItem(widget.pickerModel.currentMiddleIndex(),
            duration: const Duration(milliseconds: 350), curve: Curves.easeOut),
        rightScrollCtrl.animateToItem(widget.pickerModel.currentRightIndex(),
            duration: const Duration(milliseconds: 350), curve: Curves.easeOut),
      ]);
    } finally {
      if (mounted) {
        setState(() => _adjusting = false);
        _notifyDateChanged();
      }
    }
  }

  void _selectionEnded(int column, int index) {
    if (_adjusting) return;
    // The wheel's selection notification may follow its scroll-end event.
    // Resolve after that frame so the correction uses the final wheel value.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _adjusting) return;
      setState(() {
        if (column == 0) widget.pickerModel.setLeftIndex(index);
        if (column == 1) widget.pickerModel.setMiddleIndex(index);
        if (column == 2) widget.pickerModel.setRightIndex(index);
      });
      widget.route.onSelectionRequested?.call(widget.pickerModel.finalTime()!);
      _settleSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    picker_theme.DatePickerTheme theme = widget.route.theme;
    return GestureDetector(
      child: AnimatedBuilder(
        animation: widget.route.animation!,
        builder: (BuildContext context, Widget? child) {
          final double bottomPadding = MediaQuery.of(context).padding.bottom;
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(
                widget.route.animation!.value,
                theme,
                showTitleActions: widget.route.showTitleActions!,
                bottomPadding: bottomPadding,
              ),
              child: GestureDetector(
                child: Material(
                  color: theme.backgroundColor,
                  child: _renderPickerView(theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.pickerModel.finalTime()!);
    }
  }

  Widget _renderPickerView(picker_theme.DatePickerTheme theme) {
    Widget itemView = _renderItemView(theme);
    if (widget.route.showTitleActions == true) {
      return Column(
        children: <Widget>[
          _renderTitleActionsView(theme),
          itemView,
        ],
      );
    }
    return itemView;
  }

  Widget _renderColumnView(
    ValueKey<String> key,
    int column,
    picker_theme.DatePickerTheme theme,
    StringAtIndexCallBack stringAtIndexCB,
    ScrollController scrollController,
    int layoutProportion,
    ValueChanged<int> selectedChangedWhenScrolling,
    ValueChanged<int> selectedChangedWhenScrollEnd,
  ) {
    return Expanded(
      flex: layoutProportion,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: theme.containerHeight,
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: NotificationListener(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                notification is ScrollEndNotification &&
                notification.metrics is FixedExtentMetrics) {
              final FixedExtentMetrics metrics =
                  notification.metrics as FixedExtentMetrics;
              final int currentItemIndex = metrics.itemIndex;
              selectedChangedWhenScrollEnd(currentItemIndex);
            }
            return false;
          },
          child: CupertinoPicker.builder(
            key: key,
            backgroundColor: theme.backgroundColor,
            scrollController: scrollController as FixedExtentScrollController,
            itemExtent: theme.itemHeight,
            onSelectedItemChanged: (int index) {
              selectedChangedWhenScrolling(index);
            },
            useMagnifier: true,
            itemBuilder: (BuildContext context, int index) {
              final content = stringAtIndexCB(index);
              if (content == null) {
                return null;
              }
              return Container(
                height: theme.itemHeight,
                alignment: Alignment.center,
                child: Text(
                  content,
                  style: _itemAvailable(column, index)
                      ? theme.itemStyle
                      : theme.itemStyle
                          .copyWith(color: const Color(0xFFD1D5DB)),
                  textAlign: TextAlign.start,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _renderItemView(picker_theme.DatePickerTheme theme) {
    return Container(
      color: theme.backgroundColor,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: widget.pickerModel.layoutProportions()[0] > 0
                  ? _renderColumnView(
                      const ValueKey('booking-date-wheel'),
                      0,
                      theme,
                      widget.pickerModel.leftStringAtIndex,
                      leftScrollCtrl,
                      widget.pickerModel.layoutProportions()[0], (index) {
                      if (!_adjusting) {
                        setState(() => widget.pickerModel.setLeftIndex(index));
                      }
                    }, (index) {
                      _selectionEnded(0, index);
                    })
                  : null,
            ),
            Text(
              widget.pickerModel.leftDivider(),
              style: theme.itemStyle,
            ),
            Container(
              child: widget.pickerModel.layoutProportions()[1] > 0
                  ? _renderColumnView(
                      const ValueKey('booking-hour-wheel'),
                      1,
                      theme,
                      widget.pickerModel.middleStringAtIndex,
                      middleScrollCtrl,
                      widget.pickerModel.layoutProportions()[1], (index) {
                      if (!_adjusting) {
                        setState(
                            () => widget.pickerModel.setMiddleIndex(index));
                      }
                    }, (index) {
                      _selectionEnded(1, index);
                    })
                  : null,
            ),
            Text(
              widget.pickerModel.rightDivider(),
              style: theme.itemStyle,
            ),
            Container(
              child: widget.pickerModel.layoutProportions()[2] > 0
                  ? _renderColumnView(
                      const ValueKey('booking-minute-wheel'),
                      2,
                      theme,
                      widget.pickerModel.rightStringAtIndex,
                      rightScrollCtrl,
                      widget.pickerModel.layoutProportions()[2], (index) {
                      if (!_adjusting) {
                        setState(() => widget.pickerModel.setRightIndex(index));
                      }
                    }, (index) {
                      _selectionEnded(2, index);
                    })
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _onCancel() {
    Navigator.pop(context);
    widget.route.onCancel?.call();
  }

  void _onConfirm() async {
    if (_adjusting || _confirming) return;
    _confirming = true;
    await _settleSelection();
    if (!mounted) return;
    if (!_available(widget.pickerModel.finalTime()!)) {
      _confirming = false;
      return;
    }
    Navigator.pop(context, widget.pickerModel.finalTime());
    widget.route.onConfirm?.call(widget.pickerModel.finalTime()!);
  }

  // Title View
  Widget _renderTitleActionsView(picker_theme.DatePickerTheme theme) {
    final builder = widget.route.titleActionsBuilder;
    if (builder != null) {
      return builder(
        context,
        _onCancel,
        _onConfirm,
        widget.pickerModel.finalTime()!,
      );
    }

    final done = _localeDone();
    final cancel = _localeCancel();

    return Container(
      height: theme.titleHeight,
      decoration: BoxDecoration(
        color: theme.headerColor ?? theme.backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: theme.titleHeight,
            child: CupertinoButton(
              pressedOpacity: 0.3,
              padding: const EdgeInsetsDirectional.only(start: 16, top: 0),
              onPressed: _onCancel,
              child: Text(cancel, style: theme.cancelStyle),
            ),
          ),
          SizedBox(
            height: theme.titleHeight,
            child: CupertinoButton(
              pressedOpacity: 0.3,
              padding: const EdgeInsetsDirectional.only(end: 16, top: 0),
              onPressed:
                  _adjusting || !_available(widget.pickerModel.finalTime()!)
                      ? null
                      : _onConfirm,
              child: Text(done, style: theme.doneStyle),
            ),
          ),
        ],
      ),
    );
  }

  String _localeDone() {
    return i18nObjInLocale(widget.locale)['done'] as String;
  }

  String _localeCancel() {
    return i18nObjInLocale(widget.locale)['cancel'] as String;
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(
    this.progress,
    this.theme, {
    this.showTitleActions,
    this.bottomPadding = 0,
  });

  final double progress;
  final bool? showTitleActions;
  final picker_theme.DatePickerTheme theme;
  final double bottomPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = theme.containerHeight;
    if (showTitleActions == true) {
      maxHeight += theme.titleHeight;
    }

    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: maxHeight + bottomPadding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
