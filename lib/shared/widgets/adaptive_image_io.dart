import 'dart:io';

import 'package:flutter/widgets.dart';

Widget buildPlatformImage(String path, {BoxFit? fit}) {
  return Image.file(
    File(path),
    fit: fit,
  );
}
