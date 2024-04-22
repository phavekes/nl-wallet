part of 'sign_bloc.dart';

const kSignSteps = 6;

sealed class SignState extends Equatable {
  bool get showStopConfirmation => true;

  bool get canGoBack => false;

  bool get didGoBack => false;

  FlowProgress get stepperProgress => const FlowProgress(currentStep: 1, totalSteps: kSignSteps);

  const SignState();

  @override
  List<Object?> get props => [
        showStopConfirmation,
        canGoBack,
        didGoBack,
        stepperProgress,
      ];
}

class SignInitial extends SignState {
  const SignInitial();
}

class SignLoadInProgress extends SignState {
  const SignLoadInProgress();

  @override
  bool get showStopConfirmation => false;
}

class SignCheckOrganization extends SignState {
  final Organization organization;

  final bool afterBackPressed;

  const SignCheckOrganization({
    required this.organization,
    this.afterBackPressed = false,
  });

  @override
  FlowProgress get stepperProgress => const FlowProgress(currentStep: 2, totalSteps: kSignSteps);

  @override
  bool get didGoBack => afterBackPressed;

  @override
  List<Object?> get props => [organization, ...super.props];
}

class SignCheckAgreement extends SignState {
  final bool afterBackPressed;

  final Organization organization;
  final Organization trustProvider;
  final Document document;

  const SignCheckAgreement({
    required this.organization,
    required this.trustProvider,
    required this.document,
    this.afterBackPressed = false,
  });

  @override
  FlowProgress get stepperProgress => const FlowProgress(currentStep: 3, totalSteps: kSignSteps);

  @override
  bool get canGoBack => true;

  @override
  bool get didGoBack => afterBackPressed;

  @override
  List<Object?> get props => [organization, trustProvider, document, ...super.props];
}

class SignConfirmAgreement extends SignState {
  final bool afterBackPressed;

  final Policy policy;
  final Organization trustProvider;
  final Document document;
  final List<Attribute> requestedAttributes;

  const SignConfirmAgreement({
    required this.policy,
    required this.trustProvider,
    required this.document,
    required this.requestedAttributes,
    this.afterBackPressed = false,
  });

  @override
  FlowProgress get stepperProgress => const FlowProgress(currentStep: 4, totalSteps: kSignSteps);

  @override
  bool get canGoBack => true;

  @override
  bool get didGoBack => afterBackPressed;

  @override
  List<Object?> get props => [policy, trustProvider, document, requestedAttributes, ...super.props];
}

class SignConfirmPin extends SignState {
  const SignConfirmPin();

  @override
  FlowProgress get stepperProgress => const FlowProgress(currentStep: 5, totalSteps: kSignSteps);

  @override
  bool get canGoBack => true;
}

class SignSuccess extends SignState {
  final Organization organization;

  const SignSuccess({required this.organization});

  @override
  FlowProgress get stepperProgress => const FlowProgress(currentStep: 6, totalSteps: kSignSteps);

  @override
  bool get showStopConfirmation => false;

  @override
  List<Object?> get props => [organization, ...super.props];
}

class SignError extends SignState {
  const SignError();

  @override
  bool get showStopConfirmation => false;
}

class SignStopped extends SignState {
  const SignStopped();

  @override
  bool get showStopConfirmation => false;
}
