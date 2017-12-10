
.data

string_NaN: .asciiz "NaN"
string_tooLarge: .asciiz "too large"
string_comma: .asciiz ","

buff: .space 1001 # space for input string

.text

.globl main

main:

	la $a0,buff# input string address
	li $a1,1001 
	li $v0,8 #read string
	syscall
	xor $a0, $a0, $a0
	xor $v0, $v0, $v0
	
	main_loop:
		li $s2,0
		jal subprogram_2
		jal subprogram_3

#
#Changes each charater into its decimal equivalent
#
subprogram_1:
	move $t4, $a1
	move $t2, $zero
	li $v1, -1
	
	ZeroToNine:

		
		li $t6,47
		li $t7,58
		slt $t0,$t6,$t4    # Sets $t0=1 if $t6 < $t4, otherwise $t0=0
		slt $t1,$t4,$t7    # Sets $t1=1 if $t4 < $t7, otherwise $t1=0
		and  $t2, $t1, $t0    # Sets $t2=1 if $t6 < $t4 < $t7, otherwise $t0=0
		beq $t2, 0, A_To_F
		add $s0, $s0, 1  
		add $v1, $t4, -48 	#minus to get appropriate decimal num
		j exit

	A_To_F:
		li $t6,64
		li $t7,71
		slt $t0,$t6,$t4    # Sets $t0=1 if $t6 < $t4, otherwise $t0=0
		slt $t1,$t4,$t7    # Sets $t1=1 if $t4 < $t7, otherwise $t1=0
		and  $t3, $t1, $t0    # Sets $t3=1 if $t6 < $t4 < $t7, otherwise 				#$t0=0
		beq $t3, 0, a_to_f
		add $s0, $s0, 1  
		add $v1, $t4, -55  #minus to get appropriate decimal num
		j exit


	a_to_f:
		or $t2, $t2, $t3    
		li $t6,96
		li $t7,103
		slt $t0,$t6,$t4    # Sets $t0=1 if $t6 < $t4, otherwise $t0=0
		slt $t1,$t4,$t7    # Sets $t1=1 if $t4 < $t7, otherwise $t1=0	
		and  $t0, $t1, $t0    # Sets $t0=1 if $t6 < $t4 < $t7, otherwise $t0=0
		or $t2, $t2, $t0 
		beqz $t2 , exit	#if no characters found valid exit
		add $s0, $s0, 1 
		add $v1, $t4, -87 #minus to get appropriate decimal num
		j exit
		
	exit:
		move $v0, $s0	#move count to v0 for return
		jr $ra			# return to subprogram2
			
		

subprogram_2:
	li $v0, 0	#clear return register
	li $v1, -1	#clear return register
	li $s1, 0	#set sum to zero
	li $s5, 0 	#reset NaN  value
	li $s6, 0	#reset count value
	li $t8, 0	#reset character space character value
	move $a0, $s7
	addi $sp, $sp, -4		# go to an empty space on the stack
	sw $ra, 0($sp)		#store the return address to main loop on stack
	lbu $a1, buff($a0)   #loading each byte of input string
	move $s0, $zero
	
	loop:
		
		jal subprogram_1	
		bltz $v1, not_valid	#if v1 does not fit a valid char then go to not valid
		move $s6, $v0	#copy char count to t2
		jal dec_calc
		beq $t8, 1, set_nan	#if you see a char and a space set 1 if another char comes
		 valid:
		 li $t3, 8	#max num of chars
		add $s7, $s7, 1   #increment address of input string
		lbu $a1, buff($s7)
		move $t5, $s5		#save t5 value
		sltu $s5, $t3, $s6	#set to 1 for too large if count > 8 otherswise keep at 0
		beq $s5, 1, c0		#if it is a 1 jump to continue
		move $s5, $t5		#otherwise restore previously saved values
		c0:
		bnez $a1, loop 	#keep going until either null, return or comma seen
		 
		not_valid:
		
			bne $a1, 32, E1 #j if it is not a space
				li $t0, 1 #set 1 if space
				beqz $s6, continue0	#if count is 0 j continue
				li $t8, 1	#set as 1 if you see a char then a space
				continue0:
					add $s7, $s7, 1   #increment address of input string
					lbu $a1, buff($s7)	
				j loop
			E1:
			bne $a1, 9, E2 #j if not tab char
				li $t0, 1 #set 1 if tab
				beqz $s6, continue1
				li $t8, 1	#set as 1 if you see a char then a space
				continue1:
				j end
			E2:
			bne $a1, 10, E3 #j if not return char
				li $t1, 1
				bgtz $s6, end
				li $s5, -1	#set as NaN if no value before enter
				j end	
			E3:
			bne $a1, 0, E4 #j if not null char
				li $t1, 1
				bgtz $s6, end
				li $s5, -1	#set as NaN if no value before null
				j end
			E4:
			bne $a1,44, E5 #j if not comma char
				li $t1, 2
				bgtz $s6, end
				li $s5, -1	#set as NaN if no value before comma
				j end		
			E5:
			bne $a1, 48, set_nan	#j if not zero	
				j loop
		
		set_nan:
			li $s5, -1	#for NaN
			j valid
			
	dec_calc:
		beq $s6, 1, c2	#if there is 1 character just add without shifting
		sll $s1, $s1, 4		#shift the value left 4 bits
		add $s1, $s1, $v1	#add the value to the currently stored value
		jr $ra				#jump back to loop
		c2:
		add $s1, $s1, $v1	#add the value to the currently stored value	
		jr $ra				#jump back to loop

	end:	
	add $s7, $s7, 1	#increment to next char in input
	lw $ra, 0($sp)	#load return address saved in stack to jump to main loop
	sw $s1, 0($sp)	#store sum in stack
	addi $sp, $sp, -4		# go to an empty space on the stack
	sw $s5, 0($sp)		#store NaN/too large indicator
	addi $sp, $sp, -4		# go to an empty space on the stack
	sw $t1, 0($sp)		#store whether comma,enter or null
	jr $ra		# go back to continue main loop
			
subprogram_3:
	lw $t9, 0($sp)	#store comma,enter or null in t6 from stack
	addi $sp, $sp, 4	#return stack pointer to point to sum
	lw $t6, 0($sp)	#store nan/too large indicator in t6 from stack
	addi $sp, $sp, 4	#return stack pointer to point to sum
	lw $t0, 0($sp)	#store sum in t0 from stack
	addi $sp, $sp, 4	#return stack pointer to point to sum
	
	beq $t6, -1, Not_a_num
	beq $t6, 1, tooLarge
	li $t2,10
	bgez  $t0, b1	#if sum is positive just print otherwise separate the register and print each register consecutively
	divu  $t0, $t2
	mfhi $t3	#store hi 32 bits in t3
	mflo $t4	#store lo 32 bits in t4
	move $a0, $t4 # address of decimal
	move $t5, $v0
	li $v0,1	#print integer
	syscall
	move $a0, $t3 # address of decimal
	li $v0,1	#print integer
	syscall
	move $v0, $t5
	j functions	
	b1:	
		move $a0, $t0 # address of decimal
		li $v0,1	#print integer
		syscall
		j functions

	tooLarge:
		la $a0, string_tooLarge 
		li $v0,4	#print too large
		syscall
		j functions

	Not_a_num:
		la $a0, string_NaN 
		li $v0,4	#print NaN
		syscall
		j functions
		
	functions:
		beq $t9, 1, Else0		#if null or enter seen then exit program
		la $a0, string_comma 
		li $v0,4	#print comma
		syscall
		j main_loop
		Else0:
			li $v0,10	#exit
			syscall

