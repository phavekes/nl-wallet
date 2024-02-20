import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/timeline/timeline_attribute.dart';
import '../../../domain/model/wallet_card.dart';
import '../../../domain/usecase/card/observe_wallet_cards_usecase.dart';
import '../../../domain/usecase/history/get_wallet_timeline_attributes_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ObserveWalletCardsUseCase observeWalletCardsUseCase;
  final GetWalletTimelineAttributesUseCase getWalletTimelineAttributesUseCase;

  DashboardBloc(
    this.observeWalletCardsUseCase,
    this.getWalletTimelineAttributesUseCase,
    List<WalletCard>? preloadedCards,
  ) : super(preloadedCards == null ? const DashboardStateInitial() : DashboardLoadSuccess(cards: preloadedCards)) {
    on<DashboardLoadTriggered>(_onCardOverviewLoadTriggered, transformer: restartable());
  }

  void _onCardOverviewLoadTriggered(DashboardLoadTriggered event, Emitter<DashboardState> emit) async {
    if (state is! DashboardLoadSuccess || event.forceRefresh) emit(const DashboardLoadInProgress());
    try {
      final history = await getWalletTimelineAttributesUseCase.invoke();
      await emit.forEach(
        observeWalletCardsUseCase.invoke(),
        onData: (cards) => DashboardLoadSuccess(cards: cards, history: history),
        onError: (ex, stack) {
          //Note: when providing onError like this the subscription is not cancelled on errors
          Fimber.e('Failed to observe cards', ex: ex, stacktrace: stack);
          return const DashboardLoadFailure();
        },
      );
    } catch (ex) {
      Fimber.e('Failed to fetch dashboard info', ex: ex);
      emit(const DashboardLoadFailure());
    }
  }
}