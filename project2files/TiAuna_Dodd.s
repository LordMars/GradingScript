	.data
create_space: .space 1001
current_string: .space 1001
clean_string: .space 1001
output_string_reversed: .space 1001
output_string: .space 1001

error: .asciiz "NaN"
error_too_large: .asciiz "too large"
newline:  .asciiz "\n"
comma_string: .asciiz ","

	.text
main:
	li $v0, 8
	la $a0, create_space
	li $a1, 1001
	syscall
	add $s5, $zero, $a0
	la $t2, current_string

#loop to read each character from the input
length_of_input:
	lb $t1, 0($s5)
	beq $t1, 44, call_sub_programs
	beq $t1, 0, call_sub_programs
	beq $t1, 10, call_sub_programs
	j update_state

#only call sub_programs once ',' or '\n', or '\0' is reached
call_sub_programs:
	sb $zero, 0($t2)
	#extract string without spaces (and end string with null character)
	j clean_current_string
return_from_cleaning_ok:
#if spaces were found to be okay,  return here and call sub program 1
	la $a0 clean_string
	addi $v1, $sp, 0
	jal sub_program_2
#if subprogram1 has already printed out NaN or too large
	beq $v1, $sp, return_from_cleaning_not_ok
	jal sub_program_3
return_from_cleaning_not_ok:
	lb $t1, 0($s5)
	beq $t1, 0, exit
	beq $t1, 10, exit
	li $v0, 4
	la $a0, comma_string
	syscall
	la $t2, current_string
	j dont_store_byte

#store each read character in temporary string
update_state:
	sb $t1, 0($t2)
	addi $t2, $t2, 1

#skip past storing last byte read when beginning new string processing
#generally updartes the readng of the input string
dont_store_byte:
	addi $s5, $s5, 1
	j length_of_input

#	validates the spaces arrangements and extracts
#	the hex string into clean_string
clean_current_string:
	la $s0, current_string
	lb $t1, 0($s0)
#go ast the leading spaces
skip_leading_spaces_and_tabs:
	#if terminating character (, /0, or /n)is found while skipping leading spaces, print NaN
	beq $t1, ',', handle_space_invalid_hex_string
	beq $t1, 10, handle_space_invalid_hex_string
	beq $t1, 0, handle_space_invalid_hex_string
	beq $t1, ' ', skip_space_or_tab
	beq $t1, '	', skip_space_or_tab
	j check_spaces_in_between
skip_space_or_tab:
	addi $s0, $s0, 1
	lb $t1, 0($s0)
	j skip_leading_spaces_and_tabs
#look for spaces that occur in between characters, such spaces cannot be leading spaces
check_spaces_in_between:
	la $s1, clean_string
	lb $t1, 0($s0)
#if a spaces if found, make sure no other character is found
check_no_space_divide_loop:
	beq $t1, ' ', ensure_no_other_char
	beq $t1, '	', ensure_no_other_char
	beq $t1, ',', deal_with_actual_string
	beq $t1, 0, deal_with_actual_string
	beq $t1, 10, deal_with_actual_string
	sb $t1, 0($s1)
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	lb $t1, 0($s0)
	j check_no_space_divide_loop
#ensure that no other character is found
ensure_no_other_char:
	beq $t1, 0, deal_with_actual_string
	beq $t1, 10, deal_with_actual_string
	beq $t1, ',', deal_with_actual_string
	beq $t1, ' ', skip_space_or_tab_2
	beq $t1, '	', skip_space_or_tab_2
	j handle_space_invalid_hex_string
skip_space_or_tab_2:
	addi $s0, $s0, 1
	lb $t1, 0($s0)
	j ensure_no_other_char

#to get to this point, space validation has been passed
#extracted substringis pointed to by s1
#MUST TERMINATE WITH 0 otherwise characters from residual substring will affect
deal_with_actual_string:
	sb $zero, 0($s1)
	j return_from_cleaning_ok

