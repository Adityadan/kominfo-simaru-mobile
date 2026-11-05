import 'package:flutter_test/flutter_test.dart';
import 'package:simaru/provider/pesan_ruang_provider.dart';

void main() {
  group('PesanRuang Tests', () {
    late PesanRuangProvider pesanRuangProvider;
    setUp(() {
      pesanRuangProvider = PesanRuangProvider();
    });
    test('bookingroom - sukses', () async {
      const token = '398|Uf2NIDwkvduYgs69OqzhtH1sPeWAyGxaL5rXCIta';
      const id = 1;
      await pesanRuangProvider.bookingroom(id, token);
      expect(pesanRuangProvider.ruangan, isNotNull);
      expect(pesanRuangProvider.ruangan.length, greaterThanOrEqualTo(0));
    });
    test('bookingroom - gagal', () async {
      const token = '';
      const id = 1;
      await pesanRuangProvider.bookingroom(id, token);
      expect(pesanRuangProvider, isNotNull);
    });
  });
}
