#MIPS 2 Assignment Jarrett Cunningham


.data #lets processor know that we will be submitting data to program

userinput: .space 1001 #Need space for a 1000 digit hex

invalid: .asciiz "NaN"

useroutput: .asciiz " "

nextline: .asciiz "\n"

comma: .asciiz ","

sizemess: .asciiz "too large"

space: .asciiz "space"
space2: .asciiz "space2"

.text

main: 

#storing user input

    li $v0, 8 #op code for getting user input for a string

	la $a0, userinput #loads the address of space and stores it into $a0

	la $a1, 1001 #SPACE OF STRING

	syscall 	


jal subprogram_2 #Function call to actually convert the integer
jal subprogram_3 #function to print

exit: 

	li $v0, 10 #loads op code exit program

	syscall #exits program

#END OF MAIN

#FUNCTIONS USED IN THE MAIN FUNCTION

####################SUBPROGRAM2 TO GET WHOLE STRING AND CONVERT TO DECIMAL#################################

 subprogram_2: #loop for conversion
 move $s4,$a0 #address of the first bit of the substring
 jal getlength
move $t5,$t2 #length is in $t5
li $t2,0
li $s6,0
li $s3,0
sub $t5,$t5,$t8 #length of the string is the length minus the amount of spaces in the string
li $t8,0
move $a0,$s4


startprog2:

	
	lb $t1,0($a0) #start searching each byte
	beq $t1,0,commafunct #exit program completely
	beq $t1,10,exitnprint #exit the program completely
	beq $t1,44,commafunct #once the program hits a comma it will drop into the comma function, print the value, re initialize the variables and send it back to the top of sub prog 2
	beq $t1,32,Space
	addi $a0,$a0,1 #move to the next byte
	sub $t5,$t5,1 #incrementing the length - 1
	jal subprogram_1
	move $s5,$t3
	j startprog2
	
	exitnprint: #if we are at the end of the string
	move $t3,$s5
	move $s6,$t7
        bgt $s6,7,negnum #accounts for 2s complement of a big number at the end of a string
        beq $t3,0,nullend #if after the comma there is a null character
        move $a0, $t3 
        li $v0,1      
        syscall
        j exit
  
#################Dealing with commas########################################
#If the function encounters a comma it will save the address, print out the value thats currently stored, print a comma, then reset for the next set of numbers

	commafunct:
	move $s3,$t3 #save the overall value
	move $s4, $a0 #Address that the program left off from (the comma) will be loaded back into the a0 and then jump to the top of the subprogram 2 to redo the loop
	
	#Checking if there is a null character within the string
	sub $a0,$a0,1 #points to the character before the comma seperator
	lb $t1,0($a0)#loads it
	beq $t1,0,exitnull#if its the beginning of the string branch to exitnull
	beq $t1,44,exitnull#if its another comma branch to the exit null
	jal subprogram_3 #else send the value into subprogram_3
	
	#initializes variables for next substring
	li $t0,0 
	li $t2,0
	li $t3,0 
	li $t4,0 
	
	
	move $a0,$s4 #moving the original address back into play (which is currently on a comma)
	addi $a0,$a0,1 #takes the register off of the comma and gears it up for the next loop
	j subprogram_2
   


#############################SUBPROGRAM1 TO CONVERT EACH LETTER INTO DECIMAL#################################

