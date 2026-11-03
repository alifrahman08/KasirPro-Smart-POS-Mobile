import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository notificationRepository = Get.find<NotificationRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final result = await notificationRepository.getNotifications(businessId);
      notifications.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    await notificationRepository.markAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
    await notificationRepository.markAllAsRead(businessId);
    await loadNotifications();
  }
}
