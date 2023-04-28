import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';

import '../../../../domain/usecase/history/has_previously_interacted_with_organization_usecase.dart';
import '../../../../domain/usecase/organization/get_organization_by_id_usecase.dart';
import '../../../verification/model/organization.dart';

part 'organization_detail_event.dart';
part 'organization_detail_state.dart';

class OrganizationDetailBloc extends Bloc<OrganizationDetailEvent, OrganizationDetailState> {
  final GetOrganizationByIdUseCase _getOrganizationByIdUseCase;
  final HasPreviouslyInteractedWithOrganizationUseCase _hasPreviouslyInteractedWithOrganizationUseCase;

  OrganizationDetailBloc(this._getOrganizationByIdUseCase, this._hasPreviouslyInteractedWithOrganizationUseCase)
      : super(OrganizationDetailInitial()) {
    on<OrganizationLoadTriggered>(_onOrganizationLoadTriggered);
  }

  void _onOrganizationLoadTriggered(event, emit) async {
    try {
      final organization = await _getOrganizationByIdUseCase.invoke(event.organizationId);
      var hasInteraction = await _hasPreviouslyInteractedWithOrganizationUseCase.invoke(event.organizationId);
      emit(
        OrganizationDetailSuccess(
          organization: organization!,
          hasPreviouslyInteractedWithOrganization: hasInteraction,
        ),
      );
    } catch (exception) {
      Fimber.e('Failed to fetch organization for ${event.organizationId}', ex: exception);
      emit(OrganizationDetailFailure(organizationId: event.organizationId));
    }
  }
}