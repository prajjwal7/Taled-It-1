class jsonPersonalPosts {
  String title;
  double rate;
  int totalRates;

  jsonPersonalPosts(String title, double rate, int totalRates) {
    this.title = title;
    this.rate = rate;
    this.totalRates = totalRates;
  }

  jsonPersonalPosts.fromJson(Map json)
      : title = json['title'],
        rate = json['rate'],
        totalRates = json['totalRates'];

  Map toJson() {
    return { 'title': title, 'rate': rate, 'totalRates': totalRates };
  }
  
}