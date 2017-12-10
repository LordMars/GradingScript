.data

invalidInput:	.asciiz	"NaN "
invalidInputLength:		.asciiz	"Too large "
comma:					.asciiz	", "
userInput:				.space	1001
myString:				.space	1001

	.globl main
	.text
	
main:

	li $v0, 8						#Read in string
	la $a0, userInput				#Store string in buffer
	li $a1, 1001					#Limit size to 1000
	syscall
	
	la $s1, myString				#Save address of myString in $s1
	la $s2, ($a0)					
	la $s3, myString				
	and $t8, $t8, $zero				
	and $t9, $t9, $zero				
	
						

loop:
	lb $s0, 0($s2)					#Load character into $s0
	
	slti $t1, $t9, 9				#Check if current substring is longer than 8 characters
	beq $t1, $zero, tooLongErr	#Throw tooLongErr and skip to next comma
	
	beq $s0, $zero, displayStr	#Check if at exit of input
	beq $s0, '\n', displayStr	#Check if at exit of input
	beq $s0, ',', calcNewStr		#Process chars at the exit of the current substring
	beq $s0, ' ', spaces
	
	li $t8, 1						#Set seen valid character flag
	sb $s0, 0($s1)					#Save character in current string
	addi $s2, $s2, 1				#Go to next character from input
	addi $s1, $s1, 1				#Go to next empty place in myString
	addi $t9, $t9, 1				#Increment current substring length counter (max 8)
	
	j loop							#Continue loop
	

spaces:
	addi $s2, $s2, 1				#Go to next character in current string
	lb $s0, 0($s2)					#Load character into $s0
	beq $s0, ' ', spaces		#Skip space if at the beginning or at the exit
	beq $s0, '\t', spaces
	beq $s0, $zero, displayStr	#Check if at exit of input
	beq $s0, '\n', displayStr	#Check if at exit of input
	beq $s0, ',', calcNewStr		#Process chars at the exit of the current substring
	
	j valid						#Check if this is a valid char after reading spaces
	

valid:
	bne $t8, $zero, Error		#If previous valid char has been read then NaN
	sb $s0, 0($s1)					
	li $t8, 1						
	or $s3, $zero, $s1				
	addi $s1, $s1, 1				
	addi $s2, $s2, 1				
	addi $t9, $t9, 1				
	
	j loop	
	
calcNewStr:
	la $a0, ($s3)					#Load beginning of current substring into $a0 as argument
	beq $t8, $zero, Error		#If letter has not been seen then string is not valid
	jal subprogram_2						#Go to subroutine 2
	
	addi $s2, $s2, 1				#Go to next character from input
	and $t8, $t8, $zero				#Reset seen valid character flag
	and $t9, $t9, $zero				#Reset substring counter
	or $s3, $s1, $zero				#Move head pointer of myString to next substring beginning
	
	j loop							#Go back to main loop
	
	
displayStr:
	la $a0, ($s3)				
	lb $t1, 0($s3)					
	beq $t1, '\n', exit				
	beq $t1, $zero, exit				
	jal subprogram_2						
	j exit
	
	
Error:
	la $a0, invalidInput		#Load address of invalidInput
	li $v0, 4						#Print invalidInput
	syscall
		
	add $s1, $s1, $t9				#Move pointer for writing to current string to an empty cell
	or $s3, $zero, $s1				#Update the head of current string accordingly
	and $t8, $t8, $zero				#Reset seen valid character flag
	and $t9, $t9, $zero				#Reset substring counter
	
	j skip						#Skip to next substring

		

tooLongErr:
	la $a0, invalidInputLength		#Load address of invalidInput
	li $v0, 4						#Print invalidInput
	syscall
	
	add $s1, $s1, $t9				#Move pointer for writing to current string to an empty cell
	or $s3, $zero, $s1				#Update the head of current string accordingly
	and $t8, $t8, $zero				#Reset seen valid character flag
	and $t9, $t9, $zero				#Reset substring counter
	
	j skip	
skip:
	addi $s2, $s2, 1				#Go to next character in current string
	lb $s0, 0($s2)					#Load character into $s0
	beq $s0, ',', loop				#Check for spaces at the beginning of new substring
	beq $s0, $zero, displayStr	#Check if at exit of input
	beq $s0, '\n', displayStr	#Check if at exit of input
	bne $s0, ',', skip			#Continue loop if space is seen
	#sb $s0, 0($s1)					#First valid char encountered so save in myString
	#or $s3, $s1, $zero				#If letter is seen then set head of current string accordingly
	#addi $s1, $s1, 1				#Move to next character
	#addi $s2, $s2, 1				#Move to next character
	#addi $t9, $t9, 1				#Update character counter
	
	
	j loop							#Continue loop
					#Skip to next substring
	

	
