	.data				# mark beginning of data segment

	user_input: .space 1001		# allocate 1001 bytes of storage for 1000 charecters in global variable user_input
	too_large:			# store charectar sequence to prompt if user_input is invalid
		.asciiz "too large"
	Nan:
		.asciiz "NaN"

	.text				# mark beginning of text segment
main: 
	# read input
	li $v0, 8			
	la $a0, user_input		
	la $a1, 1001			
	syscall				
		
	la $s0, user_input
	li $a2, 0					# stores first index 
	li $a3, 0					# stores second index 
	
							# loop through string
	loop_string:
		add $t0, $s0, $a3			# add charectar and index
		lb $t1, 0($t0)				# load first byte(first charectar) of $t0 into $t1
		
							# if t1 == ',' || null || newline, call subprogram2
		beq $t1, 44, call_subProg2
		beq $t1, 0,  call_subProg2
		beq $t1, 10, call_subProg2
		j next

		call_subProg2:
			jal subprogram_2
			jal subprogram_3
			j set_start_index
		
		Print_Nan:				# prints "Nan" message
			li $v0, 4
			la $a0, Nan
			syscall
			j set_start_index
		Print_too_large:			# prints "too large" message
			li $v0, 4
			la $a0, too_large
			syscall
			
		set_start_index:
			addi $a2, $a3, 1		# set $a2 = $a3
			add $t0, $s0, $a3		# add charectar and index
			lb $t1, 0($t0)			# load first byte(first charectar) of $t0 into $t1
			beq $t1, 0, exit
			beq $t1, 10, exit
			li $v0, 11
			addi $a0, $0, 44
			syscall
		
		next:
			addi $a3, $a3, 1		# increment offset of $s0 by 1	
			j loop_string			# continue looping

   		exit:
			li $v0, 10
			syscall
		
subprogram_1:
	addi $t1, $0, 87				# saves ASCII dec to be subtracted in t1
	bgt $a1, 'f', Print_Nan			
	bge $a1, 'a', convert_num
	addi $t1, $0, 55
	bgt $a1, 'F', Print_Nan
	bge $a1, 'A', convert_num
	addi $t1, $0, 48
	bgt $a1, '9', Print_Nan
	bge $a1, '0', convert_num

	j Print_Nan					# if char < 0, print NaN

							# convert numbers
 	convert_num:
		sub $v1, $a1, $t1

	jr $ra 						# return value in $v1
	
subprogram_2:
	sw $ra, 0($sp) 					# store new return value from stackpointer
							# copy a2 and a3 in temp registers
	addi $t2, $a2, 0
	addi $t3, $a3, 0
	
							# increment and decrement to get charactar string
							# check for $t2 in a loop
	check_t2:
		add $t0, $s0, $t2
		lb $t1, 0($t0)				# load first byte(first charectar) of $t0 into $t1
	
							# if comma, endline or newline, jump to Print_Nan
		beq $t2, $t3, Print_Nan
	

							# if space or tab increment $t2
		beq $t1, 32, increment_t2
		beq $t1, 9, increment_t2
	
		addi $t3, $t3, -1			# t3 begins with comma, so decrement it at the beginning of the loop
		j check_t3

		increment_t2:
			addi $t2, $t2, 1
			j check_t2

							# check for $t3 in a loop
	check_t3:
		add $t0, $s0, $t3
		lb $t1, 0($t0)				# load first byte(first charectar) of $t0 into $t1	

							# if space or tab decrement $t3
		beq $t1, 32, decrement_t3
		beq $t1, 9, decrement_t3

		sub $t5, $t3, $t2			# store the difference between offsets to check for num_length
		addi $t4, $0 , 0
		j compute_value				# else jump to compute_value

		decrement_t3:
			addi $t3, $t3, -1
			j check_t3
	compute_value:					# converts hex string to dec 
		

		add $t0, $t2, $s0
		lb $a1, 0($t0)
		jal subprogram_1

		sll $t4, $t4, 4				# shift 4 bytes to the left
		or $t4, $t4, $v1			# or $t4 with value in $v1

		beq $t2, $t3, return_value		# if there are no more values to compute, jump to return
		addi $t2, $t2, 1
		j compute_value
   
	return_value:
		bgt $t5, 7, Print_too_large
		lw $ra, 0($sp)				# load return  value from stack
		sw $t4, 0($sp)				# store integers from stack i register $t4
		jr $ra


subprogram_3:
	addi $t2, $0, 10				# store 10 in a register
	lw $t0, 0($sp)					# get return value from subprog2
	addi $t1, $0, 0					# register to increment stackpointer offset
	
	get_digits:
		divu $t0, $t2				# divide value by 10
		mflo $t0				# move quotient to t0
		mfhi $t3				# move remainder to t3
		add $t4, $sp, $t1 			# add stack pointer and offset to keep track of digits
		sb $t3, 0($t4)				# store bytes in t4 in t3
		beq $t0, $0, print_digits		# if quotient is 0, print digits
		addi $t1, $t1, 1			# else increment stack pointer offset
		j get_digits

	print_digits:					# prints digits from the stack
		add $t4, $sp, $t1
		lb $a0, 0($t4)
				
		li $v0, 1 
		syscall					
	
		beq $t1, 0, return_subprogram3
		addi $t1, $t1, -1
		j print_digits

	return_subprogram3:
		jr $ra
	



 
# program flow:
#main:
	# loop through string
	# if char == , call subprog2
	# else increment offset
	# print Nan or too large
#subprog1:
	# convert hex to dec
#subprog2:
	# pass $a2 and $a3
	# if space or tab, increment $a1, decrement $a3
	# if charectar, 
		# check valid 
		# pass to sub1
		# check length 
		# if invalid 
#subprog3:
	#print decimal (do less than ten)
	# exit loop
