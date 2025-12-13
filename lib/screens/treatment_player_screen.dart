import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/treatment_models.dart';

class TreatmentPlayerScreen extends StatefulWidget {
  final TreatmentVideo video;

  const TreatmentPlayerScreen({super.key, required this.video});

  @override
  State<TreatmentPlayerScreen> createState() => _TreatmentPlayerScreenState();
}

class _TreatmentPlayerScreenState extends State<TreatmentPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Convert full URL to ID
    final videoId = YoutubePlayer.convertUrlToId(widget.video.youtubeUrl) ?? '';
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.teal,
        progressColors: const ProgressBarColors(
          playedColor: Colors.teal,
          handleColor: Colors.tealAccent,
        ),
        onReady: () {
          // Player is ready
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.video.title),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.titleCA,
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Category: ${widget.video.category}",
                      style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
