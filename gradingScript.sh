#!/bin/bash
declare -a inputs
inputs=(0ABcdE FFfFFffF 000000000  1234@678 , EA, pqst,  123456789, ,eA  ,pqst 
 ,234567890 
 ' ,' 
 ', '
 ' , ' 
 'EA, ' 
 'pqst, ' 
 '123456789, ' 
 ' ,eA' 
 ,pqst 
 ,234567890 
 ,, 
 ' , , ' 
 0,9 
 0,012345678 
 ' 7a3B4c6D , 12345678 ' 
 12345678,f 
 f1,+ 
 ***,F1 
 ***,%%% 
 abcde12345,12345xyz 
 '1234 abcd,12345abcd' 
 123456789,abcdefabc 
 0,9,A,a,F,f,10,1F,1f,F1,f1,EA,ea,eA,Ae,FF,ff,1234,7FFF,7fff,7ffF,FABC,FFFF,10000,12345,ABCDE,12345678,7A3B4C6D,7a3B4c6D,7FFFFFFF,87654321,8A6B7C5D,FFFFFFFF,00,00000000,000A,A000,0000A,A0000,00000ABC,4EF00000 
 '  0 , 9 , A , a , F , f , 10 , 1F , 1f , F1 , f1 , EA , ea , eA , Ae , FF , ff , 1234 , 7FFF , 7fff , 7ffF ,   FABC , FFFF , 10000 , 1  2345 ,   ABCDE   , 12345678 ,   7A3B4C6D ,   7a3B4c6D , 7FFFFFFF , 87654321 , 8A6B7C5D , FFFFFFFF , 00 , 00000000 , 000A , A000 , 0000A , A0000 , 00000ABC , 4EF00000 '
 ',  0 , 9 , A ,,, a , F , f , 10 , 1F ,,  '
 ',  0 , 9 , A ,xyz,, a , F ,1234 5678,123456789, f , 10 , 1F ,,  ')


for i in $1/* #for every file in the passed,
do
    printf  "########\n "
    echo $i #print out the name of the current file
    printf  "########\n\n" 

    #for j in ${inputs[@]};
    for ((j=0; j < ${#inputs[@]}; j++))
    do
        #echo $j | spim load $i
        #myvar=$(echo $j | spim load $i)
        #printf ${myvar##*s} \n
        myvar=$(echo "${inputs[$j]}" | spim load $i) 
        #printf "${inputs[$j]}"
        printf ${myvar##*s}
        printf '\n'
    done
done