subprogram_1:

	#Checking if the byte falls into the ranges then will send byte to designated loop
	beq $t1,32, Space
	beq $t1,9, Space
	blt $t1,48, Invalid 
	blt $t1,58, Decimal
	blt $t1,65, Invalid
	blt $t1,71, Uppercase
	blt $t1,97, Invalid
	blt $t1,103, Lowercase
	bgt $t1,102, Invalid
	 
	Space:#dealing with spaces around characters 

	move $s5,$a0 #saving the original address of the substring pointing to the comma at the end
	move $a0,$s4 #the address points to the beginning of the string
	lb $t1,0($a0) #loading the byte before the space
	beq $t1,32,space_1#if the byte before the space is a comma go to space_1
	
	#if the space isnt in the begining go check the end of the string
	move $t7,$s6 #move the overall length into t7
	add $a0,$a0,$t7 #see if there is a space at the end of the string before the comma
	lb $t1,0($a0) #checks the end of the string for a space
	beq $t1,32,space_2
	
	#if neither is found and the function has to continue then the space has to be in the middle of the string so.. Invalid
	bgt $t1,32,invalidspace
	invalidspace:
	move $a0,$s5
	j Invalid

	space_1: #if there is a space before the substring
	move $a0,$s5
	addi $a0,$a0,1
	j startprog2
	
	space_2:#if there is a space behind the integer
	 move $a0,$s5 #point the address to comma (the end)
	 addi $a0,$a0, 1 #increment from there and continue the program	 
	 j startprog2 
	

	Decimal:

	sub $t1,$t1,48 #subtract 48 to get the decimal number of the byte being checked $t1 is ripped char
	sll $t4,$t5,2 #shifting for the exponent value
	sllv $t2,$t1,$t4 #Finding the actual value of the Hex number
	add $t3,$t3,$t2 #overall num is overall num plus value found in this loop
	jr $ra

	
	Uppercase:

	sub $t1,$t1,55 #subtract 55 to get the decimal number of the byte being checked
	sll $t4,$t5,2 #shifting for the exponent value
	sllv $t2,$t1,$t4 #Finding the actual value of the Hex number
	add $t3,$t3,$t2 #overall num = overall num plus value found in this loop
	jr $ra

	Lowercase:

	sub $t1,$t1,97 #subtract 87 to get the decimal number of the byte being checked
	addi $t1, $t1, 10 #Add 10 for value
	sll $t4,$t5,2 #shifting for the exponent value
	sllv $t2,$t1,$t4 #Finding the actual value of the Hex number
	add $t3,$t3,$t2 #overall num = overall num plus value found in this loop
	jr $ra
	
	Invalid: #print invalid message and exit the loop
	
	li $t3,0 #make the overall value zero
	move $s5,$a0 #save address at this point
 	la $a0, invalid #print NaN
	li $v0, 4 #opcode to print a string
	syscall
	la $a0,comma #print comma
        li $v0,4
        syscall
        move $a0,$s5 #move the address of the character back into play
        
        #goes through string until it finds next comma
        loop:#used for skipping the rest of the characters because the substring is invalid anyway
        lb $t1,0($a0) #loads byte for checking
        beq $t1,44,exitloop #if it found the next comma
        beq $t1,10,exit #if it reached the end of the users input, exit
	addi $a0,$a0,1
	j loop
	exitloop:
	li $t5,0#initialize t5 and t2 for the next substring
	li $t2,0
	addi $a0,$a0,1 #when it comes out $a0 will point to the register of the comma,so we add one to it so it can go to the next string
	j subprogram_2


######################################SUBPROGRAM_3: PRINTING OUT VALUE#####################################################################################

subprogram_3:#printing overall value
	 move $a0,$s3
	 li $v0,1
	 syscall	 
	 la $a0,comma	 
	 li $v0,4	
	 syscall	 
	 jr $ra
	 
########################################Finding Length of String##########################################

getlength:

lb $t0,0($a0)

beq $t0,0,exit

beq $t0,44,exitgetlength #if there is a comma 

beq $t0,10,exitgetlength# if its at the end exit out

addi $a0, $a0, 1 #increment to the next byte

addi $t2,$t2, 1 #increment length of substring
 
beq $t0,9, spacelen #if theres a tab

beq $t0,32, spacelen #if theres a space

addi $t7,$t7,1 #keeping an overall length
move $s6,$t7 #this will be later used for if there is a 2s complement problem
j getlength

spacelen:
 addi $t8,$t8,1 #counts the amount of spaces
 j getlength
 
exitgetlength: #t2 has the length of the string
bgt $t2,8,printlarge
jr $ra

printlarge:
move $s5,$a0 #store the address value
la $a0,sizemess
li $v0,4
syscall

la $a0,comma
li $v0,4
syscall

li $t2,0
move $a0,$s5
addi $a0,$a0,1
j subprogram_2


##########################################################################################################
	 	 
###################################Dealing with Null spaces within or around input string#######################
       #if a substring is null or if the beginning of the user inputstring is null
         exitnull:
        la $a0,invalid #loads and prints invalid message
        li $v0,4
        syscall
        la $a0,comma #loads and prints comma message
        li $v0,4
        syscall
        
        #initializes variables for next substring
        li $t0,0
	li $t2,0
	li $t3,0 
	li $t4,0
	#moves the address back to the next substring and starts subprogram_2
        move $a0,$s4
        addi $a0,$a0,1
        j subprogram_2
        
        #if the end of the string is a null (a,)
        nullend:
        la $a0, invalid #print length premessage
	li $v0, 4 #opcode to print a string
	syscall
	j exit
	

	 
####################################Accounting for 2 complement########################################################################
negnumcom:#accounting for negative number with a comma next to it

#divides the value by a multiple of 10 to get real value of user input
	li $t7,10000
	move $t6,$t3
	divu $t6,$t6,$t7
#prints decimal output of 2s complement
	mflo $t7
	move $a0,$t7
	li $v0,1
	syscall
	mfhi $t7
	move $a0,$t7
	li $v0,1
	syscall
#prints comma
	la $a0,comma 
	 li $v0,4
	 syscall
#initializes variables for next substring
	li $t0,0
	li $t2,0
	li $t3,0 
	li $t4,0
	li $t6,0
#moves address back into play to go to next substring
	move $a0,$s4
	addi $a0,$a0,1 #loads next substring
	j subprogram_2 #goes back to subprog_2

#same exact function as above just if there isnt a comma at the end
	negnum:
	li $t7,10000
	move $t6,$t3
	divu $t6,$t6,$t7
	
	mflo $t7
	move $a0,$t7
	li $v0,1
	syscall
	
	mfhi $t7
	move $a0,$t7
	li $v0,1
	syscall

	j exit
#########################################################################################################################