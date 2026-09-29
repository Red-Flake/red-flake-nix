{ pkgs }:
pkgs.runCommand "stellaris-test-windows"
{
  nativeBuildInputs = [ pkgs.pkg-config pkgs.stdenv.cc ];
  buildInputs = [ pkgs.qt6.qtbase pkgs.gtk3 ];
} ''
  mkdir -p "$out/bin"
  c++ -std=c++17 ${./window.cpp} -o "$out/bin/stellaris-test-windows" $(pkg-config --cflags --libs Qt6Widgets)
  # A GTK3 window: plain like LibreOffice's GTK3 interface, or with a header bar (--headerbar).
  cc -x c - -o "$out/bin/stellaris-test-gtk3" $(pkg-config --cflags --libs gtk+-3.0) <<'C'
  #include <gtk/gtk.h>
  #include <string.h>
  int main(int argc, char **argv) {
    gboolean headerbar = argc > 1 && strcmp(argv[1], "--headerbar") == 0;
    gtk_init(&argc, &argv);
    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    if (headerbar) {
      GtkWidget *bar = gtk_header_bar_new();
      gtk_header_bar_set_show_close_button(GTK_HEADER_BAR(bar), TRUE);
      gtk_window_set_titlebar(GTK_WINDOW(window), bar);
    }
    gtk_window_set_title(GTK_WINDOW(window), headerbar ? "Stellaris GTK3 headerbar test" : "Stellaris GTK3 test");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 250);
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    gtk_widget_show_all(window);
    gtk_main();
  }
  C
''
