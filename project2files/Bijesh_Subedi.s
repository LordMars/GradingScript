.data
userInput: 	.space 1001
dataString:	.space 1001
naN:		.asciiz "NaN"
tooLarge:	.asciiz "too large"
.text
main:
# Program to convert coma separated hexadecimal numbers into equivalent deciaml number
	# Inputing the data from the user
	li $v0, 8		# Asking the OS to input a string
	la $a0, userInput	# Specifying where the input would be stored
	li $a1, 1001		# Specifying the max-size of the input
	syscall			# Performing the system call to input the string
	la $s0, userInput	# Saving the address of the userInput in $s0
	loop0:	la $t0, dataString		# Pointing $t0 to the beginning of dataString to start writing value
		loop1:	lb  $t3, 0($s0)		# storing the first character pointed by s0
			# Setting the conditions to exit the loop i.e. when char = newLine, endLine, coma
			beq $t3, 10, exitLoop1	
			beq $t3, 0,  exitLoop1
			beq $t3, 44, exitLoop1
			sb $t3, ($t0)		# Storing the value at $t3 into memroy address pointed by $t0
			addi $s0, $s0, 1	# $s0 now points to the next char
			addi $t0, $t0, 1	# $t0 now points to the next memory address
			j loop1			# continue looping
		exitLoop1:
		# Writing the endLine character in the dataString string.
		li $t8, 0		
		sb $t8, ($t0)
		la $a0, dataString		# Passing the intial address of dataString as parameter for subprogram_2
		jal subprogram_2		# Calling subprogram_2
		# Retreiving the values returned by the subprogram_2
		lw $a0, ($sp)
		addi $sp, $sp, 4
		lw $a1, ($sp)
		# Passing arguments for subprogram_3 using stack
		sw $a1, ($sp)
		addi $sp, $sp, -4
		sw $a0, ($sp)
		jal subprogram_3		# Calling subprogram_3
		# Setting the conditions for exiting the main loop
		beq $t3, 10, exitLoop0
		beq $t3, 0, exitLoop0
		addi $s0, $s0, 1		# $s0 now points to the next character
		# Printing the coma
		li $v0, 11
		li $a0, 44
		syscall
		j loop0				# loop continuation
	exitLoop0:	
	
	
	# Syscall to end the program
	li $v0, 10
	syscall
	
trimSpace:
# Fucntion to trim the spaces from infront and back of the input
# Takes argument in $a0
# Returns the start address of the string in $v0 and length of the string in $v1
	li $v1, 0	# the length of the string
	# Loop 1 marks the beginning of the string by getting rid of all the tabs and the spaces in front of the string
	loop2:	lb  $t7, ($a0)			# Loading the character pointed by the address at $a0
		beq $t7, 0, exitLoop2		# If the character is the end of the line character we exit the loop
		beq $t7, 10, exitLoop2
		beq $t7, 32, continueLoop2	
		beq $t7, 9, continueLoop2
		j   exitLoop2
		continueLoop2:
		addi $a0, $a0, 1
		j    loop2
	exitLoop2:
	la $v0, ($a0)
	li $t6, 0 	# The number of space
	# Loop 2 marks the end of the string by getting rid of all the tabs and the spaces at the end of the string
	loop3: 	lb  $t5, ($a0)		# Storing the byte a0 is pointing to in $t5
		beq $t5, 0, exitLoop3	# If the pointer reaches the end of the string 
		beq $t5, 10, exitLoop3	# If the pointer points to the newLine exit the loop
		beq  $t5, 32, whiteSpace # If a space is found we perform related operations in whiteSpace label
		beq  $t5, 9,  whiteSpace # If a tab is found we perform related operations in whiteSpace label
		li   $t6, 0
		j    continueLoop3
		whiteSpace:		# Operations to perform when we encounter a white space
		addi $t6, $t6, 1
		continueLoop3:		# Loop related increaments
		addi $a0, $a0, 1
		addi $v1, $v1, 1
		j    loop3
	exitLoop3:
	sub $v1, $v1, $t6
	sub $a0, $a0, $t6		# $a0 now points to the last character disregarding all the tabs and spaces at the end
	li  $t7, 0			# $t7 stores end of the line character
	sb  $t7, ($a0)			# End of the character is inserted at the end of the valid character
	jr  $ra				# Returning control to the main program
subprogram_1:
# Function to convert single hexadecimal character to decimal integer
# Arguments:    $a0
# Return Value: $v1
	slti $t8, $a0, 59		# If the char is less than 59, the char is a number
	beq $t8, 1, numbers
	
	slti $t8, $a0, 71		# If the char is less than 71 and greater than 59, the char is captial letter
	beq $t8, 1, capital
	
	slti $t8, $a0, 103		# If the char is less than 103, and greater than 71, the char is small letter
	beq $t8, 1, small
	
	numbers:
		addi $v1, $a0, -48	# subtract 48 from the numbers to get the decimal value
		b exitCharToInteger 
	capital:
		addi $v1, $a0, -55	# subtract 55 from the capital letters to get the decimal value
		b exitCharToInteger 
	small:
		addi $v1, $a0, -87	# subtract 87 from the small letters to get the decimal value
	exitCharToInteger:
	jr $ra
