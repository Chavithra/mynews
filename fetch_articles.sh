echo "<html><head><title>Articles</title></head><body>" > articles

for url in $(cat urls)
do
    awk '/<article class=\"article article_normal\"/,/<\/article>/' test.html >> articles
done

echo "</body></html>" >> articles
