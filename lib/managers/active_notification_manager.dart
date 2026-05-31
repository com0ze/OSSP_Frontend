import '/managers/abstract_notification_manager.dart';
import '/managers/mock_notification_manager.dart'
    if (dart.library.io) '/managers/notification_manager.dart'
    as platform_impl;

AbstractNotificationManager get activeNotificationManager =>
    platform_impl.createManager();
