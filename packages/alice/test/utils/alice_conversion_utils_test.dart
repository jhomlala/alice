import 'package:alice/src/utils/conversion_utils.dart';
import 'package:test/test.dart';

void main() {
  group("ConversionUtils", () {
    test("should format bytes", () {
      expect(ConversionUtils.formatBytes(-100), "-1 B");
      expect(ConversionUtils.formatBytes(0), "0 B");
      expect(ConversionUtils.formatBytes(100), "100 B");
      expect(ConversionUtils.formatBytes(999), "999 B");
      expect(ConversionUtils.formatBytes(1000), "1000 B");
      expect(ConversionUtils.formatBytes(1001), "1.00 kB");
      expect(ConversionUtils.formatBytes(100000), "100.00 kB");
      expect(ConversionUtils.formatBytes(1000000), "1000.00 kB");
      expect(ConversionUtils.formatBytes(1000001), "1.00 MB");
      expect(ConversionUtils.formatBytes(100000000), "100.00 MB");
    });

    test("should format time", () {
      expect(ConversionUtils.formatTime(-100), "-1 ms");
      expect(ConversionUtils.formatTime(0), "0 ms");
      expect(ConversionUtils.formatTime(100), "100 ms");
      expect(ConversionUtils.formatTime(1000), "1000 ms");
      expect(ConversionUtils.formatTime(1001), "1.00 s");
      expect(ConversionUtils.formatTime(5000), "5.00 s");
      expect(ConversionUtils.formatTime(60000), "60.00 s");
      expect(ConversionUtils.formatTime(60001), "1 min 0 s 1 ms");
      expect(ConversionUtils.formatTime(85000), "1 min 25 s 0 ms");
    });
  });
}
