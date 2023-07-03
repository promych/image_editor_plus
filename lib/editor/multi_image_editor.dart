import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/editor/image_filters.dart';
import 'package:image_editor_plus/editor/single_image_editor.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';

/// Show multiple image carousel to edit multple images at one and allow more images to be added
class MultiImageEditor extends StatefulWidget {
  final Directory? savePath;
  final List images;
  final int maxLength;
  final bool allowGallery, allowCamera, allowMultiple;

  const MultiImageEditor({
    Key? key,
    this.images = const [],
    this.savePath,
    this.allowCamera = false,
    this.allowGallery = false,
    this.allowMultiple = false,
    this.maxLength = 99,
  }) : super(key: key);

  @override
  createState() => _MultiImageEditorState();
}

class _MultiImageEditorState extends State<MultiImageEditor> {
  List<ImageItem> images = [];

  @override
  void initState() {
    images = widget.images.map((e) => ImageItem(e)).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            const BackButton(),
            const Spacer(),
            if (images.length < widget.maxLength && widget.allowGallery)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.photo),
                onPressed: () async {
                  var selected = await picker.pickMultiImage();

                  images.addAll(selected.map((e) => ImageItem(e)).toList());
                },
              ),
            if (images.length < widget.maxLength && widget.allowCamera)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  var selected =
                      await picker.pickImage(source: ImageSource.camera);

                  if (selected == null) return;

                  images.add(ImageItem(selected));
                },
              ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                Navigator.pop(context, images);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 332,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    for (var image in images)
                      Stack(children: [
                        GestureDetector(
                          onTap: () async {
                            var img = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SingleImageEditor(
                                  image: image,
                                ),
                              ),
                            );

                            if (img != null) {
                              image.load(img);
                              setState(() {});
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 32, right: 32, bottom: 32),
                            width: 200,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border:
                                  Border.all(color: Colors.white.withAlpha(80)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                image.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 36,
                          right: 36,
                          child: Container(
                            height: 32,
                            width: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(60),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              iconSize: 20,
                              padding: const EdgeInsets.all(0),
                              onPressed: () {
                                // print('removing');
                                images.remove(image);
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear_outlined),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 32,
                          left: 0,
                          child: Container(
                            height: 38,
                            width: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(100),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(19),
                              ),
                            ),
                            child: IconButton(
                              iconSize: 20,
                              padding: const EdgeInsets.all(0),
                              onPressed: () async {
                                Uint8List? editedImage = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageFilters(
                                      image: image.image,
                                    ),
                                  ),
                                );

                                if (editedImage != null) {
                                  image.load(editedImage);
                                }
                              },
                              icon: const Icon(Icons.photo_filter_sharp),
                            ),
                          ),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final picker = ImagePicker();
}
