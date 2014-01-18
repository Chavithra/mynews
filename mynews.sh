# Allow the user to configure his email address
# Input : user
# Output : file "config_email"
chooseEmail()
{
    # Display the msg and read the answer of the user
    read -p "Veuillez saisir votre adresse email : " email

    # Save the email written by the user
    echo $email >  config_email
}


# Allow the user to configure his dictionary
# Input : user
# Output : file "config_dico"
chooseDictionary()
{
    read -p "Veuillez saisir vos mots clés séparés par des signes \"+\" : " dictionary

    echo $dictionary > config_dico
}


# Allow the user to configure the crontab
askCrontab()
{
   # Back up the crontab
   crontab -l > mycron
   
   read -p "Veuillez configurer la crontab : " cron

   echo "$cron cd $PWD/; sh $PWD/bot.sh -o=launch" > mycron
    
   # Install the new crontab
   crontab mycron
   
   echo "Bravo ! Votre configuration est sauvegardée :-) "
}


# Fetch urls of articles according to the dictionary
fetchUrls()
{
    # Retrieve "config_dico" in the variable dictionary
    dictionary=$(<config_dico)
    
    # Store the url of the research with the dictionary
    url="http://www.lemonde.fr/recherche/?keywords="
    url+=$dictionary
    url+="&page_num=1&operator=or&exclude_keywords=&qt=recherche_texte_titre&author=&period=for_1_week&start_day=01&start_month=01&start_year=1944&end_day=20&end_month=12&end_year=2013&sort=desc"

    # Store the source code of url in "site.html"
    wget $url -O  site.html

    # Extract the urls of each link of the research (in "urls" )
    grep "grid_3 alpha obf" site.html | awk -F "\"" '/grid_3 alpha obf/ {print"http://www.lemonde.fr"$2}' > urls;
};


# Fetch the contains of the articles
fetchArticles()
{
    echo "<html><head><title>Articles</title></head><body>" > articles;

    # Store the source code of each article at the end of the files "articles"
    for url in $(cat urls)
    do
       curl $url > article.html
       awk '/<article class=\"article article_normal\"/,/<\/article>/' article.html >> articles;
    done

    echo "</body></html>" >> articles;
};


# Send the articles
sendArticles()
{
    # Retrieve the email of the user in "mail" 
    mail=$(<config_email)

    echo "On est en train d'envoyer l'email à l'adresse $mail"

    html=$(<articles)

    # Configuration of the recipient, the subject and the content
    (
        echo "To: $mail"
        echo "Subject: [myNews] Articles"
        echo "Content-Type: text/html"
        echo $html;
    ) | /usr/sbin/sendmail -t
};


# Retrieve the value of the option "o" or "operation" of the program in the variable "operation"
for param in "$@"
do
    option=${param%%=*}
    value=${param##*=}

    case $option in
        -o | --operation)       operation=$value;
    esac
done


# Matching on the variable "operation"
# The variable hasn't been defined
if [ "$operation" == "" ]; then
    echo "Please choose an operation typing : sh $0 -o=my_operation"
fi

# The value is "config" : the programm launchs the 3 functions
if [ "$operation" == "config" ]; then
    chooseEmail
    chooseDictionary
    askCrontab
fi

# The value is "launch" : the programm launchs the 3 functions
if [ "$operation" == "launch" ]; then
    fetchUrls
    fetchArticles
    sendArticles
fi
