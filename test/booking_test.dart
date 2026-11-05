// import 'dart:html';

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:simaru/provider/booking_room_provider.dart';

// void main() {
//   group('Booking Ruang Test', () {
//     BookingRoomProvider bookingRoomProvider;

//     setUp(() {
//       bookingRoomProvider = BookingRoomProvider();
//     });

//     test('bookingRoom - success', () async {
//       // Arrange
//       final token = '11|Npvyb6MjByR0j1JNHIZZWlIMboO9A2D7fw1tVJy0';
//       final startDate = '2023-12-15 03:50:00';
//       final endDate = '2023-12-15 03:51:00';
//       final roomid = '5';
//       final name = 'Ratna Diah';
//       final nip = '56155246618';
//       final devisi = 0;
//       final phone = '08766625166261';
//       final description = 'Rapat Mingguan Devisi Kesekretariatan';
//       final participant = '120';
//       final participant_type = 'INTERNAL';
//       final attachment =
//           'https://diskominfo-simaru.snhgroup.space/uploads/file/170258219738.jpg';

//       // Act
//       final result = await bookingRoomProvider.bookingsRoom(
//         token: token,
//         startDate: startDate,
//         endDate: endDate,
//         roomid: roomid,
//         name: name,
//         // devisi: devisi,
//         nip: nip,
//         phone: phone,
//         description: description,
//         participant: participant,
//         attachment: attachment,
//       );

//       // Assert
//       expect(result, true);
//     });

//     test('bookingRoom - failed', () async {
//       // Arrange
//       final token = '441|VVlZjVPktxo0D6Y3Y1kYDuwfcisPlSui97LE3vLy';
//       final startDate = '2023-09-29 01:01:00';
//       final endDate = '2023-09-29 23:00:00';
//       final roomid = '13';
//       final name = 'Ratna Diah';
//       final nip = '';
//       final phone = '08766625166261';
//       final description = 'Rapat Mingguan Devisi Kesekretariatan';
//       final participant = '120';

//       // Act
//       final result = await bookingRoomProvider.bookingsRoom(
//         token: token,
//         startDate: startDate,
//         endDate: endDate,
//         roomid: roomid,
//         name: name,
//         nip: nip,
//         phone: phone,
//         description: description,
//         participant: participant,
//       );

//       // Assert
//       expect(result, false);
//     });

//     test('Booking Ruang - Failed', () async {
//       // Arrange
//       final token = 'your_token_here';
//       final startDate = '2023-08-10';
//       final endDate = '2023-08-15';
//       final roomid = 'room_id_here';
//       final name = 'John Doe';
//       final nip = '123456';
//       final phone = '1234567890';
//       final description = 'Meeting description';
//       final participant = 'Jane Smith';

//       // Act
//       final result = await bookingRoomProvider.bookingsRoom(
//         token: token,
//         startDate: startDate,
//         endDate: endDate,
//         roomid: roomid,
//         name: name,
//         nip: nip,
//         phone: phone,
//         description: description,
//         participant: participant,
//       );

//       // Assert
//       expect(result, false);
//     });
//   });
// }
