import 'package:alice/utils/alice_conversion_utils.dart';
import 'package:test/test.dart';

void main() {
  group("AliceConversionUtils", () {
    test("should format bytes", () {
      expect(AliceConversionUtils.formatBytes(-100), "-1 B");
      expect(AliceConversionUtils.formatBytes(0), "0 B");
      expect(AliceConversionUtils.formatBytes(100), "100 B");
      expect(AliceConversionUtils.formatBytes(999), "999 B");
      expect(AliceConversionUtils.formatBytes(1000), "1000 B");
      expect(AliceConversionUtils.formatBytes(1001), "1.00 kB");
      expect(AliceConversionUtils.formatBytes(100000), "100.00 kB");
      expect(AliceConversionUtils.formatBytes(1000000), "1000.00 kB");
      expect(AliceConversionUtils.formatBytes(1000001), "1.00 MB");
      expect(AliceConversionUtils.formatBytes(100000000), "100.00 MB");
    });

    test("should format time", () {
      expect(AliceConversionUtils.formatTime(-100), "-1 ms");
      expect(AliceConversionUtils.formatTime(0), "0 ms");
      expect(AliceConversionUtils.formatTime(100), "100 ms");
      expect(AliceConversionUtils.formatTime(1000), "1000 ms");
      expect(AliceConversionUtils.formatTime(1001), "1.00 s");
      expect(AliceConversionUtils.formatTime(5000), "5.00 s");
      expect(AliceConversionUtils.formatTime(60000), "60.00 s");
      expect(AliceConversionUtils.formatTime(60001), "1 min 0 s 1 ms");
      expect(AliceConversionUtils.formatTime(85000), "1 min 25 s 0 ms");
    });
  });
}
