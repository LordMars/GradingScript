.data

notNum:	.asciiz	"NaN "
tooLargeString:		.asciiz	"Large String "
comma:					.asciiz	" "
userInput:				.space	1001
userSubString:				.space	1001

.globl main

.text

main:
	li $v0, 8						#Read in string
	la $a0, userInput				#Store string in buffer
	li $a1, 1001					#Limit size to 1000
	syscall
	
	la $s1, userSubString				#Save address of userSubString in $s1
	la $s2, ($a0)					#Move address of input string to $s2
	la $s3, userSubString				#Copy of userSubString to know where to start printing
	and $t8, $t8, $zero				#Flag when non-terminating char/space has been read
	and $t9, $t9, $zero				#Current string length counter (8 max length)
	
loop:
	lb $s0, 0($s2)					#Load character into $s0
	
	slti $t1, $t9, 9				#Check if current substring is longer than 8 characters
	beq $t1, $zero, length_error	#Throw length_error and skip to next comma
	
	beq $s0, $zero, print_strings	#Check if at end of input
	beq $s0, '\n', print_strings	#Check if at end of input
	beq $s0, ',', subStringProcess		#Process chars at the end of the current substring
	beq $s0, ' ', space_loop
	
	li $t8, 1						#Set seen valid character flag
	sb $s0, 0($s1)					#Save character in current string
	addi $s2, $s2, 1				#Go to next character from input
	addi $s1, $s1, 1				#Go to next empty place in userSubString
	addi $t9, $t9, 1				#Increment current substring length counter (max 8)
	
	j loop							#Continue loop
	

space_loop:
	addi $s2, $s2, 1				#Go to next character in current string
	lb $s0, 0($s2)					#Load character into $s0
	beq $s0, ' ', space_loop		#Skip space if at the beginning or at the end
	beq $s0, '\t', space_loop
	beq $s0, $zero, print_strings	#Check if at end of input
	beq $s0, '\n', print_strings	#Check if at end of input
	beq $s0, ',', subStringProcess		#Process chars at the end of the current substring
	
	j is_valid						#Check if this is a valid char after reading spaces
	

is_valid:
	bne $t8, $zero, main_error		#If previous valid char has been read then NaN
	sb $s0, 0($s1)					#First valid char encountered so save in userSubString
	li $t8, 1						#Set seen valid character flag
	or $s3, $zero, $s1				#Update current string head pointer
	addi $s1, $s1, 1				#Go to next empty place in userSubString
	addi $s2, $s2, 1				#Go to next character from input
	addi $t9, $t9, 1				#Increment current substring length counter (max 8)
	
	j loop							#Back to main loop

	
subStringProcess:
	la $a0, ($s3)					#Load beginning of current substring into $a0 as argument
	beq $t8, $zero, main_error		#If letter has not been seen then string is not valid
	jal subprogram_2						#Go to subroutine 2
	
	addi $s2, $s2, 1				#Go to next character from input
	and $t8, $t8, $zero				#Reset seen valid character flag
	and $t9, $t9, $zero				#Reset substring counter
	or $s3, $s1, $zero				#Move head pointer of userSubString to next substring beginning
	
	j loop							#Go back to main loop
	
	
print_strings:
	la $a0, ($s3)					#Load beginning of current substring into $a0 as argument
	lb $t1, 0($s3)					#Load first character in current substring
	beq $t1, '\n', end				#Check if at end of input string
	beq $t1, $zero, end				#Check if at end of input string
	jal subprogram_2						#Go to subroutine 2
	j end


length_error:
	la $a0, tooLargeString		#Load address of notNum
	li $v0, 4						#Print notNum
	syscall
	
	add $s1, $s1, $t9				#Move pointer for writing to current string to an empty cell
	or $s3, $zero, $s1				#Update the head of current string accordingly
	and $t8, $t8, $zero				#Reset seen valid character flag
	and $t9, $t9, $zero				#Reset substring counter
	j skip_loop						#Skip to next substring
	
main_error:
	la $a0, notNum		#Load address of notNum
	li $v0, 4						#Print notNum
	syscall
		
	add $s1, $s1, $t9				#Move pointer for writing to current string to an empty cell
	or $s3, $zero, $s1				#Update the head of current string accordingly
	and $t8, $t8, $zero				#Reset seen valid character flag
	and $t9, $t9, $zero				#Reset substring counter
	
	j skip_loop						#Skip to next substring
	

skip_loop:
	addi $s2, $s2, 1				#Go to next character in current string
	lb $s0, 0($s2)					#Load character into $s0
	beq $s0, ',', loop				#Check for spaces at the beginning of new substring
	beq $s0, $zero, print_strings	#Check if at end of input
	beq $s0, '\n', print_strings	#Check if at end of input
	bne $s0, ',', skip_loop			#Continue loop if space is seen
	
	
	j loop							#Continue loop
	
	
