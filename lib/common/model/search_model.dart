

class SearchModel {
  late String searchYearMonth = '';
  late String searchStartDate = '';
  late String searchEndDate = '';
  late String searchType = '';
  late String userEmail = '';
  int currentPage = 1;
  final int pageSize = 10;

  /* 페이지당 출력할 데이터 개수 */
  late int recordCount;

  /* 화면 하단에 출력할 페이지 사이즈 */

  /* 전체 데이터 개수 */
  late int totalCount;

  /* 전체 페이지 개수 */
  late int totalPage;

  /* 페이지 리스트의 첫 페이지 번호 */
  late int firstPage;

  /* 페이지 리스트의 마지막 페이지 번호 */
  late int lastPage;

  /* SQL의 조건절에 사용되는 첫 RNUM */
  late int firstrecordindex;

  /* SQL의 조건절에 사용되는 마지막 RNUM */
  late int lastrecordindex;

  /* 이전 페이지 존재 여부 */
  late bool hasPrev;

  /* 다음 페이지 존재 여부 */
  late bool hasNext;

  late int startPage;
  late int endPage;

  SearchModel(){
    SearchModel.init(1);
  }

  SearchModel.init(this.currentPage);


  String listParams(){
    String params = "";
    if(searchYearMonth.isNotEmpty){
      if(params.isNotEmpty) params += "&";
      params += "searchYearMonth=$searchYearMonth";
    }
    if(searchType.isNotEmpty){
      if(params.isNotEmpty) params += "&";
      params += "searchYearMonth=$searchType";
    }
    if(searchStartDate.isNotEmpty){
      if(params.isNotEmpty) params += "&";
      params += "searchYearMonth=$searchStartDate";
    }
    if(searchEndDate.isNotEmpty){
      if(params.isNotEmpty) params += "&";
      params += "searchYearMonth=$searchEndDate";
    }
    if(params.isNotEmpty) params += "&";
    params += "currentPage=$currentPage";
    if(params.isNotEmpty) params += "&";
    params += "pageSize=$pageSize";
    return params;
  }

}