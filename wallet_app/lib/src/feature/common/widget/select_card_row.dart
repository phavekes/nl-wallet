import 'package:flutter/material.dart';

import '../../../domain/model/wallet_card.dart';
import 'card/sized_card_front.dart';

const _kCardDisplayWidth = 40.0;

class SelectCardRow extends StatelessWidget {
  final Function(WalletCard) onCardSelectionToggled;
  final WalletCard card;
  final bool isSelected;
  final bool showError;

  const SelectCardRow({
    required this.onCardSelectionToggled,
    required this.card,
    required this.isSelected,
    this.showError = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          constraints: const BoxConstraints(minHeight: 96),
          child: InkWell(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedCardFront(
                    cardFront: card.front,
                    displayWidth: _kCardDisplayWidth,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.front.title, style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        card.front.subtitle ?? card.front.info ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (checked) => onCardSelectionToggled(card),
                  fillColor: showError ? MaterialStatePropertyAll(Theme.of(context).colorScheme.error) : null,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
