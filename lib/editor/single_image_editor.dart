import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/editor/bottom_button.dart';
import 'package:image_editor_plus/editor/draw_editor.dart';
import 'package:image_editor_plus/editor/image_cropper.dart';
import 'package:image_editor_plus/editor/image_filters.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/layers/background_blur_layer.dart';
import 'package:image_editor_plus/layers/background_layer.dart';
import 'package:image_editor_plus/layers/emoji_layer.dart';
import 'package:image_editor_plus/layers/image_layer.dart';
import 'package:image_editor_plus/layers/text_layer.dart';
import 'package:image_editor_plus/modules/all_emojies.dart';
import 'package:image_editor_plus/modules/color_pickers_slider.dart';
import 'package:image_editor_plus/modules/text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

/// Image editor with all option available
class SingleImageEditor extends StatefulWidget {
  final Directory? savePath;
  final dynamic image;
  final List? imageList;
  final bool allowCamera, allowGallery;
  final Widget? progressIndicator;

  const SingleImageEditor({
    Key? key,
    this.savePath,
    this.image,
    this.imageList,
    this.allowCamera = false,
    this.allowGallery = false,
    this.progressIndicator,
  }) : super(key: key);

  @override
  createState() => _SingleImageEditorState();
}

class _SingleImageEditorState extends State<SingleImageEditor> {
  ImageItem currentImage = ImageItem();

  bool isLoading = false;
  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  final scaf = GlobalKey<ScaffoldState>();

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void dispose() {
    layers.clear();
    super.dispose();
  }

