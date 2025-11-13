import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/comment.dart';

class CommentScreen extends StatefulWidget {
  final String taskId;
  const CommentScreen({super.key, required this.taskId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final ApiService _api = ApiService();
  List<CommentModel> _comments = [];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final data = await _api.get('comments/${widget.taskId}');
    setState(() {
      _comments =
          (data as List).map((e) => CommentModel.fromJson(e)).toList();
    });
  }

  Future<void> _sendComment() async {
    if (_ctrl.text.isEmpty) return;
    await _api.post('comments', {
      'taskId': widget.taskId,
      'content': _ctrl.text,
    });
    _ctrl.clear();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bình luận')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _comments
                  .map((c) => ListTile(
                        title: Text(c.content),
                        subtitle: Text(
                            '${c.createdAt.day}/${c.createdAt.month} ${c.createdAt.hour}:${c.createdAt.minute}'),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration:
                        const InputDecoration(hintText: 'Nhập bình luận...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendComment,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
