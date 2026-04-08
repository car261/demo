import 'package:flutter/widgets.dart';

import 'adaptive_image_io.dart'
    if (dart.library.html) 'adaptive_image_web.dart';

Widget buildAdaptiveImage(String path, {BoxFit? fit}) {
  return buildPlatformImage(path, fit: fit);
}