  List<Widget> get filterActions {
    return [
      const BackButton(),
      const Spacer(),
      IconButton(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(Icons.undo,
            color: layers.length > 1 || removedLayers.isNotEmpty
                ? Colors.white
                : Colors.grey),
        onPressed: () {
          if (removedLayers.isNotEmpty) {
            layers.add(removedLayers.removeLast());
            setState(() {});
            return;
          }

          if (layers.length <= 1) return; // do not remove image layer

          undoLayers.add(layers.removeLast());

          setState(() {});
        },
      ),
      IconButton(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(Icons.redo,
            color: undoLayers.isNotEmpty ? Colors.white : Colors.grey),
        onPressed: () {
          if (undoLayers.isEmpty) return;

          layers.add(undoLayers.removeLast());

          setState(() {});
        },
      ),
      if (widget.allowGallery)
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.photo),
          onPressed: () async {
            var image = await picker.pickImage(source: ImageSource.gallery);

            if (image == null) return;

            loadImage(image);
          },
        ),
      if (widget.allowCamera)
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.camera_alt),
          onPressed: () async {
            var image = await picker.pickImage(source: ImageSource.camera);

            if (image == null) return;

            loadImage(image);
          },
        ),
      IconButton(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: const Icon(Icons.check),
        onPressed: () async {
          resetTransformation();
          isLoading = true;
          var binaryIntList =
              await screenshotController.capture(pixelRatio: pixelRatio);
          isLoading = false;
          if (mounted) Navigator.pop(context, binaryIntList);
        },
      ),
    ];
  }

  @override
  void initState() {
    if (widget.image != null) {
      loadImage(widget.image!);
    }

    super.initState();
  }

  double flipValue = 0;
  int rotateValue = 0;

  double x = 0;
  double y = 0;
  double z = 0;

  double lastScaleFactor = 1, scaleFactor = 1;
  double widthRatio = 1, heightRatio = 1, pixelRatio = 1;

  resetTransformation() {
    scaleFactor = 1;
    x = 0;
    y = 0;
    setState(() {});
  }

  /// obtain image Uint8List by merging layers
  Future<Uint8List?> getMergedImage() async {
    if (layers.length == 1 && layers.first is BackgroundLayerData) {
      return (layers.first as BackgroundLayerData).file.image;
    } else if (layers.length == 1 && layers.first is ImageLayerData) {
      return (layers.first as ImageLayerData).image.image;
    }

    return screenshotController.capture(
      pixelRatio: pixelRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

    var layersStack = Stack(
      children: layers.map((layerItem) {
        // Background layer
        if (layerItem is BackgroundLayerData) {
          return BackgroundLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        // Image layer
        if (layerItem is ImageLayerData) {
          return ValueListenableBuilder(
            valueListenable: layerItem.image,
            builder: (context, size, __) {
              return ImageLayer(
                layerData: layerItem,
                onUpdate: () {
                  setState(() {});
                },
              );
            },
          );
        }

        // Background blur layer
        if (layerItem is BackgroundBlurLayerData && layerItem.radius > 0) {
          return BackgroundBlurLayer(
            layerData: layerItem,
          );
        }

        // Emoji layer
        if (layerItem is EmojiLayerData) {
          return EmojiLayer(layerData: layerItem);
        }

        // Text layer
        if (layerItem is TextLayerData) {
          return TextLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        // Blank layer
        return Container();
      }).toList(),
    );

    widthRatio = currentImage.width / viewportSize.width;
    heightRatio = currentImage.height / viewportSize.height;
    pixelRatio = math.max(heightRatio, widthRatio);

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        key: scaf,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: filterActions,
        ),
        body: Stack(
          children: [
            GestureDetector(
              onScaleUpdate: (details) {
                // print(details);

                // move
                if (details.pointerCount == 1) {
                  // print(details.focalPointDelta);
                  x += details.focalPointDelta.dx;
                  y += details.focalPointDelta.dy;
                  setState(() {});
                }

                // scale
                if (details.pointerCount == 2) {
                  // print([details.horizontalScale, details.verticalScale]);
                  if (details.horizontalScale != 1) {
                    scaleFactor = lastScaleFactor *
                        math.min(
                            details.horizontalScale, details.verticalScale);
                    setState(() {});
                  }
                }
              },
              onScaleEnd: (details) {
                lastScaleFactor = scaleFactor;
              },
              child: Center(
                child: SizedBox(
                  height: currentImage.height / pixelRatio,
                  width: currentImage.width / pixelRatio,
                  child: Screenshot(
                    controller: screenshotController,
                    child: layersStack,
                    // child: RotatedBox(
                    //   quarterTurns: rotateValue,
                    //   child: Transform(
                    //     transform: Matrix4(
                    //       1,
                    //       0,
                    //       0,
                    //       0,
                    //       0,
                    //       1,
                    //       0,
                    //       0,
                    //       0,
                    //       0,
                    //       1,
                    //       0,
                    //       x,
                    //       y,
                    //       0,
                    //       1 / scaleFactor,
                    //     )..rotateY(flipValue),
                    //     alignment: FractionalOffset.center,
                    //     child: layersStack,
                    //   ),
                    // ),
                  ),
                ),
              ),
            ),
            if (isLoading && widget.progressIndicator != null)
              widget.progressIndicator!,
          ],
        ),
        bottomNavigationBar: Container(
          // color: Colors.black45,
          alignment: Alignment.bottomCenter,
          height: 86 + MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.rectangle,
            //   boxShadow: [
            //     BoxShadow(blurRadius: 1),
            //   ],
          ),
          child: SafeArea(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                BottomButton(
                  icon: Icons.crop,
                  text: i18n('Crop'),
                  onTap: () async {
                    resetTransformation();

                    setState(() => isLoading = true);

                    Uint8List? mergedImage = await getMergedImage();

                    setState(() => isLoading = false);

                    if (!mounted || mergedImage == null) return;

                    Uint8List? croppedImage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageCropper(
                          image: mergedImage,
                        ),
                      ),
                    );

                    if (croppedImage == null) return;

                    flipValue = 0;
                    rotateValue = 0;

                    undoLayers.clear();
                    removedLayers.clear();

                    layers.removeWhere((e) => e is! BackgroundLayerData);

                    await currentImage.load(croppedImage);
                    setState(() {});
                  },
                ),
                BottomButton(
                  icon: Icons.edit,
                  text: i18n('Brush'),
                  onTap: () async {
                    setState(() => isLoading = true);

                    Uint8List? mergedImage = await getMergedImage();

                    setState(() => isLoading = false);

                    if (!mounted || mergedImage == null) return;

                    Uint8List? drawing = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageEditorDrawing(
                          image: mergedImage,
                        ),
                      ),
                    );

                    if (drawing != null) {
                      undoLayers.clear();
                      removedLayers.clear();

                      final layer = ImageLayerData(
                        image: ImageItem(drawing),
                        offset: Offset.zero,
                        scale: 1,
                      );

                      layers.add(layer);

                      setState(() {});
                    }
                  },
                ),
                BottomButton(
                  icon: Icons.text_fields,
                  text: i18n('Text'),
                  onTap: () async {
                    TextLayerData? layer = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TextEditorImage(),
                      ),
                    );

                    if (layer == null) return;

                    undoLayers.clear();
                    removedLayers.clear();

                    layers.add(layer);

                    setState(() {});
                  },
                ),
                // BottomButton(
                //   icon: Icons.flip,
                //   text: i18n('Flip'),
                //   onTap: () {
                //     setState(() {
                //       flipValue = flipValue == 0 ? math.pi : 0;
                //     });
                //   },
                // ),
                // BottomButton(
                //   icon: Icons.rotate_left,
                //   text: i18n('Rotate left'),
                //   onTap: () {
                //     var t = currentImage.width;
                //     currentImage.width = currentImage.height;
                //     currentImage.height = t;

                //     rotateValue--;
                //     setState(() {});
                //   },
                // ),
                // BottomButton(
                //   icon: Icons.rotate_right,
                //   text: i18n('Rotate right'),
                //   onTap: () {
                //     var t = currentImage.width;
                //     currentImage.width = currentImage.height;
                //     currentImage.height = t;

                //     rotateValue++;
                //     setState(() {});
                //   },
                // ),
                BottomButton(
                  icon: Icons.blur_on,
                  text: i18n('Blur'),
                  onTap: () {
                    var blurLayer = BackgroundBlurLayerData(
                      color: Colors.transparent,
                      radius: 0.0,
                      opacity: 0.0,
                    );

                    undoLayers.clear();
                    removedLayers.clear();
                    layers.add(blurLayer);
                    setState(() {});

                    showModalBottomSheet(
                      backgroundColor: Colors.black87,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      context: context,
                      builder: (context) {
                        return ColorPickersSlider(
                          blurLayer: blurLayer,
                          onUpdate: (v) => setState(() {
                            blurLayer.color = v.color;
                            blurLayer.radius = v.radius;
                            blurLayer.opacity = v.opacity;
                          }),
                        );
                      },
                    );
                  },
                ),
                // BottomButton(
                //   icon: FontAwesomeIcons.eraser,
                //   text: 'Eraser',
                //   onTap: () {
                //     _controller.clear();
                //     layers.removeWhere((layer) => layer['type'] == 'drawing');
                //     setState(() {});
                //   },
                // ),
                BottomButton(
                  icon: Icons.photo,
                  text: i18n('Filter'),
                  onTap: () async {
                    resetTransformation();

                    /// Use case: if you don't want to stack your filter, use
                    /// this logic. Along with code on line 888 and
                    /// remove line 889
                    // for (int i = 1; i < layers.length; i++) {
                    //   if (layers[i] is BackgroundLayerData) {
                    //     layers.removeAt(i);
                    //     break;
                    //   }
                    // }
                    var mergedImage = await getMergedImage();

                    if (!mounted) return;

                    Uint8List? filterAppliedImage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageFilters(
                          image: mergedImage!,
                        ),
                      ),
                    );

                    if (filterAppliedImage == null) return;

                    removedLayers.clear();
                    undoLayers.clear();

                    var layer = BackgroundLayerData(
                      file: ImageItem(filterAppliedImage),
                    );

                    /// Use case, if you don't want your filter to effect your
                    /// other elements such as emoji and text. Use insert
                    /// instead of add like in line 888
                    //layers.insert(1, layer);
                    layers.add(layer);

                    await layer.file.status;

                    setState(() {});
                  },
                ),
                BottomButton(
                  icon: Icons.emoji_emotions_outlined,
                  text: i18n('Emoji'),
                  onTap: () async {
                    EmojiLayerData? layer = await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black,
                      builder: (BuildContext context) {
                        return const Emojies();
                      },
                    );

                    if (layer == null) return;

                    undoLayers.clear();
                    removedLayers.clear();
                    layers.add(layer);

                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final picker = ImagePicker();

  Future<void> loadImage(dynamic imageFile) async {
    await currentImage.load(imageFile);

    layers.clear();

    layers.add(BackgroundLayerData(
      file: currentImage,
    ));

    setState(() {});
  }
}
