REPORT z_trycatch_loop_measure.

DATA: lo_measurement_run TYPE REF TO zcl_run_trycatch_loop.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(40) TEXT-ite.
PARAMETERS: pa_iters TYPE i DEFAULT 10.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(40) TEXT-rep.
PARAMETERS: pa_repts TYPE i DEFAULT 100.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(40) TEXT-tes.
PARAMETERS: pa_tests TYPE i DEFAULT 101.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN ULINE.
PARAMETERS: pa_alv AS CHECKBOX DEFAULT ' '.

SELECTION-SCREEN BEGIN OF SCREEN 2000.
SELECTION-SCREEN END OF SCREEN 2000.


AT SELECTION-SCREEN OUTPUT.

  IF sy-dynnr = '2000'.

    DATA(lt_results) = lo_measurement_run->get_results( ).

    cl_salv_table=>factory( IMPORTING r_salv_table = DATA(alv)
                            CHANGING  t_table      = lt_results ).

    alv->get_columns( )->set_optimize( abap_true ).
    alv->get_display_settings( )->set_list_header( |Test results| ).
    alv->get_display_settings( )->set_striped_pattern( abap_true ).
    alv->get_functions( )->set_all( abap_true ).

    alv->get_columns( )->get_column( 'TEST_ID' )->set_short_text( |Test ID| ).
    alv->get_columns( )->get_column( 'RTIME' )->set_edit_mask( value = '==DEC6' ).

    alv->display( ).

    LEAVE TO SCREEN 0.

  ENDIF.


START-OF-SELECTION.

  lo_measurement_run = NEW #(
    iv_measurement_iterations  = pa_iters
    iv_measurement_repeats     = pa_repts
    iv_measurement_total_tests = pa_tests
  ).

  CAST zif_measurement_runner( lo_measurement_run )->run_tests( ).

  IF pa_alv = 'X'.
    CALL SELECTION-SCREEN 2000.
  ELSE.
    lo_measurement_run->show_results( ).
  ENDIF.
