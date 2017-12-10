# MIPS Assignment 2
# Programmed by Shelton Allen

	.data

						# Data declaration 	

string_NaN:					# If invalid input, programs outputs this string
	.asciiz "NaN"
string_tooLarge:
	.asciiz "too large"
char_comma:
	.asciiz ","

buffer:							# Reserved space in memory for user input
	.space 1001

	.text



						# Assembly language instructions
main:							# Begin main code
	
	li $v0, 8					# load read string call code
	la $a0, buffer					# load buffer address into $a0
	li $a1, 1001					# define amount of characters to be read
	syscall						# system call for keyboard input
	
getNextString:
	jal subprogram_2				# Call convertString subprogram and pass address of starting character in $a0
	lbu $t0, 1($sp)					# Check if last string conversion
	beq $t0, 1, endGetNextString			# If this is the last string branch out of loop
	jal subprogram_3				# Call display subprogram and pass values in stack
	lw $a0, 6($sp)					# Get starting position of next string
	addiu $sp, $sp, 10				# Cancel space in stack created by subprogram_2
	j getNextString					# loop back to getNextString
endGetNextString:
	jal subprogram_3				# Call display subprogram and pass values in stack
	addiu $sp, $sp, 10				# Cancel space in stack
endFunc:
	li $v0, 10

					# Load exit code
	syscall
						# System call to exit


##################################################################################################################	
# 		########################## Subprogram_1 ##################################
#	Converts single hex digit to decimal.
# 	Returns $v0 as 0 if string was too large, 1 if string is NaN, and 2 if string is valid
# 	Returns the decimal conversion of the hex digit in $v1
##################################################################################################################
subprogram_1:						# hexToDec
					
	move $t6, $a1	
	li $t5, 0
	li $t4, 0					# Reset these registers


     checkChar:						# Check if hex digit is 0-9 and return decimal in $v1
	li $t1, 0x0000003A
	slt $t2, $t6, $t1				# Sets $t2 if t0 <3Ah
	li $t1, 0x0000002F				
	slt $t3, $t1, $t6				# Sets $t3 if $t0 > 2Fh
	and $t4, $t2, $t3				# Sets $t4 if byte is in range of 0-9 ASCII 
	addu $t5, $t5, $t4				# If falls in the range, increments $t5
	bne $t5, 1, checkAThroughF
    	li $v0, 2					# Set to 2 to show that inputted character is valid
	addi $v1, $a1, -48				# Put decimal conversion of hex digit between 0-9 in $v1
	jr $ra
	
     checkAThroughF:					# Check if byte has code for ASCII A-F
	li $t1, 0x00000047
	slt $t2, $t6, $t1				# Sets $t2 if t0 < 47
	li $t1, 0x00000040				
	slt $t3, $t1, $t6				# Sets $t3 if $t0 > 40
	and $t4, $t2, $t3				# Sets $t4 if byte is in range of A-F ASCII 
	addu $t5, $t5, $t4				# If falls in the range, increments $t5
	bne $t5, 1, aThroughfCheck
	li $v0, 2					# Set to 2 to show that inputted character is valid
	addi $v1, $a1, -55				# Put decimal conversion of hex digit between A-F in $v1
	jr $ra
	
     aThroughfCheck:		# Check if byte has code for ASCII a-f 
	li $t1, 0x00000067
	slt $t2, $t6, $t1				# Sets $t2 if t0 < 67
	li $t1, 0x00000060				
	slt $t3, $t1, $t6				# Sets $t3 if $t0 > 60
	and $t4, $t2, $t3				# Sets $t4 if byte is in range of a-f ASCII 
	addu $t5, $t5, $t4				# If falls in the range, increments $t5
	bne $t5, 1, invalidInput
	li $v0, 2					# Set to 2 to show that inputted character is valid
	addi $v1, $a1, -87				# Put decimal conversion of hex digit between in $v1
	jr $ra

     invalidInput:
	li $v0, 1					# Set $v0 to 3 if NaN
	jr $ra		

##################################################################################################################	
# 	########################## Subprogram_2 ##################################
#	Converts string to decimal.
# 	Returns 0 if string was too large, 1 if string is NaN, and 2 if string is valid (first byte in stack)
# 	Returns 1 if all strings were converted (second byte in stack)
# 	Returns unsigned decimal in stack (4 bytes in stack)
# 	Returns starting address of next string (4 bytes in stack)
##################################################################################################################

