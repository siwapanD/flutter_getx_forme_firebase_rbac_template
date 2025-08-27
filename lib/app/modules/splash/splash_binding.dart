import 'package:get/get.dart';

import 'splash_controller.dart';

/// Splash binding for dependency injection
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}