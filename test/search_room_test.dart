// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:simaru/provider/search_room_provider.dart';
// import 'package:simaru/services/search_room_service.dart';

// void main() {
//   group('SearchProvider Integration Test', () {
//     SearchProvider searchProvider;

//     setUp(() {
//       searchProvider = SearchProvider();
//     });

//     test('searchroom - Success', () async {
//       // Arrange
//       final startDate = '2023-09-29 18:01:00';
//       final endDate = '2023-09-29 23:00:00';
//       final token = '398|Uf2NIDwkvduYgs69OqzhtH1sPeWAyGxaL5rXCIta';

//       // Act
//       final result = await searchProvider.searchroom(
//         startDate: startDate,
//         endDate: endDate,
//         token: token,
//       );

//       // Assert
//       expect(result, true);
//       expect(searchProvider.search, isNotEmpty);
//     });

//     test('searchroom - Failed data cant empty', () async {
//       // Arrange
//       final startDate = '2023-08-13 18:01:00';
//       final endDate = '';
//       final token = '398|Uf2NIDwkvduYgs69OqzhtH1sPeWAyGxaL5rXCIta';

//       // Act
//       final result = await searchProvider.searchroom(
//         startDate: startDate,
//         endDate: endDate,
//         token: token,
//       );

//       // Assert
//       expect(result, false);
//       expect(searchProvider.search, isEmpty);
//     });
//     test('searchroom - Failed token not access', () async {
//       // Arrange
//       final startDate = '2023-09-29 18:01:00';
//       final endDate = '2023-09-29 23:00:00';
//       final token = '398|Uf2NIDwkvduYgs69OqzhtH1sPeWAyGxaL5rXCIta';

//       // Act
//       final result = await searchProvider.searchroom(
//         startDate: startDate,
//         endDate: endDate,
//         token: token,
//       );

//       // Assert
//       expect(result, false);
//       expect(searchProvider.search, isEmpty);
//     });
//   });
// }
import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/provider/search_room_provider.dart';

void main() {
  group('SearchProvider Tests', () {
    test('searchroom - success', () async {
      final provider = SearchProvider();

      // Replace 'your_token_here' with a valid token for testing.
      const token = '430|ZSSQ5KNPnsWm00cmUzJOeBNVsu0QfYeGohM0FNct';
      const startDate = '2023-09-29 18:01:00';
      const endDate = '2023-09-29 23:00:00';

      final result = await provider.searchroom(
        startDate: startDate,
        endDate: endDate,
        token: token,
      );

      // Assert that the result is true after a successful search.
      expect(result, true);

      // Assert that the provider's search list is not empty.
      expect(provider.search, isNotNull);
      expect(provider.search.length, greaterThan(0));
    });

    test('searchroom - failed invalid token', () async {
      final provider = SearchProvider();

      // Use an invalid token to trigger an error.
      const token = 'invalid_token';
      const startDate = '2023-09-29 18:01:00';
      const endDate = '2023-09-29 23:00:00';

      final result = await provider.searchroom(
        startDate: startDate,
        endDate: endDate,
        token: token,
      );

      // Expect the result to be false after a failed search.
      expect(result, false);

      // Expect that the provider's search list is empty.
      expect(provider.search, isNotNull);
      expect(provider.search.length, 0);
    });
    test('searchroom - failed data cant empty', () async {
      final provider = SearchProvider();

      // Use an invalid token to trigger an error.
      const token = '430|ZSSQ5KNPnsWm00cmUzJOeBNVsu0QfYeGohM0FNct';
      const startDate = '';
      const endDate = '2023-09-29 23:00:00';

      final result = await provider.searchroom(
        startDate: startDate,
        endDate: endDate,
        token: token,
      );

      // Expect the result to be false after a failed search.
      expect(result, false);

      // Expect that the provider's search list is empty.
      expect(provider.search, isNotNull);
      expect(provider.search.length, 0);
    });
  });
}
