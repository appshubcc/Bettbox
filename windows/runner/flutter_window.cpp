#include "flutter_window.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <shlobj.h>

#include <cwchar>
#include <optional>
#include <string>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

#ifdef BETTBOX_DEV
#define BETTBOX_REG_KEY L"Software\\BettboxDev"
#else
#define BETTBOX_REG_KEY L"Software\\Bettbox"
#endif

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

std::wstring GetExecutableDirectory(const std::wstring& exe_path) {
  size_t last_slash = exe_path.find_last_of(L"\\/");
  if (exe_path.empty() || last_slash == std::wstring::npos) {
    return L".";
  }
  return exe_path.substr(0, last_slash);
}

std::wstring GetIconPath(bool use_dark_icon) {
  std::wstring exe_path = GetExecutablePath();
  std::wstring base_dir = GetExecutableDirectory(exe_path);
  std::wstring icon_name = use_dark_icon ? L"icon_light.ico" : L"icon.ico";
  return base_dir + L"\\data\\flutter_assets\\assets\\images\\" + icon_name;
}

bool ReadRegistryDword(const wchar_t* name, DWORD* value) {
  HKEY hKey;
  LONG result = RegOpenKeyExW(
      HKEY_CURRENT_USER,
      BETTBOX_REG_KEY,
      0,
      KEY_READ,
      &hKey
  );
  if (result != ERROR_SUCCESS) {
    return false;
  }

  DWORD size = sizeof(DWORD);
  result = RegQueryValueExW(hKey, name, NULL, NULL, (BYTE*)value, &size);
  RegCloseKey(hKey);
  return result == ERROR_SUCCESS;
}

bool WriteRegistryDword(const wchar_t* name, DWORD value) {
  HKEY hKey;
  LONG result = RegCreateKeyExW(
      HKEY_CURRENT_USER,
      BETTBOX_REG_KEY,
      0,
      NULL,
      REG_OPTION_NON_VOLATILE,
      KEY_WRITE,
      NULL,
      &hKey,
      NULL
  );
  if (result != ERROR_SUCCESS) {
    return false;
  }

  result = RegSetValueExW(hKey, name, 0, REG_DWORD, (BYTE*)&value, sizeof(DWORD));
  RegCloseKey(hKey);
  return result == ERROR_SUCCESS;
}

void DeleteRegistryValue(const wchar_t* name) {
  HKEY hKey;
  LONG result = RegOpenKeyExW(
      HKEY_CURRENT_USER,
      BETTBOX_REG_KEY,
      0,
      KEY_SET_VALUE,
      &hKey
  );
  if (result == ERROR_SUCCESS) {
    RegDeleteValueW(hKey, name);
    RegCloseKey(hKey);
  }
}

bool UpdateShortcutIcon(const std::wstring& lnk_path,
                        const std::wstring& exe_path,
                        const std::wstring& icon_path,
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

  if (FAILED(shell_link->SetIconLocation(icon_path.c_str(), 0))) {
    return false;
  }
  return SUCCEEDED(persist_file->Save(lnk_path.c_str(), TRUE));
}

bool UpdateShortcutsInDirectory(const std::wstring& dir_path,
                                const std::wstring& exe_path,
                                const std::wstring& icon_path,
                                IShellLinkW* shell_link,
                                IPersistFile* persist_file,
                                bool recursive) {
  bool updated_any = false;

  WIN32_FIND_DATAW find_data;
  std::wstring shortcut_pattern = dir_path + L"\\*.lnk";
  HANDLE hFind = FindFirstFileW(shortcut_pattern.c_str(), &find_data);
  if (hFind != INVALID_HANDLE_VALUE) {
    do {
      std::wstring lnk_path = dir_path + L"\\" + find_data.cFileName;
      if (UpdateShortcutIcon(lnk_path, exe_path, icon_path, shell_link,
                             persist_file)) {
        updated_any = true;
      }
    } while (FindNextFileW(hFind, &find_data));
    FindClose(hFind);
  }

  if (!recursive) {
    return updated_any;
  }

  std::wstring child_pattern = dir_path + L"\\*";
  hFind = FindFirstFileW(child_pattern.c_str(), &find_data);
  if (hFind == INVALID_HANDLE_VALUE) {
    return updated_any;
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
    if (UpdateShortcutsInDirectory(child_dir, exe_path, icon_path, shell_link,
                                   persist_file, recursive)) {
      updated_any = true;
    }
  } while (FindNextFileW(hFind, &find_data));
  FindClose(hFind);

  return updated_any;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  
  SetupAppMethodChannel();
  
  bool use_dark_icon = LoadIconPreference();
  SetWindowIcon(use_dark_icon);
  ApplyPendingShortcutIcon(use_dark_icon);
  
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {

  });

  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
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
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::SetupAppMethodChannel() {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "app",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        if (call.method_name() == "setLauncherIcon") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments) {
            auto use_dark_icon_it = arguments->find(flutter::EncodableValue("useDarkIcon"));
            if (use_dark_icon_it != arguments->end()) {
              bool use_dark_icon = std::get<bool>(use_dark_icon_it->second);
              bool success = SetWindowIcon(use_dark_icon);
              if (success) {
                SaveIconPreference(use_dark_icon, true);
              }
              result->Success(flutter::EncodableValue(success));
              return;
            }
          }
          result->Error("INVALID_ARGUMENT", "Missing useDarkIcon argument");
        } else {
          result->NotImplemented();
        }
      });
}

