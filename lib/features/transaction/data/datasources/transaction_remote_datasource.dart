import 'package:neu_trade/core/services/transaction_services.dart';
import 'package:neu_trade/features/transaction/data/models/transaction_model.dart';
import 'package:supabase/supabase.dart';

import '../../../../core/error/exceptions.dart';

abstract class TransactionRemoteDatasource {
  Future<TransactionModel> createTransaction({
    required int postId,
    String? note,
  });

  Future<List<TransactionModel>> getTransactions();

  Future<TransactionModel> getTransaction({required int transactionId});

  Future<TransactionModel> completeTransaction({required int transactionId});

  Future<TransactionModel> cancelTransaction({
    required int transactionId,
    String? reason,
  });
}

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  final TransactionServices _transactionServices;

  const TransactionRemoteDatasourceImpl(this._transactionServices);

  @override
  Future<TransactionModel> createTransaction({
    required int postId,
    String? note,
  }) async {
    try {
      final result = await _transactionServices.createTransaction(
        postId: postId,
        note: note,
      );
      return TransactionModel.fromJson(result);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final result = await _transactionServices.getTransactions();
      return result
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<TransactionModel> getTransaction({
    required int transactionId,
  }) async {
    try {
      final result = await _transactionServices.getTransaction(
        transactionId: transactionId,
      );
      return TransactionModel.fromDetailJson(result);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<TransactionModel> completeTransaction({
    required int transactionId,
  }) async {
    try {
      final result = await _transactionServices.completeTransaction(
        transactionId: transactionId,
      );
      return TransactionModel.fromJson(result);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<TransactionModel> cancelTransaction({
    required int transactionId,
    String? reason,
  }) async {
    try {
      final result = await _transactionServices.cancelTransaction(
        transactionId: transactionId,
        reason: reason,
      );
      return TransactionModel.fromJson(result);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }
}
