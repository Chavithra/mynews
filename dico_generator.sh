#dictionary=""

#for params in "$@"
#do
#    dictionary+=$params"+"
#done

read -p "Veuillez saisir vos filtres séparés par des signe \"+\" : " dictionary

echo ${dictionary:0:-1}
