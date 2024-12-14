import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:pdf_printer/service/debug/logger.dart';

class NetworkService extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool isConnected = false;
  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResultList) {
    logger.d("Started logging - Network Service");
    if (connectivityResultList.contains(ConnectivityResult.none)) {
      logger.d("Network down");
      isConnected = false;
      // Get.to(
      //   () => const NoInternet(),
      // );
    } else {
      logger.d("Network service restored");
      isConnected = true;
      // Get.back();
    }
  }
}
