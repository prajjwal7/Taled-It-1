class jsonLogin {
  String userName;
  String password;
  int loggedIn;

  jsonLogin(String userName, String password, int loggedIn) {
    this.userName = userName;
    this.password = password;
    this.loggedIn = loggedIn;
  }

  jsonLogin.fromJson(Map json)
      : userName = json['userName'],
        password = json['userPassWord'],
        loggedIn = json['loggedIn'];

  Map toJson() {
    return { 'userName': userName, 'userPassWord': password, 'loggedIn': loggedIn };
  }
}