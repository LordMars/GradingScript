# HEXADECIMAL TO DECIMAL CONVERTER, by Sean Mills
# Tmp registers used:
# $t0: sum
# $t1: address
# $t2: length ( or end of a hex value in subprogram 3)
# $t3: character
# $t4: power
# $t5: x, (16^n)
# $t6: mult, the value of the hexadecimal digit in string (0, 1, 2,...,15)
# $t7: product
# $t8: quotient, and also the characters, '0'-'9' and 'A'-'F'
# $t9: remainder, and also the characters, 'a'-'f'
# $s0: keeps track of the address of the first character in one hex value
# $s1: keeps track of the addres of the end of that hex value (',', '\n' or null)
# decimal integer = (x * mult0) + (x * mult1) +...+ (x * multn)
	
	.text
main:
	la $a0, hex_str
	li $a1, 1002
	li $v0, 8						# read user input
	syscall
	add $s0, $zero, $a0				# store address of list of hex string in $s0
main_loop:
	add $s1, $s0, $zero				# store address of list of hex string in $s1 as well
# finds the end of one hex value by looking for ',' or '/'
find_end:
	lb $t0, ($s1)					
	beq $t0, 44, end_find			# when $t0 is ',' end_find
	beq $t0, 10, end_find			# when $t0 is '\n' end_find
	beqz $t0, end_find				# when $t0 is null end_find
	add $s1, $s1, 1					# otherwise, move to the next character 
	b find_end						# and repeat
end_find:
	addi $sp, $sp, -12				# adjust stack for 3 items: return address, deimal int, and end of hex value
	add $a0, $s0, $zero				# pass the beginning of hex val
	jal subprogram_2				# to subprogram 2
	sw $s1, 8($sp)					# push the address of the end of a hex value to the stack
	jal subprogram_3				# pass it to subprogram 3
	lb $t0, ($s1)					
	addi $sp, $sp, 12				# destruct stack
	bne $t0, 44, exit				# if the end of that hex value is also the end of the entire string, exit
	add $s0, $s1, 1					# otherwise, find the beginning of the next hex val
	b main_loop						# and repeat
exit:
	la $a0, new_line				# print new line at the end of string
	li $v0, 4
	syscall
	li $v0, 10						# exit
	syscall

########################################################################### Subprogram 2
# gets address of the first character of the hex value and converts the entire hex value
# it uses this address to also find the end of the value
# Arg register used: $a0
# Tmp registers used: $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7
# Post: stack contains decimal integer
# returns decimal integer
# called by main
# calls subprogram_1
subprogram_2:
	add $t0, $zero, $zero						# initialize sum
	add $t1, $zero, $a0							# store address of hex string in $t1
	add $t2, $zero, $zero						# intialize length
	sw $ra, 0($sp)								# save return address
# check for spaces before, between, and after digits
space_check:									
	lb $t3, ($t1)
	beq $t3, 10, nan							# if there are no digits, display error message
	beq $t3, 44, nan
	beqz $t3, nan
	bne $t3, 9, check_if_not_space1				# if character is not a tab, check if it's neither a space
	b dont_check1
check_if_not_space1:
	bne $t3, 32, check_for_space_after_char		# once a character is found that is not a space, \t, or \n,
dont_check1:
	add $t1, $t1, 1
	b space_check
check_for_space_after_char:						# check for spaces after that character
	lb $t3, ($t1)
	beq $t3, 44, end_space_check
	beq $t3, 10, end_space_check				# if there are no spaces after that, proceed with the program
	beqz $t3, end_space_check
	beq $t3, 9, check_for_char_after_space
	beq $t3, 32, check_for_char_after_space		# if there is a space or tab after that, check if there are anymore digits
	add $t1, $t1, 1								# otherwise, check the next character
	b check_for_space_after_char
check_for_char_after_space:
	lb $t3, ($t1)
	beq $t3, 10, end_space_check				# if there are no more non-space characters, proceed with the program
	beqz $t3, end_space_check
	beq $t3, 44, end_space_check
	bne $t3, 9, check_if_not_space2
	b dont_check2
check_if_not_space2:
	bne $t3, 32, nan							# if there is a non-space character, display error message
dont_check2:
	add $t1, $t1, 1								# otherwise, check the next character
	b check_for_char_after_space
end_space_check:								
	add $t1, $zero, $a0							# reset address pointer
length_loop:
	lb $t3, ($t1)					# load a byte in hex string into $t3
	beqz $t3, sub_length1			# if character is null, branch to sub_length
	beq $t3, 10, sub_length2		# if character is '\n' branch to sub_length2
	beq $t3, 44, sub_length2		# if character is ',' branch to sub_length2
	beq $t3, 32, skip_increment		# if the character is a space, do not increment length
	beq $t3, 9, skip_increment		# if the character is a tab, do not increment length
	add $t2, $t2, 1					# increment length
skip_increment:
	addi $t1, $t1, 1				# move to the next character in the string,
	b length_loop					# and repeat
sub_length1:						# move length back 2 spaces, to represent the largest exponent
	sub $t2, $t2, 2
	b reset_address
sub_length2:						# move length back 1 space to represent the largest exponent
	sub $t2, $t2, 1
reset_address:
	bgt $t2, 7, too_large			# if length > 7 (largest possible exponent), display error message
	add $t1, $zero, $a0				# move pointer back to the first character
