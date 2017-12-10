# A MIPS Program that prints the corresponding decimal number 
# of an hexadecimal number specified by user input
.data
str: .space 9
str2: .space 1000
error: .asciiz "Invalid hexadecimal number."
comma_string: .asciiz ","
nan: .asciiz "NaN"
large: .asciiz "too large"
buffer: .space 11	# buffer string to store decimal string

.text
main:
addi $s0, $zero, 0    			# Initialize $s0

addi $s1, $zero, 0				# Initialize $s1

li $v0, 8 						# Read in hexadecimal numbers
la $a0, str2
li $a1, 1000					# of size 1000 
syscall

la $s4, str2					# Load address of str2

addi $s6, $zero, 0				# Initialize check $s6

anotherloop:
add $s5, $s4, $zero				# Copy the address of str2 to $s5

lbu $t3, 0($s5)					# Load character at $s5
bne $t3, $zero, checkenter		# Exit loop if the null character is encountered
bne $s1, 1, continue			# Check if previous character was comma
# Print NaN
li $v0, 4 						
la $a0, nan						# Print NaN if so
syscall
j continue

checkenter:
addi $t7, $zero, 10 
bne $t3, $t7, innerloop			# Exit loop if enter character is encountered
bne $s1, 1, continue			# Check if previous character was comma
# Print NaN
li $v0, 4 						
la $a0, nan						# Print NaN if so
syscall
j continue

innerloop:
lbu $t3, 0($s5)					# Load character at $s5 --
addi $t7, $zero, 44				# Load the ascii value of comma for comparison
addi $t6, $zero, 10				# Load the ascii value of enter for comparison
bne $t3, $t6, notenter			# Check if the ascii value is enter
addi $s6, $zero, 1				# Add a check to indicate that enter character denoting end of input has been encountered
j equalenter
notenter:
bne $t3, $zero, notzero			# Check if the ascii value is zero
addi $s6, $zero, 1				# Add a check to indicate that zero denoting end of input has been encountered
j equalenter
notzero:
bne $t3, $t7, notcomma			# Check if the ascii value is comma
addi $s1, $zero, 1				# Add a check to indicate last value encountered was comma
equalenter: 
add $a0, $s4, $zero				# Add address of string to argument for subprogram_2 function
jal subprogram_2				# Call function to convert hexadecimal string to integer
lw $s0, 0($sp)					# Copy return value from stack to $s0

addi $t8, $zero, 1				# Check that returned value is not NaN
sub  $t7, $zero, $t8
bne $s0, $t7, notnan
li $v0, 4 						
la $a0, nan						# Print NaN if so
syscall
# Print comma
bne $s6, $zero, continue		# Don't print comma after last input
li $v0, 4 						
la $a0, comma_string
syscall
addi $s4, $s5, 1
j anotherloop

notnan:							# Check that returned value is not too large
addi $t7, $zero, 2
sub  $t7, $zero, $t7
bne $s0, $t7, nottoolarge
li $v0, 4 						
la $a0, large					# Print too large if so
syscall

# Print comma
bne $s6, $zero, continue		# Don't print comma after last input
li $v0, 4 						
la $a0, comma_string
syscall

addi $s4, $s5, 1
j anotherloop
 
nottoolarge:
#addi $sp, $sp, 4				# Increment stack pointer by 4
jal subprogram_3 				# Print decimal string

# Print comma
print_comma:
bne $s6, $zero, continue		# Don't print comma after last input
li $v0, 4 						
la $a0, comma_string
syscall

addi $s4, $s5, 1
j anotherloop
notcomma:
addi $s1, $zero, 0				# Add a check that the last character encountered was not comma
addi $s5, $s5, 1				# Check the next value
j innerloop	

continue:						# Exit anotherloop
#Exit program ideally

li $v0, 10 						# Exit Program
syscall

########################################subprogram_3
# Function prints unsigned decimal value of argument
#
# Arg registers used: none
# Tmp registers used: $t0, $t6, $t7
#
# Pre: 0($sp) contains the argument value
# Post: none
# Returns: none
#
# Called by: main
# Calls: none
subprogram_3:
la $t0, buffer

