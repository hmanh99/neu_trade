import 'dart:typed_data';

import 'package:equatable/equatable.dart';

const int maxPostHistoryImages = 10;

sealed class PostHistoryImageInput extends Equatable {
  const PostHistoryImageInput();
}

final class ExistingPostHistoryImage extends PostHistoryImageInput {
  const ExistingPostHistoryImage({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}

final class NewPostHistoryImage extends PostHistoryImageInput {
  const NewPostHistoryImage({
    required this.bytes,
    required this.extension,
    required this.contentType,
    this.localPath,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
  final String? localPath;

  @override
  List<Object?> get props => [bytes, extension, contentType, localPath];
}
