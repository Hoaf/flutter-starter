class APIConfig {
  static String baseApiUrl = '';
  static String baseGraphQLApiUrl = '';
  static String baseUrlBrowser = '';
  static const login = '/identity/api/mobile/encrypted-login';
  static const refreshToken = '/identity/api/mobile/refresh-token';
  static const sendForgotPassword = '/identity/api/mobile/forgot-password';
  static const saveErrorLogs = '/personal/api/personal-data/producer/SaveErrorLog';
  static String downloadFile(String fileName) => '/portal/api/Asset/DownloadFileByFileName?fileName=$fileName';
  static String downloadFileFromCMS(String documentId) => '/cms/api/Asset/DownloadFileByDocId?documentId=$documentId';
  static String downloadMyDocument(String documentId) => '/personal/api/Asset/download-mydocument?documentId=$documentId';
  static const String uploadDocument = '/personal/api/Asset/upload-mydocument';

// Other api

}
