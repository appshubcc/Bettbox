#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
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

// 除 --exit/--restart 之外，位置参数一律当作控制命令（`Bettbox status`）。
// 把非 '-' 开头的参数按顺序拼成一行。
static gchar* _get_control_command(gchar** arguments) {
  GString* command = g_string_new(nullptr);
  for (gchar** arg = arguments; arg != nullptr && *arg != nullptr; arg++) {
    if (**arg == '\0' || **arg == '-') {
      continue;
    }
    if (command->len > 0) {
      g_string_append_c(command, ' ');
    }
    g_string_append(command, *arg);
  }
  if (command->len == 0) {
    g_string_free(command, TRUE);
    return nullptr;
  }
  return g_string_free(command, FALSE);
}

// 把命令写进控制 socket，回执打到 stdout；返回进程退出码。
static int _run_control_command(const char* command) {
  g_autofree gchar* socket_path = _get_control_socket_path();

  int client_fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (client_fd < 0) {
    fprintf(stderr, "error: cannot create control socket: %s\n",
            g_strerror(errno));
    return 1;
  }

  struct sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);

  if (connect(client_fd, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
    fprintf(stderr, "error: Bettbox is not running (no control socket: %s)\n",
            socket_path);
    close(client_fd);
    return 1;
  }

  // 切换订阅/重启内核可能要等几秒，读超时留够余量。
  struct timeval timeout;
  timeout.tv_sec = 10;
  timeout.tv_usec = 0;
  setsockopt(client_fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

  g_autofree gchar* payload = g_strdup_printf("%s\n", command);
  const size_t total = strlen(payload);
  size_t sent = 0;
  while (sent < total) {
    ssize_t written = write(client_fd, payload + sent, total - sent);
    if (written > 0) {
      sent += (size_t)written;
      continue;
    }
    if (written < 0 && errno == EINTR) {
      continue;
    }
    fprintf(stderr, "error: failed to send command: %s\n", g_strerror(errno));
    close(client_fd);
    return 1;
  }

  GString* response = g_string_new(nullptr);
  char buffer[4096];
  ssize_t bytes_read;
  while ((bytes_read = read(client_fd, buffer, sizeof(buffer))) > 0) {
    g_string_append_len(response, buffer, bytes_read);
  }
  const int read_error = errno;
  close(client_fd);

  if (bytes_read < 0 && read_error != EAGAIN && read_error != EWOULDBLOCK &&
      read_error != EINTR) {
    fprintf(stderr, "error: failed to read response: %s\n",
            g_strerror(read_error));
    g_string_free(response, TRUE);
    return 1;
  }

  if (response->len > 0) {
    fwrite(response->str, 1, response->len, stdout);
    if (response->str[response->len - 1] != '\n') {
      fputc('\n', stdout);
    }
    fflush(stdout);
  }

  const gboolean failed = g_str_has_prefix(response->str, "error:");
  g_string_free(response, TRUE);
  return failed ? 1 : 0;
}

static GtkWindow* main_window = nullptr;

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
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
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

  // Save window reference for single-instance activation
  main_window = window;

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_enable_impeller(project, FALSE);
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

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

  // 其它位置参数是控制命令，在注册/激活之前就转发掉，否则会落到
  // GApplication 的单实例激活逻辑，表现成「所有命令都是唤醒窗口」。
  g_autofree gchar* control_command =
      _get_control_command(self->dart_entrypoint_arguments);
  if (control_command != nullptr) {
    *exit_status = _run_control_command(control_command);
    return TRUE;
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
