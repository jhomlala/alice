import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:test/test.dart';

void main() {
  group("AliceConversionHelper", () {
    test("should format bytes", () {
      expect(AliceConversionHelper.formatBytes(-100), "-1 B");
      expect(AliceConversionHelper.formatBytes(0), "0 B");
      expect(AliceConversionHelper.formatBytes(100), "100 B");
      expect(AliceConversionHelper.formatBytes(999), "999 B");
      expect(AliceConversionHelper.formatBytes(1000), "1000 B");
      expect(AliceConversionHelper.formatBytes(1001), "1.00 kB");
      expect(AliceConversionHelper.formatBytes(100000), "100.00 kB");
      expect(AliceConversionHelper.formatBytes(1000000), "1000.00 kB");
      expect(AliceConversionHelper.formatBytes(1000001), "1.00 MB");
      expect(AliceConversionHelper.formatBytes(100000000), "100.00 MB");
    });

    test("should format time", () {
      expect(AliceConversionHelper.formatTime(-100), "-1 ms");
      expect(AliceConversionHelper.formatTime(0), "0 ms");
      expect(AliceConversionHelper.formatTime(100), "100 ms");
      expect(AliceConversionHelper.formatTime(1000), "1000 ms");
      expect(AliceConversionHelper.formatTime(1001), "1.00 s");
      expect(AliceConversionHelper.formatTime(5000), "5.00 s");
      expect(AliceConversionHelper.formatTime(60000), "60.00 s");
      expect(AliceConversionHelper.formatTime(60001), "1 min 0 s 1 ms");
      expect(AliceConversionHelper.formatTime(85000), "1 min 25 s 0 ms");
    });
  });
}
