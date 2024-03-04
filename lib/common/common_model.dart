class CommonModel {
  String userEmail = "";
  int currentPage = 1;
  final int _pageSize = 10;

  CommonModel({
    required String userEmail,
    required int currentPage
  });

  int get pageSize => _pageSize;
}