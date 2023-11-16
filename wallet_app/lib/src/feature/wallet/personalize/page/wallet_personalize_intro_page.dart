import 'package:flutter/material.dart';

import '../../../../util/extension/build_context_extension.dart';
import '../../../../wallet_assets.dart';
import '../../../common/widget/button/text_icon_button.dart';
import '../../../common/widget/sliver_sized_box.dart';

class WalletPersonalizeIntroPage extends StatelessWidget {
  final VoidCallback onLoginWithDigidPressed;
  final VoidCallback onNoDigidPressed;

  const WalletPersonalizeIntroPage({
    required this.onLoginWithDigidPressed,
    required this.onNoDigidPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            const SliverSizedBox(height: 36),
            SliverToBoxAdapter(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.walletPersonalizeIntroPageTitle,
                      textAlign: TextAlign.start,
                      style: context.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.walletPersonalizeIntroPageDescription,
                      textAlign: TextAlign.start,
                      style: context.textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
            ),
            const SliverSizedBox(height: 32),
            SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  WalletAssets.illustration_personalize_wallet_intro,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            const SliverSizedBox(height: 32),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: _buildBottomSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          key: const Key('loginWithDigidCta'),
          onPressed: onLoginWithDigidPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                WalletAssets.logo_digid,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(context.l10n.walletPersonalizeIntroPageLoginWithDigidCta),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextIconButton(
            key: const Key('noDigidCta'),
            onPressed: onNoDigidPressed,
            child: Text(context.l10n.walletPersonalizeIntroPageNoDigidCta),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
