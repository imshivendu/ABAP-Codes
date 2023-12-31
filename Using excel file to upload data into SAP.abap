#########################################################################

*&  The below prorams achieve the following

*&  1. Create a custom table where data is upload from the excel sheet
*&  2. Display data in the custom table in the output with buttons approve and reject
*&  3. Click on the button in output to create sales orders


########################################################################


************************************************
*&  STEP 1  -- Upload data from excel into custom table
************************************************


*  &---------------------------------------------------------------------*
*  & Report Z_UPLOAD_CSV_TO_TABLE1
*  &---------------------------------------------------------------------*
*  &
*  &---------------------------------------------------------------------*
  REPORT z_upload_csv_to_table2.
  TYPES: BEGIN OF z_mara_csv,
           vbeln TYPE vbap-vbeln,
           matnr TYPE vbap-matnr,
           kunnr TYPE vbak-kunnr,
           vkorg TYPE vbak-vkorg,
           kostl TYPE vbak-kostl,
         END OF z_mara_csv.

 TYPES: BEGIN OF ttab,
rec(1000) TYPE c,
END OF ttab.

*   Internal Table

  DATA:  itab type TABLE of ttab WITH HEADER LINE,
         gt_z_mara_csv TYPE TABLE OF ztable_sales,
         gt_z_mara_csv2 TYPE TABLE OF ztable_sales,
        wa_gt         TYPE ztable_sales,
        wa        TYPE ztable_sales.


*  FIELD-SYMBOLS <fs_ztable_sales> TYPE ztable_sales.

DATA: file_str TYPE string.

*   Selection Screen
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
    PARAMETERS p_file TYPE localfile.
  SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
EXPORTING
static = 'X'
CHANGING
file_name = p_file.

file_str = p_file.


  START-OF-SELECTION.
**   Upload CSV file
*    CALL FUNCTION 'GUI_UPLOAD'
*      EXPORTING
*        filename                = file_str
*        filetype                = 'ASC'
*
*      TABLES
*        data_tab                = gt_z_mara_csv
*      EXCEPTIONS
*        file_open_error         = 1
*        file_read_error         = 2
*        no_batch                = 3
*        gui_refuse_filetransfer = 4
*        invalid_type            = 5
*        no_authority            = 6
*        unknown_error           = 7
*        bad_data_format         = 8
*        header_not_allowed      = 9
*        separator_not_allowed   = 10
*        header_too_long         = 11
*        unknown_dp_error        = 12
*        access_denied           = 13
*        dp_out_of_memory        = 14
*        disk_full               = 15
*        dp_timeout              = 16
*        OTHERS                  = 17.

CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    FILENAME                      = file_str
*   FILETYPE                      = 'ASC'
*   HAS_FIELD_SEPARATOR           = ' '
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE                      = ' '
*   CODEPAGE                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
  TABLES
    DATA_TAB                      = itab
* CHANGING
*   ISSCANPERFORMED               = ' '
* EXCEPTIONS
*   FILE_OPEN_ERROR               = 1
*   FILE_READ_ERROR               = 2
*   NO_BATCH                      = 3
*   GUI_REFUSE_FILETRANSFER       = 4
*   INVALID_TYPE                  = 5
*   NO_AUTHORITY                  = 6
*   UNKNOWN_ERROR                 = 7
*   BAD_DATA_FORMAT               = 8
*   HEADER_NOT_ALLOWED            = 9
*   SEPARATOR_NOT_ALLOWED         = 10
*   HEADER_TOO_LONG               = 11
*   UNKNOWN_DP_ERROR              = 12
*   ACCESS_DENIED                 = 13
*   DP_OUT_OF_MEMORY              = 14
*   DISK_FULL                     = 15
*   DP_TIMEOUT                    = 16
*   OTHERS                        = 17
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.



    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*   Insert data into custom table