# check_loop verifires each character in the hex string
check_loop:
	add $t4, $zero, $zero			# initialize power
	add $t5, $zero, 1				# set x to 1
	lb $t3, ($t1)					# load byte from address
	add $a0, $t3, $zero				# make the character a parameter 
	jal subprogram_1				# call subprogram 1
	add $t6, $zero, $v0				# get the value returned
	beq $t6, -1, nan				# if the character was invalid, return address of "NaN"
	beq $t6, 16, next_char			# if the character was a space or tab, ignore it and more to the next character
	b power_loop					# repeat
next_char:
	add $t1, $t1, 1					# move to the next character
	b check_loop					# and repeat
power_loop:
	beq $t4, $t2, end_power_loop	# if power == length, then end loop
	mulou $t5, $t5, 16				# x = x * 16
	addi $t4, $t4, 1				# increment power
	b power_loop					# and repeat
end_power_loop:
	beqz $t2, set_x_to_one			# if the string entered had only one character,
	j sum
set_x_to_one:
	addi $t5, $zero, 1				# set x to 1
sum:
	mulou $t7, $t5, $t6				# product = x * mult
	add $t0, $t0, $t7				# sum += product
	addi $t1, $t1, 1				# increment address to move to the next character
	beqz $t2, return_full_int		# when length is 0, return decimal 
	sub $t2, $t2, 1					# decrement length
	b check_loop					# repeat check_loop
nan:
	la $a0, nan_msg				# get address of "NaN"
	add $t0, $zero, $a0			# store address in $t0
	b return_full_int
too_large:
	la $a0, too_large_msg		# get address of "too large"
	add $t0, $zero, $a0			# store address in $t0
return_full_int:
	lw $ra, 0($sp)				# get the return address from the stack
	sw $t0, 4($sp)				# push the decimal value to be returned, to the stack
	jr $ra						# return

################################################################## Subprogram 1
# get a hex character from subprogram 2, converts it to decimal, and returns it
# Arg register used: $a0
# Tmp registers used: $t3, $t6, $t9
# Post: $v0 contains decimal integer of one hex character
# returns decimal integer
# called by subprogram_2
# calls: none
subprogram_1:
	add $t3, $a0, $zero				# get character from parameter
check_characters1:					
	beq $t3, 32, skip_char			# if character is a space,
	beq $t3, 9, skip_char			# or a tab, branch to skip_char
check_characters2:					
	add $t8, $zero, 48				# set $t8 to the character, '0'
	add $t6, $zero, $zero			# set mult to 0
check_numbers:
	beq $t8, 58, end_check_numbers	# when $t8 is outside the range of '0'-'9', check for letters
	beq $t3, $t8, set_int			# when character is found, go back to power_loop
	add $t8, $t8, 1					# increment $t8
	add $t6, $t6, 1					# increment mult
	b check_numbers
end_check_numbers:
	add $t8, $zero, 65				# set $t8 to the character, 'A'
	add $t9, $zero, 97				# set $t9 to the charatcer, 'a'
check_letters:
	beq $t8, 71, invalid_char		# if the character in the string is invalid, branch to invalid_char
	beq $t3, $t8, set_int			# when character is found, branch to set_int
	beq $t3, $t9, set_int			
	add $t8, $t8, 1					# increment $t8
	add $t9, $t9, 1					# increment $t9
	add $t6, $t6, 1					# increment mult
	b check_letters					# and repeat
invalid_char:
	add $v0, $zero, -1				# set return value to -1, so the program knows the character is invalid
	b return_int
skip_char:
	add $v0, $zero, 16				# set return value to 16, so the program knows the character is a space or tab
	b return_int
set_int:
	add $v0, $t6, $zero				# store decimal integer as return value
return_int:
	jr $ra							# return

################################################################################# Subprogram 3
# gets decimal integer (or address of error message) and address end of hex value from main
# it uses the address of the end of that hex value, to determine if it should also print a ','
# Arg register used: $a0 (for printing)
# Tmp registers used: $t0, $t1, $t2, $t8, $t9
# Post: none
# returns: void
# called by main
# calls: none
subprogram_3:
	lw $t1, 8($sp)					# get address of end of hex value (',' or '\n') from stack
	lw $t0, 4($sp)					# get decimal integer (or address of error message) from stack
	la $a0, nan_msg					
	beq $t0, $a0, print_error_str	# display NaN if input is invalid
	la $a0, too_large_msg
	beq $t0, $a0, print_error_str	# display "too large" if input is too large
	add $t9, $zero, 10				# store 10 in $t9
	divu $t0, $t9					# split the value into 2 halves
	mflo $t8						# store the first half in $t8
	mfhi $t9						# store the second half in $t9
	beqz $t8, print_2nd_half		# if the first half is 0, only print the second
	move $a0, $t8					# display first half
	li $v0, 1
	syscall
print_2nd_half:					
	move $a0, $t9					# display second half
	li $v0, 1
	syscall
	b print_comma
print_error_str:
	li $v0, 4						# print error message
	syscall
print_comma:
	lb $t2, ($t1)					# get character at the end of that hex value entered
	beq $t2, 10, return				# if it is the end of the entire list, return
	beqz $t2, return				
	la $a0, 44						# otherwise, print ',' then return
	li $v0, 11
	syscall
return:
	jr $ra							# return

	.data				
hex_str: .space 1002
new_line: .asciiz "\n"
nan_msg: .asciiz "NaN"
too_large_msg: .asciiz "too large"
