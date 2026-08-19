import 'package:flutter/material.dart';

class NewsTickerOverlay extends StatefulWidget {
  final List<String> headlines;
  const NewsTickerOverlay({super.key, required this.headlines});

  @override
  State<NewsTickerOverlay> createState() => _NewsTickerOverlayState();
}

class _NewsTickerOverlayState extends State<NewsTickerOverlay> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: widget.headlines.length * 5),
          curve: Curves.linear,
        );
        if (!mounted) return;
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 30,
        color: Colors.red.withValues(alpha: 0.8),
        child: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.headlines.join("  |  "),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
