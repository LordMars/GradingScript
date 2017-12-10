.data 
user_input: .space 9
error_message: .asciiz "Invalid hexadecimal number."
answer: .space 8

.text 
main:

la $a0, user_input # load address of where input will be stored
li $a1, 9 # tell system how much input space
li $v0, 8 # tell system to read input
syscall # exectue call
la $t3, ($a0) # add base address to another register
addi $t0, $t0, -1
addi $t8, $t8, 10
lb $t9, ($t3)
beq $t9, $zero invalid_input_path
beq $t9, 10, invalid_input_path
addi $s6, $s6, -1


# next few loops check if space in between character
first_loop: # loops until character is found then goes to next loop
add $s6, $s6, 1
add $s7, $s6, $t3
lb $s7, 0($s7)
bne $s7, 32, second_loop
beq $s7, 0, validation_loop
beq $s7, 10, validation_loop  
j first_loop

second_loop: # loops until a space is found then jumps to next loop
add $s6, $s6, 1
add $s7, $s6, $t3
lb $s7, 0($s7)
beq $s7, 32, third_loop
beq $s7, 0, validation_loop
beq $s7, 10, validation_loop  
j second_loop

third_loop: # loops until another character is found. If found then prints error message
add $s6, $s6, 1
add $s7, $s6, $t3
lb $s7, 0($s7)
bne $s7, 32, invalid_input_path
beq $s7, 0, validation_loop
beq $s7, 10, validation_loop  
j third_loop

validation_loop: # loop that checks if each character is valid
addi $t0, $t0, 1 # increment the incrementor
addu $t1, $t0, $t3 # t0 is used as incrementor starting at 0. The base address plus the incrementor is stored in t1.
lb $t1, 0($t1) # load byte to register

beq $t1, 32, space_count

# check if at the end of input
beq $t1, 10 , valid_input_loop # check for endline character
beq $t1, 0, valid_input_loop # check for null value

# checks for a - f
bltu $t1, 103, lower_case_lower_bound # checks if less than greatest valid ascii value
j invalid_input_path 
lower_case_lower_bound: # checks if greater than least valid lower case value
bgtu $t1, 96, validation_loop 
j upper_case_upper_bound 

# checks for A - F
upper_case_upper_bound: # check if less than largest valid upper case value
bltu $t1, 71, upper_case_lower_bound 
j invalid_input_path 
upper_case_lower_bound: # checks if greater than smallest valid upper case ascii value
bgtu $t1, 64, validation_loop
j integer_upper_bound

# checks for 0 - 9
integer_upper_bound: # checks if less than the greatest valid integer ascii value
bltu $t1, 58, integer_lower_bound
j invalid_input_path
integer_lower_bound: # checks if greater than the lowest valid integer ascii value
bgtu $t1, 47, validation_loop
j invalid_input_path

space_count:
addi $s4, $s4, 1
j validation_loop

valid_input_loop: # store results
addi $t0, $t0, -1
blt $t0, $zero, print_answer
addi $t6, $t6, 1
addu $t1, $t0, $t3
lb $t1, 0($t1)

beq $t1, 32, valid_input_loop
blt $t1, 59, is_int
blt $t1, 72, is_upper
blt $t1, 103 is_lower

is_int:
sub $t1, $t1, 48
sllv $t1, $t1, $t4 # t4 holds shift amount
add $t5, $t5, $t1 # t5 holds sum
addi $t4, $t4, 4
j valid_input_loop

is_upper:
sub $t1, $t1, 55
sllv $t1, $t1, $t4
add $t5, $t5, $t1 # t5 holds sum
addi $t4, $t4, 4
j valid_input_loop

is_lower:
sub $t1, $t1, 87
sllv $t1, $t1, $t4
add $t5, $t5, $t1 # t5 holds sum
addi $t4, $t4, 4
j valid_input_loop

invalid_input_path: # print error message
la $a0, error_message
li $v0, 4
syscall
li $v0, 10
syscall

print_answer: # print decimal numbesr under 7 digits
beq $s4, $t6, invalid_input_path # if num spaces equals size of input
bgt $t6, 7, too_large 
li $v0, 1
move $a0, $t5
syscall
li $v0 10
syscall

too_large: # prints numbers over 7 digits by diving number by 10000 and printing lo and hi registers
addi $s1, $s1, 10000
divu $t5, $s1 
li $v0, 1
mflo $s2 
mfhi $s3
move $a0, $s2
syscall
move $a0, $s3
syscall
li $v0, 10
syscall
