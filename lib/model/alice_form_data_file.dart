class AliceFormDataFile {
  final String? key;
  final String? fileName;
  final String contentType;
  final int length;

  AliceFormDataFile({
    required this.fileName,
    required this.contentType,
    required this.length,
    required this.key,
  });
}
