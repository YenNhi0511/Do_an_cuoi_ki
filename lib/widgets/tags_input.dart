// lib/widgets/tags_input.dart
import 'package:flutter/material.dart';

class TagsInput extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onChanged;

  const TagsInput({
    Key? key,
    required this.tags,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<TagsInput> createState() => _TagsInputState();
}

class _TagsInputState extends State<TagsInput> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.tags);
  }

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      widget.onChanged(_tags);
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Thêm Tag',
            hintText: 'Nhập tag và nhấn Enter',
            prefixIcon: Icon(Icons.label_outline),
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _addTag,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        SizedBox(height: 12),

        // Tags chips
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
