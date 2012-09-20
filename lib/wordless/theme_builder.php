<?php

require 'wordless_bridge.php';

class ThemeBuilder extends WordlessBridge {
  public static function start() {
    global $argv, $theme_name;

    parent::initialize();

    require_once Wordless::join_paths(self::$plugin_dir, "wordless", "theme_builder.php");

    $theme_name = $argv[1] ? $argv[1] : 'wordless';
    $permissions = substr(sprintf('%o', fileperms(self::$plugin_dir)), -4);

    $builder = new WordlessThemeBuilder($theme_name, $theme_name, intval($permissions, 8));
    $builder->build();
  }
}

ThemeBuilder::start();

?>
