.data			#code portion for predefined data
str:	.space 1001 	#allocates uninitialized 1001 bytes of information for string including NULL character
error:	.asciiz "NaN"	#error message to be displayed if input string found to be invalid
large:	.asciiz "too large"	#error message to be displayed if input string found to be too large
.text			#code portion for instructions
main: 
	li $v0, 8	#syscall code for reading in strings
	la $a0, str	#load space into call variable
	li $a1, 1001	#allow input buffer size of 1001 bytes
	syscall		#call for user input
initialize_stack:
	addi $sp, $sp, -16	#allot stack space of 4 words: (0-3) hex number sum, (4-7) output type: string or integer, 
				#(8-11) current input string address, (12-15) program termination flag
	add $s4, $a0, $zero	#save initial input string address
loop:
	add $a2, $s4, $zero	#load current input string address into subprogram 2 parameters
	jal subprogram_2	#call subprogram 2
	lw $t0, 0($sp)		#load integer value be displayed from subprogram 2 return
	lw $t1, 4($sp)		#load output type from subprogram 2 return
	lw $t2, 8($sp)		#load current input string from subprogram 2 return
	lw $t3, 12($sp)		#load termination flag from subprogram 2 return
	add $s4, $t2, $zero	#save current input string address received from subprogram 2
	add $s6, $t3, $zero	#save termination flag received from subprogram 2
	sw $t0, 0($sp)		#load integer value recieved from subprogram 2 into subprogram 3 parameters
	sw $t1, 4($sp)		#load output type recieved from subprogram 2 into subprogram 3 parameters
	sw $t3, 8($sp)		#load termination flag recieved from subprogram 2 into subprogram 3 parameters
	jal subprogram_3	#call subprogram 3
	bne $s6, $zero, exit	#if termination flag is true (1) proceed to exit the program
	j loop			#else return to start of loop
exit:			
	addi $sp, $sp, 16	#pop/cancel space in stack
	li $v0, 10	#load syscall code for program exit
	syscall		#exit program



subprogram_1:
#****************************************************
	add $t0, $a1, $zero	#read in function parameters
check_value1:
	slti $t1, $t0, 103	#check if byte from input is less than 103 (highest hex digit is 'f', decimal value 102)
	bne $t1, $zero, af_range	#if byte is less than 103 proceed to a-f range of values
	j return_nan			#else byte is invalid character to be returned as "NaN"
af_range:
	slti $t1, $t0, 97	#check if byte from input is less than 97, decimal value of 'a'
	bne $t1, $zero, check_value2	#if byte is less than 97, proceed to check for invalid byte values between A-F and a-f
	li $t6, 87			#87 to be subtracted from value in this range to obtain true value
	sub $t2, $t0, $t6	#if byte is between 97 and 102, obtain the true value of the hex number between 'a' and 'f'
	j return_hex_num	#proceed to return true value
check_value2:
	slti $t1, $t0, 71	#check if byte from input is less than 71. the range of characters 'A' through 'F' is 65-70
	bne $t1, $zero, AF_range	#if byte is less than 71 proceed to A-F range of values
	j return_nan			#else byte is invalid character to be returned as "NaN"
AF_range:
	slti $t1, $t0, 65	#check if byte from input is less than 65, decimal value of 'A'
	bne $t1, $zero, check_value3	#if byte is less than 65, proceed to check for invalid byte values between 0-9 and A-F
	li $t6, 55		#55 to be subtracted from value in this range to obtain true value
	sub $t2, $t0, $t6	#if byte is between 65 and 70, obtain the true value of the hex number between 'A' and 'F'
	j return_hex_num	#proceed to return true value
check_value3:
	slti $t1, $t0, 58	#check if byte from input is less than 58. the range of characters '0' through '9' is 48-57
	bne $t1, $zero, digit_range	#if byte is less than 58 proceed to 0-9 range of values
	j return_nan			#else byte is invalid character to be returned as "NaN"
digit_range:
	slti $t1, $t0, 48	#check if byte from input is less than 48, decimal value of '0'
	bne $t1, $zero, low_range	#if less than 48, proceed to lower range of deicmal values
	li $t6, 48		#48 to be subtracted from value in this range to obtain true value
	sub $t2, $t0, $t6	#find hexadecimal value of current byte from input
	j return_hex_num	#proceed to return true value
