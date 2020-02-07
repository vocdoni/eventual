import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventual/eventual.dart';

void main() {
  testEventualValue();
  testEventualNotifier();
  testEventualBuilder();
}

void testEventualValue() {
  test('is created empty by default', () {
    final val = EventualValue<int>();
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    // expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });

  test('is created with a default value', () {
    final val = EventualValue<int>(42);
    expect(val.value, 42);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);
  });

  test('updates the current value', () {
    final val = EventualValue<int>(42);
    expect(val.value, 42);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.value = 100;
    expect(val.value, 100);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.setValue(250);
    expect(val.value, 250);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);
  });

  test('sets to loading', () {
    final val = EventualValue<int>();
    val.loading = true;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.loading = false;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.loadingMessage = "Please, wait...";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.loading = false;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    final val2 =
        EventualValue<int>().setToLoading("Please, wait a bit more...");
    expect(val2.value, null);
    expect(val2.hasValue, false);
    expect(val2.isLoading, true);
    expect(val2.isLoadingFresh, false);
    expect(val2.loadingMessage, "Please, wait a bit more...");
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, null);
    expect(val2.lastError, null);
    expect(val2.isFresh, false);

    val2.loading = false;
    expect(val2.value, null);
    expect(val2.hasValue, false);
    expect(val2.isLoading, false);
    expect(val2.isLoadingFresh, false);
    expect(val2.loadingMessage, null);
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, null);
    expect(val2.lastError, null);
    expect(val2.isFresh, false);
  });

  test('sets an error', () {
    final val = EventualValue<int>();
    val.error = "Failed to do something";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Failed to do something");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);

    val.value = 100;
    expect(val.value, 100);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.setError("Something else failed");
    expect(val.value, 100);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Something else failed");
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, true);
  });

  test('setting to loading keeps the current value', () {
    final val = EventualValue<int>(1234);

    val.loadingMessage = "Please, wait...";
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);
  });

  test('setting an error keeps the current value', () {
    final val = EventualValue<int>(42);

    val.error = "Fatal error";
    expect(val.value, 42);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Fatal error");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);
  });

  test('setting a value clears the loading state', () {
    final val = EventualValue<int>();
    val.loading = true;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.value = 1234;
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.loadingMessage = "Please, wait...";
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.setValue(2345);
    expect(val.value, 2345);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);
  });

  test('setting an error clears the loading state', () {
    final val = EventualValue<int>();
    val.loadingMessage = "Please, wait...";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.error = "Something fatal happened";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Something fatal happened");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);

    val.loadingMessage = "Please, wait a bit more...";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait a bit more...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.setError("Something fatal happened again");
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Something fatal happened again");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);
  });

  test('handle the freshness of the main value', () async {
    final val =
        EventualValue<int>().withFreshnessTimeout(Duration(milliseconds: 50));
    val.value = 1234;
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    await Future.delayed(Duration(milliseconds: 60));

    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, false);
  });

  test('handle the age of the loading status', () async {
    final val =
        EventualValue<int>().withLoadingTimeout(Duration(milliseconds: 50));
    val.loadingMessage = "Please, wait 50ms";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait 50ms");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    await Future.delayed(Duration(milliseconds: 60));

    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, true);
    expect(val.loadingMessage, "Please, wait 50ms");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    final val2 =
        EventualValue<int>().withLoadingTimeout(Duration(milliseconds: 50));
    val2.value = 1234;
    val2.loadingMessage = "Please, wait 50ms more";
    expect(val2.value, 1234);
    expect(val2.hasValue, true);
    expect(val2.isLoading, true);
    expect(val2.isLoadingFresh, false);
    expect(val2.loadingMessage, "Please, wait 50ms more");
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, isA<DateTime>());
    expect(val2.lastError, null);
    expect(val2.isFresh, true);

    await Future.delayed(Duration(milliseconds: 60));

    expect(val2.value, 1234);
    expect(val2.hasValue, true);
    expect(val2.isLoading, true);
    expect(val2.isLoadingFresh, true);
    expect(val2.loadingMessage, "Please, wait 50ms more");
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, isA<DateTime>());
    expect(val2.lastError, null);
    expect(val2.isFresh, true);
  });

  test('modifiers', () async {
    final val1 = EventualValue<int>();
    expect(val1, val1.withLoadingTimeout(Duration(milliseconds: 50)));

    final val2 = EventualValue<int>();
    expect(val2, val2.withFreshnessTimeout(Duration(milliseconds: 50)));

    final val3 = EventualValue<int>();
    expect(
        val3,
        val3
            .withLoadingTimeout(Duration(milliseconds: 50))
            .withFreshnessTimeout(Duration(milliseconds: 50)));

    final val4 = EventualValue<int>();
    expect(
        val4,
        val4
            .withFreshnessTimeout(Duration(milliseconds: 50))
            .withLoadingTimeout(Duration(milliseconds: 50)));

    final val5 = EventualValue<int>();
    expect(val5, val5.setValue(1234));

    final val6 = EventualValue<int>();
    expect(val6, val6.setToLoading("Please, wait..."));

    final val7 = EventualValue<int>();
    expect(val7, val7.setError("Oh my!"));

    final val8 = EventualValue<int>();
    expect(
        val8,
        val8
            .withFreshnessTimeout(Duration(milliseconds: 50))
            .withLoadingTimeout(Duration(milliseconds: 50))
            .setToLoading()
            .setError("Fail")
            .setValue(1234));
  });
}

