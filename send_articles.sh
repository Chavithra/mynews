html=$(<articles)

(
    echo "To: chavithra@gmail.com"
    echo "Subject: Articles"
    echo "Content-Type: text/html"
    echo $html;
) | /usr/sbin/sendmail -t
