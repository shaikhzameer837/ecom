import 'package:firebase_database/firebase_database.dart';

import '../../core/utils/app_exception.dart';
import '../../core/utils/app_logger.dart';

/// Base class for all Realtime Database repositories.
/// Centralizes reference creation and error mapping so controllers only
/// ever see typed [AppException]s.
abstract class BaseRepository {
  DatabaseReference ref(String path) => FirebaseDatabase.instance.ref(path);

  /// Runs [action] and converts low-level Firebase failures into
  /// [FirebaseDataException] with logging.
  Future<T> guard<T>(Future<T> Function() action, String context) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.e('Repository failure: $context', error: error, stackTrace: stackTrace);
      throw const FirebaseDataException();
    }
  }
}
