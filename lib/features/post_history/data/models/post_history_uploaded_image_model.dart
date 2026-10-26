import 'package:equatable/equatable.dart';

class PostHistoryImagePayloadModel extends Equatable {
  const PostHistoryImagePayloadModel({
    required this.url,
    this.path,
  });

  final String url;
  final String? path;

  Map<String, dynamic> toJson() => {
    if (path != null) 'path': path,
    'url': url,
  };

  @override
  List<Object?> get props => [url, path];
}
