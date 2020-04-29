class jsonSignUp {
  int response;

  jsonLogin(int response) {
    this.response = response;
  }

  jsonSignUp.fromJson(Map json)
      : response = json['message'];

  Map toJson() {
    return { 'message': response };
  }
}