void testEventualNotifier() {
  test('is created empty by default', () {
    final val = EventualNotifier<int>();
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    // expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });

  test('is created with a default value', () {
    final val = EventualNotifier<int>(42);
    expect(val.value, 42);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);
  });

  test('updates the current value', () {
    final val = EventualNotifier<int>(42);
    expect(val.value, 42);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.value = 100;
    expect(val.value, 100);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.setValue(250);
    expect(val.value, 250);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);
  });

  test('sets to loading', () {
    final val = EventualNotifier<int>();
    val.loading = true;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.loading = false;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.loadingMessage = "Please, wait...";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.loading = false;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    final val2 =
        EventualNotifier<int>().setToLoading("Please, wait a bit more...");
    expect(val2.value, null);
    expect(val2.hasValue, false);
    expect(val2.isLoading, true);
    expect(val2.isLoadingFresh, false);
    expect(val2.loadingMessage, "Please, wait a bit more...");
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, null);
    expect(val2.lastError, null);
    expect(val2.isFresh, false);

    val2.loading = false;
    expect(val2.value, null);
    expect(val2.hasValue, false);
    expect(val2.isLoading, false);
    expect(val2.isLoadingFresh, false);
    expect(val2.loadingMessage, null);
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, null);
    expect(val2.lastError, null);
    expect(val2.isFresh, false);
  });

  test('sets an error', () {
    final val = EventualNotifier<int>();
    val.error = "Failed to do something";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Failed to do something");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);

    val.value = 100;
    expect(val.value, 100);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.setError("Something else failed");
    expect(val.value, 100);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Something else failed");
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, true);
  });

  test('setting to loading keeps the current value', () {
    final val = EventualNotifier<int>(1234);

    val.loadingMessage = "Please, wait...";
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);
  });

  test('setting an error keeps the current value', () {
    final val = EventualNotifier<int>(42);

    val.error = "Fatal error";
    expect(val.value, 42);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Fatal error");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);
  });

  test('setting a value clears the loading state', () {
    final val = EventualNotifier<int>();
    val.loading = true;
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.value = 1234;
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.loadingMessage = "Please, wait...";
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    val.setValue(2345);
    expect(val.value, 2345);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);
  });

  test('setting an error clears the loading state', () {
    final val = EventualNotifier<int>();
    val.loadingMessage = "Please, wait...";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.error = "Something fatal happened";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Something fatal happened");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);

    val.loadingMessage = "Please, wait a bit more...";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait a bit more...");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    val.setError("Something fatal happened again");
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, true);
    expect(val.errorMessage, "Something fatal happened again");
    expect(val.lastUpdated, null);
    expect(val.lastError, isA<DateTime>());
    expect(val.isFresh, false);
  });

  test('handle the freshness of the main value', () async {
    final val = EventualNotifier<int>()
        .withFreshnessTimeout(Duration(milliseconds: 50));
    val.value = 1234;
    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, true);

    await Future.delayed(Duration(milliseconds: 60));

    expect(val.value, 1234);
    expect(val.hasValue, true);
    expect(val.isLoading, false);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, null);
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, isA<DateTime>());
    expect(val.lastError, null);
    expect(val.isFresh, false);
  });

  test('handle the age of the loading status', () async {
    final val =
        EventualNotifier<int>().withLoadingTimeout(Duration(milliseconds: 50));
    val.loadingMessage = "Please, wait 50ms";
    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, false);
    expect(val.loadingMessage, "Please, wait 50ms");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    await Future.delayed(Duration(milliseconds: 60));

    expect(val.value, null);
    expect(val.hasValue, false);
    expect(val.isLoading, true);
    expect(val.isLoadingFresh, true);
    expect(val.loadingMessage, "Please, wait 50ms");
    expect(val.hasError, false);
    expect(val.errorMessage, null);
    expect(val.lastUpdated, null);
    expect(val.lastError, null);
    expect(val.isFresh, false);

    final val2 =
        EventualNotifier<int>().withLoadingTimeout(Duration(milliseconds: 50));
    val2.value = 1234;
    val2.loadingMessage = "Please, wait 50ms more";
    expect(val2.value, 1234);
    expect(val2.hasValue, true);
    expect(val2.isLoading, true);
    expect(val2.isLoadingFresh, false);
    expect(val2.loadingMessage, "Please, wait 50ms more");
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, isA<DateTime>());
    expect(val2.lastError, null);
    expect(val2.isFresh, true);

    await Future.delayed(Duration(milliseconds: 60));

    expect(val2.value, 1234);
    expect(val2.hasValue, true);
    expect(val2.isLoading, true);
    expect(val2.isLoadingFresh, true);
    expect(val2.loadingMessage, "Please, wait 50ms more");
    expect(val2.hasError, false);
    expect(val2.errorMessage, null);
    expect(val2.lastUpdated, isA<DateTime>());
    expect(val2.lastError, null);
    expect(val2.isFresh, true);
  });

  test('modifiers', () async {
    final val1 = EventualNotifier<int>();
    expect(val1, val1.withLoadingTimeout(Duration(milliseconds: 50)));

    final val2 = EventualNotifier<int>();
    expect(val2, val2.withFreshnessTimeout(Duration(milliseconds: 50)));

    final val3 = EventualNotifier<int>();
    expect(
        val3,
        val3
            .withLoadingTimeout(Duration(milliseconds: 50))
            .withFreshnessTimeout(Duration(milliseconds: 50)));

    final val4 = EventualNotifier<int>();
    expect(
        val4,
        val4
            .withFreshnessTimeout(Duration(milliseconds: 50))
            .withLoadingTimeout(Duration(milliseconds: 50)));

    final val5 = EventualNotifier<int>();
    expect(val5, val5.setValue(1234));

    final val6 = EventualNotifier<int>();
    expect(val6, val6.setToLoading("Please, wait..."));

    final val7 = EventualNotifier<int>();
    expect(val7, val7.setError("Oh my!"));

    final val8 = EventualNotifier<int>();
    expect(
        val8,
        val8
            .withFreshnessTimeout(Duration(milliseconds: 50))
            .withLoadingTimeout(Duration(milliseconds: 50))
            .setToLoading()
            .setError("Fail")
            .setValue(1234));
  });
}

