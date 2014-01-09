fetchUrls()
{
    dictionary=$(<dico)

    url="http://www.lemonde.fr/recherche/?keywords="
    url+=$dictionary
    url+="&page_num=1&operator=or&exclude_keywords=&qt=recherche_texte_titre&author=&period=for_1_week&start_day=01&start_month=01&start_year=1944&end_day=20&end_month=12&end_year=2013&sort=desc"

    wget $url -O  site.html

    grep "grid_3 alpha obf" site.html | awk -F "\"" '/grid_3 alpha obf/ {print"http://www.lemonde.fr"$2}' > urls;
};

fetchArticles()
{
#    echo "<html><head><title>Articles</title></head><body>" > articles;

    for url in $(cat urls)
    do
       curl $url > article.html
       awk '/<article class=\"article article_normal\"/,/<\/article>/' article.html >> articles;
    done

    echo "</body></html>" >> articles;
};

sendArticles()
{
    mail=$(<config_email)

    echo "On est en train d'envoyer l'email à l'adresse $mail"

    html=$(<articles)

    (
        echo "To: $mail"
        echo "Subject: Articles"
        echo "Content-Type: text/html"
        echo $html;
    ) | /usr/sbin/sendmail -t
};

fetchUrls
fetchArticles
sendArticles

