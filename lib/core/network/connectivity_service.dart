import 'dart:io';

/// Minimal connectivity probe.
///
/// Rather than pull in a plugin, we do a short DNS lookup: if it resolves,
/// the device has a working route to the internet. Used by [ApiClient] to fail
/// fast with a friendly "no internet" message instead of a raw socket error.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  /// Returns true when the device appears to be online.
  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      // On platforms without dart:io networking (e.g. web) assume online and
      // let the actual request surface any error.
      return true;
    }
  }
}
