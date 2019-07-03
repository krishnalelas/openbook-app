import 'package:Buzzing/services/httpie.dart';

class DocumentsService {
  HttpieService _httpService;

  static const guidelinesUrl = 'https://buzzingorg.github.io/buzzing-api/COMMUNITY_GUIDELINES.md';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  Future<String> getCommunityGuidelines() async {
    HttpieResponse response = await _httpService.get(guidelinesUrl);
    return response.body;
  }
}
