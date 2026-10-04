import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'address.dart';
import 'category.dart';
import 'condition.dart';

const int maxPostImages = 10;

class CreateDocumentRequest extends Equatable {
  const CreateDocumentRequest({
    required this.category,
    required this.name,
    required this.condition,
    required this.price,
    this.publicationYear,
    this.conditionNote,
  });

  final Category category;
  final String name;
  final Condition condition;
  final String price;
  final int? publicationYear;
  final String? conditionNote;

  @override
  List<Object?> get props => [
    category,
    name,
    condition,
    price,
    publicationYear,
    conditionNote,
  ];
}

class CreatePostRequest extends Equatable {
  const CreatePostRequest({
    required this.document,
    required this.title,
    required this.address,
    this.description,
  });

  final CreateDocumentRequest document;
  final String title;
  final Address address;
  final String? description;

  @override
  List<Object?> get props => [document, title, address, description];
}

class PostImageRequest extends Equatable {
  const PostImageRequest({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;

  @override
  List<Object?> get props => [bytes, extension, contentType];
}

class UploadedPostImage extends Equatable {
  const UploadedPostImage({required this.path, required this.url});

  final String path;
  final String url;

  Map<String, String> toJson() => {'path': path, 'url': url};

  @override
  List<Object?> get props => [path, url];
}
