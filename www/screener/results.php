<!doctype html public "-//W3C//DTD HTML 4.0 //EN"> 
<html>
<body bgcolor="#D8FfF0">
<?php 	  
	
	//TO INSTALL: Put this script in an appropriate file, and then
	// refer to it in a manner somewhat like the following code:
	/*
		 
		//include our snippet
		require ('results.php'); //Or whatever you name the snippet
		
		//Override some defaults
		$tblQuery['columns']='*';						//The columns to select
		$tblQuery['tblName']='HachiSoft';				//The table to select from
		$tblQuery['where']="WebDesign='Excruciating'";	//The Where clause for the SELECT
		$tblQuery['viewSize']=10;						//How many records to a page
		
		//Pass along any self-referral parameters for table ordering and paging
		//////////////////////////////////////////////////////////////////////
		if (isset($orderBy))
			$tblQuery['orderBy']=$orderBy;		//The column to orderBy
		if (isset($viewStart))
			$tblQuery['viewStart']=$viewStart;  //The starting offset for record paging
		if (isset($orderDir))
			$tblQuery['orderDir']=$orderDir;    //Whether to sort ascending or descending ('ASC' or 'DESC')
		
		//To Set a default self-referral parameter:
		/////////////////////////////////////////////////
		//if (isset($orderDir))
		//	$tblQuery['orderDir']=$orderDir;
		//else
		//	$tblQuery['orderDir']='DESC';
		
		//To set column-specific formatting and processing:
		///////////////////////////////////////////////////
		
		$tblFormat['colFormat']=array(
			  'Column1'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'<B>',		   //prefix formatting inside column
			  					'formatEnd'=>'</B>',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=left>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				),								   //Note: callback needs to be in the format:  function (p1), return a string, and can be any function (even user)
			  'Column2'=>array( //Second column-specific formatter array (limited in number only by the column count)
			  				'colBegin'=>'<TD ALIGN=left>',
			  				 ),
			);
		
		
		//Call the table generation function with our (modified) default parameters
		echoTable($tblFormat, $tblQuery, $dbData);
		
	*/
	//Begin actual code///////

	////////////////////////////////
	//Initialize Default Variables
	
	////////////////////////////
	//The Database Connection Information
	if (!isset($dbData))
		$dbData=array(
			'Host'=>'213.208.89.139',			//DBHost to connect to
			'UserName'=>'screener',		//User To Logon as
			'Password'=>'read',	//User's Password
			'dbName'=>'ftse'				//Default Database
			);

// Concatenate Show Checkboxes with commas

