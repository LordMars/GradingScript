.data
	buffer: .space 1001
	temp_str: .space 1001
	str1: .asciiz "NaN"
	str2: .asciiz ","
	str3: .asciiz "too large"
.text
	
main:
	li $v0,8                                             #take in input
	la $a0,buffer                                        #load argument with byte space
	li $a1,1001                                          #allot byte space for string
	add $s0,$zero,$a0                                    #load user input into register
	syscall
	
	add $t3,$zero,$s0                                    #put value of string into register
	move $s0, $zero                                      #clear $s0                                     
loop:
	move $t4,$zero                                       #clears contents of register $t4
	j validate_substr                                    #calls validate substring subprogram, returns substring
validate_substr_return:
	addi $s0, $s0, 1                                     #increment function called counter
	add $t4,$v0,$zero                                    #puts return value of validate_substr in a register
	lb $t6,0($t4)                                        #loads first byte of string
	beq $t6,$zero,loop                                   #substring wasn't a number, jumps to check next substring
	beq $t6,24,loop                                      #substring was too large, jumps to check next substring
	add $a0,$t4,$zero                                    #put parameter for subprogram2 in argument register
    jal subprogram_2                                     #calls subprogram2
subprogram_2_return:  
    lw $s2, 0($sp)                                        #read subprogram2 value from stack
    addi $sp, $sp, 4                                     #restores space on stack
    beq $s2,-3,not_num                                   #branches if string wasn't a number
call_prog3:
	sw $s2,0($sp)                                        #load subprogram3 parameters using stack
	jal subprogram_3                                     #calls subprogram3
	j loop                                               #loops to check next substring
not_num:
	bne $t5, 10, loop                                    #loops to check next substring if string wasn't valid
	bne $t5, $zero, loop                                 #loops to check next substring if string wasn't valid
loop_exit:
		
end:
	li $v0,10                     #end program     
	syscall

invalid_nan:
	la $a0,str1                  #load argument with invalid string
	li $v0,4                     #load with code to print a string
	syscall
	beq $t5,10,nan_exit          #jumps to return if new line
	beq $t5,$zero,nan_exit       #jumps to return if null
	beq $t5,44,add_comma_1         #branches to print comma if comma in string
	addi $t3,$t3,1               #change current byte
	lb $t6,0($t3)                #load next byte of string
	beq $t6,10,nan_exit          #jumps to return if new line
	beq $t6,$zero,nan_exit       #jumps to return if null
add_comma_1:	
	li $v0,11                    #load syscall to print a character
	li $a0, ','                  #load argument with a comma
	syscall	
nan_exit:
	lb $t5, 0($t3)               #loads current character
	beq $t5, 10, end             #jumps to end of program if character is new line
	beq $t5, $zero, end          #jumps to end of program if character is null
	addi $s6, $t3, -2
	lb $s6, 0($t3)
	beq $s6, 44, skip_iteration
	addi $t3,$t3,1               #change current byte to next byte of string
skip_iteration:
	jr $ra	                     #jumps to return address
	
invalid_large:
	la $a0,str3                  #load argument with too large string
	li $v0,4                     #load with code to print a string
	syscall
	beq $t5,10,nan_exit          #jumps to return if new line
	beq $t5,$zero,nan_exit       #jumps to return if null
	beq $t5,44,add_comma_2         #branches to print comma if comma in string
	addi $t3,$t3,1               #change current byte
	lb $t6,0($t3)                #load next byte of string
	beq $t6,10,nan_exit          #jumps to return if new line
	beq $t6,$zero,nan_exit       #jumps to return if null
add_comma_2:
	li $v0,11                    #load syscall to print a character
	li $a0, ','                  #load argument with a comma
	syscall
large_exit:
	lb $t5, 0($t3)               #loads current character
	beq $t5, 10, end             #jumps to end of program if character is new line
	beq $t5, $zero, end          #jumps to end of program if character is null
	addi $s6, $t3, -2
	lb $s6, 0($t3)
	beq $s6, 44, skip_iteration_2
	addi $t3,$t3,1               #change current byte to next byte of string
