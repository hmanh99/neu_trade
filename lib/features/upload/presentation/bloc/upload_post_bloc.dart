import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/create_upload_post_request.dart';
import '../../domain/usecases/create_post_use_case.dart';
import 'upload_post_event.dart';
import 'upload_post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required CreatePostUseCase createPost, Uuid? uuid})
    : _createPost = createPost,
      _uuid = uuid ?? const Uuid(),
      super(const PostInitialState()) {
    on<PostSubmissionRequested>(_onSubmissionRequested);
    on<PostFormReset>((event, emit) {
      _pendingRequestId = null;
      _pendingInput = null;
      _pendingImages = null;
      emit(const PostInitialState());
    });
  }

  final CreatePostUseCase _createPost;
  final Uuid _uuid;
  String? _pendingRequestId;
  CreatePostRequest? _pendingInput;
  List<PostImageRequest>? _pendingImages;

  Future<void> _onSubmissionRequested(
    PostSubmissionRequested event,
    Emitter<PostState> emit,
  ) async {
    if (state is PostSubmittingState) return;

    final canRetryPending =
        state is PostSubmissionFailureState &&
        _pendingInput == event.input &&
        _sameImages(_pendingImages, event.images);
    final requestId = canRetryPending ? _pendingRequestId! : _uuid.v4();

    _pendingRequestId = requestId;
    _pendingInput = event.input;
    _pendingImages = List.unmodifiable(event.images);
    emit(const PostSubmittingState());

    final result = await _createPost(
      CreatePostParams(
        requestId: requestId,
        input: event.input,
        images: event.images,
      ),
    );

    result.fold(
      (failure) => emit(PostSubmissionFailureState(message: failure.message)),
      (post) {
        _pendingRequestId = null;
        _pendingInput = null;
        _pendingImages = null;
        emit(PostSubmissionSuccessState(post));
      },
    );
  }

  bool _sameImages(List<PostImageRequest>? left, List<PostImageRequest> right) {
    if (left == null || left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
