import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/provider/feedback_provider.dart';

void main() {
  group('Feedback Tests', () {
    late FeedbackProvider feedbackProvider;

    setUp(() {
      feedbackProvider = FeedbackProvider();
    });

    test('feedback - succes', () async {
      const bookingId = '1';
      const description = 'Test feedback dari unit tes';
      const token =
          '32|w1YyrdvAGQKNeCAxuget2HDTk4RHBTCAmZlblV1X';

      final image1 = File('assets/meeting-room1.jpg');
      final image2 = File('assets/meeting-room1.jpg');

      final mediaList = [image1, image2];

      final result = await feedbackProvider.feedback(
        bookingId: bookingId,
        description: description,
        mediaList: mediaList,
        token: token,
      );

      expect(result, isNotNull);
    });

    test('failed - data cant empty', () async {
      const bookingId = '13';
      const description = 'Test feedback';
      const token =
          '430|ZSSQ5KNPnsWm00cmUzJOeBNVsu0QfYeGohM0FNct';
      final result = await feedbackProvider.feedback(
        bookingId: bookingId,
        description: description,
        mediaList: [],
        token: token,
      );
      expect(result, false);
    });

    test('failed - no token acces', () async {
      const bookingId = '11';
      const description = 'Test feedback';
      const token = '';

      final image1 = File('assets/meeting-room1.jpg');
      final image2 = File('assets/meeting-room1.jpg');

      final mediaList = [image1, image2];

      final result = await feedbackProvider.feedback(
        bookingId: bookingId,
        description: description,
        mediaList: mediaList,
        token: token,
      );

      expect(result, false);
    });
  });
}