end:
	add $t0, $s2, -1				#Check previous character
	lb $t1, 0($t0)					#Load the character into $t1
	beq $t1, ',', print_end			#If the last character was a comma then we know this was an invalid string
	
	li $v0, 10						#End program
	syscall


print_end:
	la $a0, notNum		#Load address of notNum
	li $v0, 4						#Print error message
	syscall
	
	li $v0, 10						#End the program
	syscall
	
subprogram_1:
	sll $t2, $t2, 4					#Multiply by 16
	
	slti $t4, $t3, ':'				#Check if character is a number
	bne $t4, $zero, digit_subpro_1		#Take care of character being a number case
	
	slti $t4, $t3, 'G'				#Check if the character is uppercase
	bne $t4, $zero, upperCase_subpro_1		#Take care of character being uppercase
	
	addi $t4, $t3, -87				#Subtract 87 from lowercase to get hexadecimal value
	add $t2, $t2, $t4				#Add translated character to running sum
	
	jr $ra							#Return to subprogram_2
	

upperCase_subpro_1:
	addi $t4, $t3, -55				#Subract 55 from uppercase to get hexadecimal value
	add $t2, $t2, $t4				#Add translated character to running sum
	
	jr $ra							#Return to subprogram_2
	
digit_subpro_1:
	addi $t4, $t3, -48				#Subract 48 from number to get hexadecimal value					
	add $t2, $t2, $t4				#Add translated character to running sum
	jr $ra							#Return to subprogram_2

subprogram_2:
	la $t0, ($a0)					#Load current substring head from argument $a0 into $t0
	addi $sp, $sp, -12				#Make space on the stack for return addresses and return values
	sw $ra, 0($sp)					#Save return address on the stack
	and $t1, $t1, $zero				#Character counter up to value of $t9
	and $t2, $t2, $zero				#Will hold the unsigned integer to be printed
	and $t3, $t3, $zero				#Will hold the characters being read in
	
subprogram_2_loop:
	slt $t4, $t1, $t9				#Check if counter is less than substring length
	beq $t4, $zero, return_subprogram_2	#If equal or greater than, then return from subprogram_2
	lb $t3, 0($t0)					#Load next character into $t3
	
	slti $t4, $t3, '0'				#Check if current character is less than ascii value of '0'
	bne $t4, $zero, subprogram_2_error		#Substring is not a valid string
	
	slti $t4, $t3, 'A'				#Check if current character is less than ascii value of 'A'
	slti $t5, $t3, ':'				#Check if current character is less than ascii value of ':'
	bne $t4, $t5, subprogram_2_error		#If checks are not equal then character is between '9' and 'A'
	
	slti $t4, $t3, 'a'				#Check if current character is less than ascii value of 'a'
	slti $t5, $t3, 'G'				#Check if current character is less than ascii value of 'G'
	bne $t4, $t5, subprogram_2_error		#If checks are not equal then character is between 'F' and 'a'
	
	slti $t4, $t3, 'g'
	beq $t4, $zero, subprogram_2_error		#Substring is not a valid string
	
	jal subprogram_1						#Go to subprogram_1
	
	addi $t1, $t1, 1				#Increment character counter
	addi $t0, $t0, 1				#Go to the next character in the substring
	
	j subprogram_2_loop					#Continue the loop
	
	
return_subprogram_2:
	li $t4, 10000					#Load 10000 into $t4 for splitting $t2
	divu $t2, $t4					#Split unsigned number of $t2 and $t4
	
	mflo $t5						#Move upper bits into $t5
	sw $t5,  4($sp)					#Save upper bits onto stack
	mfhi $t5						#Move lower bits into $t5
	sw $t5,  8($sp)					#Save lower bits onto stack
	jal subprogram_3						#Go to subroutine 3
	
	lw $ra,	0($sp)					#Restore return address from the stack
	addi $sp, $sp, 12				#Return space on the stack
	jr $ra							#Return to main/subStringProcess
	
subprogram_2_error:
	lw $ra, 0($sp)					#Restore return address from the stack
	addi $sp, $sp, 12				#Return space on the stack
	
	la $a0, notNum		#Load address of notNum
	li $v0, 4						#Print notNum
	syscall
	
	jr $ra							#Return to main/subStringProcess
	
subprogram_3:	
	lw $a0, 4($sp)					#Load the upper bits of the unsigned number from the stack
	beq $a0, $zero, print_lower		#Don't print if upper bits is just 0
	li $v0, 1						#Print the integer
	syscall
	
print_lower:
	lw $a0, 8($sp)					#Load the lower bits of the unsigned number from the stack
	li $v0, 1						#Print the number
	syscall
	
	la $a0, comma					#Load comma string into $a0
	li $v0, 4						#Print comma string for separating the substrings
	syscall
	
	jr $ra							#Return back to subprogram_2
