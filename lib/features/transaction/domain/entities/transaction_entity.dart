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
  });

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
  ];
}
