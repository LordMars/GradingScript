######################################################################Strings_to_Hex
#
# Skylar Grammas
# 
#
# Saved registers
# $s0: return register preserver	 $s1: entire string <= 1000
# $s2: pointer to char after commas	 $s3: bool to test completion
#
# Temporary registers
# $t0: individual char evaluations	 $t1: length of current word
# $t2: front word ptr			 $t3: end word ptr
# $t4: index				 $t5: hex sum (totalHex)
# $t6: unsigned printing divisor	 $t7: printing parameters
# $t8: unsigned printing quotient	 $t9: unsigned printing remainder
#
# Argument registers
# $a0: various uses			 $a1: various uses
#
# PROGRAM: Programming Assignment 2 (Strings to Hex)
	.data                                                        # data section
	string: .space 1000                                          # allocates 1000 bytes of space in memory
	error_string: .asciiz "NaN" 			     # string to output if input is not hex
	input_string: .asciiz "\nEnter a string up to 1000 characters: " # string to output to request user input
	too_long: .asciiz "too large"			     # string to output if input is too long
	newline: .asciiz "\n"					     # newline char for formatting output
	comma: .asciiz ","					     #comma char for formatting output
	.text                                                        # code section
main:
	jal request_input
	jal read_input
	jal store_input
post_next_word:
	jal find_word_entrance
	addi $t1, $0, 0						     # initialize length counter 
	addi $t5, $0, 0						     # initialize Decimal value reg of current word within string
find_word_exit:
	jal check_validity
	
request_input:
	li $v0, 4                                                    # syscall code for printing string
	la $a0, input_string                                         # load address of string to print into $a0
	syscall
	jr $ra

read_input:                                                          # reads input from user
	li $v0, 8
	la $a0, string
	li $a1, 1000
	syscall
	jr $ra

store_input:                                                         # moves input from user to $s1
	move $s1, $a0
	jr $ra
	
find_word_entrance:						     # initial entrance to find word
	addi $t4, $0, 0						     # resets index
	addi $t1, $0, 0						     # resets string length
find_word:							     # finds front and end of word within string
	lb $t0, 0($s1)
	beq $t0, 32, ignore_space
	beq $t4, 0, set_front_ptr
	beq $t0, 44, true_end_ptr_check
	beq $t0, 0, true_end_ptr
	beq $t0, 10, truest_end_ptr
	addi $s1, $s1, 1					     # moves evaluation to next char
	addi $t4, $t4, 1					     # increments index
	addi $t1, $t1, 1					     # increments string length
	j find_word						     # loop
set_front_ptr:							     # sets pointer to head of word
	beq $t0, 44, invalid
	beq $t0, 10, exit_program
	addi $t2, $s1, 0					     # sets $t2 == head of word
	addi $t4, $t4, 1					     # increments index
	addi $t1, $t1, 1					     # increments string length
ignore_space:							     # ignores space and moves evaluation to next char
	addi $s1, $s1, 1
	j find_word
truest_end_ptr:
	addi $s3, $0, 1
	addi $s2, $0, 0
	addi $s2, $s1, 1
	j set_end_ptr
true_end_ptr:							     # sets pointer to next char after comma
	addi $s2, $0, 0
	addi $s2, $s1, 1
set_end_ptr:							     # sets pointer to tail of word
	addi $s1, $s1, -1					     # originally set as comma, moves evaluation back to last char before comma
	lb $t0, 0($s1)
	beq $t0, 32, set_end_ptr				     # if space --> moves evaluation again
	addi $t3, $s1, 0					     # sets $t3 == tail of word
	bgt $t1, 8, length_error
	j find_word_exit
	
length_error:							    # if input is longer than 8 bytes then outputs "too long"
	li $v0, 4
	la $a0, too_long
	syscall
	li $v0, 4
	la $a0, comma
	syscall
	j pre_next_word_via_error

check_validity:
	lb $t0, 0($t2)
	blt $t0, 48, invalid
	blt $t0, 58, valid					     # checks if character is 0-9
	blt $t0, 65, invalid
	blt $t0, 71, valid					     # checks if character is A-F
	blt $t0, 97, invalid
	blt $t0, 103, valid					     # checks if character is a-f
