#include "my_application.h"
#include <X11/Xlib.h>

int main(int argc, char** argv) {
  XInitThreads();

  // ── Wayland 下的兜底：有 Xwayland 时优先用 X11 后端 ──────────────────────
  // Flutter 3.50 起 Wayland 默认使用 FlViewRendererSubsurface（把引擎帧 blit
  // 到一个 wl_subsurface）。该渲染器在窗口从托盘重新唤出后不会重建子表面，
  // 表现为内容黑屏、resize 一次才恢复：
  //   https://github.com/appshubcc/Bettbox/issues/651
  //   https://github.com/flutter/flutter/pull/196862
  // 「静默启动 / 最小化到托盘」正好会反复走这条路径。
  //
  // 上游修好之前，若当前会话同时有 Wayland 与 Xwayland（DISPLAY 可用），
  // 就走 X11，行为稳定；否则保持原来的 x11,wayland 顺序不变。
  //
  // 想继续用原生 Wayland 的用户显式设 GDK_BACKEND=wayland 即可，这里不会
  // 覆盖用户的选择。上游合并后删掉这段、恢复 gdk_set_allowed_backends 即可。
  const gchar* display = g_getenv("DISPLAY");
  const gchar* wayland = g_getenv("WAYLAND_DISPLAY");
  const gchar* explicit_backend = g_getenv("GDK_BACKEND");
  gboolean has_x11 = display != nullptr && display[0] != '\0';
  gboolean has_wayland = wayland != nullptr && wayland[0] != '\0';
  if (explicit_backend == nullptr && has_x11 && has_wayland) {
    gdk_set_allowed_backends("x11");
  } else {
    gdk_set_allowed_backends("x11,wayland");
  }

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
