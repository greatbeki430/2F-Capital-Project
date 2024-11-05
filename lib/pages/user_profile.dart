import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateProfileImage() async {
    // Step 1: Pick an image from the gallery
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return; // Exit if no image is picked

    // Step 2: Upload the image to Firebase Storage
    final file = File(pickedFile.path);
    String fileName =
        'profile_images/${_auth.currentUser!.uid}.png'; // Set a unique filename
    try {
      // Upload the image
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(file);
      String downloadUrl =
          await snapshot.ref.getDownloadURL(); // Get the download URL

      // Step 3: Updates the user's profile image URL in the database
      String userId = _auth.currentUser!.uid;
      await _dbRef.child('users/$userId/profileImageUrl').set(downloadUrl);
      print('Profile image updated: $downloadUrl'); // Optional: Log the URL
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}
