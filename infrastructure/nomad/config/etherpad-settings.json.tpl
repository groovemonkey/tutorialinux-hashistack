
 {
    "title": "tutorialinux etherpad",
    "favicon": "${FAVICON}",
    "skinName": "${SKIN_NAME:colibris}",
    "skinVariants": "${SKIN_VARIANTS:super-light-toolbar super-light-editor light-background}",
    "ip": "${IP:0.0.0.0}",

    "port": "${PORT:9001}",
  
    "showSettingsInAdminPage": "${SHOW_SETTINGS_IN_ADMIN_PAGE:true}",
    "dbType": "redis",
    "dbSettings": {
      {{range service "etherpad-redis"}}
      "host":     "{{.Address}}",
      "port":     "{{.Port}}",
      {{end}}
      "database": "etherpad",
      "user":     "dave",
      "password": "thisexamplemakesmymonkeysdance"
    },
    "defaultPadText" : "${DEFAULT_PAD_TEXT:Welcome to Etherpad!\n\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\n\nGet involved with Etherpad at https:\/\/etherpad.org\n}",
    "padOptions": {
      "noColors":         "${PAD_OPTIONS_NO_COLORS:false}",
      "showControls":     "${PAD_OPTIONS_SHOW_CONTROLS:true}",
      "showChat":         "${PAD_OPTIONS_SHOW_CHAT:true}",
      "showLineNumbers":  "${PAD_OPTIONS_SHOW_LINE_NUMBERS:true}",
      "useMonospaceFont": "${PAD_OPTIONS_USE_MONOSPACE_FONT:false}",
      "userName":         "${PAD_OPTIONS_USER_NAME:false}",
      "userColor":        "${PAD_OPTIONS_USER_COLOR:false}",
      "rtl":              "${PAD_OPTIONS_RTL:false}",
      "alwaysShowChat":   "${PAD_OPTIONS_ALWAYS_SHOW_CHAT:false}",
      "chatAndUsers":     "${PAD_OPTIONS_CHAT_AND_USERS:false}",
      "lang":             "${PAD_OPTIONS_LANG:en-gb}"
    },
    "padShortcutEnabled" : {
      "altF9":     "${PAD_SHORTCUTS_ENABLED_ALT_F9:true}",      
      "altC":      "${PAD_SHORTCUTS_ENABLED_ALT_C:true}",       
      "cmdShift2": "${PAD_SHORTCUTS_ENABLED_CMD_SHIFT_2:true}", 
      "delete":    "${PAD_SHORTCUTS_ENABLED_DELETE:true}",
      "return":    "${PAD_SHORTCUTS_ENABLED_RETURN:true}",
      "esc":       "${PAD_SHORTCUTS_ENABLED_ESC:true}",         
      "cmdS":      "${PAD_SHORTCUTS_ENABLED_CMD_S:true}",       
      "tab":       "${PAD_SHORTCUTS_ENABLED_TAB:true}",         
      "cmdZ":      "${PAD_SHORTCUTS_ENABLED_CMD_Z:true}",       
      "cmdY":      "${PAD_SHORTCUTS_ENABLED_CMD_Y:true}",       
      "cmdI":      "${PAD_SHORTCUTS_ENABLED_CMD_I:true}",       
      "cmdB":      "${PAD_SHORTCUTS_ENABLED_CMD_B:true}",       
      "cmdU":      "${PAD_SHORTCUTS_ENABLED_CMD_U:true}",       
      "cmd5":      "${PAD_SHORTCUTS_ENABLED_CMD_5:true}",       
      "cmdShiftL": "${PAD_SHORTCUTS_ENABLED_CMD_SHIFT_L:true}", 
      "cmdShiftN": "${PAD_SHORTCUTS_ENABLED_CMD_SHIFT_N:true}", 
      "cmdShift1": "${PAD_SHORTCUTS_ENABLED_CMD_SHIFT_1:true}", 
      "cmdShiftC": "${PAD_SHORTCUTS_ENABLED_CMD_SHIFT_C:true}", 
      "cmdH":      "${PAD_SHORTCUTS_ENABLED_CMD_H:true}",       
      "ctrlHome":  "${PAD_SHORTCUTS_ENABLED_CTRL_HOME:true}",   
      "pageUp":    "${PAD_SHORTCUTS_ENABLED_PAGE_UP:true}",
      "pageDown":  "${PAD_SHORTCUTS_ENABLED_PAGE_DOWN:true}"
    },
    "suppressErrorsInPadText": "${SUPPRESS_ERRORS_IN_PAD_TEXT:false}",
    "requireSession": "${REQUIRE_SESSION:false}",
    "editOnly": "${EDIT_ONLY:false}",
    "minify": "${MINIFY:true}",
    "maxAge": "${MAX_AGE:21600}", // 60 * 60 * 6 = 6 hours
    "abiword": "${ABIWORD}",
    "soffice": "${SOFFICE}",
    "tidyHtml": "${TIDY_HTML}",
    "allowUnknownFileEnds": "${ALLOW_UNKNOWN_FILE_ENDS:true}",
    "requireAuthentication": "${REQUIRE_AUTHENTICATION:false}",
    "requireAuthorization": "${REQUIRE_AUTHORIZATION:false}",
    "trustProxy": "${TRUST_PROXY:false}",
    "cookie": {
      "sameSite": "${COOKIE_SAME_SITE:Lax}"
    },
    "disableIPlogging": "${DISABLE_IP_LOGGING:false}",
    "automaticReconnectionTimeout": "${AUTOMATIC_RECONNECTION_TIMEOUT:0}",
    "scrollWhenFocusLineIsOutOfViewport": {
      "percentage": {
        "editionAboveViewport": "${FOCUS_LINE_PERCENTAGE_ABOVE:0}",
        "editionBelowViewport": "${FOCUS_LINE_PERCENTAGE_BELOW:0}"
      },
      "duration": "${FOCUS_LINE_DURATION:0}",
      "scrollWhenCaretIsInTheLastLineOfViewport": "${FOCUS_LINE_CARET_SCROLL:false}",
      "percentageToScrollWhenUserPressesArrowUp": "${FOCUS_LINE_PERCENTAGE_ARROW_UP:0}"
    },
    "users": {
      "admin": {
        "password": "${ADMIN_PASSWORD}",
        "is_admin": true
      },
      "user": {
        "password": "${USER_PASSWORD}",
        "is_admin": false
      }
    },
    "socketTransportProtocols" : ["xhr-polling", "jsonp-polling", "htmlfile"],
    "socketIo": {
      "maxHttpBufferSize": 10000
    },
    "loadTest": "${LOAD_TEST:false}",
    "dumpOnUncleanExit": false,
    "importExportRateLimiting": {
      "windowMs": "${IMPORT_EXPORT_RATE_LIMIT_WINDOW:90000}",
      "max": "${IMPORT_EXPORT_MAX_REQ_PER_IP:10}"
    },
    "importMaxFileSize": "${IMPORT_MAX_FILE_SIZE:52428800}", // 50 * 1024 * 1024
    "commitRateLimiting": {
      "duration": "${COMMIT_RATE_LIMIT_DURATION:1}",
      "points": "${COMMIT_RATE_LIMIT_POINTS:10}"
    },
    "exposeVersion": "${EXPOSE_VERSION:false}",
    "loglevel": "${LOGLEVEL:INFO}",
    "logconfig" :
      { "appenders": [{ "type": "console"}]}, // logconfig
    "customLocaleStrings": {}
  }
  