#	Program: validate string hexadecimal input
	.data
err_str:
	.asciiz "NaN"
in_str:
	.space 1001
temp_str:
	.space 1001
sec_temp_str:
	.space 50
#final_str:
#	.space 11
char_buff:
	.space 2
comma:
	.asciiz ","
too_large_str:
	.asciiz "too large"

	.text
# 	HEADER for main program
#	main_loop reads in theimput string character by characters, stroing them in temp_string
#	when ',' or '/0' or '/n' is reached, it passes temp_string into sub_program_2 for processing
main:
	li $v0, 8				#	8 => read string in
	la $a0, in_str			#	a0 points to address of string in memory
	li $a1, 10001			#	note size of string
	syscall 				#	perform input action

	add $t0, $a0, $zero		#	store string address in $t0
	lb $t1, 0($t0)			#	let t1 hold ascii value of character
	la $t2, temp_str		#	t2 points to temp string space

main_loop:
	beq $zero, $t1, process_current_string		# 	if end of string found, exit
	beq $t1, 10, process_current_string			# 	if end of line character found, exit
	beq $t1, 44, process_current_string			# 	if comma found, process current string

	j y
process_current_string:		
	sb $t1, 0($t2)				#	prepare temp_string parameter for subprogram 1	
	la $a0, temp_str
	addi $t2, $t2, -1
	add $a1, $t0, $zero 		#	prepare pointer to current character in input for subprogram 1
	jal subprogram_2			#	call sub_program_1
	la $t2, temp_str
	jal subprogram_3			#	call sub_program_2 which reads from the stack
	lb $t1, 0($t0)			#	let t1 hold ascii value of character
	beq $t1, 0, exit
	beq $t1, 10, exit
	j continue_main_loop
y:
	sb $t1, 0($t2)
	addi $t2, $t2, 1

continue_main_loop:
	addi $t0, $t0, 1		#	move input string pointer up by one char
	lb $t1, 0($t0)			#	let t1 hold ascii value of character
	j main_loop

#	HEADER for sub_procedure_2 validates the temp_string, and converts it to decimal value of it is valid
#	first, it checks that the space arrangement is valid:
#		it first skips past leading spcaes and tabs:
#			if ',' or '/0', or '/n'  is encountered while reading leading spaces and tabs:
#				string is considered, empty NaN is printed.
#			if any other character is found:
#				it looks for the next space or tab after that character:
#					if encounters spaces or tabs:
#						it checks that only spaces and tabs exist until ',' or, '/0', or '/n' is encountered:
#							if anything else is encountered, string is invalid, NaN is printed
#					if it encounters ',' or '/0', or '/n':
#						string is considered valid, continues to process
#	preconditions: address of string is passed in through $a0
#				   address of last character read in input string is provided through $a1
#	postcondition: decimal number computed is placed character by character on the stack, followed by the length of the decimal
#	number to be read. if thenumber was determined to be invalid or too large already, -1 is put on top of the stack
#	thus when subprogram_3 is called, it reads -1 and knows not to print anything out
subprogram_2:
	add $t3, $a0, $zero			#address of temp string
	add $t4, $a1, $zero			#address of last char in temp string
	add $t9, $zero, $zero		#keeps track of length of string or -1 if NaN was already printed
validate_spaces:
	la $s0, sec_temp_str		#	prepare pointer to temporary output string
	lb $t1, 0($t3)				#	load current char in temp string
	
check_start_spaces:
	beq $t1, ',', print_NaN		#	skip spaces (and tabs) until a non-space, non-tb char is found
	beq $t1, 10, print_NaN		#	if none is found before the string terminates, print NaN
	beq $t1, 0, print_NaN
	bne $t1, ' ', check_start_tab_in_t1	#if not a space, it might still be a tab so check that first
	j dont_check_start_tab
check_start_tab_in_t1:
	bne $t1, '	', check_end_spaces		#if not a tab, then must also not have been a space, so look for spaces at the end   
dont_check_start_tab:			
	addi $t3, $t3, 1
	lb $t1, 0($t3)
	j check_start_spaces

