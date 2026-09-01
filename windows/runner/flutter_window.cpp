#include "flutter_window.h"

#include <shlobj.h>

#include <cwchar>
#include <optional>
#include <string>

#include "flutter/generated_plugin_registrant.h"

#ifdef BETTBOX_DEV
#define BETTBOX_REG_KEY L"Software\\BettboxDev"
#else
#define BETTBOX_REG_KEY L"Software\\Bettbox"
#endif

// TODO: Legacy cleanup routines to revert modified shortcuts/registry for users
// upgrading from older versions. Safe to remove in a future release.
namespace {

constexpr const wchar_t kUseDarkIconValue[] = L"UseDarkIcon";
constexpr const wchar_t kPendingShortcutIconUpdateValue[] =
    L"PendingShortcutIconUpdate";

std::wstring GetExecutablePath() {
  wchar_t exe_path_buf[MAX_PATH] = {0};
  DWORD exe_path_len = GetModuleFileNameW(NULL, exe_path_buf, MAX_PATH);
  if (exe_path_len == 0 || exe_path_len >= MAX_PATH) {
    return L"";
  }
  return std::wstring(exe_path_buf);
}

bool HasLegacyIconSettings() {
  HKEY hKey;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, BETTBOX_REG_KEY, 0, KEY_READ,
                    &hKey) != ERROR_SUCCESS) {
    return false;
  }

  DWORD type = 0;
  bool exists =
      (RegQueryValueExW(hKey, kUseDarkIconValue, NULL, &type, NULL, NULL) ==
       ERROR_SUCCESS) ||
      (RegQueryValueExW(hKey, kPendingShortcutIconUpdateValue, NULL, &type,
                        NULL, NULL) == ERROR_SUCCESS);
  RegCloseKey(hKey);
  return exists;
}

void RemoveLegacyIconRegistryKeys() {
  HKEY hKey;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, BETTBOX_REG_KEY, 0, KEY_SET_VALUE,
                    &hKey) == ERROR_SUCCESS) {
    RegDeleteValueW(hKey, kUseDarkIconValue);
    RegDeleteValueW(hKey, kPendingShortcutIconUpdateValue);
    RegCloseKey(hKey);
  }
}

bool ResetShortcutIcon(const std::wstring& lnk_path,
                       const std::wstring& exe_path,
                       IShellLinkW* shell_link,
                       IPersistFile* persist_file) {
  if (FAILED(persist_file->Load(lnk_path.c_str(), STGM_READWRITE))) {
    return false;
  }

  wchar_t target_path[MAX_PATH] = {0};
  if (FAILED(shell_link->GetPath(target_path, MAX_PATH, NULL, 0))) {
    return false;
  }
  if (_wcsicmp(target_path, exe_path.c_str()) != 0) {
    return false;
  }

  if (FAILED(shell_link->SetIconLocation(exe_path.c_str(), 0))) {
    return false;
  }
  return SUCCEEDED(persist_file->Save(lnk_path.c_str(), TRUE));
}

