import 'package:bloc/bloc.dart';
import '../../domain/entities/home_post_entity.dart';
import '../../domain/usecases/get_home_post_usecase.dart';
import '../../domain/usecases/send_home_report_usecase.dart';
import '../../../transaction/domain/usecases/create_transaction_usecase.dart';
import 'post_detail_event.dart';
import 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required GetHomePostUsecase getHomePost,
    required CreateTransactionUsecase createTransaction,
    required SendHomeReportUsecase sendReport,
    HomePostEntity? initialPost,
  })  : _getHomePost = getHomePost,
        _createTransaction = createTransaction,
        _sendReport = sendReport,
        super(
          initialPost != null
              ? PostDetailLoadedState(initialPost)
              : const PostDetailInitialState(),
        ) {
    on<PostDetailLoadRequested>(_onLoadRequested);
    on<PostDetailInitialised>(_onInitialised);
    on<PostDetailReserveSubmitted>(_onReserveSubmitted);
    on<PostDetailReportSubmitted>(_onReportSubmitted);
  }

  final GetHomePostUsecase _getHomePost;
  final CreateTransactionUsecase _createTransaction;
  final SendHomeReportUsecase _sendReport;

  void _onInitialised(
    PostDetailInitialised event,
    Emitter<PostDetailState> emit,
  ) {
    emit(PostDetailLoadedState(event.post));
  }

  Future<void> _onLoadRequested(
    PostDetailLoadRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(const PostDetailLoadingState());
    final result = await _getHomePost(GetHomePostParams(postId: event.postId));
    result.fold(
      (failure) => emit(PostDetailFailureState(message: failure.message)),
      (post) => emit(PostDetailLoadedState(post)),
    );
  }

  Future<void> _onReserveSubmitted(
    PostDetailReserveSubmitted event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentPost = _currentPostFromState(state);
    if (currentPost == null) return;

    emit(PostDetailReservingState(currentPost));

    final result = await _createTransaction(
      CreateTransactionParams(
        postId: event.postId,
        note: event.meetingLocation,
      ),
    );

    result.fold(
      (failure) => emit(PostDetailFailureState(
        message: failure.message,
        post: currentPost,
      )),
      (transaction) => emit(
        PostDetailReserveSuccessState(
          post: currentPost,
          message: 'Đặt trước thành công! Bạn có thể theo dõi lịch hẹn trong mục Giao dịch.',
        ),
      ),
    );
  }

  Future<void> _onReportSubmitted(
    PostDetailReportSubmitted event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentPost = _currentPostFromState(state);
    if (currentPost == null) return;

    emit(PostDetailReportingState(currentPost));
    final result = await _sendReport(
      HomePostReportParams(
        postId: event.postId,
        reason: event.reason,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(PostDetailFailureState(
        message: failure.message,
        post: currentPost,
      )),
      (_) => emit(PostDetailReportSuccessState(
        post: currentPost,
        message: 'Cảm ơn bạn. Báo cáo đã được gửi để xem xét.',
      )),
    );
  }

  HomePostEntity? _currentPostFromState(PostDetailState state) {
    if (state is PostDetailLoadedState) return state.post;
    if (state is PostDetailReservingState) return state.post;
    if (state is PostDetailReserveSuccessState) return state.post;
    if (state is PostDetailReportingState) return state.post;
    if (state is PostDetailReportSuccessState) return state.post;
    if (state is PostDetailFailureState) return state.post;
    return null;
  }
}