check_end_spaces:
	beq $t1, ' ' check_space_till_end		#	once a space is found chek that all that is left in temp string are spaces
	beq $t1, '	' check_space_till_end
	beq $t1, ',', process_string
	beq $t1, 10, process_string
	beq $t1, 0, process_string
	sb $t1, 0($s0)
	addi $s0, $s0, 1
	addi $t3, $t3, 1
	lb $t1, 0($t3)
	j check_end_spaces

check_space_till_end:
	beq $t1, 0, process_string 				#if anything other than a space or comma, or endl, or /0, string is not valid
	beq $t1, 10, process_string
	beq $t1, ',', process_string
	bne $t1, ' ', check_end_tab_in_t1
	j dont_check_end_tab_in_t1
check_end_tab_in_t1:
	bne $t1, '	', print_NaN
dont_check_end_tab_in_t1:
	addi $t3, $t3, 1
	lb $t1, 0($t3)
	j check_space_till_end

process_string:
	sb $zero, 0($s0)				
	addi $t9, $zero, 0		#keeps track of length of string or -1 if NaN was already printed, so printer knows what to do
	la $t2, sec_temp_str
	addi $t1, $t1, 1
	add $t7, $zero, $zero		#t7 shall be the running sum
count_chars:					#count the number os charaters to know much to read in temp_string
	lb $t1, 0($t2)
	beq $zero, $t1, x
	addi $t9, $t9, 1
	addi $t2, $t2, 1
	j count_chars 
x:
	slti $t2, $t9, 9			#if we havemore than 8 characters, print too large!
	beq $t2 , $zero, print_too_large
	la $t2, sec_temp_str

validate_chars:					#check that value is in the correct range foe hex character (0-9, a-e, A-E) ascii values
	lb $t1, 0($t2)
	beq $zero, $t1, sub_2_return
	addi $t9, $t9, -1

	addi $t2, $t2, 1 
	
	slti $t3, $t1, 48
	beq $t3, 1, print_NaN

	slti $t3, $t1, 58
	beq $t3, 1, compute_val_in_t1

	slti $t3, $t1, 65
	beq $t3, 1, print_NaN

	slti $t3, $t1, 71
	beq $t3, 1, compute_val_in_t1

	slti $t3, $t1, 97
	beq $t3, 1, print_NaN

	slti $t3, $t1, 103
	beq $t3, 1, compute_val_in_t1
	beq $t3, 0, print_NaN

compute_val_in_t1:
	add $a0, $t1, $zero 		#	prepare char to be computed in parameter for subprogram1
	add $s8, $ra, $zero 		#	save return address
	jal subprogram_1			#	call sub program 1
	add $t1, $v0, $zero			#	get return vlue from sub program 1
	add $ra, $s8, $zero 		#	restore return adress
	addi $t3, $zero, 4			#	get power of 2 tomultiply by
	multu $t3,  $t9
	mflo $t3
	sll $t1, $t1, $t3
	add $t7, $t7, $t1 			#increment running sum by calculated value
	j validate_chars
	
sub_2_return:
	addi $t3, $zero, 10
	beq $t7, $zero, handle_special_zero_case

put_result_in_stack:			#put value in stack digit by digit, getting each place by dividing by 10
	beq $t7, $zero, return
	divu $t7, $t3
	mflo $t7
	mfhi $t3
	addi $sp, $sp, -1
	sb $t3, 0($sp)
	addi $t9, $t9, 1
	addi $t3, $zero, 10
	j put_result_in_stack

	lb $t1, 0($t4)
	beq $t1, 0, exit
	beq $t1, 10, exit
return:
	addi $sp, $sp, -1		#store the length of the string to be printed in the stack, -1 if NaN was already printed
	sb $t9, 0($sp)
	jr $ra

handle_special_zero_case:	#in the special case of 0, store 9 in the stack
	addi $sp, $sp, -1
	sb $zero, 0($sp)
	addi $t9, $t9, 1
	j return

