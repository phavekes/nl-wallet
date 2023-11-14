import '../../../../domain/model/attribute/attribute.dart';
import '../../../../domain/model/attribute/missing_attribute.dart';
import '../../../../domain/model/policy/policy.dart';
import '../../../../domain/model/wallet_card.dart';
import '../../../../util/mapper/mapper.dart';
import '../../../../wallet_core/typed/typed_wallet_core.dart';
import '../../../../wallet_core/wallet_core.dart' as core show MissingAttribute;
import '../../../../wallet_core/wallet_core.dart' hide MissingAttribute, StartDisclosureResult;
import '../../organization/organization_repository.dart';
import '../disclosure_repository.dart';

class CoreDisclosureRepository implements DisclosureRepository {
  final TypedWalletCore _walletCore;

  final Mapper<RequestedCard, WalletCard> _cardMapper;
  final Mapper<core.MissingAttribute, MissingAttribute> _missingAttributeMapper;
  final Mapper<RelyingParty, Organization> _relyingPartyMapper;
  final Mapper<RequestPolicy, Policy> _requestPolicyMapper;
  final Mapper<List<LocalizedString>, LocalizedText> _localizedStringMapper;

  CoreDisclosureRepository(
    this._walletCore,
    this._cardMapper,
    this._relyingPartyMapper,
    this._missingAttributeMapper,
    this._requestPolicyMapper,
    this._localizedStringMapper,
  );

  @override
  Future<StartDisclosureResult> startDisclosure(String disclosureUri) async {
    final result = await _walletCore.startDisclosure(disclosureUri);
    return result.map(
      request: (value) {
        final cards = _cardMapper.mapList(value.requestedCards);
        final requestedAttributes = cards.asMap().map((key, value) => MapEntry(value, value.attributes));
        final relyingParty = _relyingPartyMapper.map(value.relyingParty);
        final policy = _requestPolicyMapper.map(value.policy);
        return StartDisclosureReadyToDisclose(
          relyingParty,
          policy,
          _localizedStringMapper.map(value.requestPurpose),
          value.isFirstInteractionWithRelyingParty,
          requestedAttributes,
        );
      },
      requestAttributesMissing: (value) {
        final relyingParty = _relyingPartyMapper.map(value.relyingParty);
        final missingAttributes = _missingAttributeMapper.mapList(value.missingAttributes);
        return StartDisclosureMissingAttributes(
          relyingParty,
          _localizedStringMapper.map(value.requestPurpose),
          value.isFirstInteractionWithRelyingParty,
          missingAttributes,
        );
      },
    );
  }

  @override
  Future<void> cancelDisclosure() => _walletCore.cancelDisclosure();

  @override
  Future<WalletInstructionResult> acceptDisclosure(String pin) => _walletCore.acceptDisclosure(pin);
}