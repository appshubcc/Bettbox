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
constexpr const wchar_t kAppUserModelId[] = L"Appshub.Gamebox.Dev";
#else
constexpr const wchar_t kAppUserModelId[] = L"Appshub.Gamebox";
#endif

static std::wstring GetDumpDirectory() {
  wchar_t path[MAX_PATH];
  DWORD len = ::GetEnvironmentVariableW(L"LOCALAPPDATA", path, MAX_PATH);
  if (len == 0 || len >= MAX_PATH) {
    return L"";
  }
  std::wstring dir(path);
  if (!dir.empty() && dir.back() != L'\\') {
    dir += L'\\';
  }
  dir += L"Gamebox\\crash_dumps";
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

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  const bool is_control_command =
      std::find(command_line_arguments.begin(),
                command_line_arguments.end(), "--exit") !=
          command_line_arguments.end() ||
      std::find(command_line_arguments.begin(),
                command_line_arguments.end(), "--restart") !=
          command_line_arguments.end();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  // [Gamebox] 冷启动登录小窗固定宽 360、高 420。登录成功后 Dart 再恢复主窗口。
  Win32Window::Size size(360, 420);
#ifdef BETTBOX_DEV
  const wchar_t *window_title = L"Gamebox Dev";
  const wchar_t *window_class = L"GAMEBOX_DEV_RUNNER_WIN32_WINDOW";
#else
  const wchar_t *window_title = L"Gamebox";
  const wchar_t *window_class = L"GAMEBOX_RUNNER_WIN32_WINDOW";
#endif
  // [Gamebox] 已经有一个 Gamebox 窗口时，Create 会把本次启动交给它然后返回失败。
  // 这种情况不要弹「无法创建窗口」。
  const bool already_running =
      ::FindWindow(window_class, window_title) != nullptr;
  if (!window.Create(window_title, origin, size, !is_control_command)) {
    if (!already_running) {
      ::MessageBoxW(
          nullptr,
          L"Gamebox \u65e0\u6cd5\u521b\u5efa\u7a97\u53e3\u3002\u865a\u62df\u673a\u8bf7\u5728\u8bbe\u7f6e\u91cc\u6253\u5f00 3D \u52a0\u901f\u540e\u518d\u8bd5\u3002",
          L"Gamebox", MB_OK | MB_ICONERROR);
    }
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
