CLASS zcl_run_trycatch_loop DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_measurement_runner .

    TYPES:
      BEGIN OF ty_result,
        rtime   TYPE rep_d_rtime,
        test_id TYPE i,
      END OF ty_result .
    TYPES:
      ty_t_result TYPE STANDARD TABLE OF zcl_run_trycatch_loop=>ty_result WITH DEFAULT KEY .
    TYPES:
      ty_t_test   TYPE STANDARD TABLE OF REF TO zif_trycatch_loop_test WITH DEFAULT KEY .

    METHODS constructor
      IMPORTING
        !iv_measurement_iterations  TYPE i
        !iv_measurement_repeats     TYPE i
        !iv_measurement_total_tests TYPE i .
    METHODS get_results
      RETURNING
        VALUE(rt_results) TYPE ty_t_result .
    METHODS show_results .
protected section.
private section.

  types:
    BEGIN OF ty_result_calculated,
      test_id       TYPE i,
      test_name     TYPE string,
      median        TYPE rep_d_rtime,
      average       TYPE rep_d_rtime,
      std_deviation TYPE rep_d_rtime,
      lv_std_error  TYPE rep_d_rtime,
    END OF ty_result_calculated .
  types:
    ty_t_result_calculated TYPE STANDARD TABLE OF ty_result_calculated WITH DEFAULT KEY .

  data MV_MEASUREMENT_ITERATIONS type I value 100 ##NO_TEXT.
  data MV_MEASUREMENT_TOTAL_TESTS type I value 1001 ##NO_TEXT.
  data MV_MEASUREMENT_REPEATS type I value 10 ##NO_TEXT.
  data MV_MEASUREMENT_REPEATS_ACC type I .
  data MT_TESTS type TY_T_TEST .
  data MT_RESULTS type TY_T_RESULT .
  data MT_RESULTS_CALCULATED type TY_T_RESULT_CALCULATED .

  methods SHOW_RESULT
    importing
      !IO_MEASUREMENT_TEST type ref to ZIF_TRYCATCH_LOOP_TEST .
ENDCLASS.



