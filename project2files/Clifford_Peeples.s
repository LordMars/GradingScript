#MIPS 2 Programming Assignment Clifford Peeples



.data #Submits data to program

userInput: .space 9 #8 digit hexidecimal 
prompt: .asciiz "Enter string: " 
tooLarge: .asciiz "too large"
invalid: .asciiz "NaN"
useroutput: .asciiz " "
commaBreak: .asciiz ","

.text

main: 

#storing user input
        li $v0, 8 #get user input for a string
	la $a0, userInput #loads the address of space and stores it into $a0
	la $a1, 9 #gets the length of $a1 to prevent overflow
	syscall 

#Converting Userin into Decimal
  
  #Function call to pull in the length of the string
 	jal getLength
	move $t5,$a0 #length: $t5
	move $s0,$t5 #string length
	li $t0,0 #initialize i for loop
	li $t3,0 #initialize number for output
	li $t2,0
	la $a0,userInput #loading the users input
	jal subprogram2 #Function call to actually convert the integer
printval:#printing overall value
	move $a0,$s3
	li $v0,1
        syscall
exit: 
	li $v0, 10 #loads op code exit program
	syscall #exits program
	

#FUNCTIONS USED IN THE MAIN FUNCTION

##Finding Length of String##
#li $t2,0 #initialize count to zero
getLength:
        lb $t0,0($a0)
        beq $t0,0,exitgetLength
        beq $t0,10,exitgetLength
        addi $a0, $a0, 1
        addi $t2,$t2, 1
        j getLength
exitgetLength:
        move $a0, $t2 
        jr $ra
        
##Subprogram 2: Convert string to decimal number##
 subprogram2: #loop for conversion
	lb $t1,0($a0) #start searching each byte
	beq $t1,0,exitsubprogram2
	beq $t1,10,exitsubprogram2
	jal subprogram1
	addi $a0,$a0,1 #move to the next byte
	sub $t5,$t5,1 #incrementing the length - 1
	j subprogram2
	
	exitsubprogram2:
	move $s3,$t3 #save the overall value
	bgt $s0,7,negnum
	jr $ra
#Accounting for 2 compliment
	negnum:
	li $t7,10000
	move $t3,$s3
	divu $t3,$t3,$t7
	
	mflo $t7
	move $a0,$t7
	li $v0,1
	syscall
	
	mfhi $t7
	move $a0,$t7
	li $v0,1
	syscall
	
	jr $ra

##Subprogram 1: convert string to decimal number##
subprogam1:
	#Checking if the byte falls into the ranges then will send byte to designated loop
	blt $t1,48, Invalid 
	blt $t1,58, Decimal
	blt $t1,65, Invalid
	blt $t1,71, Uppercase
	blt $t1,97, Invalid
	blt $t1,103, Lowercase
	bgt $t1,102, Invalid
	
	Decimal:
	    sub $t1,$t1,48 #subtract 48 to get the decimal number of the byte being checked $t1 is ripped char
	    sll $t4,$t5,2 #shifting for the exponent value
	    sllv $t2,$t1,$t4 #Finding the actual value of the Hex number
	    add $t3,$t3,$t2 #overall num is overall num plus value found in this loop
	    jr $ra
	
	Uppercase:
	    sub $t1,$t1,55 #subtract 55 to get the decimal number of the byte being checked
	    #addi $t1, $t1, 10 #Adding 10
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
 	    la $a0, invalid #print length premessage
	    li $v0, 4 #opcode to print a string
	    syscall
	    jr $ra #Retruns to Subprogram 2

subprogram3:
	move $a0,$s3
	li $v0,1
	syscall
	la $a0,commaBreak
	li $v0,4            
	syscall
	jr $ra

	
	
