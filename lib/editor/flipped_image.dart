import 'dart:typed_data';

import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart' as image_editor;

/// Short form of Image.memory wrapped in ColorFiltered
class FilterAppliedImage extends StatelessWidget {
  final Uint8List image;
  final ColorFilterGenerator filter;
  final BoxFit? fit;
  final Function(Uint8List)? onProcess;
  final double opacity;

  FilterAppliedImage({
    super.key,
    required this.image,
    required this.filter,
    this.fit,
    this.onProcess,
    this.opacity = 1,
  }) {
    // process filter in background
    if (onProcess != null) {
      // no filter supplied
      if (filter.filters.isEmpty) {
        onProcess!(image);
        return;
      }

      final image_editor.ImageEditorOption option =
          image_editor.ImageEditorOption();

      option.addOption(image_editor.ColorOption(matrix: filter.matrix));

      image_editor.ImageEditor.editImage(
        image: image,
        imageEditorOption: option,
      ).then((result) {
        if (result != null) {
          onProcess!(result);
        }
      }).catchError((err, stack) {
        // print(err);
        // print(stack);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (filter.filters.isEmpty) return Image.memory(image, fit: fit);

    return Opacity(
      opacity: opacity,
      child: filter.build(
        Image.memory(image, fit: fit),
      ),
    );
  }
}
