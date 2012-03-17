<?php

$current_dir = getcwd();
$plugin_dir = "$current_dir/wp-content/plugins/wordless";

require_once "$plugin_dir/wordless/wordless.php";
require_once Wordless::join_paths($plugin_dir, "wordless", "theme_builder.php");

$theme_name = $argv[1] ? $argv[1] : 'wordless';
$permissions = substr(sprintf('%o', fileperms($plugin_dir)), -4);

# Required WordPress function
function get_template_directory() {
  return Wordless::join_paths($current_dir, "wp-content", "themes", "whatever");
}

$builder = new WordlessThemeBuilder($theme_name, $theme_name, $permissions);
$builder->build();

?>
