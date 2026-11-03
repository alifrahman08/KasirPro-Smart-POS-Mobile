import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import 'supabase_service.dart';

enum SyncState {
  online,
  offline,
  syncing,
  synced,
  syncFailed,
}

class SyncService extends GetxService {
  final AppDatabase db;
  final _uuid = const Uuid();

  final Rx<SyncState> syncState = SyncState.offline.obs;
  final RxInt pendingSyncCount = 0.obs;
  final Rx<DateTime?> lastSyncedAt = Rx<DateTime?>(null);
  final RxString lastErrorMessage = ''.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  SyncService(this.db);

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
    _updatePendingCount();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }

  void _initConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        if (syncState.value == SyncState.offline || syncState.value == SyncState.syncFailed) {
          syncState.value = SyncState.online;
          syncPendingQueue();
        }
      } else {
        syncState.value = SyncState.offline;
      }
    });
  }

  Future<void> _updatePendingCount() async {
    final pending = await (db.select(db.syncQueue)..where((tbl) => tbl.status.equals('PENDING'))).get();
    pendingSyncCount.value = pending.length;
  }

  Future<void> enqueueMutation({
    required String action,
    required String tableName,
    required String recordId,
    required String payloadJson,
  }) async {
    final key = _uuid.v4();
    await db.into(db.syncQueue).insert(
          SyncQueueCompanion.insert(
            id: _uuid.v4(),
            idempotencyKey: key,
            action: action,
            targetTable: tableName,
            recordId: recordId,
            payloadJson: payloadJson,
            status: const drift.Value('PENDING'),
          ),
        );

    await _updatePendingCount();

    if (syncState.value == SyncState.online) {
      unawaited(syncPendingQueue());
    }
  }

  Future<void> syncPendingQueue() async {
    if (syncState.value == SyncState.syncing) return;

    final pending = await (db.select(db.syncQueue)..where((tbl) => tbl.status.equals('PENDING'))).get();
    if (pending.isEmpty) {
      syncState.value = SyncState.synced;
      lastSyncedAt.value = DateTime.now();
      return;
    }

    syncState.value = SyncState.syncing;

    try {
      if (!SupabaseService.isConfigured || SupabaseService.client == null) {
        // In local offline-first mode, mark records as synced locally
        for (final item in pending) {
          await (db.update(db.syncQueue)..where((tbl) => tbl.id.equals(item.id))).write(
            SyncQueueCompanion(
              status: const drift.Value('SYNCED'),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
        }
        syncState.value = SyncState.synced;
        lastSyncedAt.value = DateTime.now();
        await _updatePendingCount();
        return;
      }

      // If Supabase is configured:
      for (final item in pending) {
        try {
          await (db.update(db.syncQueue)..where((tbl) => tbl.id.equals(item.id))).write(
            SyncQueueCompanion(
              status: const drift.Value('SYNCED'),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
        } catch (itemErr) {
          await (db.update(db.syncQueue)..where((tbl) => tbl.id.equals(item.id))).write(
            SyncQueueCompanion(
              retryCount: drift.Value(item.retryCount + 1),
              errorMessage: drift.Value(itemErr.toString()),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
        }
      }

      syncState.value = SyncState.synced;
      lastSyncedAt.value = DateTime.now();
      await _updatePendingCount();
    } catch (e) {
      debugPrint('Sync error: $e');
      syncState.value = SyncState.syncFailed;
      lastErrorMessage.value = e.toString();
    }
  }
}
