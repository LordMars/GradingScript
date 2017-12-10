.data: 
	userString:
	#declares spece for a 1000 byte array
	.space 1001
	updateMessage: .asciiz "\nHere I am!\n"
	tooLarge:	.asciiz "Too large"
	notANum:	.asciiz "NaN"
	thru:		.asciiz "\nOk, I'm done\n"
.text:

	main:
		#loads character array into the address
		li $v0, 8
		la $a0, userString
		li $a1, 1001
		syscall
	
		#outputs the array of characters
		
		add $s0, $0, $zero	#shift position
		add $s1, $0, $zero	#starting index of substring
		add $s2, $0, $zero	#ending index of substring
		add $t3, $0, $zero	#substring value
		la $s4, userString	#loads array into address
		add $s6, $0, $zero	#place in the array
		add $s7, $0, $zero	#integer sum of all values
		addi $sp, $sp, -12
		sw $s4, 0($sp)		#array
		add $t0, $zero, $0	#location to save a character
		add $t3, $zero, 4	#shift factor
		add $t4, $zero, $0	#temporary length
		add $s3, $0, $zero	#shifting amount
		add $s5, $0, $zero
	loop:
		lb $s5, 0($s4)		#loads first byte of the array into address
		sw $s1, 4($sp)		#stores starting index to the stack
		sw $s2, 8($sp)		#stores ending index to the stack
		
		
		#exits loop if no more characters left to check
		beq $s5, 0, increment_to_next
		beq $s5, 10, increment_to_next
		beq $s5, 44, increment_to_next
		
		#outputs character
		li $v0, 11
		add $a0, $s5, $0
		syscall 
		
		add $s2, $s2, 1		#increments ending index 
		add $s4, $s4, 1		#increments to next character in array
		
		j loop
				
	increment_to_next:
		
		jal subprogram_2
		addu $s1, $s2, 1		#adds to starting index
		addu $s2, $s2, 1		#adds to ending index
		
		#li $v0, 4
		#la $a0, updateMessage
		#syscall
		
		j loop
	subprogram_1:
		li $v0, 4
		la $a0, updateMessage
		syscall
		#This subprogram converts one hex character to decimal.
		#Uses registers to pass parameters into.
		#Values are returned with registers.
		
		#copies shift amount into temp register
		addu $t4, $t0, $0
		sub $s0, $t0, 1
		#if the shift position is one, then there is only 
		#one element in the array. return its value in decimal
		add $a0, $t0, $0
		addi $v0, $0, 1
		syscall
		
		beq $s0, 1, hex_to_dec
		bgt $s0, 1, hex_to_dec
		
		
		jr $ra
		
		
	#sub program 2 calculates the value of the substrings
	subprogram_2:
		#li $v0, 4
		#la $a0, updateMessage
		#syscall
		#string_to_int:
		
		#This subprogram converts the hex string to a decimal.
		#Has to call hex_to_dec to get the decimal value of each
		#of the characters.
		#Return values with the stack.
		
		
		subu $s0, $s2, $s1	#gets length of the (sub) string by subtrating last from first index
		bgt $s0, 8, too_large	#has too many bytes if length (shift position) is greater than 8
		
		bgt $s2, $s1, exit	#when the starting and the ending indexes are equal, exit
		add $s4, $s4, $s1	#holds value at a certain index of the array
		
		add $s6, $s4, $s1	#finds element of the array at the specificied index ($s1)
		sw $s6, 12($sp)		#stores that element
		sw $s0, 16($sp)		#stores the position to the stack as well.
		
		jal subprogram_1
		
		#Outputs update

		
		#exits when the start and end are equal
		beq $s2, $s1, exit
		
		jr $ra

	hex_to_dec:
		li $v0, 4
		la $a0, updateMessage
		syscall
		#if the decimal is less than 48, 
  		#it is invalid
  		blt $s6, 48, exit
  		#48=58 is the range for numbers
  		#blt $s6, 58, check_numbers
  		#58-65 are invalid characters for hexadecimal
  		blt $s6, 65, exit
  		#65-71 is the the range for A-F
  		blt $s6, 71, check_uppercase
  		#71-97 is an invalid range for hexadecimal
  		blt $s6, 97, exit
  		#97-103 is the range for a-f
  		#blt $s6, 103, check_lowercase
  		#any decimal over 103 is invalid for hexadecimal
  		bgt $s6, 103, exit
  		
	check_uppercase:
  		subu $s6, $s6, 55
  		#translation of A - F
  		#add it to a sum
  		mult $t4, $t3
  		mflo $s3
  	
  		#shifts the decimal number 
  		subu $t4, $t4, 1  #decrements shift amount
  		j subprogram_1

#Display_int:
#Displays an unsigned integer that is calculated from other subprograms
#Stack must be used to pass parameters into the subprogram.
#Don't return any values.
	returnNaN:
		#output return NaN
		j exit
	too_large:
		#input is too large
		li $v0, 4
		la $a0, tooLarge
		syscall
		j exit
	exit:
		li $v0, 4
		la $a0, thru
		syscall
		
		li $v0, 10
		syscall


