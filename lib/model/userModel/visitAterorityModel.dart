class Territory {
  final int id;
  final String name;

  Territory({
    required this.id,
    required this.name,
  });

  factory Territory.fromJson(Map<String, dynamic> json) {
    return Territory(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TodayDailyModel {
  final int id;
  final String title;
  final String date;
  final String userName;
  final int userId;
  final int monthPlanId;
  final String monthPlanName;
  final List<Territory> territories;

  TodayDailyModel({
    required this.id,
    required this.title,
    required this.date,
    required this.userName,
    required this.userId,
    required this.monthPlanId,
    required this.monthPlanName,
    required this.territories,
  });

  factory TodayDailyModel.fromJson(Map<String, dynamic> json) {
    return TodayDailyModel(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      userName: json['user_name'],
      userId: json['user_id'],
      monthPlanId: json['month_plan_id'],
      monthPlanName: json['month_plan_name'],
      territories: (json['territories'] as List)
          .map((territory) => Territory.fromJson(territory))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'user_name': userName,
      'user_id': userId,
      'month_plan_id': monthPlanId,
      'month_plan_name': monthPlanName,
      'territories': territories.map((territory) => territory.toJson()).toList(),
    };
  }
}
