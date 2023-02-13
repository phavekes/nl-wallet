// This file initializes the dynamic library and connects it with the stub
// generated by flutter_rust_bridge_codegen.

import 'dart:ffi';
import 'dart:io' as io;

import '../../bridge_generated.dart';

// Re-export the bridge.rs so it is only necessary to import this file.
export '../../bridge_generated.dart';

const _base = 'rust_core';

// On MacOS, the dynamic library is not bundled with the binary,
// but rather directly **linked** against the binary.
final _dylib = io.Platform.isWindows ? '$_base.dll' : 'lib$_base.so';

final api =
    RustCoreImpl(io.Platform.isIOS || io.Platform.isMacOS ? DynamicLibrary.executable() : DynamicLibrary.open(_dylib));