exit:
	add $t0, $s2, -1				#Check previous character
	lb $t1, 0($t0)					#Load the character into $t1
	beq $t1, ',', quit			#If the last character was a comma then we know this was an invalid string
	
	li $v0, 10						#End program
	syscall


quit:
	la $a0, invalidInput		#Load address of invalidInput
	li $v0, 4						#Print error message
	syscall
	
	li $v0, 10						#End the program
	syscall
#Subprogram 1: Converts a hexadecimal character to a decimal integer

subprogram_1:
	sll $t2, $t2, 4					#Multiply by 16
	
	slti $t4, $t3, ':'				#Check if character is a number
	bne $t4, $zero, digits		#Take care of character being a number case
	
	slti $t4, $t3, 'G'				#Check if the character is uppercase
	bne $t4, $zero, letters		#Take care of character being uppercase
	
	addi $t4, $t3, -87				#Subtract 87 from lowercase to get hexadecimal value
	add $t2, $t2, $t4				#Add translated character to running sum
	
	jr $ra							#Return to subprogram_2
	

digits:
	addi $t4, $t3, -48				#Subract 48 from number to get hexadecimal value					
	add $t2, $t2, $t4				#Add translated character to running sum
	jr $ra							#Return to subprogram_2
	

letters:
	addi $t4, $t3, -55				#Subract 55 from uppercase to get hexadecimal value
	add $t2, $t2, $t4				#Add translated character to running sum
	
	jr $ra							#Return to subprogram_2
	
	
#Subprogram 2: It converts a single hexadecimal string to a decimal integer; Calls Subprogram 1 to get the decimal value of each of the characters in the myString. Registers used to pass parameters into the subprogram; Values are returned through the stack.

subprogram_2:
	la $t0, ($a0)					#Load current substring head from argument $a0 into $t0
	addi $sp, $sp, -12				#Make space on the stack for return addresses and return values
	sw $ra, 0($sp)					#Save return address on the stack
	and $t1, $t1, $zero				#Character counter up to value of $t9
	and $t2, $t2, $zero				#Will hold the unsigned integer to be printed
	and $t3, $t3, $zero				#Will hold the characters being read in
	
subprogram_2_loop:
	slt $t4, $t1, $t9				#Check if counter is less than substring length
	beq $t4, $zero, returnSub2	#If equal or greater than, then return from subprogram_2
	lb $t3, 0($t0)					#Load next character into $t3
	
	slti $t4, $t3, '0'				
	bne $t4, $zero, sub2err		
	
	slti $t4, $t3, 'A'				
	slti $t5, $t3, ':'				
	bne $t4, $t5, sub2err		
	
	slti $t4, $t3, 'a'			
	slti $t5, $t3, 'G'				
	bne $t4, $t5, sub2err		
	
	slti $t4, $t3, 'g'
	beq $t4, $zero, sub2err		#Substring is not a valid string
	
	jal subprogram_1						#Go to subprogram_1
	
	addi $t1, $t1, 1				#Increment character counter
	addi $t0, $t0, 1				#Go to the next character in the substring
	
	j subprogram_2_loop					#Continue the loop
	
	
sub2err:
	lw $ra, 0($sp)					#Restore return address from the stack
	addi $sp, $sp, 12				#Return space on the stack
	
	la $a0, invalidInput		#Load address of invalidInput
	li $v0, 4						#Print invalidInput
	syscall
	
	jr $ra							#Return to main/calcNewStr
	
	
returnSub2:
	li $t4, 10000					#Load 10000 into $t4 for splitting $t2
	divu $t2, $t4					#Split unsigned number of $t2 and $t4
	
	mflo $t5						#Move upper bits into $t5
	sw $t5, 4($sp)					#Save upper bits onto stack
	mfhi $t5						#Move lower bits into $t5
	sw $t5, 8($sp)					#Save lower bits onto stack
	jal subprogram_3						#Go to subroutine 3
	
	lw $ra,	0($sp)					#Restore return address from the stack
	addi $sp, $sp, 12				#Return space on the stack
	jr $ra							#Return to main/calcNewStr
	
#Subprogram 3: Displays an unsigned decimal integer

subprogram_3:	
	lw $a0, 4($sp)					#Load the upper bits of the unsigned number from the stack
	beq $a0, $zero, print_lower		
	li $v0, 1						#Print the integer
	syscall
	
print_lower:
	lw $a0, 8($sp)					
	li $v0, 1						
	syscall
	
	la $a0, comma
	li $v0, 4						
	syscall
	
	jr $ra							#Return back to subprogram_2
