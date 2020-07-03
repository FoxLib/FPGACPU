<?php

function load_stream($filename) {

    $fp = fopen($f = $filename ?: "php://stdin", "r");
    $rows = [];
    while (!feof($fp)) {
        $row = rtrim(fgets($fp));
        if (ltrim($row)) $rows[] = $row;
    }
    fclose($fp);
    return $rows;
}
