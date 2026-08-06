class PaginationMetaModel {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  String? path;

  PaginationMetaModel({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.path,
  });

  PaginationMetaModel.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] ?? json['currentPage'];
    lastPage = json['last_page'] ?? json['lastPage'];
    perPage = json['per_page'] ?? json['perPage'];
    total = json['total'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    data['path'] = path;
    return data;
  }
}
