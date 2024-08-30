class ZCL_T_TRYCATCH_OUTSIDE_LOOP_EX definition
  public
  final
  create public .

public section.

  interfaces ZIF_MEASUREMENT_TEST .
  interfaces ZIF_TRYCATCH_LOOP_TEST .

  aliases TEST_ID
    for ZIF_MEASUREMENT_TEST~TEST_ID .
  aliases TEST_NAME
    for ZIF_MEASUREMENT_TEST~TEST_NAME .
  aliases RUN_TEST
    for ZIF_MEASUREMENT_TEST~RUN_TEST .

  methods CONSTRUCTOR .
protected section.
private section.

  aliases MV_TOTAL_CALCULATIONS
    for ZIF_TRYCATCH_LOOP_TEST~MV_TOTAL_CALCULATIONS .
  aliases MV_TOTAL_EXCEPTIONS
    for ZIF_TRYCATCH_LOOP_TEST~MV_TOTAL_EXCEPTIONS .
ENDCLASS.



CLASS ZCL_T_TRYCATCH_OUTSIDE_LOOP_EX IMPLEMENTATION.


  METHOD constructor.

    test_id   = 4.

    test_name = |TRY [LOOP <-outside-> ENDLOOP] CATCH  exception_thrown|.

  ENDMETHOD.


  METHOD zif_measurement_test~run_test.

    DATA: l_d TYPE decfloat34 ##NEEDED,
          l_f TYPE f ##NEEDED.

    +REP iv_measurement_repeats TIMES.
    TRY.

        DO iv_measurement_iterations TIMES.

          l_d = zcl_measurement_blackhole=>consume( ).
          mv_total_calculations = mv_total_calculations + 1.

          IF sy-index = iv_measurement_iterations.
            l_f = 1 / 0.
          ELSE.
            l_f = 1 / 2.
          ENDIF.

        ENDDO.

      CATCH cx_root.
        mv_total_exceptions = mv_total_exceptions + 1.

    ENDTRY.
    +ENDREP RESULTS rs_results.

  ENDMETHOD.
ENDCLASS.
