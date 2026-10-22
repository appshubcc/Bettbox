#include "include/window_ext/window_ext_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

namespace {

constexpr gint64 kDefaultIconSize = 96;
constexpr gint64 kMaxIconSize = 1024;

const gchar* LookupStringArg(FlValue* args, const gchar* name) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return nullptr;
  }
  FlValue* value = fl_value_lookup_string(args, name);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) {
    return nullptr;
  }
  return fl_value_get_string(value);
}

gint64 LookupIntArg(FlValue* args, const gchar* name, gint64 fallback) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return fallback;
  }
  FlValue* value = fl_value_lookup_string(args, name);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_INT) {
    return fallback;
  }
  return fl_value_get_int(value);
}

void RespondSuccess(FlMethodCall* method_call, FlValue* result) {
  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond_success(method_call, result, &error)) {
    g_warning("window_ext: failed to respond: %s",
              error != nullptr ? error->message : "unknown error");
  }
}

void GetIconPath(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  const gchar* name = LookupStringArg(args, "name");
  const gint64 size = LookupIntArg(args, "size", kDefaultIconSize);

  if (name == nullptr || name[0] == '\0' || size <= 0 || size > kMaxIconSize) {
    g_autoptr(GError) error = nullptr;
    if (!fl_method_call_respond_error(
            method_call, "invalid_arguments",
            "Expected a non-empty icon name and a size between 1 and 1024",
            nullptr, &error)) {
      g_warning("window_ext: failed to respond: %s",
                error != nullptr ? error->message : "unknown error");
    }
    return;
  }

  // Let GtkIconTheme do the resolution: it walks Inherits, picks the best
  // size, and falls back to hicolor. SVG is intentionally not filtered out;
  // callers receive the path the desktop would actually use.
  GtkIconTheme* theme = gtk_icon_theme_get_default();
  GtkIconInfo* info = gtk_icon_theme_lookup_icon(
      theme, name, static_cast<gint>(size),
      static_cast<GtkIconLookupFlags>(0));
  const gchar* filename =
      info != nullptr ? gtk_icon_info_get_filename(info) : nullptr;
  g_autofree gchar* path =
      filename != nullptr ? g_strdup(filename) : nullptr;
  if (info != nullptr) {
    g_object_unref(info);
  }

  if (path == nullptr) {
    RespondSuccess(method_call, nullptr);
    return;
  }

  g_autoptr(FlValue) result = fl_value_new_string(path);
  RespondSuccess(method_call, result);
}

void MethodCallCallback(FlMethodChannel* channel, FlMethodCall* method_call,
                        gpointer user_data) {
  (void)channel;
  (void)user_data;
  const gchar* method = fl_method_call_get_name(method_call);
  if (g_strcmp0(method, "getIconPath") == 0) {
    GetIconPath(method_call);
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
