import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ReviewController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _imagePath = '';
  String _reviewText = '';
  List<Map<String, dynamic>> _reviewsList = [];

  // Getter method for reviewsList
  List<Map<String, dynamic>> get reviewsList => _reviewsList;

  // Method to set the image path
  String getImagePath() {
    return _imagePath;
  }
  void setImage(String path) {
    _imagePath = path;
  }

  // Method to set the review text
  void setReviewText(String text) {
    _reviewText = text;
  }

  // Function to add a review with a photo to Firestore and Storage
  Future<void> addReviewWithPhoto() async {
    try {
      if (_imagePath.isEmpty || _reviewText.isEmpty) {
        print('Error: Please select an image and enter a comment');
        return;
      }

      String photoUrl = _imagePath;
      Reference ref = _storage.ref().child('reviews_photos/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = ref.putFile(File(photoUrl));
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadURL = await snapshot.ref.getDownloadURL();

      await _firestore.collection('reviews').add({
        'review_text': _reviewText,
        'photo_url': downloadURL,
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Success: Review added successfully');

      // Clear image path after successfully adding the review
      _imagePath = '';
    } catch (e) {
      print('Error adding review: $e');
      print('Error: Failed to add review');
    }
  }

  // Function to add a comment to a review
  Future<void> addComment(String reviewId, String commentText) async {
    try {
      DocumentReference reviewRef = _firestore.collection('reviews').doc(reviewId);

      await reviewRef.update({
        'comments': FieldValue.arrayUnion([
          {
            'text': commentText,
            'timestamp': DateTime.now(), // Use client-side timestamp
          }
        ])
      });

      print('Success: Comment added successfully');
    } catch (e) {
      print('Error adding comment: $e');
      print('Error: Failed to add comment');
    }
  }





  // Function to fetch reviews from Firestore
  Future<void> fetchReviews() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('reviews').get();
      if (snapshot.docs.isNotEmpty) {
        _reviewsList = snapshot.docs.map((doc) => doc.data()).toList();
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  // Function to fetch reviews with images from Firestore and Storage
  Future<void> fetchReviewsWithImages() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('reviews').get();

      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> reviews = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> reviewData = doc.data();
          if (reviewData.containsKey('photo_url')) {
            String imageURL = reviewData['photo_url'];
            reviewData['image_url'] = await _getImageURL(imageURL);
          }
          reviews.add(reviewData);
        }
        _reviewsList = reviews;
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  // Function to fetch image URLs from Firebase Storage
  Future<String> _getImageURL(String imagePath) async {
    try {
      return await _storage.ref(imagePath).getDownloadURL();
    } catch (e) {
      print('Error fetching image: $e');
      return ''; // Return empty string or default image URL in case of error
    }
  }
}
