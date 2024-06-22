class AliceFormDataFile {
  const AliceFormDataFile(
    this.fileName,
    this.contentType,
    this.length,
  );

  final String? fileName;
  final String contentType;
  final int length;
}
