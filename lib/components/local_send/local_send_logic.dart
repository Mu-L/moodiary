import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:moodiary/components/local_send/local_send_client/local_send_client_logic.dart';
import 'package:moodiary/components/local_send/local_send_server/local_send_server_logic.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'local_send_state.dart';

Future<String?> getDeviceIP() async {
  // 获取当前的连接状态
  final connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult.isNotEmpty) {
    // 如果当前连接到wifi
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      final info = NetworkInfo();
      return info.getWifiIP();
    } else {
      // 获取所有网络接口
      for (final interface in await NetworkInterface.list()) {
        // 检查接口是否有 IPv4 地址
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4) {
            return address.address; // 返回第一个有效的 IPv4 地址
          }
        }
      }
    }
  }

  return null; // 未连接网络或无法获取 IP 地址
}

class LocalSendLogic extends GetxController {
  final LocalSendState state = LocalSendState();

  @override
  void onReady() async {
    await getWifiInfo();
    super.onReady();
  }

  Future<void> getWifiInfo() async {
    state.deviceIpAddress = (await getDeviceIP()) ?? '无法获取';
    update(['WifiInfo']);
  }

  // // client
  // Future<void> findServer() async {
  //   state.findingServer.value = true;
  //   var serverInfo = await localSendClient.findServer();
  //   if (serverInfo != null) {
  //     state.serverIp.value = serverInfo['ip'];
  //     state.serverPort.value = serverInfo['port'];
  //     state.findingServer.value = false;
  //   }
  // }

  void showInfo() {
    state.showInfo = !state.showInfo;
    update(['Info']);
  }

  void changeType(String value) {
    state.type = value;
    update(['SegmentButton', 'Panel']);
  }

  void changeScanPort(int value) {
    state.scanPort.value = value;
    if (Bind.isRegistered<LocalSendServerLogic>()) {
      Bind.reload<LocalSendServerLogic>();
    }

    if (Bind.isRegistered<LocalSendClientLogic>()) {
      Bind.reload<LocalSendClientLogic>();
    }
  }

  void changeTransferPort(int value) {
    state.transferPort.value = value;

    if (Bind.isRegistered<LocalSendServerLogic>()) {
      Bind.reload<LocalSendServerLogic>();
    }

    if (Bind.isRegistered<LocalSendClientLogic>()) {
      Bind.reload<LocalSendClientLogic>();
    }
  }
}
