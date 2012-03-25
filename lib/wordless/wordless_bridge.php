<?php

# WordPress function stubs

function get_template_directory() {
  return Wordless::join_paths(getcwd(), "wp-content", "themes", "whatever");
}

function add_action() {
  // Do nothing
}

class WordlessBridge {
  public static $current_dir;
  public static $plugin_dir;
  
  public static function initialize() {
    self::$current_dir = getcwd();
    self::$plugin_dir = self::$current_dir . '/wp-content/plugins/wordless';

    require_once self::$plugin_dir . "/wordless/wordless.php";
  }
}

?>