subprogram_2: 						# convertString
	
	addi $sp, $sp, -22
	sw $s7, 18($sp)					# Save saved registers used in subprogram in stack
	sw $s6, 14($sp)
	sw $s5, 10($sp)
	move $t0, $a0					# Move address to $t0
	li $s5, 0					# If last string, set to 1
	li $t7, 2					# If valid string, $t7=2
	li $t8, 0					# Count good characters
	li $t9, 0					# Count space after valid character
	move $s7, $ra					# Save return address to $s7
	li $s6, 0					# Store integer
     loop:
	lb $a1, 0($t0)					# Load current to $a1
	beq $a1, 44, exitLoop
	beqz $a1, endProgram				# Check if current character is end of line character, if so end checkString					
	beq $a1, 10, endProgram				# End checkString if current character is carriage return
	beq $a1, 32, spaceCheck				# Check if current character is a space, if not branch to notASpace
	bne $a1, 9, notASpace				# Check if tab, if not branch to notASpace
      spaceCheck:					# If current character is a space, check where the space is and if the input string is invalid
	addiu $t0, $t0, 1				# Put address of next byte of input string in $a0
	beqz $t8, loop					# check if there was a valid character before the space, if not ignore space
	addiu $t9, $t9, 1				# Record space following valid character entry
	j loop						# Loop back to checkString
	
     notASpace:
	bne $t9, $zero, setNaN				# Check if there was a sequence of character, any amount of spaces, then a character. If so branch to invalid
	jal subprogram_1				# Call subprogram_1 to figure out decimal
	beq $v0, 1, setNaN				# If subprogram_1 returns that char is NaN then branch to setNaN
	sll $s6, $s6, 4					# Shift left logical $s6 
	addu $s6, $s6, $v1				# Put decimal conversion in $s6
	addi $t8, $t8, 1				# Increment char counter
	j jumpToLoop
     setNaN:
	li $t7, 1					# If not a number, record it
     jumpToLoop:
	addiu $t0, $t0, 1				# Set for next character
	j loop
    endProgram:
	li $s5, 1					# Set to 1 if this is last string
    exitLoop:
	addiu $t0, $t0, 1				# Get next string starting address in case needed
	beq $t7, 1, exitFunc				# Jump to exitFunc if NaN was set
	bge $t8, 9, setTooLarge				# Branch to setTooLarge if chars counter in string is greater than 8
	beqz $t8, setNoInput				# If no chars entered 
	j exitFunc
    setTooLarge:
	li $t7, 0					
	j exitFunc
    setNoInput:
	li $t7, 1
    exitFunc: 
	sb $t7, 0($sp)					# Return if string is valid, too large or NaN
	sb $s5, 1($sp)					# Return if end of string
	sw $s6, 2($sp)					# Return decimal
	sw $t0, 6($sp)					# Return next string starting address
	
	move $ra, $s7					# Restore $ra value to return to main

	lw $s7, 18($sp)					# Restore saved registers 
	lw $s6, 14($sp)
	lw $s5, 10($sp)
	
	
	jr $ra						# Return to main


	
##################################################################################################################	
# 	########################## Subprogram_3 ##################################
#	Displays integer

##################################################################################################################
subprogram_3:						# displayResult:
	
		# Take first single byte from stack, if 1 then should display value passed in stack. 
		# If zero, jump to invalid and display invalid_string "NaN"
	lbu $t0, 0($sp)					# Check first byte of stack, if 1, print NaN, if 2 Too large, if 0
	beqz $t0, tooLarge
	beq $t0, 1, notANumber
	lw $t0, 2($sp) 					# Move 4 byte long number to $t0
	bgez $t0, showInt				# If number is positive, show integer
	li $t1, 10					
	divu $t0, $t1					# Divide number by 10
	mflo $t1					# Store quotient in $t1
	mfhi $t2					# Store remainder in $t2
	li $v0, 1					# Load print integer call code
	move $a0, $t1					# Load quotient into $a0	
	syscall						# Print quotient
	move $a0, $t2					# Put remainder in $a0
	syscall						# Print remainder
	j printComma					# Jump to printComma
     showInt:
	li $v0, 1					# Load print integer call code
	move $a0, $t0					# Load integer into $a0	
	syscall						# Print integer (if div occurred, print quotient)
	j printComma					# Return to main
     tooLarge:
	li $v0, 4
	la $a0, string_tooLarge
	syscall
	j printComma
     notANumber: 
	li $v0, 4				# load print string call code
	la $a0, string_NaN			# Print error message
	syscall					# print buffer string
	
     printComma:
	lbu $t0, 1($sp)
	beq $t0, 1, returnToMain
	li $v0, 4				# load print string call code
	la $a0, char_comma			# Print error message
	syscall					# print buffer string
     returnToMain:
		jr $ra

 
	
	
