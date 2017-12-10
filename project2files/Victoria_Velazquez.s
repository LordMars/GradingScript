#MIPS Programming Assignment 2 - Como Org I Fall 2017
#Victoria Velazquez
#clone https://github.com/vicvlzqz/MIPS-Programming-Assignment-2.git
.data														 #declare variables
	str1: .space 1001        							 	 #allocating space in memory
	temp_str: .space 1001
	comma: .ascii ","
	nan_error_msg: .ascii "NaN"
	large_error_msg: .ascii "too large"
	newline: .ascii "\n"
	
.text 														  #where code is being executed
		
main:
	la $a0, str1 								    	 	 #making variable to store user input
	li $a1, 1001 											 #limits amount of characters
	li $v0, 8												 #loads syscall that reads user input for strings
	add $s0,$zero,$a0                                        #load input into register
	syscall
	add $t3,$zero,$s0                                    	 #storing input value in register
	move $s0, $zero                        #resetting $s0                                     
loop_through_input:
	move $t4,$zero                                       	 #resetting $t4
	j check_for_validity                                     #call subprogram, validate, returns substr
substr_process:
	addi $s0, $s0, 1                               #increment counter to iterate through input
	add $t4,$v0,$zero                                    #storing return value of valid substr
	lb $t6,0($t4)                                        #load byte of str		beq $t6,$zero,loop_through_input                     #if substr was NaN go to next substr
	beq $t6,24,loop_through_input                        #if too large go to next substr
	add $a0,$t4,$zero                                    #add parameter for subprogram2 
	jal subprogram_2                                     #call subprogram2
sub2_output:  
	lw $s2, 0($sp)                                       #read value from subprogram2
	addi $sp, $sp, 4                                     #account for spaces
	beq $s2,-3, not_a_number                                   #if string is NaN
connect_to_sub3:
	sw $s2,0($sp)                                        #store subprogram3
	jal subprogram_3                                     #root to subprogram3
	j loop_through_input                                 #loops to check next substring
not_a_number:
	bne $t5, 10, loop_through_input                      #does string qualify?
	bne $t5, $zero, loop_through_input                   #continue to loop
exit1:
	li $v0,10                     						 #terminate execution     
	syscall													#sum 
is_nan:
	la $a0,nan_error_msg                  #load invalid input
	li $v0,4                     #add to be printed with other substr 
	syscall
	beq $t5,10,exit2          #if new line, exit
	beq $t5,$zero,exit2       #if null, exit
	beq $t5,44,apply_comma         #print comma like in the input
	addi $t3,$t3,1               #change current byte
	lb $t6,0($t3)                #load next byte of string
	beq $t6,10,exit2          #if new line, exit
	beq $t6,$zero,exit2       #if null, exit
apply_comma:	
	li $v0,11                    #print char
	li $a0, ','                  #add comma to substr
	syscall	
exit2:
	lb $t5, 0($t3)               #keeping track of current char
	beq $t5, 10, exit1             #f char is new line, exit
	beq $t5, $zero, exit1          #if char is null, exit
	addi $s6, $t3, -2
	lb $s6, 0($t3)
	beq $s6, 44, jump
	addi $t3,$t3,1               #move to next substr
jump:
	jr $ra	                     
		
is_too_large:
	la $a0,large_error_msg                  #load too large string
	li $v0,4                     #add to be printed with other substr
	syscall
	beq $t5,10,exit2          #if new line, exit
	beq $t5,$zero,exit2       #if null, exit
	beq $t5,44,apply_comma         #add comma to substr
	addi $t3,$t3,1               #change current byte
	lb $t6,0($t3)                #go to next char
	beq $t6,10,exit2          #if new line, exit
	beq $t6,$zero,exit2       #if null, exit

subprogram_1: #convert single char
	addi $sp,$sp,-4                             
	sw $ra, 12($sp)                             #save return address 
	add $t1, $a0, $zero                         
	move $t2,$zero                              #resetting
	blt $t1,48, invalid                          #if character is less than 0
	blt $t1,58, is_number                        #if char is less than 9
	blt $t1,65, invalid                          #if char is less than A
	blt $t1,71, is_uppercase                  #if char is less than F
	blt $t1,97, invalid                        #if char is less than a
	blt $t1,103, is_lowercase                 #if char is less than f
	#bgt $t0, 102, nan_error_msg 			 #if char is greater than f
	j subprogram_1
		
