

class jsonMates {
  String name;
  String place;
  String profile;
  String status = "Follow";
  
  jsonMates(String name, String place, String profile) {
    this.name = name;
    this.place = place;
    this.profile = profile;
  }

  jsonMates.fromJson(Map json)
      : name = json['name'],
        place = json['place'],
        profile = json['profile'];

  Map toJson() {
    return { 'name': name, 'place': place, 'profile': profile };
  }
}