import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/receipt_photo.dart';
import '../repositories/receipt_capture_repository.dart';

class DeleteReceiptPhotoParams extends Params {
  const DeleteReceiptPhotoParams({required this.photo, this.cancellation});

  final ReceiptPhoto photo;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'path': photo.path};

  @override
  List<Object?> get props => <Object?>[photo, cancellation];
}

class DeleteReceiptPhotoUseCase
    extends UseCase<bool, DeleteReceiptPhotoParams> {
  DeleteReceiptPhotoUseCase({required ReceiptCaptureRepository repository})
    : _repository = repository;

  final ReceiptCaptureRepository _repository;

  @override
  Future<Either<Failure, bool>> call(DeleteReceiptPhotoParams params) async {
    final Either<Failure, void> deleted = await _repository.delete(
      params.photo,
    );
    return deleted.map((_) => true);
  }
}
