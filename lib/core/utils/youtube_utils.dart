import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Safely extracts an 11-character YouTube video ID from various URL formats
/// or raw video ID strings.
///
/// Supported formats:
/// - Raw ID: `dQw4w9WgXcQ`
/// - Short URL: `https://youtu.be/dQw4w9WgXcQ`
/// - Watch URL: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
/// - Embed URL: `https://www.youtube.com/embed/dQw4w9WgXcQ`
/// - Shorts URL: `https://www.youtube.com/shorts/dQw4w9WgXcQ`
/// - Mobile URL: `https://m.youtube.com/watch?v=dQw4w9WgXcQ`
String? extractYouTubeId(String? input) {
  if (input == null || input.trim().isEmpty) return null;
  final String trimmed = input.trim();

  // If input is already an 11-character YouTube ID string
  final RegExp rawIdRegex = RegExp(r'^[a-zA-Z0-9_-]{11}$');
  if (rawIdRegex.hasMatch(trimmed)) {
    return trimmed;
  }

  // Cover standard, embed, shorts, mobile, thumbnail, and short links
  final RegExp urlRegex = RegExp(
    r'(?:https?:\/\/)?(?:www\.|m\.|img\.)?(?:youtube\.com\/(?:watch\?.*v=|embed\/|shorts\/|vi\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
  );

  final Match? match = urlRegex.firstMatch(trimmed);
  if (match != null && match.groupCount >= 1) {
    final String? id = match.group(1);
    if (id != null && id.length == 11) {
      return id;
    }
  }

  // Fallback to youtube_player_iframe's parser
  try {
    return YoutubePlayerController.convertUrlToId(trimmed);
  } catch (_) {
    return null;
  }
}
