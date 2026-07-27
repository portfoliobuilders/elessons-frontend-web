// Conditional export for Web Security Shield utility.
export 'web_security_stub.dart'
    if (dart.library.html) 'web_security_web.dart';
