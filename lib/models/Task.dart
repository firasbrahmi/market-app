class Task {
  final int id;
  final int? parentId; // Nullable to indicate if it's a subtask
  final String name;
  final String type;
  final String priority;
  final String? estimatedTime;
  final String details;
  final String? dueDate;
   bool status;
  final bool recurring;
   double progress;
  final int companyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<Task> subTasks; // List of subtasks

  Task({
    required this.id,
    this.parentId,
    required this.name,
    required this.type,
    required this.priority,
     this.estimatedTime,
    required this.details,
    this.dueDate,
    required this.status,
    required this.recurring,
    required this.progress,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.subTasks,
  });

factory Task.fromJson(Map<String, dynamic> json) {
  return Task(
    id: json['id'],
    parentId: json['parent_id'], // Nullable
    name: json['name'],
    type: json['type'],
    priority: json['priority'],
    estimatedTime: json['estimated_time'],
    details: json['details'],
    dueDate: json['due_date'] != null ? json['due_date'] as String : '', // Handle null value
    status: json['status'] == 1, // Convert to bool (1 = true, 0 = false)
    recurring: json['recurring'] == 1, // Convert to bool (1 = true, 0 = false)
    progress: json['progress'] != null ? json['progress'].toDouble() : 0.0, // Convert to double
    companyId: json['company_id'] != null ? json['company_id'] as int : 0, // Set a default value (0) if null
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    subTasks: json['sub_tasks'] != null
        ? List<Task>.from(json['sub_tasks'].map((x) => Task.fromJson(x)))
        : [], // Set to an empty list if no subtasks
  );
}


}
