interface ZIF_TRYCATCH_LOOP_TEST
  public .


  interfaces ZIF_MEASUREMENT_TEST .

  aliases TEST_ID
    for ZIF_MEASUREMENT_TEST~TEST_ID .
  aliases TEST_NAME
    for ZIF_MEASUREMENT_TEST~TEST_NAME .
  aliases RUN_TEST
    for ZIF_MEASUREMENT_TEST~RUN_TEST .

  data MV_TOTAL_CALCULATIONS type I .
  data MV_TOTAL_EXCEPTIONS type I .
endinterface.
