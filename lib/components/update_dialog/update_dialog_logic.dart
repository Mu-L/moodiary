import 'package:get/get.dart';
import 'package:moodiary/common/models/github.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialogLogic extends GetxController {
  Future<void> toDownload(GithubRelease githubRelease) async {
    await launchUrl(
      Uri.parse(githubRelease.htmlUrl!),
      mode: LaunchMode.platformDefault,
    );
  }
}
