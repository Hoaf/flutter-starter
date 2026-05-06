import 'package:flutter/material.dart';

class ModalBottomSheetProps {
  final ShapeBorder? shape;
  final bool useRootNavigator;
  final BoxConstraints? constraints;
  final double? elevation;
  final Color? barrierColor;
  final Color? backgroundColor;
  final bool barrierDismissible;
  final Clip clipBehavior;
  final AnimationController? animation;
  final bool enableDrag;
  final Offset? anchorPoint;
  final bool isScrollControlled;
  final EdgeInsets padding;
  final bool useSafeArea;
  final bool? showDragHandle;
  final AnimationStyle? sheetAnimationStyle;
  final String? barrierLabel;
  final double scrollControlDisabledMaxHeightRatio;
  final RouteSettings? routeSettings;

  const ModalBottomSheetProps({
    this.anchorPoint,
    this.elevation,
    this.shape,
    this.barrierColor,
    this.backgroundColor,
    this.barrierDismissible = true,
    this.animation,
    this.enableDrag = true,
    this.clipBehavior = Clip.none,
    this.useRootNavigator = false,
    this.constraints,
    this.isScrollControlled = true,
    this.padding = EdgeInsets.zero,
    this.useSafeArea = true,
    this.sheetAnimationStyle,
    this.showDragHandle,
    this.barrierLabel,
    this.scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
    this.routeSettings,
  });
}

class ModalBottomSheetUtils {
  static Future<T?> openMaterialModalBottomSheet<T>(
      BuildContext context, Widget content, ModalBottomSheetProps props) {
    final sheetTheme = Theme.of(context).bottomSheetTheme;
    return showModalBottomSheet<T>(
      context: context,
      barrierLabel: props.barrierLabel,
      scrollControlDisabledMaxHeightRatio:
      props.scrollControlDisabledMaxHeightRatio,
      showDragHandle: props.showDragHandle,
      sheetAnimationStyle: props.sheetAnimationStyle,
      useSafeArea: props.useSafeArea,
      barrierColor: props.barrierColor,
      backgroundColor: props.backgroundColor ??
          sheetTheme.modalBackgroundColor ??
          sheetTheme.backgroundColor,
      isDismissible: props.barrierDismissible,
      isScrollControlled: props.isScrollControlled,
      enableDrag: props.enableDrag,
      clipBehavior: props.clipBehavior,
      elevation: props.elevation,
      shape: props.shape,
      anchorPoint: props.anchorPoint,
      useRootNavigator: props.useRootNavigator,
      transitionAnimationController: props.animation,
      constraints: props.constraints,
      routeSettings: props.routeSettings,
      builder: (ctx) {
        return Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: content,
        );
      },
    );
  }
}