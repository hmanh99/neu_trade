import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasources.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required this.remoteDatasource});

  final PostRemoteDatasource remoteDatasource;

}