CLASS ZCL_RUN_TRYCATCH_LOOP IMPLEMENTATION.


  METHOD CONSTRUCTOR.

    mv_measurement_iterations  = iv_measurement_iterations.
    mv_measurement_repeats     = iv_measurement_repeats.
    mv_measurement_total_tests = iv_measurement_total_tests.

  ENDMETHOD.


  METHOD GET_RESULTS.

    rt_results = mt_results.

  ENDMETHOD.


  METHOD SHOW_RESULT.

    WRITE: / |{ io_measurement_test->test_name }|.

    DATA(lv_tests) = REDUCE i( INIT x = 0 FOR wa IN mt_results WHERE ( test_id = io_measurement_test->test_id ) NEXT x = x + 1 ).

    IF lv_tests = 0.
      WRITE: / |No results are available for the test { io_measurement_test->test_id }|.
      RETURN.
    ENDIF.

    DATA(lv_median)  = mt_results[ ( io_measurement_test->test_id - 1 ) * lv_tests + ceil( lv_tests / 2 ) ]-rtime.

    DATA(lv_average) = REDUCE rep_d_rtime( INIT sum = 0 FOR result IN mt_results WHERE ( test_id = io_measurement_test->test_id ) NEXT sum = sum + result-rtime )
                 / lv_tests.

    DATA(lv_squared_deviations_sum) = REDUCE rep_d_rtime( INIT sum = 0 FOR result IN mt_results WHERE ( test_id = io_measurement_test->test_id ) NEXT sum = sum + ( ( result-rtime - lv_average ) ** 2 ) ).

    DATA(lv_std_deviation) = sqrt( lv_squared_deviations_sum / ( lv_tests ) ).

    DATA(lv_std_error) = sqrt( lv_squared_deviations_sum / ( lv_tests ** 2 ) ).

    WRITE: /4 |{ 'Median:'             WIDTH = 20 }{ lv_median        DECIMALS = 2 } ms|.
    WRITE: /4 |{ 'Average:'            WIDTH = 20 }{ lv_average       DECIMALS = 2 } ms|.
    WRITE: /4 |{ 'Std. deviation:'     WIDTH = 20 }{ lv_std_deviation DECIMALS = 2 } ms|.
    WRITE: /4 |{ 'Std. error:'         WIDTH = 20 }{ lv_std_error     DECIMALS = 2 } ms|.
    WRITE: /4 |{ 'Total tests:'        WIDTH = 20 }{ lv_tests WIDTH = 10 }|.
    WRITE: /4 |{ 'Total calculations:' WIDTH = 20 }{ io_measurement_test->mv_total_calculations WIDTH = 10 }|.
    WRITE: /4 |{ 'Total exceptions:'   WIDTH = 20 }{ io_measurement_test->mv_total_exceptions   WIDTH = 10 }|.

    APPEND VALUE #( test_id       = io_measurement_test->test_id
                    test_name     = io_measurement_test->test_name
                    median        = lv_median
                    average       = lv_average
                    std_deviation = lv_std_deviation
                    lv_std_error  = lv_std_error )
    TO mt_results_calculated.

  ENDMETHOD.


  METHOD SHOW_RESULTS.

    WRITE: / |One test is the average of a dynamic number of runs from { mv_measurement_repeats
    } till { mv_measurement_repeats_acc
    } (each run performs { mv_measurement_iterations
    } loop iterations)|.

    SKIP 1.

    me->show_result( mt_tests[ 2 ] ).
    SKIP 1.

    me->show_result( mt_tests[ 1 ] ).
    SKIP 3.

    me->show_result( mt_tests[ 4 ] ).
    SKIP 1.

    me->show_result( mt_tests[ 3 ] ).

  ENDMETHOD.


  METHOD ZIF_MEASUREMENT_RUNNER~RUN_TESTS.

    DATA: ls_test_stat TYPE rep_s_results.

    APPEND NEW zcl_t_trycatch_inside_loop( )     TO mt_tests.
    APPEND NEW zcl_t_trycatch_outside_loop( )    TO mt_tests.
    APPEND NEW zcl_t_trycatch_inside_loop_ex( )  TO mt_tests.
    APPEND NEW zcl_t_trycatch_outside_loop_ex( ) TO mt_tests.

    mv_measurement_repeats_acc = mv_measurement_repeats.

    DO mv_measurement_total_tests TIMES.
      ls_test_stat = mt_tests[ 1 ]->run_test( iv_measurement_repeats = mv_measurement_repeats_acc iv_measurement_iterations = mv_measurement_iterations ).
      INSERT VALUE #( rtime = ls_test_stat-rtime / mv_measurement_repeats_acc test_id = mt_tests[ 1 ]->test_id ) INTO TABLE mt_results.

      ls_test_stat = mt_tests[ 2 ]->run_test( iv_measurement_repeats = mv_measurement_repeats_acc iv_measurement_iterations = mv_measurement_iterations ).
      INSERT VALUE #( rtime = ls_test_stat-rtime / mv_measurement_repeats_acc test_id = mt_tests[ 2 ]->test_id ) INTO TABLE mt_results.

      ls_test_stat = mt_tests[ 3 ]->run_test( iv_measurement_repeats = mv_measurement_repeats_acc iv_measurement_iterations = mv_measurement_iterations ).
      INSERT VALUE #( rtime = ls_test_stat-rtime / mv_measurement_repeats_acc test_id = mt_tests[ 3 ]->test_id ) INTO TABLE mt_results.

      ls_test_stat = mt_tests[ 4 ]->run_test( iv_measurement_repeats = mv_measurement_repeats_acc iv_measurement_iterations = mv_measurement_iterations ).
      INSERT VALUE #( rtime = ls_test_stat-rtime / mv_measurement_repeats_acc test_id = mt_tests[ 4 ]->test_id ) INTO TABLE mt_results.

      mv_measurement_repeats_acc = mv_measurement_repeats_acc + 1.
    ENDDO.

    SORT mt_results BY test_id ASCENDING rtime ASCENDING.

  ENDMETHOD.
ENDCLASS.
