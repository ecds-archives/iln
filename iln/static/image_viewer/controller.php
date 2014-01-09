
<CENTER>
<TABLE WIDTH="100%" height="65" CELLSPACING="0" CELLPADDING="0">
<TR><TD height="65%">
<center>

<?php
include_once("../../config.php");
include("../../common_functions.php");
include_once("../../lib/xmlDbConnection.class.php");

$id = $_REQUEST["id"];

$exist_args{"debug"} = false;
$xmldb = new xmlDbConnection($exist_args);
$query = 'declare namespace tei="http://www.tei-c.org/ns/1.0";
//tei:figure[tei:graphic/@url = "' . "$id" . '"]';
$xmldb->xquery($query);
$head = $xmldb->findNode("tei:head");
$width = $xmldb->findNode("tei:graphic/@width");
$height = $xmldb->findNode("tei:graphic/@height");

//$head = utf8_decode($head);

print "<h3>$head</h3>"; 

// calculate image dimensions for each setting
$dim_25 = "width=" . ($width*0.25) . "&height=" . ($height*0.25);
$dim_50 = "width=" . ((float)$width * 0.5) . "&height=" . ($height*0.5);
$dim_75 = "width=" . ($width*0.75) . "&height=" . ($height*0.75);
$dim_100 = "width=$width&height=$height";
$dim_150 = "width=" . ($width*1.5) . "&height=" . ($height*1.5);
$dim_200 = "width=" . ($width*2) . "&height=" . ($height*2);
$dim_fitHeight = "height=100%";
$dim_fitWidth =  "width=100%";


print '<map name="zoom">
<area shape="rect" alt="Zoom: 25%" coords="0,0,40,24" ';
print "href=\"image.php?id=$id&$dim_25\" target=\"image\">";
print '<area shape="rect" alt="Zoom: 50%" coords="40,0,75,24" ';
print "href=\"image.php?id=$id&$dim_50\" target=\"image\">";
print '<area shape="rect" alt="Zoom: 75%" coords="76,0,110,24" ';
print "href=\"image.php?id=$id&$dim_75\" target=\"image\">";
print '<area shape="rect" alt="Zoom: 100%" coords="111,1,151,24" ';
print "href=\"image.php?id=$id&$dim_100\" target=\"image\">";
print '<area shape="rect" alt="Zoom: 150%" coords="152,1,194,23" ';
print "href=\"image.php?id=$id&$dim_150\" target=\"image\">";
print '<area shape="rect" alt="Zoom: 200%" coords="195,2,237,24" ';
print "href=\"image.php?id=$id&$dim_200\" target=\"image\">";
print '<area shape="rect" alt="Fit width" coords="238,1,298,24" ';
print "href=\"image.php?id=$id&$dim_fitWidth\" target=\"image\">";
print '<area shape="rect" alt="Fit height" coords="299,0,370,23" ';
print "href=\"image.php?id=$id&$dim_fitHeight\" target=\"image\">";
print '<area shape="rect" alt="White background" coords="372,0,396,24"
      href="">
<area shape="rect" alt="Close window" coords="448,0,492,24" href="javascript:window.parent.close()">
<area shape="default" nohref>
</map>';

?>

</center>
</TD></TR>
<TR><TD valign="bottom" WIDTH="100%" height="20" COLSPAN="2" BGCOLOR="#C0C0C0"><CENTER><IMG SRC="zoom.gif" border=0 usemap="#zoom"></CENTER></TD></TR>
</TABLE>