invalid:
	li $v0, 4
	la $a0, error_string                                         # load address of error_string to print
	syscall
	li $v0, 4
	la $a0, comma
	syscall
	addi $t5, $0, 0						     # resets hex sum
	j pre_next_word_via_error
	
valid:
	add $a0, $0, $t0					     # passes char parameter into $a0
	jal subprogram_2
	beq $t2, $t3, pre_next_word				     # checks if at the end of the current word
	addi $t2, $t2, 1					     # moves evaluation to next char
	j check_validity					     # loops evaluation for next char(s)
	
subprogram_1:							     # subprogram_1
	add $t0, $a0, $0					     # retrieves char parameter from $a0
	bgt $t0, 96, lowercaseVal
	bgt $t0, 64, uppercaseVal
	bgt $t0, 47, numberVal
numberVal:							     # converts number char to hexadecimal
	addi $t0, $t0, -48
	j subprogram_1_continued
uppercaseVal:							     # converts upper case letter char to hexadecimal
	addi $t0, $t0, -55
	j subprogram_1_continued
lowercaseVal:							     # converts lower case letter char to hexadecimal
	addi $t0, $t0, -87
subprogram_1_continued:
	add $v0, $t0, $0					     # puts calculated decimal value into return reg ($v0)
	jr $ra

subprogram_2:							     # subprogram_2
	add $s0, $ra, $0					     # preserves return reg value
	jal subprogram_1
	add $t0, $v0, $0					     # retrieves return value from subprogram 1
	sll $t5, $t5, 4						     # shifts to make room for next char to be added
	add $t5, $t5, $t0					     # adds decimal value of char to decimal value of current word
	add $ra, $s0, $0					     # restores return reg to subprogram_2 (call) return location
	beq $t2, $t3, add_to_stack				     # checks if at the end of the current word
	jr $ra
add_to_stack:
	addi $sp, $sp, -4					     # allocates space on stack
	sw $t5, 0($sp)						     # stores decimal value of current word ($t5) to stack
	add $ra, $s0, $0					     # restores return reg to subprogram_2 (call) return location
	jr $ra
	
print:								     # also part of subprogram_3
	lw $t8, 0($sp)						     # loads stack contents into $t8
	li $v0, 1
	la $a0, ($t8)
	syscall
	addi $sp, $sp, 4					     # pops previous word from stack
	addi $t5, $0, 0						     # resets running sum register
	beq $s3, 1, exit_program
	li $v0, 4
	la $a0, comma
	syscall
	jr $ra
subprogram_3:
	addi $t8, $0, 0						     # sets/resets quotient register
	addi $t9, $0, 0						     # sets/resets remainder register
	lw $t7, 0($sp)
	add $s0, $ra, $0					     # preserves return reg value in case of jump
	beq $t7, 0, print_zero
	addi $t6, $0, 10
	divu $t7, $t6
	mflo $t8
	mfhi $t9
	li $v0, 1
	la $a0, ($t8)
	syscall
	li $v0, 1
	la $a0, ($t9)
	syscall
	addi $sp, $sp, 4					     # pops previous word from stack
	addi $t5, $0, 0						     # resets running sum register
	beq $s3, 1, exit_program
	li $v0, 4
	la $a0, comma
	syscall
	jr $ra
print_zero:
	li $v0, 1
	la $a0, ($t7)
	syscall
	addi $sp, $sp, 4					     # pops previous word from stack
	addi $t5, $0, 0						     # resets running sum register
	beq $s3, 1, exit_program
	li $v0, 4
	la $a0, comma
	syscall
	add $ra, $s0, $0					     # restores return reg to subprogram_3 (call) return location
	jr $ra
	
pre_next_word_via_error:
	beq $t4, 0, move_evaluation
	add $s1, $0, $s2
	j post_next_word
pre_next_word:
	add $s1, $0, $s2					    # sets to next word
	beq $t1, 8, pre_print
	jal print
	j post_next_word
pre_print:
	jal subprogram_3
	j post_next_word

exit_program:
	li $v0, 10                                                   # exits program
	syscall
true_end_ptr_check:
	beq $t4, 0, invalid
	j true_end_ptr
move_evaluation:
	addi $s1, $s1, 1
	j post_next_word