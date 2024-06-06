import 'package:flutter/material.dart';

import '../../../navigation/wallet_routes.dart';
import '../../../util/extension/build_context_extension.dart';
import '../widget/text/body_text.dart';
import '../widget/text/title_text.dart';

class ScanWithWalletDialog extends StatelessWidget {
  const ScanWithWalletDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitleText(
        context.l10n.scanWithWalletDialogTitle,
        style: context.textTheme.displayMedium,
      ),
      content: BodyText(context.l10n.scanWithWalletDialogBody),
      actions: <Widget>[
        TextButton(
          child: Text(context.l10n.generalClose.toUpperCase()),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(context.l10n.scanWithWalletDialogScanCta.toUpperCase()),
          onPressed: () async {
            final navigator = Navigator.of(context);
            navigator.pushNamedAndRemoveUntil(
              WalletRoutes.qrRoute,
              ModalRoute.withName(WalletRoutes.dashboardRoute),
            );
          },
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => const ScanWithWalletDialog(),
    );
  }
}
