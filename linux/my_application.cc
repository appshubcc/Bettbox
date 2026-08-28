#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <glib/gstdio.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#include "flutter/generated_plugin_registrant.h"

static gboolean _is_dev_build() {
  return g_str_has_suffix(APPLICATION_ID, ".dev");
}

static gchar* _get_control_socket_path() {
  const gchar* user_data_dir = g_get_user_data_dir();
  const gchar* name = _is_dev_build() ? "BettboxDev.control.sock" : "Bettbox.control.sock";
  return g_build_filename(user_data_dir, APPLICATION_ID, name, nullptr);
}

static void _send_control_command(const char* command) {
  g_autofree gchar* socket_path = _get_control_socket_path();

  int client_fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (client_fd < 0) {
    return;
  }

  struct sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);

  if (connect(client_fd, (struct sockaddr*)&addr, sizeof(addr)) == 0) {
    gchar* payload = g_strdup_printf("%s\n", command);
    ssize_t bytes_written = write(client_fd, payload, strlen(payload));
    (void)bytes_written; // Suppress unused result warning
    g_free(payload);
    close(client_fd);
    return;
  }
  close(client_fd);
}

// App method channel related
static FlMethodChannel* app_channel = nullptr;
static GtkWindow* main_window = nullptr;
static gboolean use_dark_icon = FALSE;

// Forward declarations
static void setup_app_method_channel(FlView* view);
static gboolean set_window_icon(gboolean use_dark);
static gboolean restore_window_icon(gboolean use_dark);
static void save_icon_preference(gboolean use_dark);
static gboolean load_icon_preference();
static gboolean is_appimage();
static gchar* get_executable_dir();
static void write_pending_desktop_flag();
static void apply_pending_desktop_icon(gboolean use_dark);
static gboolean save_ssd_preference(gboolean use_ssd);
static gboolean ensure_ssd_preference();
static gboolean load_ssd_preference();

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  if (main_window != nullptr) {
    gtk_window_present(main_window);
    return;
  }

  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
  ensure_ssd_preference();
  if (load_ssd_preference()) {
    use_header_bar = FALSE;
  } else {
#ifdef GDK_WINDOWING_X11
    GdkScreen* screen = gtk_window_get_screen(window);
    if (GDK_IS_X11_SCREEN(screen)) {
      const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
      if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
        use_header_bar = FALSE;
      }
    }
#endif
  }
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Bettbox");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Bettbox");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_realize(GTK_WIDGET(window));

  // Save window reference
  main_window = window;

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  // Setup app method channel
  setup_app_method_channel(view);

  // Restore window icon from saved preference (no pending flag side-effect).
  use_dark_icon = load_icon_preference();
  restore_window_icon(use_dark_icon);

  // Apply pending desktop icon update (deb/rpm only, skipped for AppImage).
  apply_pending_desktop_icon(use_dark_icon);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  // Check for --exit or --restart before GApplication registration
  for (gchar** arg = self->dart_entrypoint_arguments; arg && *arg; arg++) {
    if (g_strcmp0(*arg, "--exit") == 0 || g_strcmp0(*arg, "--restart") == 0) {
      const gchar* command = g_strcmp0(*arg, "--exit") == 0 ? "exit" : "restart";
      _send_control_command(command);
      *exit_status = 0;
      return TRUE; // Skip registration/activation and exit immediately
    }
  }

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 0;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     nullptr));
}

// ---------------------------------------------------------------------------
// App method channel implementation
// ---------------------------------------------------------------------------

