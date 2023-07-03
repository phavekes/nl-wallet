import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../util/extension/build_context_extension.dart';
import '../common/widget/placeholder_screen.dart';
import '../menu/widget/menu_row.dart';

const _kAboutUrl = 'https://edi.pleio.nl/';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aboutScreenTitle),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scrollbar(
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDescription(context),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          MenuRow(
            label: context.l10n.aboutScreenPrivacyCta,
            onTap: () => PlaceholderScreen.show(context, secured: false),
          ),
          const Divider(height: 1),
          MenuRow(
            label: context.l10n.aboutScreenTermsCta,
            onTap: () => PlaceholderScreen.show(context, secured: false),
          ),
          const Divider(height: 1),
          MenuRow(
            label: context.l10n.aboutScreenFeedbackCta,
            onTap: () => PlaceholderScreen.show(context, secured: false),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final textStyle = context.textTheme.bodyLarge;
    final fullText = context.l10n.aboutScreenDescription;
    final url = context.l10n.aboutScreenUrl;

    final startIndexOfUrl = fullText.indexOf(url);
    // Make sure the text still renders, albeit without the clickable url, if the translation requirement is not met.
    if (startIndexOfUrl < 0) return Text(context.l10n.aboutScreenDescription, style: textStyle);
    final endIndexOfUrl = startIndexOfUrl + url.length;

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: fullText.substring(0, startIndexOfUrl)),
          TextSpan(
            text: url,
            style: textStyle?.copyWith(
              color: context.colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: context.colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrlString(_kAboutUrl, mode: LaunchMode.externalApplication),
          ),
          TextSpan(text: fullText.substring(endIndexOfUrl)),
        ],
      ),
    );
  }
}