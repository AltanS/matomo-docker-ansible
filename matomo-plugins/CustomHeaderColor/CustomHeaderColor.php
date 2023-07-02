<?php

namespace Piwik\Plugins\CustomHeaderColor;

use Piwik\Plugins\CustomHeaderColor\CustomHeaderColor;

class CustomHeaderColor extends \Piwik\Plugin
{
    public function registerEvents()
    {
        return array(
            'AssetManager.getStylesheetFiles' => 'getStylesheetFiles',
        );
    }

    public function getStylesheetFiles(&$stylesheets)
    {
        $stylesheets[] = "plugins/CustomHeaderColor/stylesheets/headerColor.css";
    }
}
