import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/editor/color_button.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/modules/drawing_board.dart';

/// Show image drawing surface over image
class ImageEditorDrawing extends StatefulWidget {
  final Uint8List image;

  const ImageEditorDrawing({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  State<ImageEditorDrawing> createState() => _ImageEditorDrawingState();
}

class _ImageEditorDrawingState extends State<ImageEditorDrawing> {
  late SignatureController controller;
  ImageItem image = ImageItem();

  double penStrokeWidth = 3.0;
  Color pickerColor = Colors.white;
  Color currentColor = Colors.white;
  List<List<Point>> undoList = [];

  List<Color> colorList = [
    Colors.black,
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.purple,
    Colors.brown,
    Colors.indigo,
  ];

  void setController() {
    controller = SignatureController(
      penStrokeWidth: penStrokeWidth,
      penColor: currentColor,
      // exportBackgroundColor: Colors.red.withOpacity(.5),
    )..onDrawEnd = () => setState(() {});
  }

  void changeColor(Color color) {
    currentColor = color;
    setController();
    setState(() {});
  }

  @override
  void initState() {
    image.load(widget.image);
    setController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;

    return ValueListenableBuilder<Size>(
        valueListenable: image,
        builder: (context, size, __) {
          double resizeWidth = size.width.toDouble();
          double resizeHeight = size.height.toDouble();

          double aspect = resizeWidth / resizeHeight;

          if (resizeWidth > maxWidth) {
            resizeWidth = maxWidth;
            resizeHeight = resizeWidth / aspect;
          }
          if (resizeHeight > maxHeight) {
            aspect = resizeWidth / resizeHeight;
            resizeHeight = maxHeight;
            resizeWidth = resizeHeight * aspect;
          }

          return Theme(
            data: ImageEditor.theme,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(
                      Icons.undo,
                      color: controller.isNotEmpty
                          ? Colors.white
                          : Colors.white.withAlpha(80),
                    ),
                    onPressed: () {
                      if (controller.isEmpty) return;
                      undoList.add(controller.value);
                      controller.undo();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(
                      Icons.redo,
                      color: undoList.isNotEmpty
                          ? Colors.white
                          : Colors.white.withAlpha(80),
                    ),
                    onPressed: () {
                      if (undoList.isEmpty) return;
                      undoList.removeLast();
                      controller.redo();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: const Icon(Icons.check),
                    onPressed: () async {
                      if (controller.isEmpty) return Navigator.pop(context);
                      final img = await controller.toPngBytes(
                        Size(resizeWidth, resizeHeight),
                      );
                      if (mounted) {
                        return Navigator.pop(context, img);
                      }
                    },
                  ),
                ],
              ),
              body: Container(
                height: maxHeight,
                width: maxWidth,
                decoration: BoxDecoration(
                  color: currentColor == Colors.black
                      ? Colors.white
                      : Colors.black,
                  image: DecorationImage(
                    image: Image.memory(widget.image).image,
                    fit: BoxFit.contain,
                  ),
                ),
                child: Signature(
                  controller: controller,
                  backgroundColor: Colors.transparent,
                  width: resizeWidth,
                  height: resizeHeight,
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(blurRadius: 2),
                    ],
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      ColorButton(
                        color: Colors.yellow,
                        onTap: (color) {
                          showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Colors.black87,
                                padding: const EdgeInsets.all(20),
                                child: SingleChildScrollView(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: HueRingPicker(
                                      pickerColor: pickerColor,
                                      onColorChanged: changeColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      for (int i = 0; i < colorList.length; i++)
                        ColorButton(
                          color: colorList[i],
                          onTap: (color) => changeColor(color),
                          isSelected: colorList[i] == currentColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