lw $t2, 0($sp)					# Copy argument from stack
addi $sp, $sp, 4				# Increment the stack

# write buffer spaces to all space

addi $t7, $zero, 0
sb $t7, 8($t0)					# Null terminate the buffer string

addi $t0, $t0, 8				# Start from the end of the buffer string

stringloop: addi $t6, $zero, 1
sub $t0, $t0, $t6				# Subtract 1 from s3
addi $t6, $zero, 10
divu $t2, $t6					# Divide the decimal in $t2 by 10
mfhi $t7						# Put the remainder in $t7
mflo $t2						# Put the quotient in $t2
addi $t7, $t7, 48 				# Convert decimal in $t7 to ascii
sb $t7, 0($t0)   				# store remainder in $t0

bne $t2, $zero, stringloop		# Continue looping until quotient is 0

finalexit: 

li $v0, 4  						# Print string
la $a0, 0($t0)
syscall

jr $ra							# Exit function

########################################subprogram_2
# Function returns decimal value of an hexadecimal string
#
# Arg registers used: $a0
# Tmp registers used: $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9
#
# Pre: none
# Post: 0($sp) contains the return value
# Returns: the value of the hex, -1 if not valid, -2 if too large
#
# Called by: main
# Calls: subprogram_1
subprogram_2:
addi $t6, $zero, 0				# Initialize $t6 to 0

add $t9, $a0, $zero				# Load address of string from argument
lbu $t2, 0($t9)					# Load character at $t9
addi $t1, $zero, 0				# initialize counter $t1 to zero
add $t5, $ra, $zero 			# Store the value in $ra into $t5

sp: 
addi $t7, $zero, 44				# Store 44 - ascii comma in $t7
bne $t2, $t7, notcomma1			# Check if comma
gotofinish:
addi $t7, $zero, 1
sub $t6, $zero, $t7				# the input character is not a hex value, set return value to -1
j finish						# exit subfunction

notcomma1:
addi $t7, $zero, 10				# Store 10 - ascii enter in $t7
bne $t2, $t7, notenter1			# Check if enter
j gotofinish

notenter1:
bne $t2, $zero, notnull1			# Check if null
j gotofinish

notnull1:
addi $t7, $zero, 32			# Store 32 - ascii space in $t7
bne $t2, '\t', nottab
addi $t9, $t9, 1				
lbu $t2, 0($t9)					# Load the next charcter
j sp							# Repeat until character is not tab
nottab:
bne $t2, $t7, loop				# If not space branch to loop
addi $t9, $t9, 1				
lbu $t2, 0($t9)					# Load the next charcter
j sp							# Repeat until character is not space

loop: 
add $a0, $zero,  $t2			# Initialize values for function: subprogram_1
jal subprogram_1
addi $t7, $zero, 1				# Set temporary variable to 1
sub $t3, $zero, $t7				# Set temporary variable to -1
bne $v0, $t3, checkspace		# Check whether $v0 is not equal to -1

addi $t7, $zero, 1
sub $t6, $zero, $t7				# the input character is not a hex value, set return value to -1
j finish						# exit subfunction

checkspace:						# Check if space
addi $t7, $zero, 2
sub $t3, $zero, $t7
bne $v0, $t3, valid

addi $t9, $t9, 1				
lbu $t2, 0($t9)					# Load the next charcter

bne $t2, '\t', nottab1
j checkspace

nottab1:
addi $t7, $zero, 32
bne $t2, $t7, notspace
j checkspace

notspace:						# If character after space is not space, check if comma
addi $t7, $zero, 44
bne $t2, $t7, notcomma2
j finish						# If character after space is comma, valid, go to finish

notcomma2:
addi $t7, $zero, 10
bne $t2, $t7, notenter2
j finish

notenter2:
bne $t2, $zero, gotofinish
j finish


