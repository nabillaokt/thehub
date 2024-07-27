import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadAvatar {
  static Future<String?> uploadImage(File? image, String userId) async {
    // Mark as async and correct parameter name
    if (image == null) return null; // Check if image is not null

    String fileName = basename(image.path);

    try {
      // Initialize Firebase (if not already initialized)
      await Firebase.initializeApp();

      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);

      // Wait for the upload task to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user data in Firestore with the download URL
      await FirebaseFirestore.instance
          .collection('user') // Assuming 'users' is the collection name
          .doc(userId) // Document ID of the user
          .update({'avatarUrl': downloadUrl}); // Update avatar URL

      return downloadUrl;
    } catch (e) {
      // Handle any errors that occurred during the upload process
      print('Error uploading image: $e');
      return null;
    }
  }
}
