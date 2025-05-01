import 'package:flutter/material.dart';

class ConclusionWidget extends StatefulWidget {
  final String messageContent;
  final Function(String)? onConfirm;
  
  const ConclusionWidget({
    Key? key, 
    required this.messageContent,
    this.onConfirm,
  }) : super(key: key);

  @override
  _ConclusionWidgetState createState() => _ConclusionWidgetState();
}

class _ConclusionWidgetState extends State<ConclusionWidget> {
  late TextEditingController _textController;
  bool _isEditable = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.messageContent);
  }

  @override
  void didUpdateWidget(ConclusionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageContent != oldWidget.messageContent) {
      _textController.text = widget.messageContent;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (widget.onConfirm != null) {
      widget.onConfirm!(_textController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Conclusion",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  if (widget.onConfirm != null)
                    TextButton(
                      onPressed: _handleConfirm,
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _isEditable ? Icons.check : Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditable = !_isEditable;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 150,
                  ),
                  child: IntrinsicHeight(
                    child: TextField(
                      controller: _textController,
                      enabled: _isEditable,
                      maxLines: null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Edit the conclusion...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}