bool FlutterWindow::SetWindowIcon(bool use_dark_icon) {
  HWND hwnd = GetHandle();
  if (!hwnd) {
    return false;
  }

  std::wstring icon_path = GetIconPath(use_dark_icon);

  HICON hIcon = (HICON)LoadImageW(
      NULL,
      icon_path.c_str(),
      IMAGE_ICON,
      0,
      0,
      LR_LOADFROMFILE | LR_DEFAULTSIZE | LR_SHARED
  );

  if (!hIcon) {
    hIcon = LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_APP_ICON));
    if (!hIcon) {
      return false;
    }
  }

  SendMessage(hwnd, WM_SETICON, ICON_SMALL, (LPARAM)hIcon);
  SendMessage(hwnd, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
  SetClassLongPtr(hwnd, GCLP_HICON, (LONG_PTR)hIcon);
  SetClassLongPtr(hwnd, GCLP_HICONSM, (LONG_PTR)hIcon);

  RedrawWindow(hwnd, NULL, NULL,
               RDW_INVALIDATE | RDW_FRAME | RDW_UPDATENOW | RDW_ALLCHILDREN);

  return true;
}

void FlutterWindow::ApplyPendingShortcutIcon(bool use_dark_icon) {
  DWORD value = 0;
  if (!ReadRegistryDword(kPendingShortcutIconUpdateValue, &value) || value == 0) {
    return;
  }

  UpdateShortcutsIcon(use_dark_icon);
  DeleteRegistryValue(kPendingShortcutIconUpdateValue);
}

bool FlutterWindow::UpdateShortcutsIcon(bool use_dark_icon) {
  std::wstring exe_path = GetExecutablePath();
  if (exe_path.empty()) return false;

  std::wstring icon_path = GetIconPath(use_dark_icon);

  const struct {
    int csidl;
    bool recursive;
  } shortcut_locations[] = {
      {CSIDL_DESKTOPDIRECTORY, false},
      {CSIDL_COMMON_DESKTOPDIRECTORY, false},
      {CSIDL_PROGRAMS, true},
      {CSIDL_COMMON_PROGRAMS, true},
  };

  IShellLinkW* pShellLink = NULL;
  HRESULT hr = CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_IShellLinkW, (void**)&pShellLink);
  if (FAILED(hr) || !pShellLink) {
    return false;
  }

  IPersistFile* pPersistFile = NULL;
  hr = pShellLink->QueryInterface(IID_IPersistFile, (void**)&pPersistFile);
  if (FAILED(hr) || !pPersistFile) {
    pShellLink->Release();
    return false;
  }

  bool updated_any = false;
  for (const auto& location : shortcut_locations) {
    wchar_t dir_path[MAX_PATH] = {0};
    if (SUCCEEDED(SHGetFolderPathW(NULL, location.csidl, NULL, 0, dir_path))) {
      if (UpdateShortcutsInDirectory(dir_path, exe_path, icon_path, pShellLink,
                                     pPersistFile, location.recursive)) {
        updated_any = true;
      }
    }
  }

  pPersistFile->Release();
  pShellLink->Release();

  return updated_any;
}

void FlutterWindow::SaveIconPreference(bool use_dark_icon, bool defer_shortcut_update) {
  WriteRegistryDword(kUseDarkIconValue, use_dark_icon ? 1 : 0);
  if (defer_shortcut_update) {
    WriteRegistryDword(kPendingShortcutIconUpdateValue, 1);
  }
}

bool FlutterWindow::LoadIconPreference() {
  DWORD value = 0;
  if (ReadRegistryDword(kUseDarkIconValue, &value)) {
    return value != 0;
  }

  return false;
}