*    LOOP AT gt_z_mara_csv ASSIGNING FIELD-SYMBOL(<fs_z_mara_csv>).
*      INSERT ztable_sales FROM <fs_z_mara_csv>.
*    ENDLOOP.

    LOOP AT itab.
      clear wa_gt.
      SPLIT itab AT ',' INTO wa_gt-vbeln
      wa_gt-matnr
      wa_gt-kunnr
      wa_gt-vkorg
      wa_gt-kostl.
      APPEND wa_gt to gt_z_mara_csv2.
    ENDLOOP.


*  *   Insert data into custom table
    LOOP AT gt_z_mara_csv2 into wa.
      INSERT ztable_sales FROM wa.
    ENDLOOP.


***************************************************************************

*&  STEP 2 -  Display data in the custom table in the output with buttons approve and reject


***************************************************************************



*&---------------------------------------------------------------------*
*& Report ZALVK
*&---------------------------------------------------------------------*
*& This program displays the list of sales order which is stored in the 
*& which was stored in the Z table through the excel upload program
*&---------------------------------------------------------------------*
REPORT ZALVK.

DATA : gr_table      TYPE REF TO cl_salv_table,
      gr_events     TYPE REF TO cl_salv_events_table,
*      gr_alv_grid   TYPE REF TO  lcl_gui_alv_grid,
      gr_container  TYPE REF TO cl_gui_custom_container,
      it_tab        TYPE TABLE of Ztable_sales1,
      wa            type Ztable_sales1.

CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
  CLASS-METHODS: handle_click for EVENT double_click of cl_salv_events_table
                 IMPORTING row column.
  CLASS-METHODS: added_function for EVENT added_function of cl_salv_events_table
                 IMPORTING e_salv_function.

  ENDCLASS.


  CLASS lcl_alv_handler IMPLEMENTATION.
    METHOD handle_click.
*      MESSAGE sy-ucomm TYPE 'I'.
      DATA : msg TYPE string,
             lt_so TYPE vbeln.
      READ TABLE it_tab INDEX row into wa.
      select SINGLE vbeln FROM vbap INTO lt_so where vbeln = wa-VBELN.
        if sy-subrc = 0.
          msg = ' sales order is present in the system : ' && wa-vbeln.
          else.
            msg = 'You can create sales order by click on approve button : ' && wa-vbeln.
          ENDIF.


*      if column eq 'VBELN'.
*        msg = 'You are going to create sales order : ' && wa-vbeln.
        MESSAGE msg TYPE 'I'.
*        ENDIF.
        ENDMETHOD.

        METHOD added_function.
*          MESSAGE e_Salv_function TYPE 'I'.
   data: lo_selections type ref to cl_salv_selections.
data lt_rows type salv_t_row.

data ls_row type I.
data lo_alv TYPE REF TO cl_salv_table.

lo_alv = gr_table.

lo_selections = lo_alv->get_selections( ).

lt_rows = lo_selections->get_selected_rows( ).

loop at lt_rows into ls_row.

read table it_tab index ls_row INTO wa.

* do the action

endloop.


*          READ TABLE it_tab INDEX 1 INTO wa.
          export wa = wa to memory id 'TEST'.
*          submit ZALVBAPI.
          submit ZALVBAPI1.            "program below which is used to create sales order
          ENDMETHOD.

    ENDCLASS.


 START-OF-SELECTION.

 select * FROM ztable_sales1 INTO TABLE it_tab.

      TRY.
      cl_salv_table=>factory(
*        EXPORTING
*          r_container    = gr_container
*          container_name = 'CONTAINER'
        IMPORTING
          r_salv_table   = gr_table
        CHANGING
          t_table        = it_tab ).
    CATCH cx_salv_msg.
  ENDTRY.

  gr_table->SET_SCREEN_STATUS(
  EXPORTING
    report = sy-repid
    pfstatus = 'STATUS'
    set_functions = cl_salv_table=>C_FUNCTIONS_ALL ).

  gr_events = gr_table->get_event( ).
  set HANDLER lcl_alv_handler=>HANDLE_CLICK FOR gr_events.
  set HANDLER lcl_alv_handler=>ADDED_FUNCTION FOR gr_events.
  gr_table->display( ).


********************************************************************************


REPORT zalvbapi1.
*