#when string is invalid by space, return to "return_from_cleaning _not oka label"
handle_space_invalid_hex_string:
	li $v0, 4
	la $a0, error
	syscall
	j return_from_cleaning_not_ok

#when size is determined invalid (IN SUB PROGRAM 2!), return to place of funciton call
handle_size_invalid_hex_string:
	li $v0, 4
	la $a0, error_too_large
	syscall
	jr $ra

exit:
	li $v0, 10
	syscall

#	currently simply prints out hex string read in
sub_program_2:
	addi $t3, $a0, 0
#first count string to make sure it is not too large
	li $t9, 0
	lb $t1, 0($t3)
count_loop:
	beq $t1, 0, end_count_loop
	addi $t9, 1
	addi $t3, 1
	lb $t1, 0($t3)
	j count_loop
end_count_loop:
	slti $t9, $t9, 9
	beq $t9, 0, handle_size_invalid_hex_string

	addi $t3, $a0, 0		#point to clean_string start again
	lb $t1, 0($t3)
	li $s8, 0

#check the ranges of each ascii character,, make sure its 0-9a-fA-F else, print invalid or too large
is_ascii_char:
	beq $t1, $zero, sub_program_2_return

	slti $t5, $t1, '0'
	bne $t5, $zero, handle_char_invalid_hex_string

	slti $t5, $t1, 'A'
	slti $t6, $t1, ':'
	bne $t5, $t6, handle_char_invalid_hex_string

	slti $t5, $t1, 'a'
	slti $t6, $t1, 'G'
	bne $t5, $t6, handle_char_invalid_hex_string

	slti $t5, $t1, 'g'
	beq $t5, $zero, handle_char_invalid_hex_string

	add $s7, $ra, $zero
	add $a0, $t1, $zero
	jal sub_program_1

	add $t1, $v0, $zero
	sll $s8, $s8, 4
	add $s8, $s8, $t1
	add $ra, $s7, $zero

	addi $t3, $t3, 1		#point to clean_string start again
	lb $t1, 0($t3)
	j is_ascii_char

sub_program_2_return:
	addi $sp, $sp, -4
	sw $s8, 0($sp)
exit_sub_program_2:
	jr $ra

handle_char_invalid_hex_string:
	li $v0, 4
	la $a0, error
	syscall
	jr $ra

sub_program_1:
	addi $t1, $a0, 0

	slti $t5, $t1, ':'				#	in ascii, digits have values less than :
	bne $t5, $zero, num_conversion

	slti $t5, $t1, 'G'				#	only uppercase characters are A to F
	bne $t5, $zero, upper_case_conversion

	addi $t1, $t1, -87				#	anything else has to be a lower case character
	addi $v0, $t1, 0
	jr $ra

num_conversion:
	addi $t1, $t1, -48
	addi $v0, $t1, 0
	jr $ra

upper_case_conversion:
	addi $t1, $t1, -55
	addi $v0, $t1, 0
	jr $ra

sub_program_3:
get_result_from_stack:							
	la $t4, output_string_reversed				
	la $t6, output_string_reversed
	#	load result from stack
	lw $t8, 0($sp)
	addi $sp, $sp, 4
	# slti $t7, $t8, 10
	# slt $t9, $zero, $t8
	# beq $t7, $t9, print_unit

	#	and then split unsigned into 2 by dividing 
	li $t3, 10
	divu $t8, $t3
	mflo $t8
	mfhi $t3
	#	print  out both parts separately
	beq $t8, $zero, dont_print_zero_remainder_and_return
	add $a0, $t8, $zero
	li $v0, 1
	syscall
	
dont_print_zero_remainder_and_return:
	add $a0, $t3, $zero
	li $v0, 1
	syscall
	jr $ra

print_unit:
	li $v0, 1
	addi $a0, $t8, 0
	syscall
	jr $ra
	