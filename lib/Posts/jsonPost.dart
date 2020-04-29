import 'package:audioplayers/audioplayers.dart';

//Receives post data in form of json - POJO
class jsonPost {
  int postID;
  String fileName;
  String postOwner;
  String title;
  String description;
  String postTime;
  double rating;
  String totalRates;
  String profilePic;
  String place;
  double yourRating = -1;
  bool showSlider = false;
  bool showDesc = false;
  bool isPlaying = false;
  bool allowRating = true;
  String currentTime = "00:00";
  String completeTime= "--:--";

  
  AudioPlayer player = new AudioPlayer();
  
  jsonPost(int postID, String fileName, String postOwner, String title, String place, String description, String postTime, double rating, String totalRates, String profilePic) {
    this.postID = postID;
    this.fileName = fileName;
    this.postOwner = postOwner;
    this.place = place;
    this.title = title;
    this.description = description;
    this.postTime = postTime;
    this.totalRates = totalRates;
    this.profilePic = profilePic;
    this.rating = rating;
  }

  jsonPost.fromJson(Map json)
      : postID = json['postID'],
        fileName = json['fileName'],
        postOwner = json['postOwner'],
        title = json['title'],
        description = json['description'],
        postTime = json['postTime'],
        totalRates = json['totalRates'],
        profilePic = json['profilePic'],
        rating = json['rating'],
        place = json['place'];

  Map toJson() {
    return { 'postID': postID, 'place': place, 'fileName': fileName, 'postOwner': postOwner, 'title': title, 'description': description, 'postTime': postTime, 'totalRates': totalRates, 'profilePic': profilePic, 'rating': rating };
  }
}