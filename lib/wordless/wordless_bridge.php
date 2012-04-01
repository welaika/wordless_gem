<?php

// WordPress function stubs

function get_template_directory() {
  return Wordless::join_paths(getcwd(), "wp-content", "themes", WordlessBridge::$theme_name);
}

function __($string) {
  return $string;
}

class WordlessBridge {
  public static $current_dir;
  public static $plugin_dir;
  public static $theme_name = 'stub';
  
  public static function initialize() {
    self::$current_dir = getcwd();
    self::$plugin_dir = self::$current_dir . '/wp-content/plugins/wordless';
    
    require_once self::$plugin_dir . "/wordless/wordless.php";
  }
}

?>