low_range:
	li $t6, 44			#load value of comma
	sub $t3, $t0, $t6		#check to see if the decimal value of the byte 44, the value of comma, via subtraction
	beq $t3, $zero, return_comma		#if the above difference is zero, then handle the byte as a comma
	li $t6, 32			#load value of space key
	sub $t3, $t0, $t6		#check to see if the decimal value of the byte 32, the value of space key, via subtraction
	beq $t3, $zero, return_white_space	#if the above difference is zero, then handle the byte as white space
	li $t6, 9			#load value of tab key
	sub $t3, $t0, $t6		#check to see if the decimal value of the byte 9, the value of tab key, via subtraction
	beq $t3, $zero, return_white_space	#if the above difference is zero, then handle the byte as white space
	li $t6, 10			#load value of enter key
	sub $t3, $t0, $t6		#check to see if the decimal value of the byte 10, the value of enter key, via subtraction
	beq $t3, $zero, return_eoi	#if the above difference is zero, then handle the byte as a newline character
	beq $t0, $zero, return_eoi	#Finally, if $t0, the byte read in, is zero it is a null, end of string character
	j return_nan			#else byte is invalid character to be returned as "NaN"	
return_comma:	
	li $v0, 20		#byte is code 20
	jr $ra 			#return code 20 (comma)
return_white_space:
	li $v0, 16		#byte is code 16
	jr $ra 			#return code 16 (whitespace)
return_eoi:
	li $v0, 18		#byte is code 18
	jr $ra 			#return code 18 (end of input)
return_nan:
	li $v0, 19			#byte is code 19
	jr $ra			#return code 19 (NaN)
return_hex_num:
	add $v0, $t2, $zero	#load decimal value of hex number found
	jr $ra			#return value to subprogram 2
#***************************************************************************


subprogram_2:
#**************************************************************************
initialize:
	li $s0, 0	#to hold the decimal value of final converted hexadecimal number
	li $s1, 0	#used to determine if hex number has been read in at one point in the program
	li $s2, 0	#used to determine if whitespace has been read in at one point in the program
	li $s3, 0	#used to determine last byte read was whitespace (1) or hex number (0)
	li $s5, 0	#used to indicate the amount of actual hex numbers read
	li $t7, 0	#used to indicate if errroneous string is present
	add $s7, $zero, $ra	#save return address for jump return
byte_loop:
	lb $t0, 0($a2)		#load in byte from stored input string
	add $a1, $t0, $zero	#save byte in arguements for subprogram 1 parameter
	jal subprogram_1	#call subprogram 1
	add $t2, $zero, $v0	#save value returned from program
	slti $t1, $t2, 20	#check if code 20 (comma) is found
	beq $t1, $zero, comma_found	#if comma found proceed to handle this event
	slti $t1, $t2, 19		#check if code 19 (NaN) is found 
	beq $t1, $zero, error_found	#if NaN found proceed to handle this event
	slti $t1, $t2, 18		#check if code 18 (End of input) is found
	beq $t1, $zero, end_found	#if End of Input found proceed to handle this event
	slti $t1, $t2, 16		#check if code 16 (White space) is found
	beq $t1, $zero, space_found	#if white space found proceed to handle this event
sum_check1:				#otherwise the return value is its hex value in decimal
	bne $s1, $zero, sum_check2	#if a hex number has been read in at any point proceed to check if whitespace has been read in as well
	j sum_up			#otherwise proceed to the first addition to the total sum
sum_check2:
	bne $s2, $zero, sum_check3	#if white space has been read in at one point proceed to check the validity of the string
	j sum_up			#otherwise proceed to add the hex number to sum
sum_check3:
	beq $s3, $zero, sum_up		#if the previous byte read was not a space proceed to the sum as normal
	addi $a2, $a2, 1		#otherwise, increment input string address by one to read the next byte of information
	j error_found			#since the previous byte was a space and both a space and a hex number were read in at one point,
					#then this implies a string with two space seperated hex numbers was entered, an error found 
comma_found:
	addi $a2, $a2, 1		#increment input string address by one to read the next byte of information
	bne $t7, $zero, return_error	#if an error was at one point found proceed to return error string
	bne $s1, $zero, return_int	#if a real hex number was identified at one point proceed to return the sum
	j return_error			#otherwise the string is empty and must be returned as error
end_found:
	addi $t6, $zero, 1		#prepare a 1 to be stored
	sw $t6, 12($sp)			#set termination flag to true
	addi $a2, $a2, 1		#increment input string address by one to read the next byte of information
	bne $t7, $zero, return_error	#if an error was at one point found proceed to return error string
	bne $s1, $zero, return_int	#if a real hex number was identified at one point proceed to return the sum
	j return_error			#otherwise the string is empty and must be returned as error
