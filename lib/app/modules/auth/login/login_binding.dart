import 'package:get/get.dart';

import 'login_controller.dart';

/// Login binding for dependency injection
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}