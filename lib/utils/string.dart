extension StringOps on String {
  String trimAll() => replaceAll(RegExp(r"\s+"), "");
}
