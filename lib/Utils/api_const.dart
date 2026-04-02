class ApiConst{

  ApiConst._();
  static ApiConst apiConst = ApiConst._();

  static const String basUrl = "https://agsdemo.in/macapi/public/api/";

  static const String login = "${basUrl}login";
  static const String fetchServiceBanner = "${basUrl}fetch-service-banner";
  static const String fetchProfile = "${basUrl}fetch-profile";
  static const String addComplaint = "${basUrl}addComplaint";
  static const String fetchComplaint = "${basUrl}fetchComplaint";
  static const String fetchFamilyMember = "${basUrl}fetch-family-member-list";
  static const String removeMember = "${basUrl}removeFamilyMember/";
  static const String addFamilyMember = "${basUrl}addFamilyMember";
  static const String fetchService = "${basUrl}fetch-service-logo";


}