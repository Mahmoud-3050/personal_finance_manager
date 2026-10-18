import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/receipt_image_source.dart';
import '../entities/receipt_photo.dart';
import '../repositories/receipt_capture_repository.dart';

class PickReceiptImageParams extends Params {
  const PickReceiptImageParams({required this.source, this.cancellation});

  final ReceiptImageSource source;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'source': source.name};

  @override
  List<Object?> get props => <Object?>[source, cancellation];
}

class PickReceiptImageUseCase
    extends UseCase<ReceiptPhoto?, PickReceiptImageParams> {
  PickReceiptImageUseCase({required ReceiptCaptureRepository repository})
    : _repository = repository;

  final ReceiptCaptureRepository _repository;

  @override
  Future<Either<Failure, ReceiptPhoto?>> call(PickReceiptImageParams params) {
    return _repository.pick(params.source);
  }
}