void testEventualBuilder() {
  testWidgets('EventuallBuilder handles one value',
      (WidgetTester tester) async {
    final name = EventualNotifier<String>();

    await tester.pumpWidget(EventualTesterWidget(notifier: name));

    expect(find.text("notifierList.length: 1"), findsOneWidget,
        reason: "notifierList.length should be 1, but it isn't");

    expect(find.text("notifierList[0].value = null"), findsOneWidget,
        reason: "value should be null, but it isn't");
    expect(find.text("notifierList[0].hasValue = false"), findsOneWidget,
        reason: "hasValue should be false, but it isn't");
    expect(find.text("notifierList[0].value = Hello"), findsNothing,
        reason: "value should be Hello but it isn't");

    name.value = "Hello";
    await tester.pump();

    expect(find.text("notifierList[0].value = Hello"), findsOneWidget,
        reason: "value should be Hello, but it isn't");
    expect(find.text("notifierList[0].value = null"), findsNothing,
        reason: "value should be null but it isn't");
    expect(find.text("notifierList[0].hasValue = true"), findsOneWidget,
        reason: "hasValue should be true, but it isn't");

    name.error = "Oh my!";
    await tester.pump();

    expect(find.text("notifierList[0].value = Hello"), findsOneWidget,
        reason: "value should be Hello, but it isn't");
    expect(find.text("notifierList[0].value = null"), findsNothing,
        reason: "value should be null but it isn't");
    expect(find.text("notifierList[0].hasValue = true"), findsOneWidget,
        reason: "hasValue should be true, but it isn't");
    expect(find.text("notifierList[0].errorMessage = Oh my!"), findsOneWidget,
        reason: "errorMessage should be Oh my!, but it isn't");
    expect(find.text("notifierList[0].hasError = true"), findsOneWidget,
        reason: "hasError should be true, but it isn't");

    name.loadingMessage = "Please wait...";
    await tester.pump();

    expect(find.text("notifierList[0].value = Hello"), findsOneWidget,
        reason: "value should be Hello, but it isn't");
    expect(find.text("notifierList[0].value = null"), findsNothing,
        reason: "value should be null but it isn't");
    expect(find.text("notifierList[0].hasValue = true"), findsOneWidget,
        reason: "hasValue should be true, but it isn't");
    expect(find.text("notifierList[0].errorMessage = null"), findsOneWidget,
        reason: "errorMessage should be null, but it isn't");
    expect(find.text("notifierList[0].hasError = false"), findsOneWidget,
        reason: "hasError should be true, but it isn't");
    expect(find.text("notifierList[0].loadingMessage = Please wait..."),
        findsOneWidget,
        reason: "loadingMessage should be Please wait..., but it isn't");
    expect(find.text("notifierList[0].isLoading = true"), findsOneWidget,
        reason: "isLoading should be true, but it isn't");
  });

  testWidgets('EventuallBuilder handles three values',
      (WidgetTester tester) async {
    final value1 = EventualNotifier<String>("Hello");
    final value2 = EventualNotifier<String>("EventualBuilder");
    final value3 = EventualNotifier<String>("users");

    await tester
        .pumpWidget(EventualTesterWidget(notifiers: [value1, value2, value3]));

    expect(find.text("notifierList.length: 3"), findsOneWidget,
        reason: "notifierList.length should be 3, but it isn't");

    expect(find.text("notifierList[0].value = Hello"), findsOneWidget,
        reason: "value should be Hello, but it isn't");
    expect(find.text("notifierList[1].value = EventualBuilder"), findsOneWidget,
        reason: "value should be EventualBuilder but it isn't");
    expect(find.text("notifierList[2].value = users"), findsOneWidget,
        reason: "value should be users, but it isn't");
  });
}

