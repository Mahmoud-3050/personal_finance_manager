import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../entities/capture_draft.dart';

abstract interface class CaptureRepository {
  Future<Either<Failure, CaptureDraft?>> read();

  Future<Either<Failure, CaptureDraft>> hold(CaptureDraft draft);

  Future<Either<Failure, void>> clear();

  Future<Either<Failure, bool>> isFinished();

  Future<Either<Failure, void>> markFinished();
}