static void app_method_call_handler(FlMethodChannel* channel,
                                    FlMethodCall* method_call,
                                    gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "setLauncherIcon") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* use_dark_value = fl_value_lookup_string(args, "useDarkIcon");
      if (use_dark_value != nullptr && fl_value_get_type(use_dark_value) == FL_VALUE_TYPE_BOOL) {
        gboolean use_dark = fl_value_get_bool(use_dark_value);
        gboolean success = set_window_icon(use_dark);

        g_autoptr(FlValue) result = fl_value_new_bool(success);
        fl_method_call_respond_success(method_call, result, nullptr);
        return;
      }
    }

    fl_method_call_respond_error(method_call, "INVALID_ARGUMENT",
                                 "Missing useDarkIcon argument", nullptr, nullptr);
  } else if (strcmp(method, "setServerSideDecoration") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    gboolean use_ssd = FALSE;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* use_ssd_value = fl_value_lookup_string(args, "useSsd");
      if (use_ssd_value != nullptr &&
          fl_value_get_type(use_ssd_value) == FL_VALUE_TYPE_BOOL) {
        use_ssd = fl_value_get_bool(use_ssd_value);
      }
    }
    gboolean success = save_ssd_preference(use_ssd);
    g_autoptr(FlValue) result = fl_value_new_bool(success);
    fl_method_call_respond_success(method_call, result, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

static void setup_app_method_channel(FlView* view) {
  FlEngine* engine = fl_view_get_engine(view);
  FlBinaryMessenger* messenger = fl_engine_get_binary_messenger(engine);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  app_channel = fl_method_channel_new(messenger, "app", FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(app_channel, app_method_call_handler,
                                            nullptr, nullptr);
}

// ---------------------------------------------------------------------------
// Icon preference (window icon, immediate)
// ---------------------------------------------------------------------------

// Internal: update the GTK window icon only (no side effects).
static gboolean restore_window_icon(gboolean use_dark) {
  if (main_window == nullptr) {
    return FALSE;
  }

  const gchar* icon_name = use_dark ? "icon_light.png" : "icon.png";
  gchar* icon_path = g_strdup_printf("data/flutter_assets/assets/images/%s", icon_name);

  GError* error = nullptr;
  GdkPixbuf* pixbuf = gdk_pixbuf_new_from_file(icon_path, &error);
  g_free(icon_path);

  if (error != nullptr) {
    g_warning("Failed to load icon: %s", error->message);
    g_error_free(error);
    return FALSE;
  }

  if (pixbuf == nullptr) {
    return FALSE;
  }

  gtk_window_set_icon(main_window, pixbuf);
  g_object_unref(pixbuf);
  use_dark_icon = use_dark;
  return TRUE;
}

// Called from MethodChannel when the user explicitly changes the icon setting.
static gboolean set_window_icon(gboolean use_dark) {
  if (!restore_window_icon(use_dark)) {
    return FALSE;
  }

  save_icon_preference(use_dark);

  // Mark the desktop entry for update on next restart (deb/rpm only).
  write_pending_desktop_flag();

  return TRUE;
}

static void save_icon_preference(gboolean use_dark) {
  const gchar* config_dir = g_get_user_config_dir();
  gchar* app_config_dir = g_build_filename(config_dir, "bettbox", nullptr);

  g_mkdir_with_parents(app_config_dir, 0755);

  gchar* config_file = g_build_filename(app_config_dir, "icon_preference", nullptr);

  const gchar* value = use_dark ? "1" : "0";
  GError* error = nullptr;
  g_file_set_contents(config_file, value, -1, &error);

  if (error != nullptr) {
    g_warning("Failed to save icon preference: %s", error->message);
    g_error_free(error);
  }

  g_free(config_file);
  g_free(app_config_dir);
}

static gboolean load_icon_preference() {
  const gchar* config_dir = g_get_user_config_dir();
  gchar* config_file = g_build_filename(config_dir, "bettbox", "icon_preference", nullptr);

  gchar* contents = nullptr;
  GError* error = nullptr;
  gboolean result = FALSE;

  if (g_file_get_contents(config_file, &contents, nullptr, &error)) {
    result = (g_strcmp0(contents, "1") == 0);
    g_free(contents);
  } else if (error != nullptr) {
    g_error_free(error);
  }

  g_free(config_file);
  return result;
}

static gchar* get_ssd_preference_path() {
  return g_build_filename(g_get_user_data_dir(), APPLICATION_ID,
                          "prefer_ssd", nullptr);
}

static gboolean ensure_ssd_preference() {
  gchar* config_file = get_ssd_preference_path();
  gchar* data_dir = g_path_get_dirname(config_file);
  g_mkdir_with_parents(data_dir, 0755);

  gboolean ok = TRUE;
  if (!g_file_test(config_file, G_FILE_TEST_EXISTS)) {
    GError* error = nullptr;
    ok = g_file_set_contents(config_file, "0", -1, &error);
    if (!ok) {
      g_warning("Failed to init ssd preference: %s", error->message);
      g_error_free(error);
    }
  }

  g_free(data_dir);
  g_free(config_file);
  return ok;
}

static gboolean load_ssd_preference() {
  gchar* config_file = get_ssd_preference_path();

  gchar* contents = nullptr;
  GError* error = nullptr;
  gboolean result = FALSE;
  if (g_file_get_contents(config_file, &contents, nullptr, &error)) {
    g_strstrip(contents);
    result = (g_strcmp0(contents, "1") == 0);
    g_free(contents);
  } else if (error != nullptr) {
    g_error_free(error);
  }

  g_free(config_file);
  return result;
}

static gboolean save_ssd_preference(gboolean use_ssd) {
  gchar* config_file = get_ssd_preference_path();
  gchar* data_dir = g_path_get_dirname(config_file);
  g_mkdir_with_parents(data_dir, 0755);

  const gchar* value = use_ssd ? "1" : "0";
  GError* error = nullptr;
  gboolean ok = g_file_set_contents(config_file, value, -1, &error);
  if (!ok) {
    g_warning("Failed to save ssd preference: %s", error->message);
    g_error_free(error);
  }

  g_free(data_dir);
  g_free(config_file);
  return ok;
}

// ---------------------------------------------------------------------------
// Desktop icon update (launcher/taskbar, takes effect after restart)
// ---------------------------------------------------------------------------

// Returns TRUE if running as an AppImage ($APPIMAGE env var is present).
static gboolean is_appimage() {
  return g_getenv("APPIMAGE") != nullptr;
}

// Returns the directory containing the running executable.
// Caller must g_free() the result.
static gchar* get_executable_dir() {
  gchar exe_path[4096] = {0};
  ssize_t len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
  if (len <= 0) {
    return nullptr;
  }
  exe_path[len] = '\0';
  return g_path_get_dirname(exe_path);
}

// Writes a flag file so the desktop entry is refreshed the next time the app starts.
static void write_pending_desktop_flag() {
  if (is_appimage()) {
    return;
  }
  const gchar* config_dir = g_get_user_config_dir();
  gchar* flag_file = g_build_filename(config_dir, "bettbox", "pending_desktop_update", nullptr);
  GError* error = nullptr;
  g_file_set_contents(flag_file, "1", -1, &error);
  if (error != nullptr) {
    g_warning("Failed to write pending desktop flag: %s", error->message);
    g_error_free(error);
  }
  g_free(flag_file);
}

// On startup: if the pending flag exists, copy the system .desktop file to
// ~/.local/share/applications/ (XDG user-level override) and update Icon=
// to point to the correct PNG.  Skipped entirely when running as AppImage.
static void apply_pending_desktop_icon(gboolean use_dark) {
  if (is_appimage()) {
    return;
  }

  const gchar* config_dir = g_get_user_config_dir();
  gchar* flag_file = g_build_filename(config_dir, "bettbox", "pending_desktop_update", nullptr);
  gboolean flag_exists = g_file_test(flag_file, G_FILE_TEST_EXISTS);
  g_free(flag_file);

  if (!flag_exists) {
    return;
  }

  // Resolve the absolute icon path from the executable location.
  g_autofree gchar* exe_dir = get_executable_dir();
  if (exe_dir == nullptr) {
    g_warning("apply_pending_desktop_icon: could not resolve executable directory");
    return;
  }

  const gchar* icon_name = use_dark ? "icon_light.png" : "icon.png";
  gchar* icon_abs_path = g_build_filename(
      exe_dir, "data", "flutter_assets", "assets", "images", icon_name, nullptr);

  if (!g_file_test(icon_abs_path, G_FILE_TEST_IS_REGULAR)) {
    g_warning("apply_pending_desktop_icon: icon not found at %s", icon_abs_path);
    g_free(icon_abs_path);
    return;
  }

  // Determine the .desktop filename. Try multiple candidates to handle
  // packaging tools that differ in capitalisation or use the full app ID.
  const gchar* desktop_candidates[] = {
    _is_dev_build() ? "Bettbox-dev.desktop" : "Bettbox.desktop",
    _is_dev_build() ? "bettbox-dev.desktop" : "bettbox.desktop",
    "com.appshub.bettbox.desktop",
    nullptr
  };
  const gchar* desktop_filename = desktop_candidates[0];

  // Load the system-level .desktop as a template, trying each candidate name.
  GKeyFile* kf = g_key_file_new();
  GError* error = nullptr;
  gboolean loaded = FALSE;
  const gchar* xdg_data_home_tmp = g_get_user_data_dir();
  gchar* user_apps_dir_tmp = g_build_filename(xdg_data_home_tmp, "applications", nullptr);

  for (int ci = 0; desktop_candidates[ci] != nullptr && !loaded; ci++) {
    desktop_filename = desktop_candidates[ci];

    // Try system location first.
    gchar* sys_path = g_build_filename("/usr/share/applications", desktop_filename, nullptr);
    g_clear_error(&error);
    if (g_key_file_load_from_file(kf, sys_path, G_KEY_FILE_KEEP_COMMENTS, &error)) {
      loaded = TRUE;
    } else {
      // Try existing user-level copy as fallback.
      g_clear_error(&error);
      gchar* user_path = g_build_filename(user_apps_dir_tmp, desktop_filename, nullptr);
      if (g_key_file_load_from_file(kf, user_path, G_KEY_FILE_KEEP_COMMENTS, &error)) {
        loaded = TRUE;
      }
      g_free(user_path);
    }
    g_free(sys_path);
  }
  g_free(user_apps_dir_tmp);

  if (!loaded) {
    g_warning("apply_pending_desktop_icon: no .desktop template found for any candidate");
    if (error != nullptr) { g_error_free(error); }
    g_free(icon_abs_path);
    g_key_file_free(kf);
    return;
  }

  // Write the patched .desktop to ~/.local/share/applications/,
  // or delete the user override when reverting to default (use_dark=FALSE).
  const gchar* xdg_data_home = g_get_user_data_dir();
  gchar* user_apps_dir = g_build_filename(xdg_data_home, "applications", nullptr);
  g_mkdir_with_parents(user_apps_dir, 0755);

  gchar* user_desktop = g_build_filename(user_apps_dir, desktop_filename, nullptr);
  g_free(user_apps_dir);

  gboolean write_ok = FALSE;

  if (!use_dark) {
    // Reverting to the default dark icon: remove the user-level override so
    // the system .desktop takes full effect again (including future upgrades).
    g_key_file_free(kf);
    if (g_file_test(user_desktop, G_FILE_TEST_EXISTS)) {
      if (g_remove(user_desktop) != 0) {
        g_warning("apply_pending_desktop_icon: could not remove user override %s", user_desktop);
      }
    }
    write_ok = TRUE;
  } else {
    // Applying light icon: patch Icon= and write the user override.
    g_key_file_set_string(kf, "Desktop Entry", "Icon", icon_abs_path);

    gsize length = 0;
    gchar* file_data = g_key_file_to_data(kf, &length, nullptr);
    g_key_file_free(kf);

    GError* write_error = nullptr;
    g_file_set_contents(user_desktop, file_data, (gssize)length, &write_error);
    g_free(file_data);

    if (write_error != nullptr) {
      g_warning("apply_pending_desktop_icon: write failed: %s", write_error->message);
      g_error_free(write_error);
    } else {
      write_ok = TRUE;
    }
  }

  g_free(icon_abs_path);
  g_free(user_desktop);

  if (!write_ok) {
    return;
  }

  // Success — remove the pending flag.
  gchar* done_flag = g_build_filename(config_dir, "bettbox", "pending_desktop_update", nullptr);
  g_remove(done_flag);
  g_free(done_flag);
}
