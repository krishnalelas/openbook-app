import 'package:Buzzing/services/httpie.dart';

class WaitlistApiService {
  HttpieService _httpService;
  String buzzingSocialApiURL;

  static const MAILCHIMP_SUBSCRIBE_PATH = 'waitlist/subscribe/';
  static const HEALTH_PATH = 'health/';

  void setBuzzingSocialApiURL(String newApiURL) {
    buzzingSocialApiURL = newApiURL;
  }

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  Future<HttpieResponse> subscribeToBetaWaitlist({String email}) {
    var body = {};
    if (email != null && email != '') {
      body['email'] = email;
    }
    return this
        ._httpService
        .postJSON('$buzzingSocialApiURL$MAILCHIMP_SUBSCRIBE_PATH', body: body);
  }
}