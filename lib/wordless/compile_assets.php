<?php

require 'wordless_bridge.php';

class CompileAssets extends WordlessBridge {
  public static function start() {
    parent::initialize();
    
    // Determine theme name
    foreach (scandir(self::$current_dir . '/wp-content/themes') as $theme_dir) {
      if (in_array($theme_dir, array('.', '..')) && !is_dir($theme_dir)) {
        continue;
      }
      
      $previous_theme_name = WordlessBridge::$theme_name;
      WordlessBridge::$theme_name = $theme_dir;
      if (Wordless::theme_is_wordless_compatible()) {
        if (basename(self::$current_dir) == $theme_dir) {
          // A theme with the same name as the site is Wordless-compatible, this is probably the one we want
          break;
        }
      } else {
        WordlessBridge::$theme_name = $previous_theme_name;
      }
    }
    
    require(get_template_directory() . '/config/initializers/wordless_preferences.php');
    
    Wordless::register_preprocessors();
    Wordless::compile_assets();
  }
}

CompileAssets::start();

?>