if (!$selec){
	for( $i = 0; $i < sizeof( $show ); $i++ ){
		$selec .= "," . $show[$i];
		}
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

$sql = "SELECT $selection FROM current WHERE $searchname $PEg $PEl $pPEg $pPEl $Capg $Capl $yieldg $yieldl $divcoverg $divcoverl $g1g $g1l $g2g $g2l $PEGg $PEGl $geg $gel $PTBVg $PTBVl $PBVg $PBVl ORDER BY `$order`";

echo $sql;



	/////////////////////////////
	//The Customizable Table Formatting information
	
	if (!isset($tblFormat))
		$tblFormat=array(
			'header'=>'',			//An Optional header for the table
			'footer'=>'',			//An Optional footer for the table
			'headingBegin'=>'<TH vAlign=top align=center bgColor=silver>', //Column heading format prefix
			'headingEnd'=>'</TH>',	//Column heading format suffix
			'tblBegin'=>'<TABLE borderColor=gray cellSpacing=0 cellPadding=5 border=1>', //Table Format prefix
			'tblEnd'=>'</TABLE>',	//Table Format suffix
			'rowBegin'=>'<TR>',		//Row Format prefix
			'rowEnd'=>'</TR>',		//Row Format suffix
			'colBegin'=>'<TD vAlign=top align=center bgcolor=#eeeeee>', //Column format prefix
			'colEnd'=>'</TD>',		//Column Format suffix
			'nextCode'=>'Next',		//HTML inside the "Next Page" Link (for paging)
			'prevCode'=>'Prev',		//HTML inside the "Prev Page" Link (for paging)
			'ascendCode'=>'<IMG SRC="up.gif" WIDTH="15" HEIGHT="15" BORDER="0" ALT="Ascend">',	//HTML inside the "Ascend" Link for column sorting (can be IMG tag)
			'descendCode'=>'<IMG SRC="down.gif" WIDTH="15" HEIGHT="15" BORDER="0" ALT="Descend">'//HTML inside the "Descend" Link for column sorting (can be IMG tag)
			);
	
	$tblFormat['colFormat']=array(
			  'Cap'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#D7D7D7>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
			);
		
		
	
	
	////////////////////////////
	//The Specifics of the underlying SQL query	
	if (!isset($tblQuery))
		$tblQuery=array(
			'columns'=>"hsid,$selection",
			'selec'=>"$selec",		//The columns to be selected
			'tblName'=>'current',		//The table to select from
			'where'=>"WHERE $searchname $PEg $PEl $pPEg $pPEl $Capg $Capl $yieldg $yieldl $divcoverg $divcoverl $g1g $g1l $g2g $g2l $PEGg $PEGl $geg $gel $PTBVg $PTBVl $PBVg $PBVl",		//Conditional selection parameter
			'orderBy'=>"$order",		//Row ordering
			'orderDir'=>'ASC',	//Row ordering direction
			'viewStart'=>0,		//Index of first record to show in the view table
			'viewSize'=>"$rows",		//The maximum number of records allowed in the view table
			);

if (isset($orderBy))
			$tblQuery['orderBy']=$orderBy;		//The column to orderBy
if (isset($viewStart))
			$tblQuery['viewStart']=$viewStart;  //The starting offset for record paging
if (isset($orderDir))
			$tblQuery['orderDir']=$orderDir;    //Whether to sort ascending or descending ('ASC' or 'DESC')
		



	echoTable($tblFormat, $tblQuery, $dbData);

	///////////////////////////////
	//Purpose: to Echo a table's data
	// Inputs:	$tblFormat:	The associative array of table formatting information
	//						as described above.
	//			$tblQuery:	An associative array of the SQL query specifics driving this table
	//						as described above.
	//			$dbData:	An associative array of the Database connection information
	//						as described above.
	// Usage: Inclusion of this snippet defines the variable defaults ($tblFormat, $tblQuery, & $dbData)
	//		  Manipulate these data items and then pass them to this function.
	//Outputs: NONE		
	function echoTable( $tblFormat, $tblQuery, $dbData)
	{
	
		//Verify Parameters
		//////////////////////
		
		//orderDir
		if (strcasecmp($tblQuery['orderDir'], 'asc')==0 or strcasecmp($tblQuery['orderDir'], 'desc')==0)
			$tblQuery['orderDir']=mysql_escape_string($tblQuery['orderDir']);
		else
		{
			echo "<B>Error:</B> \"orderDir\" parameter must be either ASC or DESC";
			return;
		}
		//orderBy
		$tblQuery['orderBy']=mysql_escape_string($tblQuery['orderBy']);
	
		//viewStart
		if (is_numeric($tblQuery['viewStart']))
			$tblQuery['viewStart']=intval(mysql_escape_string($tblQuery['viewStart']));
		else
		{
			echo "<B>Error:</B> \"viewStart\" parameter must be an integer value";
			return;
		}
	
	
		if (!$link=mysql_connect ($dbData['Host'], $dbData['UserName'], $dbData['Password']))
		{
				echo "Could not connect to \"".$dbData['Host']."\"\n";
				return;
		}
	
		if (!mysql_select_db($dbData['dbName']))
		{
				echo "Could not select \"".$dbData['dbName']."\" as Database.\n";
				return;
		}
		
			
		$endIndex = $tblQuery['viewStart']+$tblQuery['viewSize'];
		
		$sSQL='SELECT '.$tblQuery['columns'].' FROM '.$tblQuery['tblName'].' '
			.$tblQuery['where'];
		
		if (!$result=mysql_query($sSQL))
		{
				echo "<B>Error:</B><BR>Could Not \"$sSQL\".\n";
				return;
		}				
		$rowCount = mysql_num_rows($result);
		if (isset($tblQuery['orderBy']) and strlen($tblQuery['orderBy'])>0)
		{
			//$fields = mysql_list_fields($dbData['dbName'], $tblQuery['tblName'], $link);
			$fcount = mysql_num_fields($result);
			$valid = false;
			
			for ($i=0;$i<$fcount;$i++)
			{
					if (strcmp(mysql_field_name($result, $i) , $tblQuery['orderBy'])==0)
					{
						$valid = true;
						break;
					}
			}
					
			if (!$valid)
			{
				echo "<B>Error:</B>\"orderBy\" parameter must be a valid Column in this table";
				return;
			}
			$orderBy='ORDER BY '.$tblQuery['orderBy'].' '.$tblQuery['orderDir'];
		}
		else
			$orderBy='';
		
		
		
		mysql_free_result($result);
		
		
		$sSQL='SELECT '.$tblQuery['columns'].' FROM '.$tblQuery['tblName'].' '
			.$tblQuery['where'].' '.$orderBy.' '
			.' LIMIT '.$tblQuery['viewStart'].', '.$tblQuery['viewSize'];	
		
		if (!$result=mysql_query($sSQL))
		{
				echo "<B>Error:</B><BR>Could Not \"$sSQL\".\n";
				return;
		}
		
		
		
		
				
		echo $tblFormat['header'];
		echo $tblFormat['tblBegin'];
		if (mysql_num_rows($result)==0)	
			echo $tblFormat['rowBegin'].$tblFormat['colBegin'].'Empty Table'.$tbl['colEnd'].$tbl['rowEnd']."\n";
		else
			echoRows($result, $tblFormat, $tblQuery);
		echo $tblFormat['tblEnd']."\n";
		echo $tblFormat['footer']."\n";
		if ($tblQuery['viewStart']>0)
		{
			
			$prevIndex=$tblQuery['viewStart']-$tblQuery['viewSize'];
			$URL = buildURL($tblQuery, 'viewStart', $prevIndex);
			$prev = "<A HREF=\"$URL\">{$tblFormat['prevCode']}</A>";
		}
		else
		{
			$prev = '';
		}
		if ($endIndex<$rowCount)
		{
			$nextIndex=$tblQuery['viewStart']+$tblQuery['viewSize'];
			$URL = buildURL($tblQuery, 'viewStart', $nextIndex);
			$next = "<A HREF=\"$URL\">{$tblFormat['nextCode']}</A>";
		}
		else
		{
			$endIndex=$rowCount;
			$next = '';
		}
		
		echo "<SMALL>$prev ({$tblQuery['viewStart']}-{$endIndex}) of $rowCount $next</SMALL>";
		mysql_free_result($result);
		mysql_close ($link);
		
	}
	
	//////////////////////////
	//Purpose: Keep track of current SQL query options
	//		   And build a self-referring URL with one additional
	//		   option change.
	//  Input: $tblQ(uery): The Table's SQL Query information as it is
	//						currently and is defined above
	//		   $changeIndex: The associative array "index" of the item that would
	//						 be changed by this link.
	//		   $value:	The new value of the item to be changed by this link.
	// Output: A string version of the new URL, complete with parameters			
	//			"myscript.php?orderBy=Name&viewStart=20" For example
	function buildURL($tblQ, $changeIndex, $value)
	{
		$tblQuery = $tblQ;
		$tblQuery[$changeIndex]=$value;
		$URL = $SCRIPT_NAME;
		if ($tblQuery['orderBy']!='')
		{
			$params .= "&selec={$tblQuery['selec']}&orderBy={$tblQuery['orderBy']}&rows={$tblQuery['viewSize']}";
		}
		if (isset($tblQuery['viewStart']))
		{
			$params .= "&selec={$tblQuery['selec']}&viewStart={$tblQuery['viewStart']}&rows={$tblQuery['viewSize']}";
		}
		if ($tblQuery['orderDir']!='')
		{
			$params .= "&selec={$tblQuery['selec']}&orderDir={$tblQuery['orderDir']}&rows={$tblQuery['viewSize']}";
		}
		if (isset($params))
			$URL .= '?'.$params;
		return $URL;
	}
	
	///////////////////
	//Purpose: To take a result set from an SQL query and iterate 
	//		   Field information and data into a query
	function echoRows($result, $tblFormat, $tblQuery)
	{
		$rows=mysql_fetch_array($result);
		$colCount = mysql_num_fields ($result);
		$rowCount = mysql_num_rows ($result);
		$i = 1;
		if (strlen($tblQuery['orderBy'])>0)
		{
			if (strcmp($tblQuery['orderDir'],'ASC')==0)
			{
				$orderDirURL = buildURL($tblQuery, 'orderDir', 'DESC');
				$orderLink = "<A HREF=\"$orderDirURL\">{$tblFormat['descendCode']}</A>";
			}
			else if (strcmp($tblQuery['orderDir'],'DESC')==0)
			{
				$orderDirURL = buildURL($tblQuery, 'orderDir', 'ASC');
				$orderLink = "<A HREF=\"$orderDirURL\">{$tblFormat['ascendCode']}</A>";
			}
		}
			
		while ($i < $colCount) 
		{
			$fname = mysql_field_name ($result, $i);
			$URL = buildURL($tblQuery, 'orderBy', $fname);
			
			
			echo $tblFormat['headingBegin'];
			if (strcmp($fname, $tblQuery['orderBy'])==0)
				echo "$orderLink&nbsp";
			echo "<A HREF=\"$URL\">$fname</A>".$tblFormat['headingEnd']."\n";
			$i++;
	    }
	    mysql_data_seek($result,0);
	    while($row = mysql_fetch_row($result))
	    {
			echo $tblFormat['rowBegin'];
			for ($i=1;$i<$colCount;$i++)
			{
				$fname = mysql_field_name ($result, $i);
				$colFormatBegin = '';
				$colFormatEnd = '';
				$colBegin = $tblFormat['colBegin'];
				$colEnd = $tblFormat['colEnd'];
				$data = $row[$i];
				$hsid = $row[0];
				$ep = $row[1];
				if ($fname == "Name"){
					$tblFormat['colFormat']=array(
								'Name'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>"<TD ALIGN=left><a href='oonpad.php?epic=$ep&hsid=$hsid'>", //override the default column formatting prefix
			  					'colEnd'=>'</a></TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
				if ($fname == "Cap"){
				$tblFormat['colFormat']=array(
								'Cap'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#FFCC66>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
				if ($fname == "PE"){
				$tblFormat['colFormat']=array(
								'PE'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#82a97C>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
				if ($fname == "ProsPE"){
				$tblFormat['colFormat']=array(
								'ProsPE'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#82a97C>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
				if ($fname == "yield"){
				$tblFormat['colFormat']=array(
								'yield'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#FFFFCC>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
				if ($fname == "DividendCover"){
				$tblFormat['colFormat']=array(
								'DividendCover'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#FFFFCC>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
				if ($fname == "PEG"){
				$tblFormat['colFormat']=array(
								'PEG'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#A0DEA4>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
				if ($fname == "Gearing"){
				$tblFormat['colFormat']=array(
								'Gearing'=>array( //The name of the column is case-sensitive	
			  					'formatBegin'=>'',		   //prefix formatting inside column
			  					'formatEnd'=>'',		   //sufffix formatting inside column
			  					'colBegin'=>'<TD ALIGN=right bgcolor=#bb6666>', //override the default column formatting prefix
			  					'colEnd'=>'</TD>',			   //override the default column formatting suffix
			  					'callback'=>'strrev'		   //output data after being processed by the named function.		
			  				)
					);
				}
										
				if (isset($tblFormat['colFormat'])&& isset($tblFormat['colFormat'][$fname]))
				{
					if (isset($tblFormat['colFormat'][$fname]['formatBegin']))
						$colFormatBegin = $tblFormat['colFormat'][$fname]['formatBegin'];
				
					if (isset($tblFormat['colFormat'][$fname]['formatEnd']))
						$colFormatEnd = $tblFormat['colFormat'][$fname]['formatEnd'];
						
					if (isset($tblFormat['colFormat'][$fname]['colBegin']))
						$colBegin = $tblFormat['colFormat'][$fname]['colBegin'];
				
					if (isset($tblFormat['colFormat'][$fname]['colEnd']))
						$colEnd = $tblFormat['colFormat'][$fname]['colEnd'];	
						
					if (isset($tblFormat['colFormat'][$fname]['callBack']))
					{
						$callback=$tblFormat['colFormat'][$fname]['callBack'];
						$data = $callback($data);
					}
				}
				echo $colBegin.$colFormatBegin.$data.$colFormatEnd.$colEnd;
			}
			echo $tblFormat['rowEnd'];
	    }
	    $rows=mysql_fetch_array($result);
	}

	
	
	
	
	

?>
</body>
</html>