skip_iteration_2:
	jr $ra	                     #jumps to return address

	
subprogram_1:
	addi $sp,$sp,-4                             #reserve space on the stack
	sw $ra, 12($sp)                             #save return address onto stack
	add $t1, $a0, $zero                         #copy parameter into $t1
	move $t2,$zero                              #initializes register 2 to zero
	blt $t1,48,not_hex                          #checks if character is less than 48, branches to invalid section if true
	blt $t1,58,check_num                        #goes to get value of char since it's valid
	blt $t1,65,not_hex                          #checks if character is less than 65, branches to invalid section if true
	blt $t1,71,check_uppercase                  #goes to get value of char since it's valid
	blt $t1,97,not_hex                          #checks if character is less than 97, branches to invalid section if true
	blt $t1,103,check_lowercase                 #goes to get value of char since it's valid
	j not_hex
	
#converts character to its decimal value
check_num:
	addi $t2,$t1,-48                            #convert 0-9 ascii to 0-9 hex
	addi $a0, $t2, 0                            #load sum into argument register
	lw $ra, 12($sp)                             #load return address back into register
	addi $sp, $sp, 4                            #restore stack space
	jr $ra                                      #jumps to return address

check_uppercase:
	addi $t2,$t1,-55                            #convert A-F ascii to 10-15 hex
	addi $a0, $t2, 0                            #load sum into argument register
	lw $ra, 12($sp)                             #load return address back into register
	addi $sp, $sp, 4                            #restore stack space
	jr $ra                                      #jumps to return address

check_lowercase:
	addi $t2,$t1,-87                            #convert a-f ascii to 10-15 hex
	addi $a0, $t2, 0                            #load sum into argument register
	lw $ra, 12($sp)                             #load return address back into register
	addi $sp, $sp, 4                            #restore stack space
	jr $ra                                      #jumps to return address


not_hex:
	jal invalid_nan                             #calls invalid nan program
	addi $a0, $zero, -3                         #load -1 into argument register
	lw $ra, 12($sp)                             #load return address back into register
	addi $sp, $sp, 4                            #restore stack space
	jr $ra                                      #returns from function

#converts a hexadecimal string to a decimal integer by calling
#subprogram1 in a loop and adding it to a total sum
subprogram_2:
	add $t6,$a0,$zero             #copy parameter with substring into $t6
	move $t7,$zero                #initialize sum register
    add $t8, $t6, $zero           #load string argument into $t8
	move $t6, $zero
sum_loop:
	bge $t6, $s1, sum_exit        #exits loop if all characters were converted
	lb $s3, 0($t8)                #load first character into $t8
	addi $a0, $s3, 0              #load character into argument register
	jal subprogram_1              #call subprogram 1
	add $t9, $a0, $zero           #load return from program 1 into $t9
	beq $t9, -3, sum_exit_invalid   #character wasn't a valid hex character, exit loop
	sll $t7,$t7,4                 #shift sum register left by four
	add $t7,$t7,$t9               #add character's decimal value to it
	addi $t8,$t8,1                #increments $t0 by one to point to next element in the string
	addi $t6,$t6,1                #increment counter
	j sum_loop                    #jump back to sump loop
	
sum_exit:
	addi $sp, $sp, -4             #reserve space on the stack
	beq $t7,$zero, zero_string    #checks to see if hex string is all zeros
	sw $t7, 0($sp)                #save decimal value to the stack
	j subprogram_2_return         #jumps back to beginning of loop

sum_exit_invalid:
	addi $sp, $sp, -4             #reserve space on the stack
	sw $t9, 0($sp)                #save decimal value to the stack
	j subprogram_2_return

zero_string:
	move $t7, $zero
	addi $t7, $t7, 0
	sw $t7, 0($sp)                #save decimal value to the stack
	j subprogram_2_return         #jumps back to beginning of loop

