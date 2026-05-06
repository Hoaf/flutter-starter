class BaseListRequest {
  int pageIndex;
  int pageSize;

  BaseListRequest({
    this.pageIndex = 1,
    this.pageSize = 10
  });
}