print_NaN:					#print NaN if the number was toonot valid
	la $a0, err_str
	li $v0, 4
	syscall
	lb $t1, 0($t4)
	beq $t1, 0, sub_p2_dont_print_comma		#if currently point ing to end of input string (pointed to by t4) terminate program
	beq $t1, 10, sub_p2_dont_print_comma
	addi $sp, $sp, -1		#signal -1, for printing function
	addi $t1, $zero, -1
	sb $t1, 0($sp)
	la $a0, comma
	li $v0, 4
	syscall
	jr $ra
	
print_too_large:
	la $a0, too_large_str	#print too large if the numbe rof digits was greater than 9
	li $v0, 4
	syscall
	lb $t1, 0($t4)
	beq $t1, 0, sub_p2_dont_print_comma		#if currently point ing to end of input string (pointed to by t4) terminate program
	beq $t1, 10, sub_p2_dont_print_comma
	addi $sp, $sp, -1		#signal -1, for printing function
	addi $t1, $zero, -1
	sb $t1, 0($sp)
	la $a0, comma
	li $v0, 4
	syscall
	jr $ra

sub_p2_dont_print_comma:
	addi $sp, $sp, -1		#signal -1, for printing function
	addi $t1, $zero, -1
	sb $t1, 0($sp)
	jr $ra

exit:
	li $v0, 10
	syscall

#	HEADER for sub_procedure_1
#	sub_program_1 converts each indivdual hex character to its decimal equivalent
#	precondition: character to be converted is passed through $a0
#	postcondition: decimal value computed is returned through $v0
subprogram_1:
	add $t1, $a0, $zero
ascii_to_value:			#replace ascii value with actual value based on offset gotten ascii table
	slti $t3, $t1, 58				#	0 - 9 => ASCII => 47 - 58
	bne $t3, $zero, digit_reduce	#	need to sutract 48

	slti $t3, $t1, 71				#	A - F => ASCII => 65 - 70
	bne $t3, $zero, upper_reduce	#	need to subtract 55

	slti $t3, $t1, 103				#	a - f => ASCII => 97 - 102
	bne $t3, $zero, lower_reduce	#	need to subtract 87

digit_reduce:
	addi, $t1, -48
	add $v0, $t1, $zero
	jr $ra

upper_reduce:
	addi, $t1, -55
	add $v0, $t1, $zero
	jr $ra

lower_reduce:
	addi, $t1, -87
	add $v0, $t1, $zero
	jr $ra

#	HEADER for subprocedure_3: 
#	subprocedure_3 gets the string to be printed out from the stack by printing character by character
#	it first reads the length of the string to print out as the first item in the stack
#	if this value is -1, does no printing, (-1 signals that the stirng was invalid)
#	else it prints out each character from teh stack
#	precondition: decimal values to be printed have been loaded character by character onto the stack
#	postcondition: decimal values are printed to console except if -1 was first read from the stack,
#	signalling that there is no imput to be read from the stack
subprogram_3:
	add $t4, $a1, $zero			#address of last char in temp string
	la $s8, char_buff
	lb $t3, 0($sp)
	addi $sp, $sp, 1
	beq $t3, -1, sub_p3_dont_print_comma		#if -1 at stack top, don't print anything out, NaN or too large has alrready been handled
sub_p_3_loop:
	beq $t3, $zero, sub_p3_return		#t3 holds length of string to print out, once it is 0, return
	addi $t3, $t3, -1
	lb $t5, 0($sp)
	addi $t5, $t5, '0'
	sb $t5 0($s8)
	la $a0 char_buff
	li $v0, 4
	syscall
	addi $sp, $sp, 1
	j sub_p_3_loop
sub_p3_return:
	lb $t1, 0($t4)						#check if at end of input string, if yes, exit
	beq $t1, 0, sub_p3_dont_print_comma
	beq $t1, 10, sub_p3_dont_print_comma
	la $a0, comma						#if not at end of input string, print comma
	li $v0, 4
	syscall
sub_p3_dont_print_comma:
	jr $ra