#displays an unsigned decimal integer
subprogram_3:
#have condition that checks if output is 8 characters, if so does special output
#otherwise just prints unsigned integer and checks to see whether next character in the string is the last character
    move $s6, $zero
    move $s7, $zero
    addi $s4,$zero,7                  #initializes a register with the value seven
	bgt $s1,$s4,special_output        #jumps to special output register if length of string is less than zero
	li $v0,1                          #load code for printing an integer
	lw $a0, 0($sp)                    #load number into argument register
	syscall
	lb $t5, 0($t3)                    #loads current character
	beq $t5, 10, end                  #jumps to end of program if character is new line
	beq $t5, $zero, end               #jumps to end of program if character is null
	li $v0,11                         #load syscall to print a character
	li $a0, ','                       #load argument with a comma
	syscall
	addi $t3,$t3,1                    #change current byte to next byte of string
	lb $t6, 0($t3)
	beq $t6, 44, reverse_in_string
    jr $ra                            #returns from function
special_output:
	addi $s5,$zero,10000         #initializes register with 10,000 for special output
	lw $t7, 0($sp)               #put number into register $t7
	divu $t7,$s5                 #divide sum by 10,000
	mflo $s6                     #move quotient from low
	mfhi $s7                     #move remainder from high
    beq $s6, $zero, ignore_zero  #branches to ignore printing extra zero
	li $v0,1                     #load code to print integer
	add $a0,$zero,$s6            #load argument with quotient
	syscall
	li $v0,1                     #load code to print integer
	add $a0,$zero,$s7            #load argument with remainder
	syscall
	lb $t5, 0($t3)               #loads current character
	beq $t5, 10, end             #jumps to end of program if character is new line
	beq $t5, $zero, end          #jumps to end of program if character is null
	li $v0,11                    #load syscall to print a character
	li $a0, ','                  #load argument with a comma
	syscall
	addi $t3,$t3,1               #change current byte to next byte of string
	lb $t6, 0($t3)
	beq $t6, 44, reverse_in_string
	jr $ra     	                 #jump to return address


ignore_zero:
	li $v0,1                     #load code to print integer
	add $a0,$zero,$s7            #load argument with remainder
	syscall
	lb $t5, 0($t3)               #loads current character
	beq $t5, 10, end             #jumps to end of program if character is new line
	beq $t5, $zero, end          #jumps to end of program if character is null
	li $v0,11                    #load syscall to print a character
	li $a0, ','                  #load argument with a comma
	syscall
	addi $t3,$t3,1               #change current byte to next byte of string
	jr $ra     	                 #jump to return address


reverse_in_string:
	addi $t3, $t3, -1
	jr $ra


#this subprogram checks the validity of a substring returns substring if spacing is correct, otherwise jumps to invalid function
validate_substr:
	la $t8, temp_str                         #load string space into $t8
clear_string:
	beq $s1,$zero,clear_exit                 #exit loop if counter is zero
	sb $zero,0($t8)                          #save zero to string
	addi $s1,$s1,-1                          #decrement counter
	addi $t8,$t8,1                           #change current byte
	j clear_string                           # loop to clear_string
clear_exit:
	move $s1,$zero                           #initializes a register with zero to act as a counter
	beq $s0, 0, preserve_character           #don't change character if it's the first iteration
	lb $t5, 0($t3)
	beq $t5,44,check_empty                   #checks if current character is a comma, and branches to check empty if true
	#addi $t3,$t3, 1                          #change current byte
preserve_character:
	lb $t5, 0($t3)                           #load byte into register
	beq $t5,44,check_empty                   #checks if current character is a comma, and branches to check empty if true
