.data
invalid_string: .asciiz "NaN"
large_string: .asciiz	"Large String"
string:  .space 1001
comma: .asciiz	" "
user_input: .space	1001

.text

main:
 #read users input
 li $v0, 8
 la $a0, user_input				#Store users string
 li $a1, 1001					#set string size limit equal to 1000
 syscall

 la $s1, string				#store address of string in $s1
 la $s2, ($a0)				#move address of input string to $s2
 la $s3, string				#store string address in $s3 to know printing location
 and $t8, $t8, $zero	#flag when char/space has been read
 and $t9, $t9, $zero	#string length counter (8 max length)

 loop:
 lb $s0, 0($s2)					#Load character into $s0

 slti $t1, $t9, 9				#Check if current substring is longer than 8 characters
 beq $t1, $zero, too_large	#if length is too long call too_large and skip to next comma

 beq $s0, $zero, print	#check if you've reached end of user input
 beq $s0, '\n', print   #check if you've reached end of user input
 beq $s0, ',', process_curr		#Process chars at the end of the current substring
 beq $s0, ' ', space_loop

 li $t8, 1						#Set seen valid character flag
 sb $s0, 0($s1)					#Save character in current string
 addi $s2, $s2, 1				#Go to next character in user input
 addi $s1, $s1, 1				#Go to next empty place in string
 addi $t9, $t9, 1				#Increment length counter

 j loop


 space_loop:
 addi $s2, $s2, 1				#Go to next character in current string
 lb $s0, 0($s2)					#Load character into $s0
 beq $s0, ' ', space_loop		#Skip space if at the beginning or at the end
 beq $s0, '\t', space_loop
 beq $s0, $zero, print	#check if you've reached end of user input
 beq $s0, '\n', print	#check if you've reached end of user input
 beq $s0, ',', process_curr		#Process chars at the end of the current substring

 j is_valid						#check if character is valid


 is_valid:
 bne $t8, $zero, string_error		#ff previous valid char has been read then NaN
 sb $s0, 0($s1)					#save first valid character in string
 li $t8, 1						#set seen valid character flag
 or $s3, $zero, $s1				#Update string head pointer
 addi $s1, $s1, 1				#next empty place in string
 addi $s2, $s2, 1				#next character from input
 addi $t9, $t9, 1				#Increment length counter

 j loop


 process_curr:
 la $a0, ($s3)					#load current substring starting from first letter
 beq $t8, $zero, string_error		#ff letter has not been seen then string is not valid
 jal subprogram_2

 addi $s2, $s2, 1				#Go to next character
 and $t8, $t8, $zero				#Reset seen valid character flag
 and $t9, $t9, $zero				#Reset substring counter
 or $s3, $s1, $zero				#Move head pointer of string to next substring beginning

 j loop


 print:
 la $a0, ($s3)					#Load beginning of current substring into $a0 as argument
 lb $t1, 0($s3)					#Load first character in current substring
 beq $t1, '\n', end				#Check if at end of input string
 beq $t1, $zero, end				#Check if at end of input string
 jal subprogram_2						#Go to subroutine 2
 j end


 string_error:
 la $a0, invalid_string		#Load address of invalid_string
 li $v0, 4						#Print invalid_string
 syscall

 add $s1, $s1, $t9				#Move pointer for writing to current string to an empty cell
 or $s3, $zero, $s1				#Update the head of current string accordingly
 or $t1, $t8, $zero
 and $t8, $t8, $zero				#Reset seen valid character flag
 and $t9, $t9, $zero				#Reset substring counter

 j skip_loop						#Skip to next substring


 too_large:
 la $a0, large_string		#Load address of invalid_string
 li $v0, 4						#Print invalid_string
 syscall

 add $s1, $s1, $t9				#Move pointer for writing to current string to an empty cell
 or $s3, $zero, $s1				#Update the head of current string accordingly
 or $t1, $t8, $zero
 and $t8, $t8, $zero				#Reset seen valid character flag
 and $t9, $t9, $zero				#Reset substring counter

 j skip_loop						#Skip to next substring


 skip_loop:
 addi $s2, $s2, 1				#Go to next character in current string
 lb $s0, 0($s2)					#Load character into $s0
 #beq $s0, ' ', loop				#Check for spaces at the beginning of new substring
 beq $s0, $zero, print	#Check if at end of input
 beq $s0, '\n', print	#Check if at end of input
 beq $t1, $zero, loop
 bne $s0, ',', skip_loop			#Continue loop if space is seen
 addi $s2, $s2, 1
 #sb $s0, 0($s1)					#First valid char encountered so save in string
 #or $s3, $s1, $zero				#If letter is seen then set head of current string accordingly
 #addi $s1, $s1, 1				#Move to next character
 #addi $s2, $s2, 1				#Move to next character
 #addi $t9, $t9, 1				#Update character counter


 j loop							#Continue loop


 end:
 add $t0, $s2, -1				#Check previous character
 lb $t1, 0($t0)					#Load the character into $t1
 beq $t1, ',', print_end			#If the last character was a comma then we know this was an invalid string

 li $v0, 10						#End program
 syscall


 print_end:
 la $a0, invalid_string		#Load address of invalid_string
 li $v0, 4						#Print error message
 syscall

 li $v0, 10						#End the program
 syscall

 subprogram_1:
 sll $t2, $t2, 4					#Multiply by 16

 slti $t4, $t3, ':'				#Check if character is a number
 bne $t4, $zero, is_num		#Take care of character being a number case

 slti $t4, $t3, 'G'				#Check if the character is uppercase
 bne $t4, $zero, is_uppercase		#Take care of character being uppercase

 addi $t4, $t3, -87				#Subtract 87 from lowercase to get hexadecimal value
 add $t2, $t2, $t4				#Add translated character to running sum

 jr $ra							#Return to subprogram_2


 is_num:
 addi $t4, $t3, -48				#Subract 48 from number to get hexadecimal value
 add $t2, $t2, $t4				#Add translated character to running sum
 jr $ra							#Return to subprogram_2


 is_uppercase:
 addi $t4, $t3, -55				#Subract 55 from uppercase to get hexadecimal value
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
 beq $t4, $zero, return_2	#If equal or greater than, then return from subprogram_2
 lb $t3, 0($t0)					#Load next character into $t3

 slti $t4, $t3, '0'				#Check if current character is less than ascii value of '0'
 bne $t4, $zero, string_error2		#Substring is not a valid string

 slti $t4, $t3, 'A'				#Check if current character is less than ascii value of 'A'
 slti $t5, $t3, ':'				#Check if current character is less than ascii value of ':'
 bne $t4, $t5, string_error2		#If checks are not equal then character is between '9' and 'A'

 slti $t4, $t3, 'a'				#Check if current character is less than ascii value of 'a'
 slti $t5, $t3, 'G'				#Check if current character is less than ascii value of 'G'
 bne $t4, $t5, string_error2		#If checks are not equal then character is between 'F' and 'a'

 slti $t4, $t3, 'g'
 beq $t4, $zero, string_error2		#Substring is not a valid string

 jal subprogram_1						#Go to subprogram_1

 addi $t1, $t1, 1				#Increment character counter
 addi $t0, $t0, 1				#Go to the next character in the substring

 j subprogram_2_loop					#Continue the loop


 string_error2: #invalid string for subprogram 2
 lw $ra, 0($sp)					#Restore return address from the stack
 addi $sp, $sp, 12				#Return space on the stack

 la $a0, invalid_string		#Load address of invalid_string
 li $v0, 4						#Print invalid_string
 syscall

 jr $ra							#Return to main/process_curr


 return_2: #returns value of subprogram_2
 li $t4, 10						#Load 10000 into $t4 for splitting $t2
 divu $t2, $t4					#Split unsigned number of $t2 and $t4

 mflo $t5						#Move upper bits into $t5
 sw $t5,  4($sp)					#Save upper bits onto stack
 mfhi $t5						#Move lower bits into $t5
 sw $t5,  8($sp)					#Save lower bits onto stack
 jal subprogram_3						#Go to subroutine 3

 lw $ra,	0($sp)					#Restore return address from the stack
 addi $sp, $sp, 12				#Return space on the stack
 jr $ra							#Return to main/process_curr


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

jr $ra                                                        #Return back to subprogram_2
