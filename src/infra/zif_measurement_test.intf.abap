interface ZIF_MEASUREMENT_TEST
  public .


  data TEST_ID type I .
  data TEST_NAME type STRING .

  methods RUN_TEST
    importing
      !IV_MEASUREMENT_ITERATIONS type I
      !IV_MEASUREMENT_REPEATS type I
    returning
      value(RS_RESULTS) type REP_S_RESULTS .
endinterface.
