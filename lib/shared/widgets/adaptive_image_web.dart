import 'package:flutter/widgets.dart';

Widget buildPlatformImage(String path, {BoxFit? fit}) {
  return Image.network(
    path,
    fit: fit,
  );
}
