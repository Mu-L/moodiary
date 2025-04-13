import 'package:get/get.dart';
import 'package:moodiary/persistence/supabase.dart';
import 'package:moodiary/router/app_routes.dart';

import 'user_state.dart';

class UserLogic extends GetxController {
  final UserState state = UserState();

  Future<void> signOut() async {
    await SupabaseUtil().signOut();
    Get.offAndToNamed(AppRoutes.loginPage);
  }
}
