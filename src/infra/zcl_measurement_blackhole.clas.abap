class ZCL_MEASUREMENT_BLACKHOLE definition
  public
  final
  create public .

public section.

  class-methods CONSUME
    returning
      value(RV_DOUBLE) type DECFLOAT34 .
protected section.
private section.

  constants CV_PI type DECFLOAT34 value '3.141592653589793238462643383279503' ##NO_TEXT.

  class-methods COMPUTE_SINGLE
    importing
      !IV_DOUBLE type DECFLOAT34
    returning
      value(RV_DOUBLE) type DECFLOAT34 .
ENDCLASS.



CLASS ZCL_MEASUREMENT_BLACKHOLE IMPLEMENTATION.


  METHOD compute_single.

    DATA: lv_index TYPE i VALUE 0.

    rv_double = iv_double.

    WHILE lv_index < 10.
      rv_double = rv_double * rv_double / cv_pi.

      lv_index = lv_index + 1.
    ENDWHILE.

  ENDMETHOD.


  METHOD consume.

    rv_double = compute_single( cv_pi ). "+ compute_single( cv_pi * 2 ).

  ENDMETHOD.
ENDCLASS.
