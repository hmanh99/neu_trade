import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/home/domain/entities/address.dart';
import 'package:neu_trade/features/transaction/domain/entities/status.dart';

class TransactionEntity extends Equatable {
  final int transactionId;
  final int postId;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String postTitle;
  final double price;
  final Address address;
  final DateTime orderTime;
  final DateTime expireTime;
  final Status status;
  final String? note;
  final List<String> imageUrls;
  final bool hasReviewed;
  final int? myStars;
  final String? cancelledById;
  final String? cancelReason;
  final DateTime? cancelledAt;

  const TransactionEntity({
    required this.transactionId,
    required this.postId,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.postTitle,
    required this.price,
    required this.address,
    required this.orderTime,
    required this.expireTime,
    required this.status,
    this.note,
    this.imageUrls = const [],
    this.hasReviewed = false,
    this.myStars,
    this.cancelledById,
    this.cancelReason,
    this.cancelledAt,
  });

  TransactionEntity copyWith({
    int? transactionId,
    int? postId,
    String? buyerId,
    String? buyerName,
    String? sellerId,
    String? sellerName,
    String? postTitle,
    double? price,
    Address? address,
    DateTime? orderTime,
    DateTime? expireTime,
    Status? status,
    String? note,
    List<String>? imageUrls,
    bool? hasReviewed,
    int? myStars,
    String? cancelledById,
    String? cancelReason,
    DateTime? cancelledAt,
  }) {
    return TransactionEntity(
      transactionId: transactionId ?? this.transactionId,
      postId: postId ?? this.postId,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      postTitle: postTitle ?? this.postTitle,
      price: price ?? this.price,
      address: address ?? this.address,
      orderTime: orderTime ?? this.orderTime,
      expireTime: expireTime ?? this.expireTime,
      status: status ?? this.status,
      note: note ?? this.note,
      imageUrls: imageUrls ?? this.imageUrls,
      hasReviewed: hasReviewed ?? this.hasReviewed,
      myStars: myStars ?? this.myStars,
      cancelledById: cancelledById ?? this.cancelledById,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  @override
  List<Object?> get props => [
    transactionId,
    postId,
    buyerId,
    buyerName,
    sellerId,
    sellerName,
    postTitle,
    price,
    address,
    orderTime,
    expireTime,
    status,
    note,
    imageUrls,
    hasReviewed,
    myStars,
    cancelledById,
    cancelReason,
    cancelledAt,
  ];
}
