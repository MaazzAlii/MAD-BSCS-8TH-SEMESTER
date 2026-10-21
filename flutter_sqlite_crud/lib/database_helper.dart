// Platform-conditional export:
//   - On native (dart:ffi available)  → uses sqlite3 via FFI
//   - On web  (dart:ffi unavailable)  → uses in-memory list
export 'db/database_helper_web.dart'
    if (dart.library.ffi) 'db/database_helper_native.dart';