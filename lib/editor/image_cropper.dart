import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_editor_plus/editor/bottom_button.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor/image_editor.dart' as image_editor;

/// Crop given image with various aspect ratios
class ImageCropper extends StatefulWidget {
  final Uint8List image;

  const ImageCropper({Key? key, required this.image}) : super(key: key);

  @override
  createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();

  double? aspectRatio;
  double? aspectRatioOriginal;
  bool isLandscape = true;
  int rotateAngle = 0;

  @override
  void initState() {
    _controller.currentState?.rotate(right: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.currentState != null) {
      // _controller.currentState?.
    }

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                var state = _controller.currentState;

                if (state == null) return;

                var data = await cropImageDataWithNativeLibrary(state: state);

                if (mounted) Navigator.pop(context, data);
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: ExtendedImage.memory(
            widget.image,
            cacheRawData: true,
            fit: BoxFit.contain,
            extendedImageEditorKey: _controller,
            mode: ExtendedImageMode.editor,
            initEditorConfigHandler: (state) {
              return EditorConfig(
                cropAspectRatio: aspectRatio,
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 80,
            child: Column(
              children: [
                // Container(
                //   height: 48,
                //   decoration: const BoxDecoration(
                //     boxShadow: [
                //       BoxShadow(
                //         color: black,
                //         blurRadius: 10,
                //       ),
                //     ],
                //   ),
                //   child: ListView(
                //     scrollDirection: Axis.horizontal,
                //     children: <Widget>[
                //       IconButton(
                //         icon: Icon(
                //           Icons.portrait,
                //           color: isLandscape ? gray : white,
                //         ).paddingSymmetric(horizontal: 8, vertical: 4),
                //         onPressed: () {
                //           isLandscape = false;
                //           if (aspectRatioOriginal != null) {
                //             aspectRatio = 1 / aspectRatioOriginal!;
                //           }
                //           setState(() {});
                //         },
                //       ),
                //       IconButton(
                //         icon: Icon(
                //           Icons.landscape,
                //           color: isLandscape ? white : gray,
                //         ).paddingSymmetric(horizontal: 8, vertical: 4),
                //         onPressed: () {
                //           isLandscape = true;
                //           aspectRatio = aspectRatioOriginal!;
                //           setState(() {});
                //         },
                //       ),
                //       Slider(
                //         activeColor: Colors.white,
                //         inactiveColor: Colors.grey,
                //         value: rotateAngle.toDouble(),
                //         min: 0.0,
                //         max: 100.0,
                //         onChangeEnd: (v) {
                //           rotateAngle = v.toInt();
                //           setState(() {});
                //         },
                //         onChanged: (v) {
                //           rotateAngle = v.toInt();
                //           setState(() {});
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: <Widget>[
                      BottomButton(
                        icon: Icons.rotate_right,
                        text: i18n('Rotate right'),
                        onTap: () => _controller.currentState?.rotate(),
                      ),
                      BottomButton(
                        icon: Icons.rotate_left,
                        text: i18n('Rotate left'),
                        onTap: () =>
                            _controller.currentState?.rotate(right: false),
                      ),
                      BottomButton(
                        icon: Icons.flip,
                        text: i18n('Flip'),
                        onTap: () => _controller.currentState?.flip(),
                      ),
                      BottomButton(
                        icon:
                            aspectRatio == 1 ? Icons.landscape : Icons.portrait,
                        text: i18n(aspectRatio == 1 ? 'Freeform' : 'Square'),
                        onTap: () {
                          setState(
                            () => aspectRatio == 1
                                ? aspectRatio = null
                                : aspectRatio = 1,
                          );
                        },
                      ),
                      // IconButton(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 8,
                      //     vertical: 4,
                      //   ),
                      //   icon: Icon(
                      //     Icons.portrait,
                      //     color: isLandscape ? Colors.grey : Colors.white,
                      //   ),
                      //   onPressed: () {
                      //     isLandscape = false;
                      //     if (aspectRatioOriginal != null) {
                      //       aspectRatio = 1 / aspectRatioOriginal!;
                      //     }
                      //     setState(() {});
                      //   },
                      // ),
                      // if (aspectRatioOriginal != null)
                      //   IconButton(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 8,
                      //       vertical: 4,
                      //     ),
                      //     icon: Icon(
                      //       Icons.landscape,
                      //       color: isLandscape ? Colors.white : Colors.grey,
                      //     ),
                      //     onPressed: () {
                      //       isLandscape = true;
                      //       aspectRatio = aspectRatioOriginal!;
                      //       setState(() {});
                      //     },
                      //   ),
                      // imageRatioButton(null, i18n('Freeform')),
                      // imageRatioButton(1, i18n('Square')),
                      // imageRatioButton(4 / 3, '4:3'),
                      // imageRatioButton(5 / 4, '5:4'),
                      // imageRatioButton(7 / 5, '7:5'),
                      // imageRatioButton(16 / 9, '16:9'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> cropImageDataWithNativeLibrary(
      {required ExtendedImageEditorState state}) async {
    final Rect? cropRect = state.getCropRect();
    final EditActionDetails action = state.editAction!;

    final int rotateAngle = action.rotateAngle.toInt();
    final bool flipHorizontal = action.flipY;
    final bool flipVertical = action.flipX;
    final Uint8List img = state.rawImageData;

    final image_editor.ImageEditorOption option =
        image_editor.ImageEditorOption();

    if (action.needCrop) {
      option.addOption(image_editor.ClipOption.fromRect(cropRect!));
    }

    if (action.needFlip) {
      option.addOption(image_editor.FlipOption(
          horizontal: flipHorizontal, vertical: flipVertical));
    }

    if (action.hasRotateAngle) {
      option.addOption(image_editor.RotateOption(rotateAngle));
    }

    // final DateTime start = DateTime.now();
    final Uint8List? result = await image_editor.ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    // print('${DateTime.now().difference(start)} ：total time');

    return result;
  }

  Widget imageRatioButton(double? ratio, String title) {
    return TextButton(
      onPressed: () {
        aspectRatioOriginal = ratio;
        if (aspectRatioOriginal != null && isLandscape == false) {
          aspectRatio = 1 / aspectRatioOriginal!;
        } else {
          aspectRatio = aspectRatioOriginal;
        }
        setState(() {});
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            i18n(title),
            style: TextStyle(
              color: aspectRatioOriginal == ratio ? Colors.white : Colors.grey,
            ),
          )),
    );
  }
}
