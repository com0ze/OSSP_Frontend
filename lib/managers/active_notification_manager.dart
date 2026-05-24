import 'package:open_source_software/managers/abstract_notification_manager.dart';
import 'package:open_source_software/managers/mock_notification_manager.dart'
    if (dart.library.io) 'package:open_source_software/managers/notification_manager.dart'
    as platform_impl;

AbstractNotificationManager get activeNotificationManager =>
    platform_impl.createManager();
