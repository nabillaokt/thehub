import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thehub/model/paket_sarana.dart';

class PaketSource {
  static Stream<List<Paketsarana>> getPaketStream() {
    return FirebaseFirestore.instance.collection("PaketSaran").snapshots().map(
        (snapshot) => snapshot.docs
            .map((document) => Paketsarana.fromJson(document.data()))
            .toList());
  }
}
