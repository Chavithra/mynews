ft()
{
    echo "<html><head><title>Articles</title></head><body>" > articles

    for url in $(cat urls)
    do
       curl $url > article.html
       awk '/<article class=\"article article_normal\"/,/<\/article>/' article.html >> articles
    done

    echo "</body></html>" >> articles
}

ft