error_found:
	li $t7, 1			#indicate that error has been found
	addi $a2, $a2, 1		#increment input string address by one to read the next byte of information
	j byte_loop			#proceed back to start of loop
space_found:
	li $s3, 1		#signify that the most recent byte read was a white space character
	li $s2, 1		#signify that a white space has been read into the program at one point
	addi $a2, $a2, 1		#increment input string address by one to read the next byte of information
	j byte_loop			#proceed back to start of loop
sum_up:
	sll $s0, $s0, 4			#shifting the sum left by 4 bits is equivalent to multiplying the sum by 16. See pseudo code
	add $s0, $t2, $s0		#after multiplying by 16 add the newly checked hex nummber to the sum
	li $s3, 0			#signify that the previously read byte is a hex number now
	li $s1, 1			#signify that a hex number has been read in at one point
	addi $s5, $s5, 1		#increment numbers read counter
	addi $a2, $a2, 1		#increment input string address by one to read the next byte of information	
	j byte_loop			#proceed back to start of loop
return_int:
	slti $t6, $s5, 9		#check if 9 hex numbers have been added to sum
	beq $t6, $zero, return_large	#if 9 o more bytes have been added to sum, number is too large
	sw $s0, 0($sp)			#otherwise, push sum into stack	
	sw $zero, 4($sp)		#push integer output type into stack
	sw $a2, 8($sp)			#push current input string address into stack
	add $ra, $s7, $zero		#restore original return address
	jr $ra				#return to main program with values in stack
return_error:
	addi $t6, $zero, 1		#prepare a 1 to be stored
	sw $t6, 4($sp)			#push string output type into stack
	sw $t6, 0($sp)			#push NaN string into stack
	sw $a2, 8($sp)			#push current input string address into stack
	add $ra, $s7, $zero		#restore original return address
	jr $ra				#return to main program with values in stack
return_large:
	addi $t6, $zero, 1		#prepare a 1 to be stored
	sw $t6, 4($sp)			#push string output type into stack
	sw $zero, 0($sp)		#push too large string into stack
	sw $a2, 8($sp)			#push current input string address into stack
	add $ra, $s7, $zero		#restore original return address
	jr $ra				#return to main program with values in stack
#*************************************************
			
subprogram_3:
#*************************************************
	lw $t0, 0($sp)		#load word containing integer value be displayed
	lw $t1, 4($sp)		#load word containing output type 
	lw $t3, 8($sp)		#load word containing flag for program termination
	li $t2, 10		#used for division during final displaying process
	beq $t1, $zero, print_int	#if output type is integer (0), proceed to print the integer
	beq $t0, $zero, print_large	#if output type is string and integer value is 0, "too large" is to be displayed 
print_error:				#else "NaN" is to be displayed
	li $v0, 4		#load syscall code for string display	
	la $a0, error		#load in previously defined string address	
	syscall			#call to display error message
	j comma_check		#check if comma needs to be displayed
print_int:
	li $v0, 1	#syscall code for outputting integers
	divu $t0, $t2	#divide the sum by 10 to ensure that a 2's complement (negative) number is not output 
	mflo $t4	#store the quotient
	mfhi $t5	#store the remainder
	beq $t4, $zero, alt_print_int	#if the quotient is zero proceed to only display the remainder
	add $a0, $t4, $zero		#otherwise display the quotient
	syscall				#call for integer output
	add $a0, $t5, $zero		#then display the remainder
	syscall				#call fo integer output
	j comma_check			#check if comma needs to be displayed
alt_print_int:	#If the original sum is less than 10 display only the reaminder
	li $v0, 1	#syscall code for outputting integers
	add $a0, $t5, $zero	#load the remainder into arguements register	
	syscall			#call to display final integer
	j comma_check		#check if comma needs to be displayed
print_large: # section to print error message
	li $v0, 4		#load syscall code for string display	
	la $a0, large		#load in previously defined string address	
	syscall			#call to display error message then immediately check if comma needs to be displayed
comma_check:
	beq $t3, $zero, print_comma	#if termination flag is true (1) don't display comma
	jr $ra				#return to main function
print_comma:
	li $v0, 11	#load syscall code for ascii character output
	li $a0, 44	#load ascii value of comma into arguement register
	syscall		#call to display comma
	jr $ra		#return to main function
#**************************************************
