<!doctype html public "-//W3C//DTD HTML 4.0 //EN"> 
<html>
<body bgcolor="#D8FfF0">
<?php 
$epicu = strtoupper($epic);
$epic = strtolower($epic);
echo "<a href='http://mwprices.ft.com/custom/ft-com/interactivecharting.asp?pageNum=&company=NEW&industry=&region=&extelID=&isin=&ftep=&sedol=0166333&FTSite=FTCOM&symb=$epic&countrycode=uk&q=$epic&t=e&s2=uk&osymb=cto&ocountrycode=uk&expanded=true&subtab=1&colMode=&time=1yr&freq=1dy&chartsize=3&compidx=aaaaa%3A0&indName=aaaaa%7E0&ma=0&maval=9&type=2&comp1=&comp2=&comp3=&uf=0&lf=1&lf2=16777216&lf3=2' target='_blank'>FT MarketWatch Chart</a><br>";
echo "<a href='http://www.hemscott.com/equities/company/cd$hsid.htm' target='_blank'>Hemscott</a><br>";
echo "<a href='http://focus.comdirect.co.uk/en/detail/_pages/quotes/main.html?sSymbol=$epicu.ISE&sRange=3' target='_blank'>Comdirect</a><br>";
echo "<a href='http://www.ukwire.co.uk/cgi-bin/index?search_type=3&words=$epic' target='_blank'>UKWire</a><br>";
echo "<a href='http://www.multexinvestor.co.uk/research/Earnings.asp?ticker=$epicu.L&country=GB' target='_blank'>Multex Investor</a><br>";
?>
</body>
</html>
