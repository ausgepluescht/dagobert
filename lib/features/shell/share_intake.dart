import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Text oder Link aus dem Teilen-Menü anderer Apps.
class SharedText {
  const SharedText({this.title, this.url});

  final String? title;
  final String? url;

  /// Trennt URL vom Rest des geteilten Texts.
  static SharedText? fromRaw(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw.trim();
    final match = RegExp(r'https?://\S+').firstMatch(text);
    if (match == null) return SharedText(title: text);
    final url = match.group(0);
    final rest = text.replaceFirst(url!, '').trim();
    return SharedText(title: rest.isEmpty ? null : rest, url: url);
  }
}

class ShareIntake {
  Stream<SharedText> get stream {
    if (kIsWeb) return const Stream.empty();
    return ReceiveSharingIntent.instance.getMediaStream().map(_convert).where(
      (s) => s != null,
    ).cast<SharedText>();
  }

  Future<SharedText?> initial() async {
    if (kIsWeb) return null;
    try {
      final files = await ReceiveSharingIntent.instance.getInitialMedia();
      final result = _convert(files);
      await ReceiveSharingIntent.instance.reset();
      return result;
    } catch (_) {
      return null;
    }
  }

  SharedText? _convert(List<SharedMediaFile> files) {
    for (final f in files) {
      if (f.type == SharedMediaType.text || f.type == SharedMediaType.url) {
        return SharedText.fromRaw(f.path);
      }
    }
    return null;
  }
}
