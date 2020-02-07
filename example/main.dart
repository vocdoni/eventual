import 'package:eventual/eventual.dart';

void main() async {
  final myValue =
      EventualValue<int>().withFreshnessTimeout(Duration(milliseconds: 10));

  print("myValue.value = ${myValue.value}");
  print("myValue.hasValue = ${myValue.hasValue}");
  print("myValue.isLoading = ${myValue.isLoading}");
  print("myValue.isLoadingFresh = ${myValue.isLoadingFresh}");
  print("myValue.loadingMessage = ${myValue.loadingMessage}");
  print("myValue.hasError = ${myValue.hasError}");
  print("myValue.errorMessage = ${myValue.errorMessage}");
  print("myValue.lastUpdated = ${myValue.lastUpdated}");
  print("myValue.lastError = ${myValue.lastError}");
  print("myValue.isFresh = ${myValue.isFresh}");
  print("\n");

  myValue.loadingMessage = "Please, wait";
  print("myValue.value = ${myValue.value}");
  print("myValue.hasValue = ${myValue.hasValue}");
  print("myValue.isLoading = ${myValue.isLoading}");
  print("myValue.isLoadingFresh = ${myValue.isLoadingFresh}");
  print("myValue.loadingMessage = ${myValue.loadingMessage}");
  print("myValue.hasError = ${myValue.hasError}");
  print("myValue.errorMessage = ${myValue.errorMessage}");
  print("myValue.lastUpdated = ${myValue.lastUpdated}");
  print("myValue.lastError = ${myValue.lastError}");
  print("myValue.isFresh = ${myValue.isFresh}");
  print("\n");

  myValue.error = "Something went wrong";
  print("myValue.value = ${myValue.value}");
  print("myValue.hasValue = ${myValue.hasValue}");
  print("myValue.isLoading = ${myValue.isLoading}");
  print("myValue.isLoadingFresh = ${myValue.isLoadingFresh}");
  print("myValue.loadingMessage = ${myValue.loadingMessage}");
  print("myValue.hasError = ${myValue.hasError}");
  print("myValue.errorMessage = ${myValue.errorMessage}");
  print("myValue.lastUpdated = ${myValue.lastUpdated}");
  print("myValue.lastError = ${myValue.lastError}");
  print("myValue.isFresh = ${myValue.isFresh}");
  print("\n");

  myValue.value = 1234;
  print("myValue.value = ${myValue.value}");
  print("myValue.hasValue = ${myValue.hasValue}");
  print("myValue.isLoading = ${myValue.isLoading}");
  print("myValue.isLoadingFresh = ${myValue.isLoadingFresh}");
  print("myValue.loadingMessage = ${myValue.loadingMessage}");
  print("myValue.hasError = ${myValue.hasError}");
  print("myValue.errorMessage = ${myValue.errorMessage}");
  print("myValue.lastUpdated = ${myValue.lastUpdated}");
  print("myValue.lastError = ${myValue.lastError}");
  print("myValue.isFresh = ${myValue.isFresh}");
  print("\n");

  await Future.delayed(Duration(milliseconds: 50));
  print("myValue.value = ${myValue.value}");
  print("myValue.hasValue = ${myValue.hasValue}");
  print("myValue.isLoading = ${myValue.isLoading}");
  print("myValue.isLoadingFresh = ${myValue.isLoadingFresh}");
  print("myValue.loadingMessage = ${myValue.loadingMessage}");
  print("myValue.hasError = ${myValue.hasError}");
  print("myValue.errorMessage = ${myValue.errorMessage}");
  print("myValue.lastUpdated = ${myValue.lastUpdated}");
  print("myValue.lastError = ${myValue.lastError}");
  print("myValue.isFresh = ${myValue.isFresh}");
  print("\n");
}
