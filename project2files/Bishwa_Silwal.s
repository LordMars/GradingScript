.data
	too_large:	.asciiz	"too large"
	end_msg:    		.asciiz "All Characters printed"
	newline: 			.asciiz "\n"
	input: .space  1001
	err_msg:			.asciiz "NaN"
.text
	main:
		
		li $v0, 8						#	Syscall code for user input
		la $a0, input 						#	Reading from the output
		li $a1, 1001
		syscall 						# 	Maximum length for the string to be read from input
		
		move $s0, $a0						# 	Save the string to t0 register
		move $t4, $s0						# Passing it to $t4 register
		

		la $s1, 0								#Initializing the starting index for the character of the substring
		la $s2, 0								#Initializing the starting index for the character of the substring
		
		j main_program							# Looping to the main program
	

	main_program:
		
		lb $t3, ($t4)							#Loading the character in the particular address
		
		# These register will be changed only when inside subprogram_1
		la $s5, 0								# Boolean for checking if a space is found after a valid character
		la $s6, 0								# Boolean for non space character found
		
		beqz   	$t3, 			end_of_loop				#If "\0" found, end of loop
		beq  	$t3, 	10, 	end_of_loop			#For string less than 9, the last characters is "\n", so checking for that
		

		
		addu 	$s2, 	$s2, 	1				#	Incrementing the end index of the string
		addu	$t4, 	$t4,	1				#	Look at the next character in the string
		
		
		bne 	$t3, 44,		main_program		# If the char is not ',' go back and look at the next character

		subu 	$s2, $s2, 1			#Since $t2 points to the comma, subtracting 1 from it gives the last index to the substring
		
		beq 	$s1,	$s2 	empty		# If no character between commas, go to this branch
		
		#Moving indexes and the string address to the $a register to pass as arguments to the function
		move	$a0, $s0			
		move 	$a1, $s1
		move 	$a2, $s2
		
		
		la $s3, 0 					# Keeing track of the length of the string being considered
		la $s4, 0					# Decimal Value of the string
		
		
		jal subprogram_2					# Calling the function to find the decimal value of the string

		jal subprogram_3   					# Use the output from subprogram_2 to print the decimal value of the hex string.
		
		jal print_comma						# Printing comma after the end of every substring
		
		addu $s2, $s2, 1					# Ignoring the ',' for both of the indices
		move $s1, $s2 						# Ignoring the ',' for both of the indices
		
		
		j main_program						#Looping back to the main program
	
	# Prints a comma
	print_comma:
		la $a0, 44
		la $v0, 11
		syscall
		
		jr $ra
	
	#Prints Nan when there are two commas without a string in between
	empty:
		la $a0, err_msg
		li $v0, 4    				#Printing Nan
		syscall
		
		addu $s2, $s2, 1
		move $s1, $s2
		
		jal print_comma
		
		j main_program
		
	
	# Subprogram 2 finds the decimal representation of the substring passed to the function
	subprogram_2:
		
		addu	$s3, $s3,  	1			#Incrementing the length of the hex number
		
		
		move $s7, $ra				# Keeping track of the address of the instruction where this subprogram was called
		move $s0, $a0				# Passing the string pointer to a variable for use
		
		#Unloading indexes and the string address passed to the function
		move 	$t0, $a0
		move 	$t1, $a1  
		move 	$t2, $a2
		
		
		
		add $t0, $t0, $t1			#Looking at the next address in the string
		
		lb  $t3, ($t0)				# Loading the character pointed by the address $t0
		
		beq 	$t3, 	32, 	space				# Case for when a space character is found
		
		move $a0, $t3				#Passing the character as an argument to subprogram 1 to find the string associated with it.

		# Since at this stage, the character can't be a space or '\n' or '\0', we can check if a character
		# AND a space has appeared before it. If both are true, then it must be invalid. Otherwise, proceed
		# to computing the decimal value
		bne $s5, 1, compute							 
		bne $s6, 1, compute
		
		
		j invalid
		
		
	compute:
		la 	$s6, 1					# Making note that a character has been found.
		# Finding the decimal representation of the character.
		jal 	subprogram_1
		
		# The code below uses the following algorithm to find the decimal value for a valid hex string
		# Initiliaze Result to 0
		# Step 1: Multiply Result by 16, Result = Result * 16
		# Step 2: Find value represented by the character.
		# Step 3: Add the value to the result.
		# Follow 1 to 3 for every character

		# Suppose the string is "ABC"
		# For A, 1. Result = 0 * 16 = 0,		2. A = 10,	3. Result = 0 + 10 = 10
		# For B, 1. Result = 10 * 16 = 160, 	2. B = 11, 	3.Result = 160 + 11 = 171
		# For C, 1. Result =  171 * 16 = 2736, 	2. C = 12,	3. Result = 2736 + 12 = 2748
		# Hence, ABC_16 = 2748_10
		sll 	$s4,	$s4, 	4 			# Multiplying the result by 16 using bit-shift	
		addu 	$s4,	$s4, 	$v0 		# Adding the value of the character to the result


		
		add 	$t1, $t1, 	1				# Incrementing the end index
		
		#Moving indexes to the $a register to pass as arguments to the function
		move 	$a1, $t1					
		move 	$a2, $t2

		move $ra, $s7				# Restoring the saved address tp the $ra register
		
		move $a0, $s0				#Moving the string address to pass as argument to subprogram 1
		
		
		bgt $s3, 8, too_big			# Print too great for output greater than 8
		
		beq $t1, $t2, go_back  		# If the starting and ending index match, we have reached the end of the sub string string. so move towards printing					

		# Re-iterate through the string by calling the subprogram once again
		j subprogram_2
		
	space:
		move 	$a1, $t1					
		move 	$a2, $t2
		
		
		
		move $ra, $s7				# Restoring the saved address tp the $ra register
		addu	$a1,	$a1,	1
		
	
		beq	$a1,	$a2			empty_or_not
		beqz	$s6, subprogram_2				# Checks if a valid character has already been found previously. If not loop back to the 

		la 	$s5, 1							# Making note of a space found after a character is found

		
		j subprogram_2						# return back to the loop
	
	empty_or_not:
		beq $s6, 0, invalid
		
		j go_back
		
		
		
		
		
		
	
	return_to_print:
			
	# This subprogram finds the decimal representation of the character passed to it. 
	# It returns two values via the stack, the return code and the value itself.
	# Return Code
	# 1 : For valid characters, returns the value as well
	# 2	: For too long strings. This subprogram doesnt return this return code
	# 3 : For invalid characters, The address of the string "Nan" defined initially is also returned with this error code
	subprogram_1:
		blt $a0, 48, invalid 		# checks if the number is less than 48. Goes to invalid if true

		ble $a0, 57, valid_num		# Checks if the ASCII of character is less than 58. At this point,
									# already greater than 48, so it is a valid num in the range 0-9

		blt $a0, 65, invalid 		# Checks if the ASCII of character is less than 68. At this point,
									# already greater than 58, so if true it is an invalid character

		ble $a0, 70, valid_capital	# Checks if the ASCII of character is less than 68. At this point,
									# already greater than 61, so if true it is a valid char in the range A - F

		blt $a0, 96, invalid 		# Checks if the ASCII of character is less than 96. At this point,
									# already greater than 70, so if true it is an invalid character

		ble $a0, 102, valid_small	# Checks if the ASCII of character is less than 58. At this point,
									# already greater than 96, so if true, it is a valid num in the range a-f

		j invalid 					#At this point, already greater than 103, so it is invalid
	

	# Returns the decimal value along with the return code via stack
	#  1 : For valid characters, returns the value as well
	go_back:
		addi $sp, $sp, -8  # Decrement stack pointer by 8
       		sw   $s4, 0($sp)   # Save the result to stack
       		
       		la $s4, 1			# Saving the return code for valid decimal numbers
       		sw   $s4, 4($sp)   # Save the result to stack
       		
		jr $ra
	

	# Returns both the return code and the address of the string of "too large" string defined initially.
	#  Return Code 2: For too long strings. This subprogram doesnt return this return code
	too_big:
		la $t0, too_large
		addi $sp, $sp, -8  		 # Decrement stack pointer by 8
		sw $t0, 0($sp)			# Save the string to stack
		
		li	$t0, 2				# Addding the error code to the stack
		sw $t0, 4($sp)			
		
		jr $ra 					#Returns back to the address that called this subprogram
	
	# Returns both the return code and the address of the string of "too large" string defined initially.
	# 3 : For invalid characters, The address of the string "Nan" defined initially is also returned with this error code
	invalid:
		la $t0, err_msg
		addi $sp, $sp, -8  		#For the error message
		sw $t0, 0($sp)
		
		li	$t0, 3			# Addding the error code to the stack
		sw $t0, 4($sp)
		
		jr $s7

	#Computes the decimal value for 0-9 characters
	valid_num:
		li 	$v0, 	0
		subu 	$v0, 	$a0, 	48				# Finding the real value of the character by subtracting
		jr $ra									#  Takes you back to the end of the instruction 'jal subprogram_2'

	#Computes the decimal value for A-F characters
	valid_capital:
		li 	$v0, 	0
		subu 	$v0, 	$a0, 	55				# Finding the real value of the character by subtracting
		jr $ra 									#  Takes you back to the end of the instruction 'jal subprogram_2'

	#Computes the decimal value for a-f characters
	valid_small:
		li 	$v0, 	0
		subu 	$v0, 	$a0, 	87				# Finding the real value of the character by subtracting
		jr $ra
		
	
	# Prints the string based on the return values passed to it.
	subprogram_3:
		lw   	$a0, 0($sp)   				# Copy the value (or string if error) from stack to $a
	      	
	    lw 		$a1, 4($sp)					# Copying the return code
   		addi $sp, $sp, 8   					# Increment stack pointer by 8
		
		# Printing the respective error messages based on the return codes
		beq	$a1,	2	print_too_large		
		beq	$a1,	3	print_nan



		la   $t2, 1000			# For very large numbers, directly printing the results gives negative results
								# So, to overcome that the number is divided by a power of 10, which allows separate
								# registers to hold the value for the quotient and the remainder which are printed
								# separately

		divu $a0, $t2			# Finding the quotient and the remainder

		mfhi $t0			# Storing the remainder in $s1
		mflo $t1					# Storing the quotient in $s2

		beq $t1, $zero, rem_print	# To avoid printing 0 if either the remainder or quotient is zero, the two cases
									# are handled separately

		beq $t0, $zero, quot_print	#

		j complete_print			# If neither are zero, both are printed
		
		jr $ra 						#Returning back to the address that called this subprogram

	
	# Prints too large
	print_too_large:
		li $v0, 4					#Syscall for printing String
		syscall
		jr $ra 						#Returning to the address which called the subprogram 3 since the error has already been printed
		 
	# Prints the quotient from the given function
	quot_print:
		li $v0, 1					# Syscall code for printing out an integer
		move $a0, $t1				# Transfer $s2 to $a0 for printing
		syscall 					

		jr $ra 						# Returning to the address which called the subprogram 3 since the value has already been printed

	# Prints the remainder from the given function
	rem_print:
		li $v0, 1					# Syscall code for printing out an integer
		move $a0, $t0				# Transfer $s1 to $a0 for printing
		syscall

		jr $ra 						# Returning to the address which called the subprogram 3 since the value has already been printed

	# Prints the complete value of the string, both the divisor and the remainder obtained by diving the number by 1000
	complete_print:

		
		li $v0, 1					# Syscall code for printing out an integer
		move $a0, $t1				# Transfer $s1 to $a0 for printing
		syscall

		li $v0, 1					# Syscall code for printing out an integer
		move $a0, $t0				# Transfer $s2 to $a0 for printing
		syscall

		jr $ra 						# Returning to the address which called the subprogram 3 since the value has already been printed
	
	# Prints Nan
	print_nan:
		li $v0, 4					# Printing string
		syscall
		jr $ra
		

	# After the string has ended, the last substring may still be unprocessed since no commas are found at the end.
	# This subprogram computes the decimal representation for that final substring
	end_of_loop:
	
		beq 	$s1,	$s2 	nan_terminate			#If nothing is found at the end (Example: 23,) the substring after 23 should print "Nan"
		
		
		la $s3, 0 					# Keeing track of the length of the string being considered
		la $s4, 0					# Result
		la $s5, 0					# Boolean for checking if a space is found after a valid character
		la $s6, 0					# Boolean for valid character found
		
		
		#Moving indexes and the string address to the $a register to pass as arguments to the function
		move	$a0, $s0
		move 	$a1, $s1
		move 	$a2, $s2
		
		jal subprogram_2						# Passing $a0 and $a1 as argument to the function.

		jal subprogram_3   					# Use the output from subprogram_2 to print the decimal value of the hex string
		
		li	$v0, 10							# system call code for exit = 10
		syscall
		
	 									#  Takes you back to the end of the instruction 'jal subprogram_2'
	 nan_terminate:
	 	la $a0, err_msg				#Passing the error message to the address for printing
		li $v0, 4    				#Printing Nan
		syscall
		
	
		
		li	$v0, 10					# system call code for exit = 10
		syscall
		
																
	 

