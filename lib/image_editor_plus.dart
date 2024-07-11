library image_editor_plus;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/editor/multi_image_editor.dart';
import 'package:image_editor_plus/editor/single_image_editor.dart';

late Size viewportSize;

List<Layer> layers = [], undoLayers = [], removedLayers = [];
Map<String, String> translations = {};

String i18n(String sourceString) =>
    translations[sourceString.toLowerCase()] ?? sourceString;

/// Single endpoint for MultiImageEditor & SingleImageEditor
class ImageEditor extends StatelessWidget {
  final Uint8List? image;
  final List? images;

  final Directory? savePath;
  final int maxLength;
  final bool allowGallery, allowCamera, allowMultiple;
  final Widget? progressIndicator;

  const ImageEditor(
      {super.key,
      this.image,
      this.images,
      this.savePath,
      this.allowCamera = false,
      this.allowGallery = false,
      this.allowMultiple = false,
      this.maxLength = 99,
      this.progressIndicator,
      Color? appBar});

  @override
  Widget build(BuildContext context) {
    if (images != null && image == null && !allowCamera && !allowGallery) {
      throw Exception(
          'No image to work with, provide an image or allow the image picker.');
    }

    if ((image == null || images != null) && allowMultiple == true) {
      return MultiImageEditor(
        images: images ?? [],
        savePath: savePath,
        allowCamera: allowCamera,
        allowGallery: allowGallery,
        allowMultiple: allowMultiple,
        maxLength: maxLength,
      );
    } else {
      return SingleImageEditor(
        image: image,
        savePath: savePath,
        allowCamera: allowCamera,
        allowGallery: allowGallery,
        progressIndicator: progressIndicator,
      );
    }
  }

  static i18n(Map<String, String> tr) {
    tr.forEach((key, value) {
      translations[key.toLowerCase()] = value;
    });
  }

  /// Set custom theme properties default is dark theme with white text
  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      surface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black87,
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarTextStyle: TextStyle(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}
