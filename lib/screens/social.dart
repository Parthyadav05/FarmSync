import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../data/review.dart';

class Social extends StatefulWidget {
  @override
  State<Social> createState() => _SocialState();
}

class _SocialState extends State<Social> {
  final ReviewController reviewController = ReviewController();

  TextEditingController value = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      reviewController.setImage(image.path);
    } else {
      print('Error: Image picking process was cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect it',
          style: GoogleFonts.ubuntu(
            textStyle: TextStyle(fontWeight: FontWeight.bold)
          ),
        ),
        elevation: 20,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: reviewController.fetchReviewsWithImages(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: reviewController.reviewsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final review = reviewController.reviewsList[index];
                      final imageUrl = review['photo_url'];
                      final reviewText = review['review_text'] as String? ?? '';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl != null && imageUrl.isNotEmpty)
                                Neumorphic(
                                  child: ClipRRect(
                                    child: Image.network(
                                      imageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              SizedBox(
                                height: 4,
                              ),
                             Neumorphic(
                               child: Padding(padding: EdgeInsets.all(8),
                                 child:Text(
                                   reviewText,
                                   style: TextStyle(
                                     fontSize: 16,
                                     color: Colors.black,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 ),
                               )
                             ),
                              SizedBox(height: 8),
                              _buildCommentSection(review),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                height: 200,
                width: 400,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: value,
                        onChanged: (value) {
                          reviewController.setReviewText(value);
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter your Experience..',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (value.text.isNotEmpty) {
                          await _pickImage(); // Wait for image selection
                          if (reviewController.getImagePath().isNotEmpty) {
                            reviewController.addReviewWithPhoto();
                            Navigator.pop(
                                context); // Close the bottom sheet after posting
                          } else {
                            print('Error: Please select an image');
                          }
                        } else {
                          print('Error: Please enter a comment');
                        }
                      },
                      child: Text(
                        "Post",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Colors.green.shade100,
        tooltip: "Add Experience..",
        child: Icon(Icons.comment),
      ),
    );
  }

  Widget _buildCommentSection(Map<String, dynamic>? review) {
    if (review == null) {
      return SizedBox(); // Return an empty widget if review is null
    }

    final comments = review['comments'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        if (comments != null &&
            comments.isNotEmpty) // Check if comments is not null and not empty
          ListView.builder(
            shrinkWrap: true,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              if (comment != null && comment['text'] != null) {
                final commentText = comment['text']
                    as String?; // Adjusted to handle potential null
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    commentText ??
                        '', // Use default empty string if comment text is null
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                );
              } else {
                return SizedBox(); // Return an empty widget if comment or comment text is null
              }
            },
          ),
        SizedBox(height: 8),
        _buildCommentTextField()
      ],
    );
  }

  Widget _buildCommentTextField() {
    final TextEditingController commentController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment..',
                suffixIcon: IconButton(

                  onPressed: () async {
                    final text = commentController.text.trim();
                    if (text.isNotEmpty) {
                      DocumentReference docRef = await FirebaseFirestore
                          .instance
                          .collection('reviews')
                          .add({});
                      String reviewId = docRef.id;
                      String commentText = text;
                      await reviewController.addComment(reviewId, commentText);
                    } else {
                      print('Error: Please provide a valid comment');
                    }
                  },
                  icon: Icon(Icons.send),
                  color: Colors.greenAccent,
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
