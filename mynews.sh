# Allow the user to configure his email address
# Input : user
# Output : file "config/email.conf"
chooseEmail()
{
    # Create "config" folder if it doesn't exist
    mkdir -p config
    
    # Display the msg and read the answer of the user
    read -p "Veuillez saisir votre adresse email : " email

    # Save the email written by the user
    echo $email > "config/email.conf"
}

# Allow the user to configure his dictionary
# Input : user
# Output : file "config/dictionary.conf"
chooseDictionary()
{
    read -p "Veuillez saisir vos mots clés séparés par des signes \"+\" : " dictionary

    echo $dictionary > "config/dictionary.conf"
}

# Allow the user to configure the crontab
askCrontab()
{
   # Back up the crontab
   crontab -l > mycron.tmp
   
   read -p "Veuillez configurer la crontab : " cron

   echo "$cron cd $PWD/; sh $PWD/mynews.sh -o=launch" >> mycron.tmp
    
   # Install the new crontab
   crontab mycron.tmp
   
   echo "Bravo ! Votre configuration a été sauvegardée :-) "
}

# Fetch urls of articles according to the dictionary
fetchUrls()
{
    # Retrieve "config/dictionary.conf" in the variable dictionary
    dictionary=$(<"config/dictionary.conf")
    
    # Store the url of the research with the dictionary
    url="http://www.lemonde.fr/recherche/?keywords="
    url+=$dictionary
    url+="&page_num=1&operator=or&exclude_keywords=&qt=recherche_texte_titre&author=&period=for_1_week&start_day=01&start_month=01&start_year=1944&end_day=20&end_month=12&end_year=2013&sort=desc"

    # Store the source code of url in "site.html"
    wget $url -O  site.html.tmp

    # Extract the urls of each link of the research (in "urls" )
    grep "grid_3 alpha obf" site.html.tmp | awk -F "\"" '/grid_3 alpha obf/ {print"http://www.lemonde.fr"$2}' > urls.tmp;
};

# Fetch the contains of the articles
fetchArticles()
{
    echo "<html><head><title>Articles</title></head><body>" > articles.tmp;

    # Store the source code of each article at the end of the files "articles"
    for url in $(cat urls.tmp)
    do
       curl $url > article.html.tmp
       awk '/<article class=\"article article_normal\"/,/<\/article>/' article.html.tmp >> articles.tmp;
    done

    echo "</body></html>" >> articles.tmp;
};

# Send the articles
sendArticles()
{
    # Retrieve the email of the user in "mail" 
    mail=$(<"config/email.conf")

    echo "L'email est en cours d'envoi à l'adresse $mail"

    html=$(<articles.tmp)

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
        -o | --operation | --option)       operation=$value;
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