subprogram_2:
# Function to convert a hexadecimal string into hexadecimal integer using subprogram_1
# Arguments:	$a0 (The string), $a1(The length of the string)	
# Return Value: $sp (Returns the final result)
	add $s7, $ra, $zero	# Saving the memory address of the ra register
	jal trimSpace		# Calling the function to trim the space
	add $s6, $v0, $zero	# Sacing the address
	li $s5, 0		# Length of the new String
	loop5:	lb  $t8, ($s6)			#loading the character at $s6 into $t8
		beq $t8,  0, exitLoop5		# If the character is a end-line character then we exit the loop
		beq $t8, 10, exitLoop5		# If the character is a new-line character then we exit the loop
		# Calling the function to check if the character is valid
		la $a0, ($t8)	# Preparing the arguments		
		jal checkChar	# Calling the function
		la $t7, ($v1)	# Storing the return value
		beq $t7, 1, continue5		# If the character is valid then we continue normal loop operations
		# If the character is not a valid character
		li $v0, 0		# $v0 refers whether the conversion was successful
		la $v1, naN		# $v1 contains the startting address of the given error
		j exitS2		# returning to the original function
		continue5:
		addi $s5, $s5, 1	# Increasing the length of the string
		addi $s6, $s6, 1	# Pointing to the next character
		j loop5			# Loop
	exitLoop5:
	bne $s5, 0, skip
	li $v0, 0
	la $v1, naN
	j exitS2
	skip:
	bgt $s5, 8, tooLarge1		# Checking if the length is greater than 8
	j valid				# If the length is 8 or smaller
	# If the string is larger than 8 characters
	tooLarge1:
	li $v0, 0		# v0 contains whether the transformation was successfull or not
	la $v1, tooLarge	# v1 points at the starting address of the output message
	j exitS2
	valid:
	sub $s6, $s6, $s5	# s6 now points to the start of the string
	li $v0, 1		# $v0 = 1, means the conversion can be made
	li $s4, 0		# #s4 stores the converted decimal integer
	loop6:	lb $t8, ($s6)			# loading the byte pointed by s6
		beq $t8, 0, exitLoop6		# If the byte is a new-line or a end-line character, we exit the loop
		beq $t8, 10, exitLoop6
		# Calling a function to covert a character into its corrosponding number
		la $a0, ($t8)
		jal subprogram_1
		la $t7, ($v1)
		# Performing the operations required to convert the hexadecimal number to decimal
		sll $s4, $s4, 4
		add $s4, $s4, $t7
		
		addi $s6, $s6, 1	# s6 now points to the next character in the string
		j loop6			# looping
	exitLoop6:
	la $v1, ($s4)
	exitS2:
	# Loading the stack registers to return the value
	addi $sp, $sp, -4
	sw $v1, 0($sp)
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	# Restoring the value of the $ra register
	add $ra, $s7, $zero
	jr $ra
subprogram_3:
# Function to print the converted decimal number or the related error message
# Argument: $sp
	lw $t8, ($sp)			# $t8 now contains the boolean variable of whether the number is valid or not
	addi $sp, $sp, 4		# Deleting the retrieved member from the stack
	lw $t7, ($sp)			# $t7 now contains the value or the error message
	beq $t8, 0, errorMessage	# If the number is invalid we print the error message
	# Making the system ready to print integer
	li $t6, 10
	divu $t7, $t6			# Unsigend division by 10
	li $v0, 1
	mflo $a0
	beq $a0, 0, skip0		# If the first character is 0, we don't print it
	syscall				# Printing the value in mflo
	skip0:
	mfhi $a0
	syscall				# Printing the value in mfhi
	j exitS3
	errorMessage:
	# Getting ready to print the error Message
	li $v0, 4
	la $a0, ($t7)
	syscall
	exitS3:
	jr $ra
checkChar:
# Function to check if the character is valid
# Arguemnt required: $a0
# Return Value in: $v1 (1 if true, 0 if false)
	li $v1, 0
	beq $a0, 97, else	# $a0 == 'a'
	beq $a0, 98, else
	beq $a0, 99, else
	beq $a0, 100, else
	beq $a0, 101, else
	beq $a0, 102, else
	beq $a0, 65, else	# $a0 == 'A'
	beq $a0, 66, else
	beq $a0, 67, else
	beq $a0, 68, else
	beq $a0, 69, else
	beq $a0, 70, else
	beq $a0, 48, else	# $a0 == 0
	beq $a0, 49, else
	beq $a0, 50, else
	beq $a0, 51, else
	beq $a0, 52, else
	beq $a0, 53, else
	beq $a0, 54, else
	beq $a0, 55, else
	beq $a0, 56, else
	beq $a0, 57, else
	jr $ra
	else:
	li $v1, 1
	jr $ra
