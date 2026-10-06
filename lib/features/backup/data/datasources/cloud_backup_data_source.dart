import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../firebase_options.dart';
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
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const String _payloadField = 'payload';
  static const String _createdAtField = 'createdAt';
  static const String _originField = 'origin';
  static const String _outcomeField = 'outcome';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Future<void> signIn() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize(
        serverClientId: DefaultFirebaseOptions.googleServerClientId,
      );
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
    try {
      final DocumentReference<Map<String, dynamic>> doc = _userCopies().doc(
        _documentId(snapshot.createdAt),
      );
      await doc.set(<String, dynamic>{
        _createdAtField: Timestamp.fromDate(snapshot.createdAt.toUtc()),
        _originField: snapshot.origin.name,
        _outcomeField: BackupOutcome.succeeded.name,
        _payloadField: snapshot.toJson(),
      });
      return BackupCopy(
        id: doc.path,
        createdAt: snapshot.createdAt,
        origin: snapshot.origin,
        outcome: BackupOutcome.succeeded,
      );
    } on FirebaseException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<List<BackupCopy>> listCopies() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> listed = await _userCopies()
          .orderBy(_createdAtField, descending: true)
          .get();
      return listed.docs.map(_copyFromDocument).toList();
    } on FirebaseException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<BookSnapshotModel> download(String copyId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .doc(copyId)
          .get();
      final Map<String, dynamic>? data = doc.data();
      final Object? payload = data?[_payloadField];
      if (!doc.exists || payload is! Map) {
        throw const CacheException(message: 'missing_backup');
      }
      return BookSnapshotModel.fromJson(Map<String, dynamic>.from(payload));
    } on FirebaseException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<void> delete(String copyId) async {
    try {
      await _firestore.doc(copyId).delete();
    } on FirebaseException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  CollectionReference<Map<String, dynamic>> _userCopies() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw const UnauthorizedException(message: 'sign_in_required');
    }
    return _firestore.collection('backups').doc(user.uid).collection('copies');
  }

  String _documentId(DateTime createdAt) =>
      createdAt.toUtc().toIso8601String().replaceAll(':', '-');

  BackupCopy _copyFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final Object? createdRaw = data[_createdAtField];
    final DateTime createdAt = switch (createdRaw) {
      Timestamp timestamp => timestamp.toDate().toUtc(),
      String iso => DateTime.parse(iso).toUtc(),
      _ => DateTime.now().toUtc(),
    };
    final String originName =
        data[_originField] as String? ?? BackupOrigin.manualCloud.name;
    return BackupCopy(
      id: doc.reference.path,
      createdAt: createdAt,
      origin:
          BackupOrigin.values.asNameMap()[originName] ??
          BackupOrigin.manualCloud,
      outcome: BackupOutcome.succeeded,
    );
  }
}
