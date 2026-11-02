import 'dart:ffi';

import 'package:ffi/ffi.dart';

class Kernel32 {
  Kernel32._()
    : createFile = _kernel32
          .lookupFunction<
            IntPtr Function(
              Pointer<Utf16> lpFileName,
              Uint32 dwDesiredAccess,
              Uint32 dwShareMode,
              Pointer<Void> lpSecurityAttributes,
              Uint32 dwCreationDisposition,
              Uint32 dwFlagsAndAttributes,
              IntPtr hTemplateFile,
            ),
            int Function(
              Pointer<Utf16> lpFileName,
              int dwDesiredAccess,
              int dwShareMode,
              Pointer<Void> lpSecurityAttributes,
              int dwCreationDisposition,
              int dwFlagsAndAttributes,
              int hTemplateFile,
            )
          >('CreateFileW', isLeaf: true),
      readFile = _kernel32
          .lookupFunction<
            Int32 Function(
              IntPtr hFile,
              Pointer<Uint8> lpBuffer,
              Uint32 nNumberOfBytesToRead,
              Pointer<Uint32> lpNumberOfBytesRead,
              Pointer<Void> lpOverlapped,
            ),
            int Function(
              int hFile,
              Pointer<Uint8> lpBuffer,
              int nNumberOfBytesToRead,
              Pointer<Uint32> lpNumberOfBytesRead,
              Pointer<Void> lpOverlapped,
            )
          >('ReadFile', isLeaf: true),
      writeFile = _kernel32
          .lookupFunction<
            Int32 Function(
              IntPtr hFile,
              Pointer<Uint8> lpBuffer,
              Uint32 nNumberOfBytesToWrite,
              Pointer<Uint32> lpNumberOfBytesWritten,
              Pointer<Void> lpOverlapped,
            ),
            int Function(
              int hFile,
              Pointer<Uint8> lpBuffer,
              int nNumberOfBytesToWrite,
              Pointer<Uint32> lpNumberOfBytesWritten,
              Pointer<Void> lpOverlapped,
            )
          >('WriteFile', isLeaf: true),
      waitNamedPipe = _kernel32
          .lookupFunction<
            Int32 Function(Pointer<Utf16> lpNamedPipeName, Uint32 nTimeOut),
            int Function(Pointer<Utf16> lpNamedPipeName, int nTimeOut)
          >('WaitNamedPipeW', isLeaf: true),
      closeHandle = _kernel32
          .lookupFunction<
            Int32 Function(IntPtr hObject),
            int Function(int hObject)
          >('CloseHandle', isLeaf: true),
      getLastError = _kernel32
          .lookupFunction<Uint32 Function(), int Function()>(
            'GetLastError',
            isLeaf: true,
          );

  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final instance = Kernel32._();

  final int Function(
    Pointer<Utf16> lpFileName,
    int dwDesiredAccess,
    int dwShareMode,
    Pointer<Void> lpSecurityAttributes,
    int dwCreationDisposition,
    int dwFlagsAndAttributes,
    int hTemplateFile,
  )
  createFile;

  final int Function(
    int hFile,
    Pointer<Uint8> lpBuffer,
    int nNumberOfBytesToRead,
    Pointer<Uint32> lpNumberOfBytesRead,
    Pointer<Void> lpOverlapped,
  )
  readFile;

  final int Function(
    int hFile,
    Pointer<Uint8> lpBuffer,
    int nNumberOfBytesToWrite,
    Pointer<Uint32> lpNumberOfBytesWritten,
    Pointer<Void> lpOverlapped,
  )
  writeFile;

  final int Function(Pointer<Utf16> lpNamedPipeName, int nTimeOut)
  waitNamedPipe;

  final int Function(int hObject) closeHandle;

  final int Function() getLastError;
}

const genericRead = 0x80000000;
const genericWrite = 0x40000000;
const openExisting = 3;
const invalidHandleValue = -1;
const errorFileNotFound = 2;
const errorPipeBusy = 231;
