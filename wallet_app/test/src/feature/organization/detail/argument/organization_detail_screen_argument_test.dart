import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/src/feature/organization/detail/argument/organization_detail_screen_argument.dart';

import '../../../../mocks/mock_data.dart';

void main() {
  test(
    'serialize to and from Map<> yields identical object',
    () {
      final expected = OrganizationDetailScreenArgument(
        organization: WalletMockData.organization,
        isFirstInteractionWithOrganization: true,
      );
      final serialized = expected.toMap();
      final result = OrganizationDetailScreenArgument.fromMap(serialized);
      expect(result, expected);
    },
  );
}