is_number:
	addi $t2,$t1,-48                            #convert 0-9 number ascii to hex
	addi $a0, $t2, 0                            
	lw $ra, 12($sp)                             
	addi $sp, $sp, 4                            
	jr $ra                                      #jump
	 
is_uppercase:
	addi $t2,$t1,-55                            #convert A-F ascii to hex
	addi $a0, $t2, 0                            
	lw $ra, 12($sp)                             
	addi $sp, $sp, 4                            
	jr $ra                                      #jump
	 
is_lowercase:
	addi $t2,$t1,-87                            #convert a-f ascii to hex
	addi $a0, $t2, 0                            
	lw $ra, 12($sp)                             
	addi $sp, $sp, 4                            
	jr $ra                                      #jump
	 
invalid:
	jal is_nan                             #calls invalid nan program
	addi $a0, $zero, -3                         #load -1 
	lw $ra, 12($sp)                             
	addi $sp, $sp, 4                            #reset
	jr $ra                                      #jump


subprogram_2:  		#calls sub1 to get decimal value of each character
	add $t6,$a0,$zero             
	move $t7,$zero                #reset sum
	add $t8, $t6, $zero           #load string 
	move $t6, $zero
combine_loop:
	bge $t6, $s1, exit3        #if char converted, exit
	lb $s3, 0($t8)                #use first char 
	addi $a0, $s3, 0              #put in register
	jal subprogram_1              #call sub1
	add $t9, $a0, $zero           #load result from program 1
	beq $t9, -3, invalid_exit   #if hex char isnt valid, exit 
	sll $t7,$t7,4                 #shift method
	add $t7,$t7,$t9               #add decimal value 
	addi $t8,$t8,1                #increment by 1
	addi $t6,$t6,1                #increase counter
	j combine_loop                #jump 
		
exit3:
	addi $sp, $sp, -4             
	beq $t7,$zero, zeros    #if all zeros
	sw $t7, 0($sp)                #save value
	j sub2_output         #jump
	 
invalid_exit:
	addi $sp, $sp, -4             
	sw $t9, 0($sp)                #save decimal value 
	j sub2_output
	 
zeros:
	move $t7, $zero
	addi $t7, $t7, 0
	sw $t7, 0($sp)                #save decimal value 
	j sub2_output         #jump

subprogram_3:
    move $s6, $zero
	move $s7, $zero
	addi $s4,$zero,7                  
	bgt $s1,$s4,less_than_zero        #if length is less than zero
	li $v0,1                          #to print
	lw $a0, 0($sp)                    
	syscall
	lb $t5, 0($t3)                    #current char
	beq $t5, 10, exit1                  #f char is new line, exit
	beq $t5, $zero, exit1               #if char is null, exit
	li $v0,11                         #to print a char
	li $a0, ','                       #load comma
	syscall
	addi $t3,$t3,1                    #move to next char
	lb $t6, 0($t3)
	beq $t6, 44, reverse_in_string
    jr $ra                            #returns from function
less_than_zero:
	addi $s5,$zero,10000         #initializes 
	lw $t7, 0($sp)               #store number
	divu $t7,$s5                 #divide sum by 10,000 to convert
	mflo $s6                     #quotient
	mfhi $s7                     #remainder
    beq $s6, $zero, ignore_zero  #ignore extra zero
	li $v0,1                     #code to print integer
	add $a0,$zero,$s6            #quotient
	syscall
	li $v0,1                     
	add $a0,$zero,$s7            #remainder
	syscall
	lb $t5, 0($t3)               #current character
	beq $t5, 10, exit1             #if character is new line, exit
	beq $t5, $zero, exit1          #if character is null, exit
	li $v0,11                    #print a char
	li $a0, ','                  #load comma
	syscall
	addi $t3,$t3,1               #move to next substr
	lb $t6, 0($t3)
	beq $t6, 44, reverse_in_string
	jr $ra     	                 #jump
	 
	 
ignore_zero:
	li $v0,1                     
	add $a0,$zero,$s7            #remainder
	syscall
	lb $t5, 0($t3)               #current char
	beq $t5, 10, exit1             #if character is new line, exit
	beq $t5, $zero, exit1          #if character is null, exit
	li $v0,11                    
	li $a0, ','                  #load comma
	syscall
	addi $t3,$t3,1               #move to next substr
	jr $ra     	                 #jump 
	 
	 
reverse_in_string:
	addi $t3, $t3, -1
	jr $ra