void ResetShortcutsInDirectory(const std::wstring& dir_path,
                              const std::wstring& exe_path,
                              IShellLinkW* shell_link,
                              IPersistFile* persist_file,
                              bool recursive) {
  WIN32_FIND_DATAW find_data;
  std::wstring shortcut_pattern = dir_path + L"\\*.lnk";
  HANDLE hFind = FindFirstFileW(shortcut_pattern.c_str(), &find_data);
  if (hFind != INVALID_HANDLE_VALUE) {
    do {
      std::wstring lnk_path = dir_path + L"\\" + find_data.cFileName;
      ResetShortcutIcon(lnk_path, exe_path, shell_link, persist_file);
    } while (FindNextFileW(hFind, &find_data));
    FindClose(hFind);
  }

  if (!recursive) {
    return;
  }

  std::wstring child_pattern = dir_path + L"\\*";
  hFind = FindFirstFileW(child_pattern.c_str(), &find_data);
  if (hFind == INVALID_HANDLE_VALUE) {
    return;
  }

  do {
    if ((find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0) {
      continue;
    }
    if (wcscmp(find_data.cFileName, L".") == 0 ||
        wcscmp(find_data.cFileName, L"..") == 0) {
      continue;
    }

    std::wstring child_dir = dir_path + L"\\" + find_data.cFileName;
    ResetShortcutsInDirectory(child_dir, exe_path, shell_link, persist_file,
                              recursive);
  } while (FindNextFileW(hFind, &find_data));
  FindClose(hFind);
}

void CleanupLegacyIconSettings() {
  if (!HasLegacyIconSettings()) {
    return;
  }

  std::wstring exe_path = GetExecutablePath();
  if (!exe_path.empty()) {
    IShellLinkW* pShellLink = NULL;
    HRESULT hr = CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER,
                                  IID_IShellLinkW, (void**)&pShellLink);
    if (SUCCEEDED(hr) && pShellLink) {
      IPersistFile* pPersistFile = NULL;
      hr = pShellLink->QueryInterface(IID_IPersistFile, (void**)&pPersistFile);
      if (SUCCEEDED(hr) && pPersistFile) {
        const struct {
          int csidl;
          bool recursive;
        } shortcut_locations[] = {
            {CSIDL_DESKTOPDIRECTORY, false},
            {CSIDL_COMMON_DESKTOPDIRECTORY, false},
            {CSIDL_PROGRAMS, true},
            {CSIDL_COMMON_PROGRAMS, true},
        };

        for (const auto& location : shortcut_locations) {
          wchar_t dir_path[MAX_PATH] = {0};
          if (SUCCEEDED(
                  SHGetFolderPathW(NULL, location.csidl, NULL, 0, dir_path))) {
            ResetShortcutsInDirectory(dir_path, exe_path, pShellLink,
                                      pPersistFile, location.recursive);
          }
        }
        pPersistFile->Release();
      }
      pShellLink->Release();
    }

    SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, NULL, NULL);
  }

  RemoveLegacyIconRegistryKeys();
}

constexpr const char kClipboardChannel[] = "clipboard_ext";
constexpr const char kPasteMethod[] = "paste";
constexpr const wchar_t kFlutterWindowProp[] = L"BettboxFlutterWindow";

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void FlutterWindow::SubclassViewWindow() {
  if (!flutter_controller_ || !flutter_controller_->view()) {
    return;
  }
  HWND view = flutter_controller_->view()->GetNativeWindow();
  if (!view) {
    return;
  }

  ::SetPropW(view, kFlutterWindowProp, reinterpret_cast<HANDLE>(this));
  original_view_proc_ = reinterpret_cast<WNDPROC>(::SetWindowLongPtrW(
      view, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(ViewWindowProc)));
  if (original_view_proc_ == nullptr) {
    ::RemovePropW(view, kFlutterWindowProp);
    return;
  }
  view_window_ = view;
}

void FlutterWindow::RestoreViewWindow() {
  if (!view_window_) {
    return;
  }
  if (original_view_proc_ != nullptr) {
    ::SetWindowLongPtrW(view_window_, GWLP_WNDPROC,
                        reinterpret_cast<LONG_PTR>(original_view_proc_));
  }
  ::RemovePropW(view_window_, kFlutterWindowProp);
  view_window_ = nullptr;
  original_view_proc_ = nullptr;
}

void FlutterWindow::NotifyPaste() {
  if (clipboard_channel_) {
    clipboard_channel_->InvokeMethod(
        kPasteMethod, std::make_unique<flutter::EncodableValue>());
  }
}

// static
LRESULT CALLBACK FlutterWindow::ViewWindowProc(HWND window, UINT message,
                                              WPARAM wparam,
                                              LPARAM lparam) noexcept {
  auto* self = reinterpret_cast<FlutterWindow*>(
      ::GetPropW(window, kFlutterWindowProp));
  if (self == nullptr || self->original_view_proc_ == nullptr) {
    return ::DefWindowProcW(window, message, wparam, lparam);
  }

  WNDPROC original = self->original_view_proc_;
  if (message == WM_PASTE) {
    self->NotifyPaste();
    return 0;
  }
  if (message == WM_NCDESTROY) {
    self->RestoreViewWindow();
    return ::CallWindowProcW(original, window, message, wparam, lparam);
  }

  return ::CallWindowProcW(original, window, message, wparam, lparam);
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  // TODO: Revert legacy shortcut and registry overrides once; remove in a future release.
  CleanupLegacyIconSettings();

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  clipboard_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), kClipboardChannel,
          &flutter::StandardMethodCodec::GetInstance());

  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  SubclassViewWindow();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {

  });

  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  RestoreViewWindow();
  clipboard_channel_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_PASTE:
      NotifyPaste();
      return 0;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
