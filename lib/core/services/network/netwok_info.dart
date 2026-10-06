import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({Future<bool> Function()? hasInternetAccess})
    : _hasInternetAccess =
          hasInternetAccess ?? (() => InternetConnection().hasInternetAccess);

  final Future<bool> Function() _hasInternetAccess;

  @override
  Future<bool> get isConnected => _hasInternetAccess();
}
