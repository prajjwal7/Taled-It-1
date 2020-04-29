class jsonProfile {
  String username, email, profilePic, place;
  int followers, following;

  jsonProfile(String username, String email, String profilePic, String place, int followers, int following) {
    this.username = username;
    this.email = email;
    this.profilePic = profilePic;
    this.place = place;
    this.followers = followers;
    this.following = following;
  }

  jsonProfile.fromJson(Map json)
      : username = json['username'],
        email = json['email'],
        profilePic = json['profilePic'],
        place = json['place'],
        followers = json['followers'],
        following = json['follows'];

  Map toJson() {
    return { 'username': username, 'email': email, 'profilePic': profilePic, 'place': place, 'followers': followers, 'follows': following };
  }

}