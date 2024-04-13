class Assignment {
  final int id;
  final String marketName;
  final int companyId;
  final bool status;  // Status as boolean
  final String slug;
  final String day;
  final String? start_time;
  final String? end_time;

  Assignment({
    required this.id,
    required this.marketName,
    required this.companyId,
    required this.status,
    required this.slug,
    required this.day,
    this.start_time,
    this.end_time,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      marketName: json['market_name'],
      companyId: json['company_id'],  // Adjusted field name
      status: json['status'] == 'pending' ? false : true,  // Convert status string to boolean
      slug: json['slug'],
      day: json['day'],
      start_time: json['start_time'],
      end_time: json['end_time'],
    );
  }
}
