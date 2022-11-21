part of 'issuance_bloc.dart';

abstract class IssuanceState extends Equatable {
  bool get showStopConfirmation => true;

  bool get canGoBack => false;

  bool get didGoBack => false;

  double get stepperProgress => 0.0;

  Organization? get organization => null;

  const IssuanceState();

  @override
  List<Object?> get props => [showStopConfirmation, canGoBack, didGoBack, stepperProgress, organization];
}

class IssuanceInitial extends IssuanceState {}

class IssuanceLoadInProgress extends IssuanceState {}

class IssuanceLoadFailure extends IssuanceState {}

class IssuanceCheckOrganization extends IssuanceState {
  final IssuanceResponse response;
  final bool afterBackPressed;

  @override
  Organization get organization => response.organization;

  const IssuanceCheckOrganization(this.response, {this.afterBackPressed = false});

  @override
  List<Object?> get props => [response, ...super.props];

  @override
  double get stepperProgress => 0.2;

  @override
  bool get didGoBack => afterBackPressed;
}

class IssuanceProofIdentity extends IssuanceState {
  final IssuanceResponse response;
  final bool afterBackPressed;

  @override
  Organization get organization => response.organization;

  List<DataAttribute> get requestedAttributes => response.requestedAttributes;

  const IssuanceProofIdentity(this.response, {this.afterBackPressed = false});

  @override
  List<Object?> get props => [response, ...super.props];

  @override
  bool get canGoBack => true;

  @override
  bool get didGoBack => afterBackPressed;

  @override
  double get stepperProgress => 0.4;
}

class IssuanceProvidePin extends IssuanceState {
  final IssuanceResponse response;

  const IssuanceProvidePin(this.response);

  @override
  Organization get organization => response.organization;

  @override
  List<Object?> get props => [response, ...super.props];

  @override
  bool get canGoBack => true;

  @override
  double get stepperProgress => 0.6;
}

class IssuanceCheckDataOffering extends IssuanceState {
  final IssuanceResponse response;

  const IssuanceCheckDataOffering(this.response);

  @override
  List<Object?> get props => [response, ...super.props];

  @override
  double get stepperProgress => 0.8;

  @override
  Organization get organization => response.organization;
}

class IssuanceCardAdded extends IssuanceState {
  final IssuanceResponse response;

  const IssuanceCardAdded(this.response);

  @override
  List<Object?> get props => [response, ...super.props];

  @override
  bool get showStopConfirmation => false;
}

class IssuanceStopped extends IssuanceState {
  @override
  List<Object> get props => [];

  @override
  bool get showStopConfirmation => false;
}

class IssuanceGenericError extends IssuanceState {
  @override
  List<Object> get props => [];

  @override
  bool get showStopConfirmation => false;
}

class IssuanceIdentityValidationFailure extends IssuanceState {
  @override
  List<Object> get props => [];

  @override
  bool get showStopConfirmation => false;
}