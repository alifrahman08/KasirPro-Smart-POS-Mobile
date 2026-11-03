import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class NotificationRepository {
  final AppDatabase db;

  NotificationRepository({required this.db});

  Stream<List<AppNotification>> watchNotifications(String businessId) {
    return (db.select(db.notifications)
          ..where((tbl) => tbl.businessId.equals(businessId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  Future<List<AppNotification>> getNotifications(String businessId) async {
    return (db.select(db.notifications)
          ..where((tbl) => tbl.businessId.equals(businessId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  Future<void> markAsRead(String id) async {
    await (db.update(db.notifications)..where((tbl) => tbl.id.equals(id))).write(
      const NotificationsCompanion(isRead: Value(true)),
    );
  }

  Future<void> markAllAsRead(String businessId) async {
    await (db.update(db.notifications)..where((tbl) => tbl.businessId.equals(businessId))).write(
      const NotificationsCompanion(isRead: Value(true)),
    );
  }
}
