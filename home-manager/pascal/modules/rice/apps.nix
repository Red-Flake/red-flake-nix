# App themes in Red Flake Noir: VS Code, Equibop (Discord) and Firefox.
# The vscode, equibop and firefox modules are shared with other users, so
# everything here is added on top of them for pascal only.
{ lib, ricePalette, ... }:
let
  p = ricePalette;
in
{
  # VS Code: keep Catppuccin Mocha for syntax colors, recolor the UI on top.
  # (Catppuccin's own colorOverrides setting can't work here: it rewrites
  # files inside the extension, which is read-only in the Nix store.)
  custom.vscode.extraSettings = {
    "editor.fontFamily" = "'Maple Mono NF', monospace";
    "editor.fontLigatures" = true;
    "terminal.integrated.fontFamily" = "'Maple Mono NF'";
    "workbench.colorCustomizations"."[Catppuccin Mocha]" = {
      "focusBorder" = p.crimson;
      "foreground" = p.text;
      "selection.background" = "${p.crimson}66";
      "widget.border" = p.border;

      "titleBar.activeBackground" = p.crust;
      "titleBar.inactiveBackground" = p.crust;
      "activityBar.background" = p.crust;
      "activityBar.activeBorder" = p.crimson;
      "activityBar.foreground" = p.text;
      "activityBar.inactiveForeground" = p.muted;
      "activityBarBadge.background" = p.crimson;
      "activityBarBadge.foreground" = "#ffffff";
      "sideBar.background" = p.mantle;
      "sideBar.border" = p.crust;
      "sideBarSectionHeader.background" = p.mantle;
      "statusBar.background" = p.crust;
      "statusBar.foreground" = p.subtext;
      "statusBar.noFolderBackground" = p.crust;
      "statusBar.debuggingBackground" = p.ember;
      "statusBarItem.remoteBackground" = p.crimson;
      "statusBarItem.remoteForeground" = "#ffffff";
      "panel.background" = p.mantle;
      "panel.border" = p.border;
      "panelTitle.activeBorder" = p.crimson;

      "editor.background" = p.base;
      "editorGutter.background" = p.base;
      "editor.lineHighlightBackground" = "${p.overlay}80";
      "editorCursor.foreground" = p.crimsonBright;
      "editorLineNumber.activeForeground" = p.crimsonBright;
      "editorWidget.background" = p.surface;
      "editorHoverWidget.background" = p.surface;
      "editorSuggestWidget.background" = p.surface;
      "editorSuggestWidget.selectedBackground" = p.overlay;
      "editorGroupHeader.tabsBackground" = p.mantle;
      "editorGroup.border" = p.crust;
      "tab.activeBackground" = p.base;
      "tab.inactiveBackground" = p.mantle;
      "tab.activeBorderTop" = p.crimson;
      "tab.border" = p.crust;

      "list.activeSelectionBackground" = p.overlay;
      "list.inactiveSelectionBackground" = p.surface2;
      "list.hoverBackground" = p.surface;
      "list.highlightForeground" = p.crimsonBright;
      "input.background" = p.surface;
      "input.border" = p.border;
      "dropdown.background" = p.surface;
      "quickInput.background" = p.surface;
      "quickInputList.focusBackground" = p.overlay;
      "button.background" = p.crimson;
      "button.foreground" = "#ffffff";
      "button.hoverBackground" = p.crimsonBright;
      "badge.background" = p.crimson;
      "badge.foreground" = "#ffffff";
      "progressBar.background" = p.crimson;
      "scrollbarSlider.background" = "${p.border}80";
      "scrollbarSlider.hoverBackground" = p.border;
      "terminal.background" = p.base;
      "terminalCursor.foreground" = p.crimsonBright;
    };
  };

  # Equibop: Quick CSS that maps Discord's color variables to the palette.
  # equibop.nix turns Quick CSS off for everyone, so turn it back on here.
  programs.nixcord = {
    equibopConfig = {
      useQuickCss = lib.mkForce true;
      useQuickCSS = lib.mkForce true;
    };
    quickCss = ''
      /* Red Flake Noir */
      .theme-dark,
      .visual-refresh.theme-dark,
      .theme-darker,
      .theme-midnight {
        --background-base-lowest: ${p.crust};
        --background-base-lower: ${p.base};
        --background-base-low: ${p.mantle};
        --background-surface-high: ${p.surface};
        --background-surface-higher: ${p.surface2};
        --background-surface-highest: ${p.overlay};
        --background-primary: ${p.base};
        --background-secondary: ${p.mantle};
        --background-secondary-alt: ${p.surface};
        --background-tertiary: ${p.crust};
        --background-floating: ${p.surface};
        --background-nested-floating: ${p.surface2};
        --background-mod-subtle: ${p.rgba p.overlay 0.6};
        --background-mod-normal: ${p.rgba p.overlay 0.8};
        --background-mod-strong: ${p.overlay};
        --channeltextarea-background: ${p.surface};
        --modal-background: ${p.mantle};
        --chat-background-default: ${p.base};
        --border-subtle: ${p.border};
        --border-normal: ${p.border};

        --text-default: ${p.text};
        --text-normal: ${p.text};
        --text-muted: ${p.muted};
        --text-link: ${p.cyan};
        --header-primary: ${p.text};
        --header-secondary: ${p.subtext};
        --channels-default: ${p.muted};
        --interactive-normal: ${p.subtext};
        --interactive-hover: ${p.text};
        --interactive-active: #ffffff;

        --brand-360: ${p.crimsonBright};
        --brand-500: ${p.crimson};
        --brand-560: ${p.crimsonDeep};
        --brand-experiment: ${p.crimson};
        --bg-brand: ${p.crimson};
        --control-brand-foreground: ${p.crimsonBright};
        --mention-background: ${p.rgba p.crimson 0.12};
        --mention-foreground: ${p.crimsonBright};
      }
    '';
  };

  # Firefox: recolor the browser UI (tabs, toolbar, URL bar, menus) on top of
  # the compact dark theme. Web pages are not touched.
  custom.firefox.extraUserChrome = ''
    /* Red Flake Noir */
    :root,
    :root[lwtheme] {
      --lwt-accent-color: ${p.crust} !important;
      --lwt-text-color: ${p.text} !important;
      --toolbar-bgcolor: ${p.mantle} !important;
      --toolbar-color: ${p.text} !important;
      --toolbar-field-background-color: ${p.base} !important;
      --toolbar-field-focus-background-color: ${p.base} !important;
      --toolbar-field-color: ${p.text} !important;
      --toolbar-field-focus-color: ${p.text} !important;
      --toolbar-field-border-color: ${p.border} !important;
      --toolbar-field-focus-border-color: ${p.crimson} !important;
      --tab-selected-bgcolor: ${p.mantle} !important;
      --tab-selected-textcolor: ${p.text} !important;
      --lwt-tab-line-color: ${p.crimson} !important;
      --tab-line-color: ${p.crimson} !important;
      --arrowpanel-background: ${p.surface} !important;
      --arrowpanel-color: ${p.text} !important;
      --arrowpanel-border-color: ${p.border} !important;
      --urlbarView-highlight-background: ${p.crimson} !important;
      --urlbarView-highlight-color: #ffffff !important;
      --focus-outline-color: ${p.crimson} !important;
      --toolbarbutton-icon-fill-attention: ${p.crimsonBright} !important;
      --sidebar-background-color: ${p.mantle} !important;
      --sidebar-text-color: ${p.text} !important;
    }

    #navigator-toolbox,
    #TabsToolbar {
      background-color: ${p.crust} !important;
    }

    .tab-background:is([selected], [multiselected]) {
      background: ${p.mantle} !important;
      box-shadow: inset 0 2px 0 ${p.crimson} !important;
    }
  '';
}