*REPORT  zbc2_trg05_prg30.
TYPES : BEGIN OF ty_main,
          f1(10),
          f2(10),
          f3(10),
          f4(10),
          f5(10),
          f6(10),
          f7(10),
        END OF ty_main.


TYPES : BEGIN OF ty_head,
          salesdocument TYPE bapivbeln-vbeln,
          doc_type      TYPE bapisdh1-collect_no,
          sales_org     TYPE bapisdh1-sales_org,
          distr_chan    TYPE bapisdh1-distr_chan,
          division      TYPE bapisdh1-division,
          req_date_h    TYPE bapisdh1-req_date_h,
          kunnr         TYPE bapisdh1-PURCH_NO_S,
        END OF ty_head.

TYPES :BEGIN OF ty_item,
         salesdocument TYPE bapivbeln-vbeln,
         itm_number    TYPE bapisditm-itm_number,
         material      TYPE bapisditm-material,
         target_qty    TYPE bapisditm-target_qty,
         target_qu     TYPE bapisditm-target_qu,
         plant         TYPE bapisditm-plant,
         itm_number1   TYPE bapischdl-itm_number,
         req_qty       TYPE bapischdl-req_qty,
       END OF ty_item.


DATA :it_order_item_in       TYPE bapisditm OCCURS 0 WITH HEADER LINE,
      it_order_item_inx      TYPE bapisditmx OCCURS 0 WITH HEADER LINE,
      it_partners            TYPE bapiparnr OCCURS 0 WITH HEADER LINE,
      it_return              TYPE bapiret2 OCCURS 0 WITH HEADER LINE,
      it_order_schedules_in  TYPE bapischdl OCCURS 0 WITH HEADER LINE,
      it_order_schedules_inx TYPE bapischdlx OCCURS 0 WITH HEADER LINE,
      it_main                TYPE ty_main OCCURS 0 WITH HEADER LINE,
      it_main1               TYPE ty_main OCCURS 0 WITH HEADER LINE,
      it_head                TYPE ty_head OCCURS 0 WITH HEADER LINE,
      it_item                TYPE ty_item OCCURS 0 WITH HEADER LINE.
*
*PARAMETERS : p_file TYPE rlgrap-filename.
DATA: c_file              TYPE string,
      wa_order_header_in  LIKE bapisdhd1,
      wa_order_header_inx LIKE bapisdhd1x,
      c_vbeln             TYPE vbak-vbeln,
      message_text_output TYPE natxt.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*  CALL FUNCTION 'F4_FILENAME'
*    EXPORTING
*      program_name  = syst-cprog
*      dynpro_number = syst-dynnr
*      field_name    = ' '
*    IMPORTING
*      file_name     = p_file.
*
*START-OF-SELECTION.
*  c_file = p_file.
*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      filename                      = c_file
*     filetype                      = 'ASC'
*     has_field_separator           = 'X'
**           HEADER_LENGTH                 = 0
**           READ_BY_LINE                  = 'X'
**           DAT_MODE                      = ' '
**           CODEPAGE                      = ' '
**           IGNORE_CERR                   = ABAP_TRUE
**           REPLACEMENT                   = '#'
**           CHECK_BOM                     = ' '
**           VIRUS_SCAN_PROFILE            =
**           NO_AUTH_CHECK                 = ' '
**         IMPORTING
**           FILELENGTH                    =
**           HEADER                        =
*    TABLES
*      data_tab                      = it_main[]
*   EXCEPTIONS
*     file_open_error               = 1
*     file_read_error               = 2
*     no_batch                      = 3
*     gui_refuse_filetransfer       = 4
*     invalid_type                  = 5
*     no_authority                  = 6
*     unknown_error                 = 7
*     bad_data_format               = 8
*     header_not_allowed            = 9
*     separator_not_allowed         = 10
*     header_too_long               = 11
*     unknown_dp_error              = 12
*     access_denied                 = 13
*     dp_out_of_memory              = 14
*     disk_full                     = 15
*     dp_timeout                    = 16
*     OTHERS                        = 17
*            .
*  IF sy-subrc = 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

