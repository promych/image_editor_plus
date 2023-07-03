import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/image_editor_plus.dart';

import 'colors_picker.dart';

class TextEditorImage extends StatefulWidget {
  const TextEditorImage({Key? key}) : super(key: key);

  @override
  createState() => _TextEditorImageState();
}

class _TextEditorImageState extends State<TextEditorImage> {
  TextEditingController controller = TextEditingController();
  Color currentColor = Colors.white;
  double size = 32.0;
  TextAlign align = TextAlign.left;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.format_align_left,
                color: align == TextAlign.left
                    ? Colors.white
                    : Colors.white.withAlpha(80),
              ),
              onPressed: () {
                setState(() {
                  align = TextAlign.left;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.format_align_center,
                  color: align == TextAlign.center
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.center;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.format_align_right,
                  color: align == TextAlign.right
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.right;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(
                  context,
                  TextLayerData(
                    background: Colors.transparent,
                    text: controller.text,
                    color: currentColor,
                    size: size.toDouble(),
                    align: align,
                  ),
                );
              },
              color: Colors.white,
              padding: const EdgeInsets.all(15),
            )
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Column(children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(10),
                    hintText: i18n('Insert Your Message'),
                    hintStyle: const TextStyle(color: Colors.white),
                    alignLabelWithHint: true,
                  ),
                  scrollPadding: const EdgeInsets.all(20.0),
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 99999,
                  style: TextStyle(color: currentColor, fontSize: size),
                  autofocus: true,
                ),
              ),
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.fromLTRB(24, 24, 0, 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(i18n('Slider Color')),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, cstr) {
                                return BarColorPicker(
                                  width: cstr.maxWidth - 20,
                                  thumbColor: Colors.white,
                                  pickMode: PickMode.color,
                                  colorListener: (int value) {
                                    setState(() {
                                      currentColor = Color(value);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          IconButton(
                            splashRadius: 24,
                            onPressed: () {
                              setState(() => currentColor = Colors.white);
                            },
                            icon: const Icon(Icons.delete_outline),
                            // child: Text(i18n('Reset')),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(i18n('Slider White Black Color')),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LayoutBuilder(builder: (context, cstr) {
                              return BarColorPicker(
                                width: cstr.maxWidth - 20,
                                thumbColor: Colors.white,
                                pickMode: PickMode.grey,
                                colorListener: (int value) {
                                  setState(() {
                                    currentColor = Color(value);
                                  });
                                },
                              );
                            }),
                          ),
                          IconButton(
                            splashRadius: 24,
                            onPressed: () {
                              setState(() => currentColor = Colors.white);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: currentColor != Colors.white
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            // child: Text(i18n('Reset')),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              i18n('Size Adjust'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                overlayShape: SliderComponentShape.noOverlay,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                activeColor: Colors.white,
                                inactiveColor: Colors.grey,
                                value: size,
                                min: 0.0,
                                max: 100.0,
                                onChangeEnd: (v) {
                                  setState(() {
                                    size = v;
                                  });
                                },
                                onChanged: (v) {
                                  setState(() {
                                    size = v;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