substr_loop:
	lb $t5,0($t3)                            #load first byte of string
	beq $t5,44,check_empty                   #exits loop if character is a comma
	beq $t5,10,check_empty                   #exits program if character is new line
	beq $t5,$zero,check_empty                #exits program if character is null
	beq $t5,32,ignore_space                  #if character is a leading space ignore it and branch to ignore space
	beq $t5,9,ignore_space                   #if character is a leading tab ignore it and branch to ignore space
    jal read_chars                           #calls read_chars subprogram

validate_exit:
	la $v0, temp_str                         #load the address of the string
	j validate_substr_return                 #return from function
	
validate_exit_pass_comma:
	la $v0, temp_str                         #load the address of the string
	addi $t3, $t3, 1                         #change current byte
	j validate_substr_return                 #return from function
	
ignore_space:
	addi $t3,$t3,1                           #change current byte to next byte of string
	j substr_loop                            #jumps to beginning of loop	

read_chars:
	la $t8, temp_str
	addi $sp,$sp,-4                          #reserve space for stack
	sw $ra,0($sp)                            #store return address in the stack
read_loop:
	bge $s1,9,call_invalid_large             #branches to call invalid subprogram instruction if substring greater than 8 characters
	beq $t5,32,check_rem                     #checks if remaining characters are tabs or spaces
	beq $t5,9,check_rem                      #checks if remaining characters are tabs or spaces
	beq $t5,44,read_loop_exit                #exits loop if character is a comma
	beq $t5,$zero,read_loop_exit             #exits loop if character is a new line
	beq $t5,10,read_loop_exit                #exits loop if character is a null
	addi $t3,$t3,1                           #changes current byte of string to next byte
	sb $t5, 0($t8)                           #save character to string
	addi $t8, $t8, 1                         #change current string
	addi $s1,$s1,1                           #increments counter, which is the length of the string
    lb $t5,0($t3)                            #loads the next byte into register $t5
    j read_loop                              #loops to check next byte
read_loop_exit:
	la $t8, temp_str                         #load address of string into $t8
	lw $ra,0($sp)                            #load correct return address
	addi $sp,$sp,4                           #add space back to stack
	jr $ra                                   #jump return


check_rem:
	addi $t3,$t3,1 #change current byte
	lb $t5,0($t3) #load byte
	beq $t5,32,check_rem                      #checks if remaining characters are tabs or spaces
	beq $t5,9,check_rem                       #checks if remaining characters are tabs or spaces
	beq $t5,44,read_loop_exit                 #exits loop if character is a comma
	beq $t5,10,read_loop_exit                 #exits loop if character is a new line
	beq $t5,$zero,read_loop_exit              #exits loop if character is null
	la $t8,temp_str                           #load address of string
	sb $zero,0($t8)                           #change byte to zero
	add $a0,$t8,$zero                         #puts address of $t8 in $a0
	jal invalid_nan
	j ignore_rest

call_invalid_large:
	la $t8,temp_str                           #load address of string
	sb $zero,0($t8)                           #change byte to zero
	jal invalid_large                         #calls invalid subprogram
	j validate_exit                           #jumps to exit of validation function
ignore_rest:
	lb $t5,0($t3) #load byte in string
	beq $t5,44,validate_exit                  #jumps to end of validate substring subprogram if character is a comma
	beq $t5,10,validate_exit                  #jumps to end of validate substring subprogram if character is a new line
	beq $t5,$zero,validate_exit               #jumps to end of validate substring subprogram if character is null
	addi $t3,$t3,1                            #changes current byte
	j ignore_rest                             

	
	
check_empty:
	addi $t6, $t3, -1
	lb $t6, 0($t6)
	beq $t6, 44, j_invalid_nan
	beq $t6, $zero, j_invalid_nan
	beq $t6, 10, j_invalid_nan
	beq $t6, 32, space_with_comma
	beq $t6, 9, space_with_comma
	j validate_exit_pass_comma                  #jumps to exit validation function
j_invalid_nan:
	jal invalid_nan
	addi $t3, $t3, 1
	j validate_exit	
	
	
space_with_comma:
	beq $s1, $zero, j_invalid_nan
	
