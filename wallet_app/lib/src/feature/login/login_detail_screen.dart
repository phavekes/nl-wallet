import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/attribute/attribute.dart';
import '../../domain/model/attribute/data_attribute.dart';
import '../../domain/model/organization.dart';
import '../../domain/model/policy/policy.dart';
import '../../domain/model/wallet_card.dart';
import '../../navigation/secured_page_route.dart';
import '../../util/extension/build_context_extension.dart';
import '../../util/mapper/context_mapper.dart';
import '../check_attributes/check_attributes_screen.dart';
import '../common/screen/placeholder_screen.dart';
import '../common/widget/button/bottom_back_button.dart';
import '../common/widget/button/link_button.dart';
import '../common/widget/card/shared_attributes_card.dart';
import '../common/widget/organization/organization_logo.dart';
import '../common/widget/sliver_divider.dart';
import '../common/widget/sliver_sized_box.dart';
import '../common/widget/sliver_wallet_app_bar.dart';
import '../organization/detail/organization_detail_screen.dart';
import '../policy/policy_screen.dart';
import 'argument/login_detail_screen_argument.dart';

class LoginDetailScreen extends StatelessWidget {
  final Organization organization;
  final Policy policy;
  final Map<WalletCard, List<DataAttribute>> requestedAttributes;
  final bool sharedDataWithOrganizationBefore;
  final VoidCallback? onReportIssuePressed;

  static LoginDetailScreenArgument getArgument(RouteSettings settings) {
    final args = settings.arguments;
    try {
      return args as LoginDetailScreenArgument;
    } catch (exception, stacktrace) {
      Fimber.e('Failed to decode $args', ex: exception, stacktrace: stacktrace);
      throw UnsupportedError('Make sure to pass in [LoginDetailScreenArgument] when opening the LoginDetailScreen');
    }
  }

  const LoginDetailScreen({
    required this.organization,
    required this.policy,
    required this.requestedAttributes,
    required this.sharedDataWithOrganizationBefore,
    this.onReportIssuePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(context),
            ),
            const BottomBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scrollbar(
      child: CustomScrollView(
        slivers: [
          SliverWalletAppBar(
            title: context.l10n.loginDetailScreenTitle(organization.displayName.l10nValue(context)),
            actions: [
              IconButton(
                onPressed: () => PlaceholderScreen.show(context),
                icon: const Icon(Icons.help_outline_rounded),
              ),
            ],
          ),
          const SliverSizedBox(height: 24),
          const SliverDivider(height: 1),
          _buildOrganizationSection(context),
          const SliverDivider(height: 1),
          _buildAttributesSection(context),
          const SliverDivider(height: 1),
          _buildAgreementSection(context),
        ],
      ),
    );
  }

  Widget _buildOrganizationSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => OrganizationDetailScreen.showPreloaded(
          context,
          organization,
          sharedDataWithOrganizationBefore,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: OrganizationLogo(image: organization.logo, size: 32, fixedRadius: 8),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.displayName.l10nValue(context),
                      textAlign: TextAlign.start,
                      style: context.textTheme.labelLarge,
                    ),
                    Text(
                      organization.category?.l10nValue(context) ?? '',
                      textAlign: TextAlign.start,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributesSection(BuildContext context) {
    final attributesSliver = SliverList.separated(
      itemCount: requestedAttributes.length,
      itemBuilder: (context, i) {
        final entry = requestedAttributes.entries.elementAt(i);
        return SharedAttributesCard(
          card: entry.key,
          attributes: entry.value,
          onTap: () => CheckAttributesScreen.show(
            context,
            card: entry.key,
            attributes: entry.value,
            onDataIncorrectPressed: () => PlaceholderScreen.show(context, secured: true),
          ),
        );
      },
      separatorBuilder: (context, i) => const SizedBox(height: 16),
    );
    final headerSliver = SliverList.list(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.credit_card_outlined),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.loginDetailScreenCredentialsTitle,
          style: context.textTheme.headlineMedium,
        ),
        Text(
          context.l10n.loginDetailScreenCredentialsBody,
          style: context.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
      ],
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      sliver: SliverMainAxisGroup(
        slivers: [
          headerSliver,
          attributesSliver,
        ],
      ),
    );
  }

  Widget _buildAgreementSection(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      sliver: SliverList.list(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.handshake_outlined),
          ),
          const SizedBox(height: 16),
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.loginDetailScreenAgreementTitle,
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  context.read<ContextMapper<Policy, String>>().map(context, policy),
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: LinkButton(
              customPadding: EdgeInsets.zero,
              child: Text(context.l10n.loginDetailScreenAgreementCta),
              onPressed: () => PolicyScreen.show(context, policy),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    Organization organization,
    Policy policy,
    Map<WalletCard, List<DataAttribute>> requestedAttributes,
    bool sharedDataWithOrganizationBefore, {
    VoidCallback? onReportIssuePressed,
  }) {
    return Navigator.push(
      context,
      SecuredPageRoute(
        builder: (context) {
          return LoginDetailScreen(
            organization: organization,
            policy: policy,
            requestedAttributes: requestedAttributes,
            sharedDataWithOrganizationBefore: sharedDataWithOrganizationBefore,
            onReportIssuePressed: onReportIssuePressed,
          );
        },
      ),
    );
  }
}
