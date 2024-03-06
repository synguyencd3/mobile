class Config {
  static const String appName = "Salon oto";
  static const String apiURL = "192.168.1.5:5000";
  static const String loginAPI = "auth/login"; 
  static const String registerAPI = "auth/register";
  static const String userprofileAPI = "/users/user-profile";

  //News API
  static const String newsURL = 'newsapi.org';
  static const String newsAPi = '/v2/everything';
  static const String apiKey = 'b019956a13da4697841c13223270901f';

  //Google API
  static const String client_id = '146451497096-2hsg5onibmrolpvdlm3vq73qsq6bpufn.apps.googleusercontent.com';
  static const String client_secret = "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";
  static const String redirect_uri_androi = 'com.googleusercontent.apps.$client_id:/oauthredirect';
}
