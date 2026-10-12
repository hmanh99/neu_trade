import 'package:neu_trade/core/services/post_services.dart';
import 'package:neu_trade/features/home/data/models/home_post_model.dart';
import 'package:supabase/supabase.dart';

import '../../../../core/error/exceptions.dart';

abstract class HomePostRemoteDatasource {
  Future<List<HomePostModel>> getPosts();

  Future<HomePostModel> getPost({required int postId});
}

class HomePostRemoteDatasourceImpl implements HomePostRemoteDatasource {
  final PostServices _postServices;

  const HomePostRemoteDatasourceImpl(this._postServices);

  @override
  Future<HomePostModel> getPost({required int postId}) async {
    try {
      final result = await _postServices.getPost(postId: postId);
      return HomePostModel.fromJson(result);
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<List<HomePostModel>> getPosts() async {
    try {
      final result = await _postServices.getPosts();
      return result.map((post) => HomePostModel.fromJson(post)).toList();
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    }
  }
}
