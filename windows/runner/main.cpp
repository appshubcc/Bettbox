#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <dbghelp.h>
#include <shlobj_core.h>
#include <shobjidl.h>

#include <algorithm>
#include <chrono>
#include <sstream>
#include <string>
#include <vector>

#include "flutter_window.h"
#include "utils.h"

namespace {

#ifdef BETTBOX_DEV
constexpr const wchar_t kAppUserModelId[] = L"Appshub.Bettbox.Dev";
#else
constexpr const wchar_t kAppUserModelId[] = L"Appshub.Bettbox";
#endif

static std::wstring GetPortableDirectory() {
  wchar_t exe_path[MAX_PATH];
  const DWORD exe_len = ::GetModuleFileNameW(nullptr, exe_path, MAX_PATH);
  if (exe_len == 0 || exe_len >= MAX_PATH) {
    return L"";
  }
  std::wstring dir(exe_path, exe_len);
  const size_t separator = dir.find_last_of(L'\\');
  if (separator == std::wstring::npos) {
    return L"";
  }
  dir = dir.substr(0, separator + 1) + L"portable";
  const DWORD attributes = ::GetFileAttributesW(dir.c_str());
  if (attributes == INVALID_FILE_ATTRIBUTES ||
      (attributes & FILE_ATTRIBUTE_DIRECTORY) == 0) {
    return L"";
  }
  return dir;
}

static std::wstring GetDumpDirectory() {
  const std::wstring portable_dir = GetPortableDirectory();
  if (!portable_dir.empty()) {
    return portable_dir + L"\\crash_dumps";
  }
  wchar_t path[MAX_PATH];
  DWORD len = ::GetEnvironmentVariableW(L"LOCALAPPDATA", path, MAX_PATH);
  if (len == 0 || len >= MAX_PATH) {
    return L"";
  }
  std::wstring dir(path);
  if (!dir.empty() && dir.back() != L'\\') {
    dir += L'\\';
  }
  dir += L"Bettbox\\crash_dumps";
  return dir;
}

static void EnsureDumpDirectory(const std::wstring &dir) {
  if (dir.empty()) {
    return;
  }
  const DWORD err = ::SHCreateDirectoryExW(nullptr, dir.c_str(), nullptr);
  if (err != ERROR_SUCCESS && err != ERROR_ALREADY_EXISTS &&
      err != ERROR_FILE_EXISTS) {
    return;
  }
}

static LONG WINAPI BettboxUnhandledExceptionFilter(
    EXCEPTION_POINTERS *exception_info) {
  const std::wstring dir = GetDumpDirectory();
  if (dir.empty()) {
    return EXCEPTION_EXECUTE_HANDLER;
  }
  EnsureDumpDirectory(dir);

  const auto now = std::chrono::system_clock::now();
  const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                      now.time_since_epoch())
                      .count();

  std::wostringstream filename;
  filename << dir << L"\\bettbox_" << ms << L".dmp";

  HANDLE file = ::CreateFileW(filename.str().c_str(), GENERIC_WRITE, 0, nullptr,
                              CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) {
    return EXCEPTION_EXECUTE_HANDLER;
  }

  MINIDUMP_EXCEPTION_INFORMATION minidump_info;
  minidump_info.ThreadId = ::GetCurrentThreadId();
  minidump_info.ExceptionPointers = exception_info;
  minidump_info.ClientPointers = FALSE;

  ::MiniDumpWriteDump(::GetCurrentProcess(), ::GetCurrentProcessId(), file,
                      MiniDumpNormal, &minidump_info, nullptr, nullptr);
  ::CloseHandle(file);

  return EXCEPTION_EXECUTE_HANDLER;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  ::SetCurrentProcessExplicitAppUserModelID(kAppUserModelId);
  ::SetUnhandledExceptionFilter(BettboxUnhandledExceptionFilter);

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  project.set_impeller_switch(flutter::ImpellerSwitch::Disabled);

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  // 位置参数（`Bettbox status` 之类）也是控制命令：既不显示窗口，
  // 也不做正常 GUI 启动，由 Dart 侧转发并打印回执后退出。
  bool has_positional_argument = false;
  for (const auto& argument : command_line_arguments) {
    if (!argument.empty() && argument[0] != '-') {
      has_positional_argument = true;
      break;
    }
  }

  const bool is_control_command =
      has_positional_argument ||
      std::find(command_line_arguments.begin(),
                command_line_arguments.end(), "--exit") !=
          command_line_arguments.end() ||
      std::find(command_line_arguments.begin(),
                command_line_arguments.end(), "--restart") !=
          command_line_arguments.end();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
#ifdef BETTBOX_DEV
  const wchar_t *window_title = L"Bettbox Dev";
#else
  const wchar_t *window_title = L"Bettbox";
#endif
  if (!window.Create(window_title, origin, size, !is_control_command)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
