<?php
include_once("../../config.php");

$id = $_REQUEST["id"];
$width = $_REQUEST["width"];
$height = $_REQUEST["height"];

print "<center><img src=\"http://beck.library.emory.edu/iln/image-content/ILN$id\"";
if ($width != '') {
   print " width=\"$width\" ";
}
if ($height != '') {
  print " height=\"$height\" ";
  }
print "></center>";
?>
