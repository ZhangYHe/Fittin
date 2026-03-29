import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

class WebStoreNames {
  static const appState = 'app_state';
  static const templates = 'templates';
  static const instances = 'instances';
  static const workoutLogs = 'workout_logs';
  static const bodyMetrics = 'body_metrics';
  static const progressPhotos = 'progress_photos';
  static const syncQueue = 'sync_queue';

  static const all = [
    appState,
    templates,
    instances,
    workoutLogs,
    bodyMetrics,
    progressPhotos,
    syncQueue,
  ];
}

class WebLocalStore {
  WebLocalStore._(this._database);

  static const _databaseName = 'fittin_v2_web_store';
  static const _databaseVersion = 1;
  static Future<WebLocalStore>? _instance;

  final web.IDBDatabase _database;

  static Future<WebLocalStore> open() {
    return _instance ??= _openInternal();
  }

  static Future<WebLocalStore> _openInternal() async {
    final request = web.window.indexedDB.open(_databaseName, _databaseVersion);
    final completer = Completer<web.IDBDatabase>();

    request.onupgradeneeded = ((web.Event _) {
      final database = request.result as web.IDBDatabase;
      for (final storeName in WebStoreNames.all) {
        if (!database.objectStoreNames.contains(storeName)) {
          database.createObjectStore(storeName);
        }
      }
    }).toJS;

    request.onsuccess = ((web.Event _) {
      completer.complete(request.result as web.IDBDatabase);
    }).toJS;

    request.onerror = ((web.Event _) {
      completer.completeError(
        request.error ?? StateError('Failed to open IndexedDB.'),
      );
    }).toJS;

    return WebLocalStore._(await completer.future);
  }

  Future<Map<String, dynamic>?> getRecord(String storeName, String key) async {
    final transaction = _database.transaction(storeName.toJS, 'readonly');
    final store = transaction.objectStore(storeName);
    final result = await _requestResult(store.get(key.toJS));
    await _transactionCompleted(transaction);
    if (result == null) {
      return null;
    }
    return _castRecord(result);
  }

  Future<List<Map<String, dynamic>>> getAllRecords(String storeName) async {
    final transaction = _database.transaction(storeName.toJS, 'readonly');
    final store = transaction.objectStore(storeName);
    final result = await _requestResult(store.getAll());
    await _transactionCompleted(transaction);
    return (result as List? ?? const <dynamic>[]).map(_castRecord).toList();
  }

  Future<void> putRecord(
    String storeName,
    String key,
    Map<String, dynamic> value,
  ) async {
    final transaction = _database.transaction(storeName.toJS, 'readwrite');
    final store = transaction.objectStore(storeName);
    await _requestResult(store.put(value.jsify(), key.toJS));
    await _transactionCompleted(transaction);
  }

  Future<void> deleteRecord(String storeName, String key) async {
    final transaction = _database.transaction(storeName.toJS, 'readwrite');
    final store = transaction.objectStore(storeName);
    await _requestResult(store.delete(key.toJS));
    await _transactionCompleted(transaction);
  }

  static Future<Object?> _requestResult(web.IDBRequest request) {
    final completer = Completer<Object?>();
    request.onsuccess = ((web.Event _) {
      completer.complete(request.result.dartify());
    }).toJS;
    request.onerror = ((web.Event _) {
      completer.completeError(
        request.error ?? StateError('IndexedDB request failed.'),
      );
    }).toJS;
    return completer.future;
  }

  static Future<void> _transactionCompleted(web.IDBTransaction transaction) {
    final completer = Completer<void>();
    transaction.oncomplete = ((web.Event _) {
      completer.complete();
    }).toJS;
    transaction.onerror = ((web.Event _) {
      completer.completeError(
        transaction.error ?? StateError('IndexedDB transaction failed.'),
      );
    }).toJS;
    transaction.onabort = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          transaction.error ?? StateError('IndexedDB transaction aborted.'),
        );
      }
    }).toJS;
    return completer.future;
  }

  static Map<String, dynamic> _castRecord(dynamic value) {
    return (value as Map).cast<String, dynamic>();
  }
}
