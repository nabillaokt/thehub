import 'package:get/get.dart';
import 'package:thehub/source/paket_source.dart';

import '../model/paket_sarana.dart';

class CDashboard extends GetxController {
  final _listPaket = <Paketsarana>[].obs;
  List<Paketsarana> get listPaket => _listPaket;

  void getListPaket() {
    PaketSource.getPaketStream().listen((List<Paketsarana> data) {
      _listPaket.assignAll(data);
    });
  }

  @override
  void onInit() {
    getListPaket();
    super.onInit();
  }
}
