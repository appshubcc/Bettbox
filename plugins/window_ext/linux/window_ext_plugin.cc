#include "include/window_ext/window_ext_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>
#include <string>

namespace {

constexpr gint kDefaultSize = 96;

std::string StripIconExtension(const std::string& name) {
  static const char* const extensions[] = {".png", ".svg", ".xpm", ".ico"};
  for (const char* extension : extensions) {
    const size_t length = std::strlen(extension);
    if (name.length() > length &&
        g_ascii_strcasecmp(name.c_str() + name.length() - length,
                           extension) == 0) {
      return name.substr(0, name.length() - length);
    }
  }
  return name;
}

GdkPixbuf* LoadIcon(const gchar* name, gint size) {
  if (g_path_is_absolute(name)) {
    return gdk_pixbuf_new_from_file_at_scale(name, size, size, TRUE, nullptr);
  }
  const std::string icon = StripIconExtension(name);
  GdkPixbuf* pixbuf = gtk_icon_theme_load_icon(
      gtk_icon_theme_get_default(), icon.c_str(), size,
      GTK_ICON_LOOKUP_FORCE_SIZE, nullptr);
  if (pixbuf != nullptr) {
    return pixbuf;
  }
  static const char* const extensions[] = {".png", ".svg", ".xpm"};
  for (const char* extension : extensions) {
    g_autofree gchar* path =
        g_strdup_printf("/usr/share/pixmaps/%s%s", icon.c_str(), extension);
    if (!g_file_test(path, G_FILE_TEST_EXISTS)) {
      continue;
    }
    pixbuf =
        gdk_pixbuf_new_from_file_at_scale(path, size, size, TRUE, nullptr);
    if (pixbuf != nullptr) {
      return pixbuf;
    }
  }
  return nullptr;
}

gint LookupSize(FlValue* args) {
  FlValue* value = fl_value_lookup_string(args, "size");
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_INT) {
    return kDefaultSize;
  }
  const gint size = static_cast<gint>(fl_value_get_int(value));
  return size > 0 ? size : kDefaultSize;
}

void GetIcon(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  FlValue* name_value =
      args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP
          ? fl_value_lookup_string(args, "name")
          : nullptr;
  if (name_value == nullptr ||
      fl_value_get_type(name_value) != FL_VALUE_TYPE_STRING) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }
  g_autoptr(GdkPixbuf) pixbuf =
      LoadIcon(fl_value_get_string(name_value), LookupSize(args));
  if (pixbuf == nullptr) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }
  gchar* buffer = nullptr;
  gsize buffer_size = 0;
  if (!gdk_pixbuf_save_to_buffer(pixbuf, &buffer, &buffer_size, "png", nullptr,
                                 nullptr)) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }
  g_autoptr(FlValue) result = fl_value_new_uint8_list(
      reinterpret_cast<const uint8_t*>(buffer), buffer_size);
  g_free(buffer);
  fl_method_call_respond_success(method_call, result, nullptr);
}

void MethodCallCallback(FlMethodChannel* channel, FlMethodCall* method_call,
                        gpointer user_data) {
  (void)channel;
  (void)user_data;
  if (g_strcmp0(fl_method_call_get_name(method_call), "getIcon") == 0) {
    GetIcon(method_call);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

}  // namespace

void window_ext_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "window_ext",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, MethodCallCallback, nullptr,
                                            nullptr);
}
