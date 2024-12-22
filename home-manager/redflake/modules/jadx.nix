{ config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory; # Dynamically get the home directory
  dynamicConfig = {
    lastSaveProjectPath = homeDir;
    lastOpenFilePath = "${config.home.homeDirectory}/Documents";
    lastSaveFilePath = homeDir;
    flattenPackage = false;
    checkForUpdates = true;
    recentProjects = [];
    fontStr = "Monospaced.plain/plain/20";
    smaliFontStr = "";
    editorThemePath = "/org/fife/ui/rsyntaxtextarea/themes/monokai.xml";
    lafTheme = "Dracula (Material)";
    langLocale = {
      locale = "en_US";
    };
    autoStartJobs = false;
    excludedPackages = "";
    saveOption = "ASK";
    shortcuts = {};
    showHeapUsageBar = false;
    alwaysSelectOpened = false;
    useAlternativeFileDialog = false;
    windowPos = {
      MainWindow = {
        windowId = "MainWindow";
        bounds = {
          x = 0.0;
          y = 33.0;
          width = 1920.0;
          height = 998.0;
        };
      };
      JDialog = {
        windowId = "JDialog";
        bounds = {
          x = 593.0;
          y = 33.0;
          width = 726.0;
          height = 999.0;
        };
      };
      JadxSettingsWindow = {
        windowId = "JadxSettingsWindow";
        bounds = {
          x = 593.0;
          y = 140.0;
          width = 1018.0;
          height = 808.0;
        };
      };
    };
    mainWindowExtendedState = 6;
    codeAreaLineWrap = false;
    srhResourceSkipSize = 3;
    srhResourceFileExt = ".xml|.html|.js|.json|.txt";
    searchResultsPerPage = 50;
    useAutoSearch = true;
    keepCommonDialogOpen = false;
    smaliAreaShowBytecode = false;
    lineNumbersMode = "AUTO";
    mainWindowVerticalSplitterLoc = 300;
    debuggerStackFrameSplitterLoc = 300;
    debuggerVarTreeSplitterLoc = 700;
    adbDialogPath = "";
    adbDialogHost = "localhost";
    adbDialogPort = "5037";
    codeCacheMode = "DISK_WITH_CACHE";
    usageCacheMode = "DISK";
    jumpOnDoubleClick = true;
    xposedCodegenLanguage = "JAVA";
    treeWidth = 400;
    dockLogViewer = true;
    tabDndGhostType = "OUTLINE";
    settingsVersion = 20;
    skipResources = false;
    skipSources = false;
    exportAsGradleProject = false;
    threadsCount = 4;
    decompilationMode = "AUTO";
    showInconsistentCode = false;
    skipXmlPrettyPrint = false;
    useImports = true;
    debugInfo = true;
    addDebugLines = false;
    inlineAnonymousClasses = true;
    inlineMethods = true;
    moveInnerClasses = true;
    allowInlineKotlinLambda = true;
    extractFinally = true;
    replaceConsts = true;
    escapeUnicode = false;
    respectBytecodeAccessModifiers = false;
    userRenamesMappingsMode = "READ";
    deobfuscationOn = false;
    deobfuscationMinLength = 3;
    deobfuscationMaxLength = 64;
    deobfuscationWhitelistStr = "android.support.v4.* android.support.v7.* android.support.v4.os.* android.support.annotation.Px androidx.core.os.* androidx.annotation.Px";
    generatedRenamesMappingFileMode = "READ";
    deobfuscationUseSourceNameAsAlias = true;
    resourceNameSource = "AUTO";
    useKotlinMethodsForVarNames = "APPLY";
    renameFlags = [ "CASE" "VALID" "PRINTABLE" ];
    integerFormat = "AUTO";
    fsCaseSensitive = false;
    cfgOutput = false;
    rawCfgOutput = false;
    fallbackMode = false;
    useDx = false;
    commentsLevel = "INFO";
    pluginOptions = {};
  };
in {
  home.file.".config/jadx/gui.json".text = builtins.toJSON dynamicConfig;
}