*IMPORT
DATA : it_tab TYPE TABLE OF Ztable_sales1,
       wa     TYPE Ztable_sales1.

IMPORT wa TO wa FROM MEMORY ID 'TEST'.

*LOOP AT it_tab INTO wa.
*  MOVE-CORRESPONDING it_main TO  it_main1.
*  AT NEW vbeln.
    it_head-salesdocument = '3046399'.
    it_head-doc_type = 'OR'.
    it_head-sales_org = '0001'.
    it_head-distr_chan = '01'.
    it_head-division = '01'.
    it_head-req_date_h = '05042023'.
    it_head-kunnr      = 'BP_ADOP'.
    APPEND it_head.
*    CONTINUE.
*  ENDAT.
  it_item-salesdocument = '3046399'.
  it_item-itm_number =  '1'.
  it_item-material =  'TM5_FERT01'.
  it_item-target_qty = '10'.
  it_item-target_qu  = '23'.
  it_item-plant =  ' '.
  APPEND it_item.

*ENDLOOP.

LOOP AT it_head.
  wa_order_header_in-doc_type = 'RE'.
  wa_order_header_in-sales_org = '0001'.
  wa_order_header_in-distr_chan = '01'.
  wa_order_header_in-division = '01'.
  wa_order_header_in-req_date_h = '05042023'.
  wa_order_header_in-PURCH_NO_S = 'BP_ADOP'.

  wa_order_header_inx-updateflag = 'I'.
  wa_order_header_inx-doc_type = 'OR'.
  wa_order_header_inx-sales_org ='0001'.
  wa_order_header_inx-distr_chan =  '01'.
  wa_order_header_inx-division = '01'.
  wa_order_header_inx-req_date_h =  '05042023'.
  wa_order_header_inx-PURCH_NO_S = 'BP_ADOP'.

  LOOP AT it_item WHERE salesdocument = it_head-salesdocument.
    it_order_item_in-itm_number = it_item-itm_number.
    it_order_item_in-material = it_item-material.
    it_order_item_in-target_qty = it_item-target_qty.
    it_order_item_in-target_qu = it_item-target_qu.
    it_order_item_in-plant = it_item-plant.
    APPEND it_order_item_in.

    it_order_item_inx-itm_number = it_item-itm_number.
    it_order_item_inx-updateflag ='I'.
    it_order_item_inx-material = 'X'.
    it_order_item_inx-target_qty = 'X'.
    it_order_item_inx-target_qu = 'X'.
    it_order_item_inx-plant = 'X'.
    APPEND it_order_item_inx.

    it_order_schedules_in-itm_number =  it_order_item_in-itm_number.
    it_order_schedules_in-req_qty = it_order_item_in-target_qty.
    APPEND it_order_schedules_in.

    it_order_schedules_inx-itm_number = it_order_item_in-itm_number.
    it_order_schedules_inx-req_qty = 'X'.
    APPEND it_order_schedules_inx.

  ENDLOOP.
  it_partners-partn_role = ' '.
  it_partners-partn_numb = ' '.
  APPEND it_partners.
  it_partners-partn_role = ' '.
  it_partners-partn_numb = ' '.
  APPEND it_partners.

*  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
*    EXPORTING
**     SALESDOCUMENTIN     =
*      order_header_in     = wa_order_header_in
*      order_header_inx    = wa_order_header_inx
**     SENDER              =
**     BINARY_RELATIONSHIPTYPE       =
**     INT_NUMBER_ASSIGNMENT         =
**     BEHAVE_WHEN_ERROR   =
**     LOGIC_SWITCH        =
**     TESTRUN             =
*      convert             = 'X'
*    IMPORTING
*      salesdocument       = c_vbeln
*    TABLES
*      return              = it_return[]
*      order_items_in      = it_order_item_in[]
*      order_items_inx     = it_order_item_inx[]
*      order_partners      = it_partners[]
*      order_schedules_in  = it_order_schedules_in[]
*      order_schedules_inx = it_order_schedules_inx[]
**     ORDER_CONDITIONS_IN =
**     ORDER_CONDITIONS_INX          =
**     ORDER_CFGS_REF      =
**     ORDER_CFGS_INST     =
**     ORDER_CFGS_PART_OF  =
**     ORDER_CFGS_VALUE    =
**     ORDER_CFGS_BLOB     =
**     ORDER_CFGS_VK       =
**     ORDER_CFGS_REFINST  =
**     ORDER_CCARD         =
**     ORDER_TEXT          =
**     ORDER_KEYS          =
**     EXTENSIONIN         =
**     PARTNERADDRESSES    =
*    .
**


  CALL FUNCTION 'SD_SALESDOCUMENT_CREATE'
    EXPORTING
