import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'colors_picker.dart';

class ColorPickersSlider extends StatefulWidget {
  const ColorPickersSlider({
    super.key,
    required this.blurLayer,
    required this.onUpdate,
  });

  final BackgroundBlurLayerData blurLayer;
  final void Function(BackgroundBlurLayerData) onUpdate;

  @override
  createState() => _ColorPickersSliderState();
}

class _ColorPickersSliderState extends State<ColorPickersSlider> {
  late BackgroundBlurLayerData layer;

  @override
  void initState() {
    super.initState();
    layer = widget.blurLayer;
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        height: 200,
        child: Column(
          children: [
            Row(children: [
              SizedBox(
                width: 100,
                child: Text(
                  i18n('Slider Filter Color'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, cstr) {
                  return BarColorPicker(
                    width: cstr.maxWidth - 16,
                    thumbColor: Colors.white,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() => layer.color = Color(value));
                      widget.onUpdate(layer);
                    },
                  );
                }),
              ),
              IconButton(
                splashRadius: 24,
                icon: Icon(
                  Icons.delete_outline,
                  color: layer.color != Colors.transparent
                      ? Colors.white
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() => layer.color = Colors.transparent);
                  widget.onUpdate(layer);
                },
              )
            ]),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    i18n('Blur Radius'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Slider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    value: layer.radius,
                    min: 0.0,
                    max: 10.0,
                    onChanged: (v) {
                      setState(() => layer.radius = v);
                      widget.onUpdate(layer);
                    },
                  ),
                ),
                IconButton(
                  splashRadius: 24,
                  icon: Icon(
                    Icons.delete_outline,
                    color: layer.radius != 0 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => layer.radius = 0);
                    widget.onUpdate(layer);
                  },
                )
              ],
            ),
            Row(children: [
              SizedBox(
                width: 100,
                child: Text(
                  i18n('Color Opacity'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                  value: layer.opacity,
                  min: 0.00,
                  max: 1.0,
                  onChanged: (v) {
                    setState(() => layer.opacity = v);
                    widget.onUpdate(layer);
                  },
                ),
              ),
              IconButton(
                splashRadius: 24,
                icon: Icon(
                  Icons.delete_outline,
                  color: layer.opacity != 0 ? Colors.white : Colors.grey,
                ),
                onPressed: () {
                  setState(() => layer.opacity = 0.0);
                  widget.onUpdate(layer);
                },
              )
            ]),
          ],
        ),
      ),
    );
  }
}
