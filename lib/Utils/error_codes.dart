class ErrorCodes {
  static const String OPERATION_OK = 'E-000';
  static const String LOGIN_FAIL_NO_USER = 'E-001';
  static const String LOGIN_FAIL_API_CONNECTION = 'E-002';
  static const String LOGIN_FAIL_PASSWORD_INCORRECT = 'E-072';
  static const String LOGIN_FAIL_USER_DEACTIVATED_DELETED = 'E-073';
  static const String ANNOUNCEMENT_CREATE_FAIL_BACKEND = 'E-003';
  static const String ANNOUNCEMENT_CREATE_FAIL_API_CONNECTION = 'E-004';
  static const String DELETE_ANNOUNCEMENT_FAIL_BACKEND = 'E-052';
  static const String DELETE_ANNOUNCEMENT_FAIL_API_CONNECTION = 'E-053';
  static const String UPDATE_ANNOUNCEMENT_FAIL_BACKEND = 'E-054';
  static const String UPDATE_ANNOUNCEMENT_FAIL_API_CONNECTION = 'E-055';
  static const String UPDATE_ANNOUNCEMENT_ISREAD_FAIL_BACKEND = 'E-056';
  static const String UPDATE_ANNOUNCEMENT_ISREAD_FAIL_API_CONNECTION = 'E-057';
  static const String LEAVE_FORM_DATA_CREATE_FAIL_BACKEND = 'E-005';
  static const String LEAVE_FORM_DATA_CREATE_FAIL_API_CONNECTION = 'E-006';
  static const String LEAVE_APPLICATION_UPDATE_FAIL_BACKEND = 'E-007';
  static const String LEAVE_APPLICATION_UPDATE_FAIL_API_CONNECTION = 'E-008';
  static const String PERSONAL_PROFILE_UPDATE_FAIL_BACKEND = 'E-009';
  static const String PERSONAL_PROFILE_UPDATE_FAIL_API_CONNECTION = 'E-010';
  static const String OLD_PASSWORD_DOES_NOT_MATCH_DIALOG = 'E-011';
  static const String PASSWORD_UPDATE_FAIL_BACKEND = 'E-012';
  static const String PASSWORD_UPDATE_FAIL_API_CONNECTION = 'E-013';
  static const String REGISTER_STAFF_FAIL_BACKEND = 'E-014';
  static const String REGISTER_SAME_STAFF = 'E-078';
  static const String REGISTER_STAFF_FAIL_API_CONNECTION = 'E-015';
  static const String UPDATE_STAFF_FAIL_BACKEND = 'E-056';
  static const String UPDATE_STAFF_FAIL_API_CONNECTION = 'E-057';
  static const String DELETE_STAFF_FAIL_BACKEND = 'E-016';
  static const String DELETE_STAFF_FAIL_API_CONNECTION = 'E-017';
  static const String CREATE_ATTENDANCE_DATA_FAIL_BACKEND = 'E-018';
  static const String CREATE_ATTENDANCE_DATA_FAIL_API_CONNECTION = 'E-019';
  static const String UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND = 'E-020';
  static const String UPDATE_ATTENDANCE_REQUEST_FAIL_API_CONNECTION = 'E-021';
  static final String CHANGE_ATTENDANCE_REQUEST_FAIL_BACKEND = 'E-070';
  static final String CHANGE_ATTENDANCE_REQUEST_FAIL_API_CONNECTION = 'E-071';
  static final String DOWNLOAD_ATTENDANCE_RECORD_FAIL_BACKEND = 'E-080';
  static final String DOWNLOAD_ATTENDANCE_RECORD_FAIL_API_CONNECTION = 'E-081';
  static final String DOWNLOAD_ATTENDANCE_RECORD_FAIL_NO_RECORD = 'E-082';
  static final String DOWNLOAD_ATTENDANCE_RECORD_FAIL_NO_STAFF = 'E-083';
  static const String REGISTER_SUPPLIER_FAIL_BACKEND = 'E-022';
  static const String REGISTER_SAME_SUPPLIER = 'E-079';
  static const String REGISTER_SUPPLIER_FAIL_API_CONNECTION = 'E-023';
  static const String DELETE_SUPPLIER_FAIL_BACKEND = 'E-026';
  static const String DELETE_SUPPLIER_FAIL_API_CONNECTION = 'E-027';
  static const String UPDATE_SUPPLIER_FAIL_BACKEND = 'E-028';
  static const String UPDATE_SUPPLIER_FAIL_API_CONNECTION = 'E-029';
  static const String CREATE_RECEIPT_FAIL_BACKEND = 'E-058';
  static const String CREATE_RECEIPT_FAIL_API_CONNECTION = 'E-059';
  static const String DOWNLOAD_PDF_FILE_FAIL_BACKEND = 'E-060';
  static const String DOWNLOAD_PDF_FILE_FAIL_API_CONNECTION = 'E-061';
  static const String DELETE_RECEIPT_FAIL_BACKEND = 'E-062';
  static const String DELETE_RECEIPT_FAIL_API_CONNECTION = 'E-063';
  static const String UPDATE_RECEIPT_FAIL_BACKEND = 'E-064';
  static const String UPDATE_RECEIPT_FAIL_API_CONNECTION = 'E-065';
  static const String CREATE_STOCK_FAIL_BACKEND = 'E-066';
  static const String CREATE_STOCK_ASSIGNED_OTHER_FAIL_BACKEND = 'E-067';
  static const String CREATE_STOCK_ASSIGNED_CURRENT_FAIL_BACKEND = 'E-068';
  static const String CREATE_STOCK_FAIL_API_CONNECTION = 'E-069';
  static const String UPDATE_ORDER_FOOD_ITEM_REMARKS_FAIL_BACKEND = 'E-030';
  static const String UPDATE_ORDER_FOOD_ITEM_REMARKS_FAIL_API_CONNECTION = 'E-031';
  static const String UPDATE_ORDER_FOOD_ITEM_STATUS_FAIL_BACKEND = 'E-032';
  static const String UPDATE_ORDER_FOOD_ITEM_STATUS_FAIL_API_CONNECTION = 'E-033';
  static const String UPDATE_ORDER_STATUS_FAIL_BACKEND = 'E-034';
  static const String UPDATE_ORDER_STATUS_FAIL_API_CONNECTION = 'E-035';
  static const String CREATE_MENU_ITEM_FAIL_BACKEND = 'E-036';
  static const String CREATE_SAME_MENU_ITEM = 'E-077';
  static const String CREATE_MENU_ITEM_FAIL_API_CONNECTION = 'E-037';
  static const String DELETE_MENU_ITEM_FAIL_BACKEND = 'E-038';
  static const String DELETE_MENU_ITEM_FAIL_API_CONNECTION = 'E-039';
  static const String UPDATE_MENU_ITEM_FAIL_BACKEND = 'E-040';
  static const String UPDATE_MENU_ITEM_FAIL_API_CONNECTION = 'E-041';
  static const String UPDATE_ISOUTOFSTOCK_STATUS_FAIL_BACKEND = 'E-042';
  static const String UPDATE_ISOUTOFSTOCK_STATUS_FAIL_API_CONNECTION = 'E-043';
  static const String UPDATE_IS_AVAILABLE_VOUCHER_STATUS_FAIL_BACKEND = 'E-044';
  static const String UPDATE_IS_AVAILABLE_VOUCHER_STATUS_FAIL_API_CONNECTION = 'E-045';
  static const String DELETE_VOUCHER_FAIL_BACKEND = 'E-046';
  static const String DELETE_VOUCHER_FAIL_API_CONNECTION = 'E-047';
  static const String CREATE_NEW_VOUCHER_FAIL_BACKEND = 'E-048';
  static const String CREATE_SAME_VOUCHER = 'E-076';
  static const String CREATE_NEW_VOUCHER_FAIL_API_CONNECTION = 'E-049';
  static const String UPDATE_VOUCHER_FAIL_BACKEND = 'E-050';
  static const String UPDATE_VOUCHER_FAIL_API_CONNECTION = 'E-051';
  static const String FORGOT_PASSWORD_INVALID_USER_FAIL_BACKEND = 'E-072';
  static const String FORGOT_PASSWORD_FAIL_API_CONNECTION = 'E-073';
  static const String RESEND_EMAIL_FAIL_BACKEND = 'E-074';
  static const String RESEND_EMAIL_FAIL_API_CONNECTION = 'E-075';
  static final String VERIFY_OTP_FAIL_BACKEND = 'E-084';
  static final String VERIFY_OTP_FAIL_API_CONNECTION = 'E-085';
  static final String VERIFY_OTP_FAIL_NOT_MATCHED = 'E-086';
}