valid: add $t0, $v0, $zero
bne $t1, $zero, else			# If it's the first number, don't shift the register
j both
else: sll $t6, $t6, 4   		# Shift register that stores the decimal number by 4
both: add $t6, $t6, $t0			# Add the new decimal returned by subprogram_1 to the number

addi $t1, $t1, 1				# Update the counter

addi $t9, $t9, 1
lbu $t2, 0($t9)					# Load the next  character

addi $t8, $zero, 9				# if counter is 9, hex is too large
bne $t1, $t8, checkfinish
addi $t7, $zero, 2				# Set return value to 2
sub $t6, $zero, $t7	
j finish

checkfinish:
beq $t2, $zero, finish 			# Exit loop when next character in string is null
addi $t8, $zero, 10
beq $t2, $t8, finish			# Exit loop when next character in string is enter
addi $t8, $zero, 44
beq $t2, $t8, finish 			# Exit loop when next character in string is comma

j loop

finish:
addi $sp, $sp, -4				# Decrement stack pointer by 4
sw $t6, 0($sp)					# Copy $t6 to stack

add $ra, $t5, $zero				# Reload $ra from t5
jr $ra


########################################subprogram_1
# Function returns decimal value of a single hexadecimal value using ascii ranges
#
# Arg registers used: $a0
# Tmp registers used: $t0, $t2, $t3, $t4, $t7
#
# Pre: none
# Post: $v0 contains the return value
# Returns: the value of the hex, -1 if not valid, -2 if space
#
# Called by: subprogram_2
# Calls: none
subprogram_1:	
addi $t7, $zero, 1								
sub $v0, $zero, $t7				# Initialize $v0 to -1

addi $t7, $zero, 32
bne $a0, $t7, checktab
j isspace

checktab:
bne $a0, '\t', start			# If ascii character is tab, return -2

isspace:
addi $t7, $zero, 2				# If ascii character is space, return -2
sub $v0, $zero, $t7
jr $ra

start:
li $t0, 48						# Initialize lower bound for the ascii range 0 - 9
li $t2, 58						# Initialize upper bound the ascii range 0 - 9
add $t3, $t0, $zero				# t3 is the value to be subtracted from the ascii value to get its value in hex

l1: bne $a0, $t0, ne1 			# a0 is the ascii value, t0 is the lower bound of the ascii range to be checked
sub $v0, $t0, $t3				# t3 is the value to be subtracted from the ascii value to get its value in hex
jr $ra
ne1: addi $t0, $t0, 1
bne $t0, $t2, nne1				# t2 is the upper bound of the ascii range plus 1
j label1						# Hex value not in range, try next range
nne1: j l1

label1: li $t0, 65				# Initialize lower bound for the ascii range A - F
li $t2, 71						# Initialize upper bound for the ascii range A - F
addi $t4, $zero, 10				# Set temporary variable to 10
sub $t3, $t0, $t4				# t3 is the value to be subtracted from the ascii value to get its value in hex

l2: bne $a0, $t0, ne2 			# a0 is the ascii value, t0 is the lower bound of the ascii range to be checked
sub $v0, $t0, $t3				# t3 is the value to be subtracted from the ascii value to get its value in hex
jr $ra
ne2: addi $t0, $t0, 1
bne $t0, $t2, nne2				# t2 is the upper bound of the ascii range plus 1
j label2						# Hex value not in range, try next range
nne2: j l2

label2: li $t0, 97				# Initialize lower bound for the for the ascii range a - f
li $t2, 103						# Initialize upper bound for the ascii range a - f
addi $t4, $zero, 10				# Set temporary variable to 10
sub $t3, $t0, $t4				# t3 is the value to be subtracted from the ascii value to get its value in hex

l3: bne $a0, $t0, ne3 			# a0 is the ascii value, t0 is the lower bound of the ascii range to be checked
sub $v0, $t0, $t3				# t3 is the value to be subtracted from the ascii value to get its value in hex
jr $ra							# Return the decimal value
ne3: addi $t0, $t0, 1
bne $t0, $t2, nne3				# t2 is the upper bound of the ascii range plus 1
jr $ra							# Invalid hex value, return
nne3: j l3