*     SALESDOCUMENT                 =
      SALES_HEADER_IN               = wa_order_header_in
     SALES_HEADER_INX               = wa_order_header_inx
*     SENDER                        =
*     BINARY_RELATIONSHIPTYPE       = ' '
*     INT_NUMBER_ASSIGNMENT         = ' '
*     BEHAVE_WHEN_ERROR             = ' '
*     LOGIC_SWITCH                  = ' '
*     BUSINESS_OBJECT               = ' '
*     TESTRUN                       =
*     CONVERT_PARVW_AUART           = ' '
*     STATUS_BUFFER_REFRESH         = 'X'
*     CALL_ACTIVE                   = ' '
*     I_WITHOUT_INIT                = ' '
*     I_REFRESH_V45I                = 'X'
*     I_TESTRUN_EXTENDED            = ' '
*     I_CHECK_AG                    = 'X'
*     I_NO_DEQUEUE_ALL              = ' '
   IMPORTING
     SALESDOCUMENT_EX              = c_vbeln
*     SALES_HEADER_OUT              =
*     SALES_HEADER_STATUS           =
   TABLES
     RETURN                        = it_return[]
     SALES_ITEMS_IN                = it_order_item_in[]
     SALES_ITEMS_INX               = it_order_item_inx[]
     SALES_PARTNERS                = it_partners[]
     SALES_SCHEDULES_IN            = it_order_schedules_in[]
     SALES_SCHEDULES_INX           = it_order_schedules_inx[]
*     SALES_CONDITIONS_IN           =
*     SALES_CONDITIONS_INX          =
*     SALES_CFGS_REF                =
*     SALES_CFGS_INST               =
*     SALES_CFGS_PART_OF            =
*     SALES_CFGS_VALUE              =
*     SALES_CFGS_BLOB               =
*     SALES_CFGS_VK                 =
*     SALES_CFGS_REFINST            =
*     SALES_CCARD                   =
*     SALES_TEXT                    =
*     SALES_KEYS                    =
*     SALES_CONTRACT_IN             =
*     SALES_CONTRACT_INX            =
*     EXTENSIONIN                   =
*     PARTNERADDRESSES              =
*     SALES_SCHED_CONF_IN           =
*     ITEMS_EX                      =
*     SCHEDULE_EX                   =
*     BUSINESS_EX                   =
*     INCOMPLETE_LOG                =
*     EXTENSIONEX                   =
*     CONDITIONS_EX                 =
*     PARTNERS_EX                   =
*     TEXTHEADERS_EX                =
*     TEXTLINES_EX                  =
*     BATCH_CHARC                   =
*     CAMPAIGN_ASGN                 =
            .


  READ TABLE it_return WITH KEY type = 'E'.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = it_return-id
        msgnr               = it_return-number
        msgv1               = it_return-message_v1
        msgv2               = it_return-message_v2
        msgv3               = it_return-message_v3
        msgv4               = it_return-message_v4
      IMPORTING
        message_text_output = message_text_output.
    WRITE :message_text_output.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'
*   IMPORTING
*       RETURN        =
      .
    DATA : lineno TYPE sy-linno VALUE 1.
    lineno = lineno + 1.
    sy-linno = lineno.
    SKIP.
    WRITE : /3 'SO created for:',c_vbeln.
  ENDIF.


  CLEAR :wa_order_header_in,wa_order_header_inx,it_order_item_in[],it_order_item_inx[],it_head,
          it_order_schedules_in[],it_order_schedules_inx[].
ENDLOOP.




