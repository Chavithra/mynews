dictionary=""

for params in "$@"
do
    dictionary+=$params"+"
done

echo ${dictionary:0:-1} > dico
