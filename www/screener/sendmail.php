<HTML>

<body bgcolor="#D8FfF0">

<?php  
$email = "Sender Name:\t$name\nSender E- Mail:\t$thereemail\nMessage:\t$message\nIP:\t$RE
MOTE_ADDR\n\n"; 
$to = "You@mail.com"; 
$subject = "Site Message"; 
$mailheaders = "From: $thereemail <> \n"; 
$mailheaders .= "Reply-To: $thereemail\n\n"; 
mail($to, $subject, $email, $mailheaders); 
echo "Thank you for your feedback...<A HREF='index.html'>Return</A>"; 
 
?> 
</body>
</html>
