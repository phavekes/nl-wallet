import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/usecase/app/check_is_app_initialized_usecase.dart';
import '../domain/usecase/card/get_wallet_card_data_attributes_usecase.dart';
import '../domain/usecase/card/get_wallet_card_summary_usecase.dart';
import '../domain/usecase/card/get_wallet_cards_usecase.dart';
import '../domain/usecase/card/lock_wallet_usecase.dart';
import '../domain/usecase/pin/get_available_pin_attempts_usecase.dart';
import '../domain/usecase/pin/unlock_wallet_usecase.dart';
import '../domain/usecase/qr/decode_qr_usecase.dart';
import '../domain/usecase/verification/get_verification_request_usecase.dart';
import '../domain/usecase/verification/get_verifier_policy_usecase.dart';

/// This widget is responsible for initializing and providing all `use cases`.
/// Most likely to be used once at the top (app) level, but notable below the
/// [WalletRepositoryProvider] as `use cases` will likely depend on one or more
/// `repositories`.
class WalletUseCaseProvider extends StatelessWidget {
  final Widget child;

  const WalletUseCaseProvider({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CheckIsAppInitializedUseCase>(
          create: (context) => CheckIsAppInitializedUseCase(context.read()),
        ),
        RepositoryProvider<UnlockWalletUseCase>(
          create: (context) => UnlockWalletUseCase(context.read()),
        ),
        RepositoryProvider<GetAvailablePinAttemptsUseCase>(
          create: (context) => GetAvailablePinAttemptsUseCase(context.read()),
        ),
        RepositoryProvider<GetVerificationRequestUseCase>(
          create: (context) => GetVerificationRequestUseCase(context.read()),
        ),
        RepositoryProvider<GetVerifierPolicyUseCase>(
          create: (context) => GetVerifierPolicyUseCase(context.read()),
        ),
        RepositoryProvider<LockWalletUseCase>(
          create: (context) => LockWalletUseCase(context.read()),
        ),
        RepositoryProvider<GetWalletCardsUseCase>(
          create: (context) => GetWalletCardsUseCase(context.read()),
        ),
        RepositoryProvider<GetWalletCardSummaryUseCase>(
          create: (context) => GetWalletCardSummaryUseCase(
            context.read(),
            context.read(),
            context.read(),
          ),
        ),
        RepositoryProvider<GetWalletCardDataAttributesUseCase>(
          create: (context) => GetWalletCardDataAttributesUseCase(context.read()),
        ),
        RepositoryProvider<DecodeQrUseCase>(
          create: (context) => DecodeQrUseCase(context.read()),
        ),
      ],
      child: child,
    );
  }
}