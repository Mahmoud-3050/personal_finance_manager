import '../../domain/entities/capture_draft.dart';

abstract interface class CaptureDraftDataSource {
  CaptureDraft? read();

  void hold(CaptureDraft draft);

  void clear();

  bool get isFinished;

  void markFinished();
}

class MemoryCaptureDraftDataSource implements CaptureDraftDataSource {
  CaptureDraft? _draft;
  bool _finished = false;

  @override
  CaptureDraft? read() => _draft;

  @override
  bool get isFinished => _finished;

  @override
  void hold(CaptureDraft draft) {
    _draft = draft;
    _finished = false;
  }

  @override
  void clear() {
    _draft = null;
    _finished = false;
  }

  @override
  void markFinished() {
    _draft = null;
    _finished = true;
  }
}
