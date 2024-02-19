#create the temporary files that will be used for replacments
touch temp.txt
truncate -s 0 temp.txt 
touch temp1.txt
truncate -s 0 temp1.txt
touch temp2.txt 
truncate -s 0 temp2.txt
touch temp4.txt
truncate -s 0 temp4.txt 
printf "\n Welcome Back to your Dectionary tool !\n\n"
printf "does dectionary.txt file is exist or not ?\n\n"
printf "if it is exist write yes/YES.\n"
printf "if it is not exitst write no/NO.\n"
read ans
if [ "$ans" = "yes" -o "$ans" = "YES"  ]
#if the dectionary is already exist
then
echo "Enter the path of your dectionary" 
read path 
# now check if the dectionary is realy exist or not
if [ -e "$path"  ]; then 
dectionary=$(cat "$path") 
else  
echo "Sorry ! the dectionary is not exist." 
exit 1
fi
elif [ "$ans" = "no" -o  "$ans" = "NO" ] 
then 
touch new.txt 
path="$new.txt" 
truncate -s 0 new.txt
pico "$path" 
else 
# in case of neither yes nor no in the dectionary question
echo "unrecognized input !!!!" 
exit 2 
fi
echo "Do you want to ?"
printf "1. Compress (c/C) a file.\n "
printf "2. Decompress (d/D) a file.\n "
read choice 
# standarize the choice to compare it
choice=$(echo "$choice"|tr '[A-Z]' '[a-z]') 
if [ "$choice" = "compress" -o "$choice" = "c" ]
then
echo "enter the path of the file to be compressed"
read path_2 
# now we will replace each . or , or ? with space 
sed 's/\./ FULLSTOP /g' "$path_2" > temp.txt 
sed 's/ / SPACE /g' temp.txt > temp1.txt
sed 's/,/ COMMA /g' temp1.txt >temp2.txt 
sed ':a;N;$!ba;s/\n/ \\n /g' temp2.txt > temp4.txt 
# the end of replacing to spaces 
paragraph=$(cat temp4.txt)
touch compressed.txt
truncate -s 0 compressed.txt
echo "$paragraph" | while d=' ' read -ra  word; do
for word in "${word[@]}"; do
# now we are searching for each word 
line=$(grep "\<$word\>" "$path" )
if [ -n "$line"  ] ; then
code=$(echo "$line" | cut -d" " -f1)
# write the result on the compressed file
echo "$code" >> compressed.txt
else  
# if the code is not exist in the dectionary so we will add it  
# increment process
lastCode=$( tail -n 1 "$path" )
lastCode=$( echo "$lastCode" | cut -d" " -f1 ) 
# now we want to convert the last code to decimal then add one 
newCode=$(printf "%d\n" "$lastCode" 2>/dev/null)
newCode=$((newCode + 1))
# convert the decimal newCode to hexa 
newCode=$(printf "0X%04X\n" "$newCode" 2>/dev/null )
echo "$newCode $word" >> "$path"
echo "$newCode" >> compressed.txt  
fi
done
done 
elif [ "$choice" = "decompress" -o "$choice" = "d" ]
# the decompression process
then 
echo "Enter the path of the file to be decompressed:"
read input_file 
# load the compressed file into variable para2
para2=$(cat "$input_file") 
res_para=""
touch decompressed.txt 
truncate -s 0 decompressed.txt
echo "$para2" | while d=' ' read -ra  word2; do
for word in "${word2[@]}"; do
# now we are searching for each word 
line=$(grep "\<$word\>" "$path" ) 
# concatenate the result paragraph according to the suitable coressponding 
if [ -n "$line"  ] ; then
result=$(echo "$line" | cut -d" " -f2) 
if [ $result = "SPACE" ]; then  
echo "" >> decompressed.txt
s=" " 
res_para="$res_para$s"
elif [ $result = "FULLSTOP" ]; then
f="." 
res_para="$res_para$f"
echo "." >> decompressed.txt 
elif [ $result = "COMMA" ]; then
c=","
res_para="$res_para$c" 
echo "," >> decompressed.txt 
elif [ $result = "\\n"  ]; then
n=""
res_para="${res_para}${n}" 
echo "" >> decompressed.txt   
else 
echo $result >> decompressed.txt  
res_para="$res_para$result" 
fi

else 
echo "The word $result doesnt have a code"
fi
done 
touch final.txt
truncate -s 0 final.txt
echo "$res_para" >> final.txt
done 
  
else 
echo "Your choice is invalid !"
exit 3
fi 
# Read data from final.txt file to add the new lines 
touch finalResult.txt
truncate -s 0 finalResult.txt
data=$(cat final.txt)
echo "$data" | awk -F'\. ' '{for(i=1;i<=NF;i++) print $i "."}' > finalResult.txt
  
# calculate the compression ratio 
para1=$(cat temp4.txt) 
echo "$para1"
c1=$(echo $para1 | wc -c) 
para2=$(cat compressed.txt)
c2=$(echo $para2 | wc -c)
uncomp=$(($c1 * 16 )) # the size of the uncompressed file
comp=$(($c2 * 16))  # the size of the compressed file 
compRatio=$(echo "scale=2; $uncomp / $comp" |bc)
printf "the compression Ratio : $compRatio"  
