#include "include/tray_manager/tray_manager_plugin.h"

// This must be included before many other Windows headers.
#include <stdio.h>
#include <windows.h>

#include <shellapi.h>
#include <strsafe.h>
#include <uxtheme.h>
#include <vsstyle.h>
#include <vssym32.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <algorithm>
#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

#define WM_MYMESSAGE (WM_USER + 1)

// Windows 11 Dark Mode APIs
using SetPreferredAppModeFunc = int (WINAPI*)(int mode);
using AllowDarkModeForWindowFunc = BOOL (WINAPI*)(HWND hwnd, BOOL allow);
using FlushMenuThemesFunc = void (WINAPI*)();

enum PreferredAppMode {
  DefaultAppMode = 0,
  AllowDarkAppMode = 1,
  ForceDarkAppMode = 2,
  ForceLightAppMode = 3,
};

static SetPreferredAppModeFunc g_setPreferredAppMode = nullptr;
static AllowDarkModeForWindowFunc g_allowDarkModeForWindow = nullptr;
static FlushMenuThemesFunc g_flushMenuThemes = nullptr;
static bool g_darkModeApisInitialized = false;

static void InitializeDarkModeApis() {
  if (g_darkModeApisInitialized) return;
  
  HMODULE hUxtheme = LoadLibrary(L"uxtheme.dll");
  if (hUxtheme) {
    g_setPreferredAppMode = (SetPreferredAppModeFunc)GetProcAddress(hUxtheme, MAKEINTRESOURCEA(135));
    g_allowDarkModeForWindow = (AllowDarkModeForWindowFunc)GetProcAddress(hUxtheme, MAKEINTRESOURCEA(133));
    g_flushMenuThemes = (FlushMenuThemesFunc)GetProcAddress(hUxtheme, MAKEINTRESOURCEA(136));
  }
  g_darkModeApisInitialized = true;
}

static bool g_darkModeLastIsDark = false;

static void ApplyDarkModeToMenu(HWND hwnd, bool isDark) {
  InitializeDarkModeApis();

  if (isDark == g_darkModeLastIsDark && g_darkModeApisInitialized) return;
  g_darkModeLastIsDark = isDark;

  if (g_setPreferredAppMode) {
    g_setPreferredAppMode(isDark ? AllowDarkAppMode : DefaultAppMode);
  }

  if (g_allowDarkModeForWindow && hwnd) {
    g_allowDarkModeForWindow(hwnd, isDark ? TRUE : FALSE);
  }

  if (g_flushMenuThemes) {
    g_flushMenuThemes();
  }
}


namespace {

const flutter::EncodableValue* ValueOrNull(const flutter::EncodableMap& map,
                                           const char* key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it == map.end()) {
    return nullptr;
  }
  return &(it->second);
}
std::unique_ptr<
    flutter::MethodChannel<flutter::EncodableValue>,
    std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>>
    channel = nullptr;

class TrayManagerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  TrayManagerPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~TrayManagerPlugin();

 private:
  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> g_converter;

  flutter::PluginRegistrarWindows* registrar;
  NOTIFYICONDATA nid{};
  NOTIFYICONIDENTIFIER niif{};
  // do create pop-up menu only once.
  HMENU hMenu = CreatePopupMenu();
  bool tray_icon_setted = false;
  UINT windows_taskbar_created_message_id = 0;

  bool is_menu_open_ = false;
  bool should_reopen_menu_ = false;

  // The ID of the WindowProc delegate registration.
  int window_proc_id = -1;

  void TrayManagerPlugin::_CreateMenu(HMENU menu, flutter::EncodableMap args);
  void TrayManagerPlugin::_UpdateMenuLabels(HMENU menu, flutter::EncodableMap args);
  void TrayManagerPlugin::_ApplyIcon();

  // Called for top-level WindowProc delegation.
  std::optional<LRESULT> TrayManagerPlugin::HandleWindowProc(HWND hwnd,
                                                             UINT message,
                                                             WPARAM wparam,
                                                             LPARAM lparam);
  HWND TrayManagerPlugin::GetMainWindow();
  void TrayManagerPlugin::Destroy(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void TrayManagerPlugin::SetIcon(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void TrayManagerPlugin::SetToolTip(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void TrayManagerPlugin::SetContextMenu(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void TrayManagerPlugin::PopUpContextMenu(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void TrayManagerPlugin::GetBounds(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

static bool plugin_already_registered = false;

// static
void TrayManagerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  if (plugin_already_registered) {
    // Skip registration in subwindow
    return;
  }
  
  plugin_already_registered = true;
  
  channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "tray_manager",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<TrayManagerPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

TrayManagerPlugin::TrayManagerPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar(registrar) {
  window_proc_id = registrar->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });
  windows_taskbar_created_message_id = RegisterWindowMessage(L"TaskbarCreated");
}

TrayManagerPlugin::~TrayManagerPlugin() {
  registrar->UnregisterTopLevelWindowProcDelegate(window_proc_id);
}

void TrayManagerPlugin::_CreateMenu(HMENU menu, flutter::EncodableMap args) {
  flutter::EncodableList items = std::get<flutter::EncodableList>(
      args.at(flutter::EncodableValue("items")));

  int count = GetMenuItemCount(menu);
  for (int i = 0; i < count; i++) {
    // always remove at 0 because they shift every time
    RemoveMenu(menu, 0, MF_BYPOSITION);
  }

  for (flutter::EncodableValue item_value : items) {
    flutter::EncodableMap item_map =
        std::get<flutter::EncodableMap>(item_value);
    int id = std::get<int>(item_map.at(flutter::EncodableValue("id")));
    std::string type =
        std::get<std::string>(item_map.at(flutter::EncodableValue("type")));
    std::string label =
        std::get<std::string>(item_map.at(flutter::EncodableValue("label")));
    auto* sublabel = std::get_if<std::string>(ValueOrNull(item_map, "sublabel"));
    if (sublabel != nullptr && !sublabel->empty()) {
      label = label + "\t" + *sublabel;
    }
    auto* checked = std::get_if<bool>(ValueOrNull(item_map, "checked"));
    bool disabled =
        std::get<bool>(item_map.at(flutter::EncodableValue("disabled")));

    UINT_PTR item_id = id;
    UINT uFlags = MF_STRING;

    if (disabled) {
      uFlags |= MF_GRAYED;
    }

    if (type.compare("separator") == 0) {
      AppendMenuW(menu, MF_SEPARATOR, item_id, NULL);
    } else {
      if (type.compare("checkbox") == 0) {
        if (checked == nullptr) {
          // skip
        } else {
          uFlags |= (*checked == true ? MF_CHECKED : MF_UNCHECKED);
        }
      } else if (type.compare("submenu") == 0) {
        uFlags |= MF_POPUP;
        HMENU sub_menu = ::CreatePopupMenu();
        _CreateMenu(sub_menu, std::get<flutter::EncodableMap>(item_map.at(
                                  flutter::EncodableValue("submenu"))));
        item_id = reinterpret_cast<UINT_PTR>(sub_menu);
      }
      AppendMenuW(menu, uFlags, item_id, g_converter.from_bytes(label).c_str());
    }
  }
}

void TrayManagerPlugin::_UpdateMenuLabels(HMENU menu, flutter::EncodableMap args) {
  flutter::EncodableList items = std::get<flutter::EncodableList>(
      args.at(flutter::EncodableValue("items")));

  int count = GetMenuItemCount(menu);
  int item_count = static_cast<int>(items.size());

  int min_count = count < item_count ? count : item_count;
  for (int i = 0; i < min_count; i++) {
    flutter::EncodableMap item_map =
        std::get<flutter::EncodableMap>(items[i]);
    std::string label =
        std::get<std::string>(item_map.at(flutter::EncodableValue("label")));
    auto* sublabel = std::get_if<std::string>(ValueOrNull(item_map, "sublabel"));
    if (sublabel != nullptr && !sublabel->empty()) {
      label = label + "\t" + *sublabel;
    }
    auto* checked = std::get_if<bool>(ValueOrNull(item_map, "checked"));
    bool disabled = std::get<bool>(item_map.at(flutter::EncodableValue("disabled")));

    MENUITEMINFO mii = { sizeof(MENUITEMINFO) };
    mii.fMask = MIIM_ID | MIIM_SUBMENU;
    if (GetMenuItemInfo(menu, i, TRUE, &mii)) {
      if (mii.hSubMenu != NULL) {
        auto submenu_it = item_map.find(flutter::EncodableValue("submenu"));
        if (submenu_it != item_map.end()) {
          _UpdateMenuLabels(mii.hSubMenu, std::get<flutter::EncodableMap>(submenu_it->second));
        }
      } else {
        std::wstring wlabel = g_converter.from_bytes(label);
        MENUITEMINFO update_mii = { sizeof(MENUITEMINFO) };
        update_mii.fMask = MIIM_STRING | MIIM_STATE;
        update_mii.dwTypeData = const_cast<LPWSTR>(wlabel.c_str());
        update_mii.cch = static_cast<UINT>(wlabel.size());

        UINT state = 0;
        if (disabled) state |= MFS_DISABLED;
        else state |= MFS_ENABLED;
        if (checked != nullptr && *checked) state |= MFS_CHECKED;
        else state |= MFS_UNCHECKED;
        update_mii.fState = state;

        SetMenuItemInfo(menu, i, TRUE, &update_mii);
      }
    }
  }
}

std::optional<LRESULT> TrayManagerPlugin::HandleWindowProc(HWND hWnd,
                                                           UINT message,
                                                           WPARAM wParam,
                                                           LPARAM lParam) {
  std::optional<LRESULT> result;
  if (message == WM_DESTROY) {
    if (tray_icon_setted) {
      Shell_NotifyIcon(NIM_DELETE, &nid);
    }
    if (nid.hIcon != nullptr) {
      DestroyIcon(nid.hIcon);
      nid.hIcon = nullptr;
    }
    tray_icon_setted = false;
  } else if (message == WM_INITMENUPOPUP) {
    HMENU hmenu = (HMENU)wParam;
    if (hmenu == hMenu && !is_menu_open_) {
      is_menu_open_ = true;
      channel->InvokeMethod("onMenuOpen",
                            std::make_unique<flutter::EncodableValue>());
    }
  } else if (message == WM_MENUSELECT) {
    HMENU hmenu = (HMENU)lParam;
    if (hmenu == hMenu || hmenu == NULL) {
      UINT flags = (UINT)HIWORD(wParam);

      if (hmenu == NULL && flags == 0xFFFF && is_menu_open_) {
        is_menu_open_ = false;
        channel->InvokeMethod("onMenuClose",
                              std::make_unique<flutter::EncodableValue>());
      }
    }
  } else if (message == WM_COMMAND) {
    flutter::EncodableMap eventData = flutter::EncodableMap();
    eventData[flutter::EncodableValue("id")] =
        flutter::EncodableValue((int)wParam);

    channel->InvokeMethod("onTrayMenuItemClick",
                          std::make_unique<flutter::EncodableValue>(eventData));
  } else if (message == WM_MYMESSAGE) {
    switch (lParam) {
      case WM_LBUTTONUP:
        channel->InvokeMethod("onTrayIconMouseDown",
                              std::make_unique<flutter::EncodableValue>());
        break;
      case WM_RBUTTONUP:
        channel->InvokeMethod("onTrayIconRightMouseDown",
                              std::make_unique<flutter::EncodableValue>());
        break;
      default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    };
  } else if (message == windows_taskbar_created_message_id) {
    if (windows_taskbar_created_message_id != 0 && tray_icon_setted) {
      // restore the icon with the existing resource.
      tray_icon_setted = false;
      _ApplyIcon();
    }
  }
  return result;
}

HWND TrayManagerPlugin::GetMainWindow() {
  return ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
}

void TrayManagerPlugin::Destroy(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (tray_icon_setted) {
    Shell_NotifyIcon(NIM_DELETE, &nid);
  }
  if (nid.hIcon != nullptr) {
    DestroyIcon(nid.hIcon);
    nid.hIcon = nullptr;
  }
  tray_icon_setted = false;

  result->Success(flutter::EncodableValue(true));
}

void TrayManagerPlugin::SetIcon(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const flutter::EncodableMap& args =
      std::get<flutter::EncodableMap>(*method_call.arguments());

  std::string iconPath =
      std::get<std::string>(args.at(flutter::EncodableValue("iconPath")));

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;

  if (nid.hIcon != nullptr) {
    DestroyIcon(nid.hIcon);
    nid.hIcon = nullptr;
  }

  nid.hIcon = static_cast<HICON>(
      LoadImage(nullptr, (LPCWSTR)(converter.from_bytes(iconPath).c_str()),
                IMAGE_ICON, GetSystemMetrics(SM_CXSMICON),
                GetSystemMetrics(SM_CYSMICON), LR_LOADFROMFILE));

  _ApplyIcon();

  result->Success(flutter::EncodableValue(true));
}

void TrayManagerPlugin::_ApplyIcon() {
  if (tray_icon_setted) {
    Shell_NotifyIcon(NIM_MODIFY, &nid);
  } else {
    nid.cbSize = sizeof(NOTIFYICONDATA);
    nid.hWnd = GetMainWindow();
    nid.uID = 1;
    nid.uCallbackMessage = WM_MYMESSAGE;
    nid.uFlags = NIF_MESSAGE | NIF_ICON;
    Shell_NotifyIcon(NIM_ADD, &nid);
  }

  niif.cbSize = sizeof(NOTIFYICONIDENTIFIER);
  niif.hWnd = nid.hWnd;
  niif.uID = nid.uID;
  niif.guidItem = GUID_NULL;

  tray_icon_setted = true;
}

void TrayManagerPlugin::SetToolTip(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const flutter::EncodableMap& args =
      std::get<flutter::EncodableMap>(*method_call.arguments());

  std::string toolTip =
      std::get<std::string>(args.at(flutter::EncodableValue("toolTip")));

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
  nid.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  StringCchCopy(nid.szTip, _countof(nid.szTip),
                converter.from_bytes(toolTip).c_str());
  Shell_NotifyIcon(NIM_MODIFY, &nid);

  result->Success(flutter::EncodableValue(true));
}

void TrayManagerPlugin::SetContextMenu(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const flutter::EncodableMap& args =
      std::get<flutter::EncodableMap>(*method_call.arguments());

  auto* keep_menu_open = std::get_if<bool>(ValueOrNull(args, "keepMenuOpen"));
  bool should_keep_open = keep_menu_open != nullptr && *keep_menu_open && is_menu_open_;

  auto* brightness = std::get_if<std::string>(ValueOrNull(args, "brightness"));
  bool is_dark = brightness != nullptr && *brightness == "dark";
  ApplyDarkModeToMenu(GetMainWindow(), is_dark);

  if (should_keep_open) {
    _UpdateMenuLabels(hMenu, std::get<flutter::EncodableMap>(
                           args.at(flutter::EncodableValue("menu"))));
  } else {
    _CreateMenu(hMenu, std::get<flutter::EncodableMap>(
                           args.at(flutter::EncodableValue("menu"))));
  }

  result->Success(flutter::EncodableValue(true));
}

void TrayManagerPlugin::PopUpContextMenu(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const flutter::EncodableMap& args =
      std::get<flutter::EncodableMap>(*method_call.arguments());

  bool bringAppToFront =
      std::get<bool>(args.at(flutter::EncodableValue("bringAppToFront")));

  HWND hWnd = GetMainWindow();

  double x, y;

  // RECT rect;
  // Shell_NotifyIconGetRect(&niif, &rect);

  // x = rect.left + ((rect.right - rect.left) / 2);
  // y = rect.top + ((rect.bottom - rect.top) / 2);

  POINT cursorPos;
  GetCursorPos(&cursorPos);
  x = cursorPos.x;
  y = cursorPos.y;

  if (bringAppToFront) {
    SetForegroundWindow(hWnd);
  }
  TrackPopupMenu(hMenu, TPM_BOTTOMALIGN | TPM_LEFTALIGN, static_cast<int>(x),
                 static_cast<int>(y), 0, hWnd, NULL);
  // Fallback: ensure onMenuClose is sent if WM_MENUSELECT didn't trigger it
  if (is_menu_open_) {
    is_menu_open_ = false;
    channel->InvokeMethod("onMenuClose",
                          std::make_unique<flutter::EncodableValue>());
  }
  result->Success(flutter::EncodableValue(true));
}

void TrayManagerPlugin::GetBounds(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const flutter::EncodableMap& args =
      std::get<flutter::EncodableMap>(*method_call.arguments());

  if (!tray_icon_setted) {
    result->Success();
    return;
  }

  double devicePixelRatio =
      std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

  RECT rect;
  Shell_NotifyIconGetRect(&niif, &rect);
  flutter::EncodableMap resultMap = flutter::EncodableMap();

  double x = rect.left / devicePixelRatio * 1.0f;
  double y = rect.top / devicePixelRatio * 1.0f;
  double width = (rect.right - rect.left) / devicePixelRatio * 1.0f;
  double height = (rect.bottom - rect.top) / devicePixelRatio * 1.0f;

  resultMap[flutter::EncodableValue("x")] = flutter::EncodableValue(x);
  resultMap[flutter::EncodableValue("y")] = flutter::EncodableValue(y);
  resultMap[flutter::EncodableValue("width")] = flutter::EncodableValue(width);
  resultMap[flutter::EncodableValue("height")] =
      flutter::EncodableValue(height);

  result->Success(flutter::EncodableValue(resultMap));
}

void TrayManagerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("destroy") == 0) {
    Destroy(method_call, std::move(result));
  } else if (method_call.method_name().compare("setIcon") == 0) {
    SetIcon(method_call, std::move(result));
  } else if (method_call.method_name().compare("setToolTip") == 0) {
    SetToolTip(method_call, std::move(result));
  } else if (method_call.method_name().compare("setContextMenu") == 0) {
    SetContextMenu(method_call, std::move(result));
  } else if (method_call.method_name().compare("popUpContextMenu") == 0) {
    PopUpContextMenu(method_call, std::move(result));
  } else if (method_call.method_name().compare("getBounds") == 0) {
    GetBounds(method_call, std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void TrayManagerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  TrayManagerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}