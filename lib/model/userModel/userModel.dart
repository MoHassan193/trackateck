class UserModel {
  final int uid;
  final String lang;
  final String tz;
  final int companyId;
  final String accessToken;
  final String expiresIn;
  final String expiryDate;
  final String representativeType;
  final int rank;


  UserModel({
    required this.uid,
    required this.lang,
    required this.tz,
    required this.companyId,
    required this.accessToken,
    required this.expiresIn,
    required this.expiryDate,
    required this.representativeType,
    required this.rank,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      lang: json['user_context']['lang'],
      tz: json['user_context']['tz'],
      companyId: json['company_id'],
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      expiryDate: json['expiry_date'],
      representativeType: json['representative_type'],
      rank: json['rank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'user_context': {
        'lang': lang,
        'tz': tz,
      },
      'company_id': companyId,
      'access_token': accessToken,
      'expires_in': expiresIn,
      'expiry_date': expiryDate,
      'representative_type': representativeType,
      'rank': rank,
    };
  }
}