class EventualTesterWidget extends StatelessWidget {
  final EventualNotifier<String> notifier;
  final List<EventualNotifier<String>> notifiers;

  const EventualTesterWidget({
    Key key,
    this.notifier,
    this.notifiers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventual Test',
      home: Scaffold(
        body: EventualBuilder(
            notifier: notifier,
            notifiers: notifiers,
            builder: (context, notifierList, child) => Center(
                  child: Column(
                    children: <Widget>[
                      Text("notifierList.length: ${notifierList.length}"),
                      buildDumpNotifier(notifierList, 0),
                      buildDumpNotifier(notifierList, 1),
                      buildDumpNotifier(notifierList, 2),
                    ],
                  ),
                )),
      ),
    );
  }

  buildDumpNotifier(List<EventualNotifier> notifierList, int idx) {
    if (notifierList.length < (idx + 1)) return Container();

    return Column(children: <Widget>[
      Text("notifierList[$idx].value = ${notifierList[idx].value}"),
      Text("notifierList[$idx].hasValue = ${notifierList[idx].hasValue}"),
      Text("notifierList[$idx].isLoading = ${notifierList[idx].isLoading}"),
      Text(
          "notifierList[$idx].isLoadingFresh = ${notifierList[idx].isLoadingFresh}"),
      Text(
          "notifierList[$idx].loadingMessage = ${notifierList[idx].loadingMessage}"),
      Text("notifierList[$idx].hasError = ${notifierList[idx].hasError}"),
      Text(
          "notifierList[$idx].errorMessage = ${notifierList[idx].errorMessage}"),
      Text("notifierList[$idx].lastUpdated = ${notifierList[idx].lastUpdated}"),
      Text("notifierList[$idx].lastError = ${notifierList[idx].lastError}"),
      Text("notifierList[$idx].isFresh = ${notifierList[idx].isFresh}"),
    ]);
  }
}
