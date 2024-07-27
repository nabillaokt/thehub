import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPackagePopup extends StatelessWidget {
  final Map<String, dynamic> packageData;

  const EditPackagePopup({Key? key, required this.packageData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: packageData['name']);
    TextEditingController descriptionController =
        TextEditingController(text: packageData['description']);
    TextEditingController priceController =
        TextEditingController(text: packageData['price'].toString());

    return AlertDialog(
      title: const Text('Edit Paket Panahan'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Paket',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: null, // Set maxLines to null for unlimited lines
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Simpan'),
          onPressed: () async {
            String name = nameController.text.trim();
            String description = descriptionController.text.trim();
            int price = int.tryParse(priceController.text.trim()) ?? 0;

            if (name.isNotEmpty && description.isNotEmpty && price > 0) {
              FirebaseFirestore.instance
                  .collection('PaketSaran')
                  .doc(packageData['id'])
                  .update({
                'name': name,
                'description': description,
                'price': price,
              });

              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Mohon lengkapi semua input dengan benar.'),
              ));
            }
          },
        ),
      ],
    );
  }
}
