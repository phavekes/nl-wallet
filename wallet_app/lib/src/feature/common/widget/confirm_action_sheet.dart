import 'package:flutter/material.dart';

import 'bottom_sheet_drag_handle.dart';
import 'button/confirm_buttons.dart';

class ConfirmActionSheet extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String title;
  final String description;
  final String cancelButtonText;
  final IconData? cancelIcon;
  final String confirmButtonText;
  final IconData? confirmIcon;
  final Color? confirmButtonColor;
  final Widget? extraContent;

  const ConfirmActionSheet({
    this.onCancel,
    this.onConfirm,
    this.confirmButtonColor,
    required this.title,
    required this.description,
    required this.cancelButtonText,
    this.cancelIcon,
    required this.confirmButtonText,
    this.confirmIcon,
    this.extraContent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(elevatedButtonTheme: buttonTheme(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Center(child: BottomSheetDragHandle()),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (extraContent != null) extraContent!,
            const SizedBox(height: 16),
            const Divider(height: 1),
            ConfirmButtons(
              onDecline: () => onCancel?.call(),
              onAccept: () => onConfirm?.call(),
              acceptText: confirmButtonText,
              acceptIcon: confirmIcon,
              declineText: cancelButtonText,
              declineIcon: cancelIcon,
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    required String cancelButtonText,
    required String confirmButtonText,
    Color? confirmButtonColor,
    Widget? extraContent,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ConfirmActionSheet(
          title: title,
          description: description,
          cancelButtonText: cancelButtonText,
          confirmButtonText: confirmButtonText,
          onConfirm: () => Navigator.pop(context, true),
          onCancel: () => Navigator.pop(context, false),
          confirmButtonColor: confirmButtonColor,
          extraContent: extraContent,
        );
      },
    );
    return confirmed == true;
  }

  ElevatedButtonThemeData? buttonTheme(BuildContext context) {
    if (confirmButtonColor == null) return null;
    return ElevatedButtonThemeData(
      style: ElevatedButtonTheme.of(context).style?.copyWith(
            backgroundColor: MaterialStatePropertyAll(confirmButtonColor!),
          ),
    );
  }
}
