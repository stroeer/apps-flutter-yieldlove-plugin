class AdSize {
  const AdSize({
    required this.width,
    required this.height
  });

  final int width;
  final int height;

  @override
  String toString() {
    // TODO: implement toString
    return 'AdSize(width: $width, height: $height)';
  }
}