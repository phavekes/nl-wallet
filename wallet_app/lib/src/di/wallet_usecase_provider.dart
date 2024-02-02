import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../domain/usecase/app/check_is_app_initialized_usecase.dart';
import '../domain/usecase/app/impl/check_is_app_initialized_usecase_impl.dart';
import '../domain/usecase/card/get_wallet_card_timeline_attributes_usecase.dart';
import '../domain/usecase/card/get_wallet_card_update_request_usecase.dart';
import '../domain/usecase/card/get_wallet_card_usecase.dart';
import '../domain/usecase/card/get_wallet_cards_usecase.dart';
import '../domain/usecase/card/impl/get_wallet_card_timeline_attributes_usecase_impl.dart';
import '../domain/usecase/card/impl/get_wallet_card_update_request_usecase_impl.dart';
import '../domain/usecase/card/impl/get_wallet_card_usecase_impl.dart';
import '../domain/usecase/card/impl/get_wallet_cards_usecase_impl.dart';
import '../domain/usecase/card/impl/lock_wallet_usecase_impl.dart';
import '../domain/usecase/card/impl/observe_wallet_card_detail_usecase_impl.dart';
import '../domain/usecase/card/impl/observe_wallet_card_usecase_impl.dart';
import '../domain/usecase/card/impl/observe_wallet_cards_usecase_impl.dart';
import '../domain/usecase/card/lock_wallet_usecase.dart';
import '../domain/usecase/card/observe_wallet_card_detail_usecase.dart';
import '../domain/usecase/card/observe_wallet_card_usecase.dart';
import '../domain/usecase/card/observe_wallet_cards_usecase.dart';
import '../domain/usecase/disclosure/accept_disclosure_usecase.dart';
import '../domain/usecase/disclosure/cancel_disclosure_usecase.dart';
import '../domain/usecase/disclosure/impl/accept_disclosure_usecase_impl.dart';
import '../domain/usecase/disclosure/impl/cancel_disclosure_usecase_impl.dart';
import '../domain/usecase/disclosure/impl/start_disclosure_usecase_impl.dart';
import '../domain/usecase/disclosure/start_disclosure_usecase.dart';
import '../domain/usecase/history/get_wallet_timeline_attributes_usecase.dart';
import '../domain/usecase/history/impl/get_wallet_timeline_attributes_usecase_impl.dart';
import '../domain/usecase/issuance/accept_issuance_usecase.dart';
import '../domain/usecase/issuance/cancel_issuance_usecase.dart';
import '../domain/usecase/issuance/continue_issuance_usecase.dart';
import '../domain/usecase/issuance/impl/accept_issuance_usecase_impl.dart';
import '../domain/usecase/issuance/impl/cancel_issuance_usecase_impl.dart';
import '../domain/usecase/issuance/impl/continue_issuance_usecase_impl.dart';
import '../domain/usecase/issuance/impl/start_issuance_usecase_impl.dart';
import '../domain/usecase/issuance/start_issuance_usecase.dart';
import '../domain/usecase/navigation/check_navigation_prerequisites_usecase.dart';
import '../domain/usecase/navigation/impl/check_navigation_prerequisites_usecase_impl.dart';
import '../domain/usecase/navigation/impl/perform_pre_navigation_actions_usecase_impl.dart';
import '../domain/usecase/navigation/perform_pre_navigation_actions_usecase.dart';
import '../domain/usecase/network/check_has_internet_usecase.dart';
import '../domain/usecase/network/impl/check_has_internet_usecase_impl.dart';
import '../domain/usecase/pid/accept_offered_pid_usecase.dart';
import '../domain/usecase/pid/cancel_pid_issuance_usecase.dart';
import '../domain/usecase/pid/continue_pid_issuance_usecase.dart';
import '../domain/usecase/pid/get_pid_issuance_url_usecase.dart';
import '../domain/usecase/pid/impl/accept_offered_pid_usecase_impl.dart';
import '../domain/usecase/pid/impl/cancel_pid_issuance_usecase_impl.dart';
import '../domain/usecase/pid/impl/continue_pid_issuance_usecase_impl.dart';
import '../domain/usecase/pid/impl/get_pid_issuance_url_usecase_impl.dart';
import '../domain/usecase/pid/impl/reject_offered_pid_usecase_impl.dart';
import '../domain/usecase/pid/reject_offered_pid_usecase.dart';
import '../domain/usecase/pin/check_is_valid_pin_usecase.dart';
import '../domain/usecase/pin/confirm_transaction_usecase.dart';
import '../domain/usecase/pin/disclose_for_issuance_usecase.dart';
import '../domain/usecase/pin/impl/check_is_valid_pin_usecase_impl.dart';
import '../domain/usecase/pin/impl/confirm_transaction_usecase_impl.dart';
import '../domain/usecase/pin/impl/disclose_for_issuance_usecase_impl.dart';
import '../domain/usecase/pin/impl/unlock_wallet_with_pin_usecase_impl.dart';
import '../domain/usecase/pin/unlock_wallet_with_pin_usecase.dart';
import '../domain/usecase/qr/decode_qr_usecase.dart';
import '../domain/usecase/qr/impl/decode_qr_usecase_impl.dart';
import '../domain/usecase/sign/accept_sign_agreement_usecase.dart';
import '../domain/usecase/sign/impl/accept_sign_agreement_usecase_impl.dart';
import '../domain/usecase/sign/impl/reject_sign_agreement_usecase_impl.dart';
import '../domain/usecase/sign/impl/start_sign_usecase_impl.dart';
import '../domain/usecase/sign/reject_sign_agreement_usecase.dart';
import '../domain/usecase/sign/start_sign_usecase.dart';
import '../domain/usecase/uri/decode_uri_usecase.dart';
import '../domain/usecase/uri/impl/decode_uri_usecase_impl.dart';
import '../domain/usecase/wallet/create_wallet_usecase.dart';
import '../domain/usecase/wallet/get_first_names_usecase.dart';
import '../domain/usecase/wallet/get_requested_attributes_from_wallet_usecase.dart';
import '../domain/usecase/wallet/get_requested_attributes_with_card_usecase.dart';
import '../domain/usecase/wallet/impl/create_wallet_usecase_impl.dart';
import '../domain/usecase/wallet/impl/get_first_names_usecase_impl.dart';
import '../domain/usecase/wallet/impl/get_requested_attributes_from_wallet_usecase_impl.dart';
import '../domain/usecase/wallet/impl/get_requested_attributes_with_card_usecase_impl.dart';
import '../domain/usecase/wallet/impl/is_wallet_initialized_with_pid_impl.dart';
import '../domain/usecase/wallet/impl/observe_wallet_locked_usecase_impl.dart';
import '../domain/usecase/wallet/impl/reset_wallet_usecase_impl.dart';
import '../domain/usecase/wallet/impl/setup_mocked_wallet_usecase_impl.dart';
import '../domain/usecase/wallet/is_wallet_initialized_with_pid_usecase.dart';
import '../domain/usecase/wallet/observe_wallet_locked_usecase.dart';
import '../domain/usecase/wallet/reset_wallet_usecase.dart';
import '../domain/usecase/wallet/setup_mocked_wallet_usecase.dart';
import '../util/extension/bloc_extension.dart';

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
        RepositoryProvider<IsWalletInitializedUseCase>(
          create: (context) => IsWalletInitializedUseCaseImpl(context.read()),
        ),
        RepositoryProvider<UnlockWalletWithPinUseCase>(
          create: (context) => UnlockWalletWithPinUseCaseImpl(context.read()),
        ),
        RepositoryProvider<CreateWalletUseCase>(
          create: (context) => CreateWalletUseCaseImpl(context.read()),
        ),
        RepositoryProvider<CheckIsValidPinUseCase>(
          create: (context) => CheckIsValidPinUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ConfirmTransactionUseCase>(
          create: (context) => ConfirmTransactionUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetRequestedAttributesFromWalletUseCase>(
          create: (context) => GetRequestedAttributesFromWalletUseCaseImpl(context.read()),
        ),
        RepositoryProvider<LockWalletUseCase>(
          create: (context) => LockWalletUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetFirstNamesUseCase>(
          create: (context) => GetFirstNamesUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetWalletCardsUseCase>(
          create: (context) => GetWalletCardsUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetWalletCardUseCase>(
          create: (context) => GetWalletCardUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ObserveWalletCardsUseCase>(
          create: (context) => ObserveWalletCardsUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ObserveWalletCardUseCase>(
          create: (context) => ObserveWalletCardUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ObserveWalletCardDetailUseCase>(
          create: (context) => ObserveWalletCardDetailUseCaseImpl(
            context.read(),
            context.read(),
          ),
        ),
        RepositoryProvider<GetWalletCardTimelineAttributesUseCase>(
          create: (context) => GetWalletCardTimelineAttributesUseCaseImpl(context.read()),
        ),
        RepositoryProvider<DecodeQrUseCase>(
          create: (context) => DecodeQrUseCaseImpl(context.read()),
        ),
        RepositoryProvider<CancelPidIssuanceUseCase>(
          create: (context) => CancelPidIssuanceUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetWalletTimelineAttributesUseCase>(
          create: (context) => GetWalletTimelineAttributesUseCaseImpl(context.read()),
        ),
        RepositoryProvider<SetupMockedWalletUseCase>(
          create: (context) => SetupMockedWalletUseCaseImpl(
            context.read(),
            context.read(),
          ),
        ),
        RepositoryProvider<StartSignUseCase>(
          create: (context) => StartSignUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetWalletCardUpdateRequestUseCase>(
          create: (context) => GetWalletCardUpdateRequestUseCaseImpl(),
        ),
        RepositoryProvider<DecodeUriUseCase>(
          create: (context) => DecodeUriUseCaseImpl(context.read()),
        ),
        RepositoryProvider<IsWalletInitializedWithPidUseCase>(
          create: (context) => IsWalletInitializedWithPidUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetRequestedAttributesWithCardUseCase>(
          create: (context) => GetRequestedAttributesWithCardUseCaseImpl(context.read()),
        ),
        RepositoryProvider<GetPidIssuanceUrlUseCase>(
          create: (context) => GetPidIssuanceUrlUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ContinuePidIssuanceUseCase>(
          create: (context) => ContinuePidIssuanceUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ObserveWalletLockedUseCase>(
          create: (context) => ObserveWalletLockedUseCaseImpl(context.read()),
        ),
        RepositoryProvider<CheckHasInternetUseCase>(
          lazy: false /* false to make sure [BlocExtensions.instance] is available */,
          create: (context) {
            final usecase = CheckHasInternetUseCaseImpl(Connectivity(), InternetConnectionChecker());
            BlocExtensions.checkHasInternetUseCase = usecase;
            return usecase;
          },
        ),
        RepositoryProvider<AcceptOfferedPidUseCase>(
          create: (context) => AcceptOfferedPidUseCaseImpl(context.read()),
        ),
        RepositoryProvider<RejectOfferedPidUseCase>(
          create: (context) => RejectOfferedPidUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ResetWalletUseCase>(
          create: (context) => ResetWalletUseCaseImpl(context.read()),
        ),
        RepositoryProvider<CheckNavigationPrerequisitesUseCase>(
          create: (context) => CheckNavigationPrerequisitesUseCaseImpl(context.read()),
        ),
        RepositoryProvider<PerformPreNavigationActionsUseCase>(
          create: (context) => PerformPreNavigationActionsUseCaseImpl(context.read()),
        ),
        RepositoryProvider<StartDisclosureUseCase>(
          create: (context) => StartDisclosureUseCaseImpl(context.read()),
        ),
        RepositoryProvider<AcceptDisclosureUseCase>(
          create: (context) => AcceptDisclosureUseCaseImpl(context.read()),
        ),
        RepositoryProvider<CancelDisclosureUseCase>(
          create: (context) => CancelDisclosureUseCaseImpl(context.read()),
        ),
        RepositoryProvider<StartIssuanceUseCase>(
          create: (context) => StartIssuanceUseCaseImpl(context.read()),
        ),
        RepositoryProvider<ContinueIssuanceUseCase>(
          create: (context) => ContinueIssuanceUseCaseImpl(context.read()),
        ),
        RepositoryProvider<DiscloseForIssuanceUseCase>(
          create: (context) => DiscloseForIssuanceUseCaseImpl(context.read()),
        ),
        RepositoryProvider<AcceptIssuanceUseCase>(
          create: (context) => AcceptIssuanceUseCaseImpl(context.read()),
        ),
        RepositoryProvider<CancelIssuanceUseCase>(
          create: (context) => CancelIssuanceUseCaseImpl(context.read()),
        ),
        RepositoryProvider<AcceptSignAgreementUseCase>(
          create: (context) => AcceptSignAgreementUseCaseImpl(context.read()),
        ),
        RepositoryProvider<RejectSignAgreementUseCase>(
          create: (context) => RejectSignAgreementUseCaseImpl(context.read()),
        ),
      ],
      child: child,
    );
  }
}
