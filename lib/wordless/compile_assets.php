<?php

require 'wordless_bridge.php';

class CompileAssets extends WordlessBridge {
  public static function start() {
    parent::initialize();
    
    Wordless::initialize();
    Wordless::compile_assets();

    print_r(Wordless);
  }
}

CompileAssets::start();

?>
