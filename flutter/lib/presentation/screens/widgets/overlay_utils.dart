import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_font_sizes.dart';

class OverlayUtils {
  static OverlayState? _overlayState;
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static showOverlayDropdownData(
      BuildContext context,
      LayerLink layerLink,
      Function(List<String>) onSelected,
      {
        bool barrierDismissible = true,
        bool showLabelMaterial = true,
        List<String> dropdownData = const [],
        List<String> selectedDropdownData = const [],
        CrossAxisAlignment? crossAxisAlignment
        // isSearchable = false,
      }
      ) {
    _overlayState = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final position = renderBox.localToGlobal(Offset.zero);
    Offset offset = Offset(position.dx, position.dy);

    removeOverlay(context);

    _isShowing = true;

    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          width: size.width,
          left: offset.dx,
          top: offset.dy,
          child: TapRegion(
            onTapOutside: (tap) {
              removeOverlay(context);
            },
            child: Material(
              color: AppColors.transparent,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => removeOverlay(context),
                      child: Container(
                        color: AppColors.transparent,
                        height: size.height - (showLabelMaterial ? 8 : 0),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: AppColors.gray),
                          borderRadius: BorderRadius.circular(5)
                      ),
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: SingleChildScrollView(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: dropdownData.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                onSelected.call([item]);
                                removeOverlay(context);
                              },
                              child: Text(item,
                                style: TextStyle(
                                  fontWeight: selectedDropdownData.contains(item) ? FontWeight.bold : FontWeight.normal,
                                  fontSize: AppFontSizes.fs_15
                                ),
                              ),
                            )
                          )).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      );
    });

    _overlayState?.insert(_overlayEntry!);
  }

  static removeOverlay(BuildContext context) {
    _overlayState = Overlay.of(context);

    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _isShowing = false;
  }

  static bool get isActivated => _isShowing;
}