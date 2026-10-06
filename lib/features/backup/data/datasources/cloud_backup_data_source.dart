import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/backup_copy.dart';
import '../../domain/entities/backup_settings.dart';
import '../models/book_snapshot_model.dart';

abstract interface class CloudBackupDataSource {
  bool get isSignedIn;

  Future<void> signIn();

  Future<BackupCopy> upload(BookSnapshotModel snapshot);

  Future<List<BackupCopy>> listCopies();

  Future<BookSnapshotModel> download(String copyId);

  Future<void> delete(String copyId);
}

class FirebaseCloudBackupDataSource implements CloudBackupDataSource {
  FirebaseCloudBackupDataSource({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Future<void> signIn() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const SocialSignInCancelledException();
      }
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialSignInCancelledException();
      }
      throw ServerException(message: error.description);
    } on FirebaseException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<BackupCopy> upload(BookSnapshotModel snapshot) async {
    final Reference ref = _userFolder().child(_objectName(snapshot.createdAt));
    await ref.putData(
      Uint8List.fromList(utf8.encode(snapshot.encode())),
      SettableMetadata(
        contentType: 'application/json',
        customMetadata: <String, String>{
          'origin': snapshot.origin.name,
          'outcome': BackupOutcome.succeeded.name,
        },
      ),
    );
    return BackupCopy(
      id: ref.fullPath,
      createdAt: snapshot.createdAt,
      origin: snapshot.origin,
      outcome: BackupOutcome.succeeded,
    );
  }

  @override
  Future<List<BackupCopy>> listCopies() async {
    final ListResult listed = await _userFolder().listAll();
    final List<BackupCopy> copies = <BackupCopy>[];
    for (final Reference item in listed.items) {
      final FullMetadata metadata = await item.getMetadata();
      final String originName =
          metadata.customMetadata?['origin'] ?? BackupOrigin.manualCloud.name;
      copies.add(
        BackupCopy(
          id: item.fullPath,
          createdAt: metadata.timeCreated ?? DateTime.now().toUtc(),
          origin:
              BackupOrigin.values.asNameMap()[originName] ??
              BackupOrigin.manualCloud,
          outcome: BackupOutcome.succeeded,
        ),
      );
    }
    return copies;
  }

  @override
  Future<BookSnapshotModel> download(String copyId) async {
    final Uint8List? bytes = await _storage.ref(copyId).getData();
    if (bytes == null) {
      throw const CacheException(message: 'missing_backup');
    }
    return BookSnapshotModel.decode(utf8.decode(bytes));
  }

  @override
  Future<void> delete(String copyId) => _storage.ref(copyId).delete();

  Reference _userFolder() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw const UnauthorizedException(message: 'sign_in_required');
    }
    return _storage.ref('backups/${user.uid}');
  }

  String _objectName(DateTime createdAt) =>
      '${createdAt.toUtc().toIso8601String()}.json';
}
