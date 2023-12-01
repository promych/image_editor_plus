import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'colors_picker.dart';

class TextLayerOverlay extends StatefulWidget {
  final int index;
  final TextLayerData layer;
  final Function onUpdate;

  const TextLayerOverlay({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
  });

  @override
  createState() => _TextLayerOverlayState();
}

class _TextLayerOverlayState extends State<TextLayerOverlay> {
  double slider = 0.0;

  Widget _buildSize() {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            i18n('Size Adjust'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Slider(
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            value: widget.layer.size,
            min: 0.0,
            max: 100.0,
            onChangeEnd: (v) {
              setState(() {
                widget.layer.size = v.toDouble();
                widget.onUpdate();
              });
            },
            onChanged: (v) {
              setState(() {
                slider = v;
                // print(v.toDouble());
                widget.layer.size = v.toDouble();
                widget.onUpdate();
              });
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildColor() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              i18n('Color'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: LayoutBuilder(builder: (context, cstr) {
              return BarColorPicker(
                width: cstr.maxWidth - 16,
                thumbColor: Colors.white,
                initialColor: widget.layer.color,
                pickMode: PickMode.color,
                colorListener: (int value) {
                  setState(() {
                    widget.layer.color = Color(value);
                    widget.onUpdate();
                  });
                },
              );
            }),
          ),
          const SizedBox(width: 4),
          IconButton(
            splashRadius: 24,
            onPressed: () {
              setState(() {
                widget.layer.color = Colors.white;
                widget.onUpdate();
              });
            },
            // child: Text(
            //   i18n('Reset'),
            //   style: const TextStyle(color: Colors.white),
            // ),
            icon: Icon(
              Icons.delete_outline,
              color: widget.layer.color != Colors.white
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColor() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              i18n('Background Color'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: LayoutBuilder(builder: (context, cstr) {
              return BarColorPicker(
                width: cstr.maxWidth - 16,
                initialColor: widget.layer.background,
                thumbColor: Colors.white,
                pickMode: PickMode.color,
                colorListener: (int value) {
                  setState(() {
                    widget.layer.background = Color(value);
                    widget.onUpdate();
                  });
                },
              );
            }),
          ),
          const SizedBox(width: 4),
          IconButton(
            splashRadius: 24,
            onPressed: () {
              setState(() {
                widget.layer.background = Colors.transparent;
                widget.onUpdate();
              });
            },
            // child: Text(
            //   i18n('Reset'),
            //   style: const TextStyle(color: Colors.white),
            // ),
            icon: Icon(
              Icons.delete_outline,
              color: widget.layer.background != Colors.transparent
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOpacity() {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            i18n('Background Opacity'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Slider(
            min: 0,
            max: 255,
            divisions: 255,
            value: widget.layer.backgroundOpacity.toDouble(),
            thumbColor: Colors.white,
            onChanged: (double value) {
              setState(() {
                widget.layer.backgroundOpacity = value.toInt();
                widget.onUpdate();
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        // if (widget.layer.backgroundOpacity != 0)
        //   IconButton(
        //     onPressed: () {
        //       setState(() {
        //         widget.layer.backgroundOpacity = 0;
        //         widget.onUpdate();
        //       });
        //     },
        //     // child: Text(
        //     //   i18n('Reset'),
        //     //   style: const TextStyle(color: Colors.white),
        //     // ),
        //     icon: const Icon(Icons.delete_outline),
        //   ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            overlayShape: SliderComponentShape.noOverlay,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildSize(),
              const SizedBox(height: 12),
              _buildColor(),
              _buildBackgroundColor(),
              const SizedBox(height: 12),
              _buildBackgroundOpacity(),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  removedLayers.add(layers.removeAt(widget.index));
                  Navigator.pop(context);
                  widget.onUpdate();
                },
                child: Text(
                  i18n('Remove'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
