<!doctype html public "-//W3C//DTD HTML 4.0 //EN"> 
<html>
<body bgcolor="#D8FfF0">
<?php 

// Connect to Database
$db = mysql_connect("213.208.89.139", "screener", "read"); 
mysql_select_db("ftse",$db);

// Concatenate Show Checkboxes with commas
for( $i = 0; $i < sizeof( $show ); $i++ ){
		$selec .= "," . $show[$i];
		}

$selection = "EPIC, Name, Sector" . $selec;

if ($searchstring)
	{
		
//	echo $searchtype . " " . $searchstring . $whynotlist . "<br>";

	
	$searchname = " $searchtype LIKE '%$searchstring%'";
	}
else
	{
	$searchname = "Name LIKE '%'";
	}

if ($Capgreater)	{$Capg = "AND Cap > $Capgreater";}
if ($Capless)	{$Capl = "AND Cap < $Capless";}
if ($PEgreater)	{$PEg = "AND PE > $PEgreater";}
if ($PEless)	{$PEl = "AND PE < $PEless";}
if ($ProsPEgreater)	{$pPEg = "AND ProsPE > $ProsPEgreater";}
if ($ProsPEless)	{$pPEl = "AND ProsPE < $ProsPEless";}
if ($yieldgreater)	{$yieldg = "AND yield > $yieldgreater";}
if ($yieldless)	{$yieldl = "AND yield < $yieldless";}
if ($DividendCovergreater)	{$divcoverg = "AND DividendCover > $DividendCovergreater";}
if ($DividendCoverless)	{$divcoverl = "AND DividendCover < $DividendCoverless";}
if ($growth1greater)	{$g1g = "AND EPSGrowth1 > $growth1greater";}
if ($growth1less)	{$g1l = "AND EPSGrowth1 < $growth1less";}
if ($growth2greater)	{$g2g = "AND EPSGrowth2 > $growth2greater";}
if ($growth2less)	{$g2l = "AND EPSGrowth2 < $growth2less";}
if ($PEGgreater)	{$PEGg = "AND PEG > $PEGgreater";}
if ($PEGless)	{$PEGl = "AND PEG < $PEGless";}

if ($Gearinggreater)	{$geg = "AND Gearing > $Gearinggreater";}
if ($Gearingless)	{$gel = "AND Gearing < $Gearingless";}

if ($PTBVgreater)	{$PTBVg = "AND PTBV > $PTBVgreater";}
if ($PTBVless)	{$PTBVl = "AND PTBV < $PTBVless";}
if ($PBVgreater)	{$PBVg = "AND PBV > $PBVgreater";}
if ($PBVless)	{$PBVl = "AND PBV < $PBVless";}

$sql = "SELECT hsid,$selection FROM current WHERE $searchname $PEg $PEl $pPEg $pPEl $Capg $Capl $yieldg $yieldl $divcoverg $divcoverl $g1g $g1l $g2g $g2l $PEGg $PEGl $geg $gel $PTBVg $PTBVl $PBVg $PBVl ORDER BY `$order`";

echo $sql;

$result = mysql_query($sql,$db);

echo "<p><TABLE  border='0' align='center' cellspacing='0' cellpadding='2' bordercolor='#D8FFF0' bordercolorlight='#D8FfF0' bordercolordark='#D8FfF0' bgcolor='#C8EFE0'>";

$color1 = "#CCFFCC"; 
$color2 = "#BFD8BC"; 
$row_count = 0;
$row_color = $color1;

print "\t<th bgcolor='#A8D0C0'>Launchpad</th>";
for ($j = 1; $j < mysql_num_fields($result); $j++) { 
	print "<th bgcolor='#A8D0C0'>".mysql_field_name($result, $j)."</th>\n";
	}

while($myrow = mysql_fetch_row($result)) 
	{ 
	$epic = $myrow[1]; $hsid = $myrow[0];
	echo "\t<tr><td><a href='oonpad.php?epic=$epic&hsid=$hsid'>Go</a></td>\n";
        for ($x = 1; $x <= count($myrow); $x++) {
            print "\t\t<td bgcolor='$row_color'>$myrow[$x]</td>\n";
			$row_color = ($row_count % 2) ? $color1 : $color2;
			$row_count++; 
        }
        print "\t</tr>\n";

	} 
	echo "</TABLE>";
?>

</body>
</html>
