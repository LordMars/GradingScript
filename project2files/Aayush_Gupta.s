# MIPS ASSIGNMENT 2
# FIRST OF ALL, TRACLS THE COMMA CHARACTER AND STORES THE INDEX IN 2 REGISTERS.
# THEN, GOES FROM THE FRONT AND THE BACK UNTIL IT FINDS A CHARACTER THAT IS NOT A SPACE OR A TAB OR A COMMA. 
# IF A NEWLINE CHARACTER, MEANS THAT IT IS THE LAST SUBSTRING AND NEED NOT PRINT THE COMMA CHARACTER.
# SO, SET A REGISTER TO 1 TO INDICATE THAT COMMA SHOULDN'T BE PRINTED.
# IF A COMMA, THIS MEANS NO CHARACTER BETWEEN TWO CONSECUTIVE COMMAS. SO, PRINTS NAN.
# ELSE, SENDS THE ACTUAL START AND END OF THE SUBSTRING TO SUBPROGRAM2.
# THE RETURN ADDRESS IS STORED ON THE STACK AS SUBPROGRAM 2 NEEDS TO CALL SUBPROGRAM 3 WHICH MODIFIES THE CONTENT OF THE $RA REGISTER.
# WHEN THE SUBPROGRAM IS ABOUT TO CALL BACK THE MAIN CALLING PROGRAM, THE VALUE STORED IN THE STACK IS RESTORED FROM THE STACK.
# IN SUBPROGRAM 2, IT CALCULATES THE LENGTH OF THE STRING THAT DETERMINES THE NUMBER OF SHIFTS TO BE MADE IN THE FINAL STRING.
# GOES THROUGH EACH CHARCTER AND SENDS THE ASCII CODE OF THE CHARACTER AND THE LENGTH OF THE STRING TO SUBPROGRAM 1.
# SUBPROGRAM 1 USES THE LENGTH TO CALCULATE THE NUMBER OF SHIFTS TO BE MADE(LENGTH * 4) AND THEN SENDS BACK THE VALUE. 
# SUBPROGRAM 2 USES THE OR TO INCORPORATE THE VALUE INTO THE VALUE CALCULATED FOR THE PREVOIS CHARACTERS.
# SUBPROGRAM 2 HAS A COUNTER THAT CHECKS IF IT IS EQUAL TO LENGTH OF STRING.
# IF EQUAL, SUBPROGRAM 2 TERMINATES AND SENDS BACK THE CALCULATED VALUE TO THE MAIN CALLING PROGRAM.
# THEN, THE MAIN PROGRAM SENDS THE VALUE TO SUBPROGRAM3 TO PRINT THE CONTENTS. 
# SUBPROGRAM 3 USES THE DIVU OPERAND TO PRINT THE UNSIGNED VALUE OF THE CONTENTS IN THE REGISTER. 
# THE CHECKS IF THE FLAG IS SET TO TRUE
# IF TRUE, PRINTS THE COMMA CHARACTER AND RETURNS BACK  TO THE MAIN PROGRAM IN THE LOOP TO PRINT THE CONVERT THE NEXT SUBSTRING
# ELSE, SIMPLY EXITS THE PROGRAM WITHOUT PRINTING THE COMMA CHARACTER.

.data 
	string_space: .space 1001
	comma: .asciiz ","
	undefined: .asciiz "NaN"
	longstring: .asciiz "too large"

.text
	main:
	la $a0, string_space
	li $a1, 1001
	li $v0, 8
	syscall
	li $s2, 0 # $S2 TRACKS THE START OF THE SUBSTRING.
	li $s1, 0 # $S1 TRACKS THE END OF THE SUBSTRING.
	la $s0, string_space # $S0 TRACKS THE START OF THE INPUY STRING.
	Loop: # THIS LOOP KEEPS ON RUNNING UNTIL IT FINDS A COMMA CHARACTER.
		add $t1, $s0, $s1
		lb $t2, 0($t1)
		beq $t2, 10, LastSubString # IF A NEWLINE CHARACTER, ITS A LAST SUBSTRING AND SO, FLAGS THE $A3 REGISTER TO TRUE. 
		bne $t2, 44, Next 
		j Transition # IF A COMMA CHARACTER SENDS TO THE SECOND PART THAT LOOKS FOR THE SPACES AND TABS IN THE START AND END OF THE SUBSTRING.
	
	LastSubString: # SETS $A3 TO TRUE. DOESN'T PRINT THE COMMA CHARACTER AND EXITS THE PROGRAM AFTER PRINTING THE STRING.
		li $a3, 1
		j Transition
		
	Next: # INCREASE THE COUNTER BY 1 ONLY IF IT'S NOT A COMMA. 
	addi $s1, $s1, 1 
	j Loop
	
	Transition:
		add $t0, $s1, $s0
		Loop1: # GOES FROM THE BACK OF THE SUBSTRING LOOKING FOR A CHARACTER THAT'S NOT A SPACE OR A TAB OR A COMMA. 
			add $t0, $t0, -1
			lb $t3, ($t0)
			beq $t3, 32, Loop1 # IF A SPACE, CONTINUE.
			beq $t3, 9, Loop1 # IF A TAB, CONTINUE.
			beq $t3, 44, Error # IF A COMMA CHARACTER, MEANS THAT NO VALID CHARACTER BETWEEN TWO COMMAS. SKIP TO THE ERROR BLOCK
			j EndFound # IF NOT A COMMA, NOT A SPACE AND NOT A TAB, PROPER END FOUND. SKIP TO THE PROGRAM THAT LOOKS FOR PROPER START.
		
		EndFound:
			add $t4, $s2, $s0
			addi $t4, $t4, -1
		Loop3: # STARTS FROM THE START OF THE SUBSTRING LOOKING FOR A CHARACTER THAT'S NOT A SPACE OR A TAB OR A COMMA. 
			add $t4, $t4, 1
			lb $t3, ($t4)
			beq $t3, 32, Loop3 # IF A SPACE, CONTINUE.
			beq $t3, 9, Loop3 # IF A TAB, CONTINUE.
			beq $t3, 44, Error # IF A COMMA CHARACTER, MEANS THAT NO VALID CHARACTER BETWEEN TWO COMMAS. SKIP TO THE ERROR BLOC
			j Done # IF NOT A COMMA, NOT A SPACE AND NOT A TAB, PROPER END FOUND. SKIP TO THE PROGRAM THAT SENDS THE SUBSTRING TOBE CONVERTED TO ITS HEXADECIMAL VALUE.
			
	Done:
		sub $t0, $t0, $s0 # CALCULATING THE LENGTH OF THE SUBSTRING
		sub $t4, $t4, $s0 
		addi $t0, $t0, 1
		add $a0, $t4, $zero # SENDING PARAMETERS TO THE SUBPROGRAM 2 USING THE ARGUMENT REGISTERS.
		add $a1, $t0, $zero
		add $a2, $s0, $zero
		jal subprogram2 # CALL TO THE SUBPROGRAM.
		
	ErrorDestination: # PART OF CODE THAT NORMALIZES THE START OF THE NEXT SUBSTRING IF ERROR FOUND.
		addi $s1, $s1, 1 # INREASE THE END BECAUSE CURRENTLY POINTING AT THE COMMA CHARACTER.
		add $s2, $s1, $zero # COPY THE END TO THE START FOR THE NEW SUBSTRING TO BE READ.
		j Loop # LOOK FOR NEXT CHARACTER.


	subprogram2:
		###############################################################################
		# Converts a hexadecimal string to it's unsigned decimal equivalent and prints it.
		#
		# Arg registers used: $a0, $a1, $a2	
		# Tmp registers used: $t0, $t3, $t4, $t5, $t7 
		# $a0 : Index for the start of the sub-string.
		# $a1 : Number of characters to read from.
		# $a2 : Index for the start of the input-string.
		# 
		# Returns: None [Prints the hexadecimal equivalent on the screen]
		# 
		# Called by main
		# Calls: sub-program-1, sub-program-2

		addi $sp, $sp, -4 # STORE THE RETURN ADDRESS TO THE STACK BECAUSE THIS IS A NON-LEAF FUNCTION.
		sw $ra, 0($sp)
		add $t0, $a0, $zero # RESTORING THE VALUES FROM THE ARGUMENT REGISTER INTO THE REGISTERS.
		add $s6 , $a1, $zero
		add $s7 , $a2, $zero
		sub $t9, $s6, $t0 # REGISTER $T9 COUNTS THE LENGTH OF THE SUB-STRING TO BE READ.
		li $t6, 4
		mult $t9, $t6
		mflo $t5 # REGISTER $T5 CALCULATES THE NUMBER OF SHIFTS TO BE MADE FOR THE FIRST CHARACTER IN THE SUB-STRNG.
		li $t7, 0
		Loop2:
			add $t3, $t0, $s7
			lb $t4, ($t3) # SEND THE LOADED CHARACTER TO THE SUBPROGRAM 2 TO CONVERT TO ITS DECIMAL EQUIVALENT.
			add $a0, $t4, $zero
			add $a1, $t5, $zero
			jal subprogram1 # CALL THE SUBPROGRAM TO CONVERT THE CHARCATER INTO ITS HEXADECIMAL EQUIVALENT.
			add $s5, $v0, $zero 
			or $t7, $t7, $s5 # USING OR TO ADD TO THE TOTAL OF THE EACH CHARACTER IN THE SUBSTRING.
			addi $t0, $t0, 1 # INCREASE THE COUNTER BY 1 AFTER EACH LOOP.
			addi $t5, $t5, -4 # REDUCE THE NUMBER OF SHIFTS TO BE MADE AFTER EACH ITERATION.
			bne $t0, $s6, Loop2
	
		bgt $t9, 8, LongString # ONCE THE SUBSTRING IS CONVERTED AND CHECKED IF IT IS A VALID NUMBER OR NOT, THE LENGTH OF THE STRING IS CHECKED. IF THE LENGTH IS GREATER THAN 8, SENT TO LONGSTRING.
		addi $sp, $sp, -4 # USING STACK TO SEND THE CORRESPONDING HEXADECIMAL VALUE TO THE SUBPROGRAM 3.
		sw $t7, ($sp)
		jal subprogram3
		lw $ra, ($sp) # RELOAD THE RETURN ADDRESS FROM THE STACK.
		addi $sp, $sp, 4
		jr $ra
		
		LongString:
			la $a0, longstring
			li $v0, 4
			syscall	
			
			beq $a3, 1, Exit # CHECKS THE FLAG TO SEE IF IT SHOULD EXIT THE PROGRAM.
			
			la $a0, comma
			li $v0, 4
			syscall
			j ErrorDestination

	subprogram1:
		###################################################################################
		# Converts a hexadecimal character to it's unsigned decimal equivalent and returns the value to the calling function.
		#
		# Arg registers used: $a0, $a1
		# Tmp registers used: None
		# $a0 : Address for that particular character.
		# $a1 : Number denoting the number of left-shifts to be made.
		# 
		# Post: $v0 contains the return value
		# Returns: The decimal equivalent of the input-character.
		# 
		# Called by sub-program-2
		# Calls: None
		   
		add $s3, $a0, $zero
		add $s4, $a1, $zero
		addi, $s4, $s4, -4 # INCLUDES THE SHIFT FOR THE COMMA CHARACTER AS WELL.
		
		bgt $s3, 64, Capital
		bgt $s3, 57, Error
		blt $s3, 48, Error
		addi $s3, $s3, -48
		Final:
			sllv $s5, $s3, $s4
			add $v0, $s5, $zero
			jr $ra
		
		Capital:
			bgt $s3, 70, Small 
			addi $s3, $s3, -55
			j Final
		
		Small:
			blt $s3, 97, Error
			bgt $s3, 102, Error
			addi $s3, $s3, -87
			j Final
			
		Error:
			la $a0, undefined
			li $v0, 4
			syscall	
			
			beq $a3, 1, Exit
			
			la $a0, comma
			li $v0, 4
			syscall
			j ErrorDestination

	subprogram3:
		###################################################################################
		# Prints out the unsigned decimal equivalent of the value passed in the register. 
		#
		# Arg registers used: None < The parameter is passed through the stack.>
		# Tmp registers used:t7
		# 
		# Post: Prints out the decimal value.
		# Returns: None
		# 
		# Called by sub-program-2
		# Calls: None
		
		lw $t7, ($sp)
		addi $sp, $sp, 4
		
		blt $t7, 10, hawa # CHECKS IF NUMBER IS LESS THAN 10. IF YES, SENDS TO A LABEL HAWA THAT JUST PRINTS WITHOUT USING THE LOW AND HIGH REGISTER THAT PRINTS TWO DIGITS FOR A SINGLE DIGIT NUMBER.
		next:
		li $t0, 10		
		divu $t7, $t0 # UNSIGNED DIVISION BY 10 THAT MAKES THE 32 BIT NUMBER 31 BIT LONG( MAKING IT SAME AS UNSINED NUMBER) AND THE LSB IS STORE IN THE HIGH REGISTER WHICH CAN BE PRINTED INDIVIDUALLY.
		mflo $t0		
		la $a0, 0($t0)
		li $v0, 1
		syscall
		mfhi $t0
		la $a0, 0($t0)
		li $v0, 1
		syscall
		j CommaPrint

		hawa:
		blt $t7, 0, next # CHECKS IF IT IS A NEGATIVE NUMBER ( BECAUSE 32 BIT NUMBERS ARE NEGATIVE WHEN STORED AS 2S COMPLEMENT.) IF YES SENDS BACK TO THE CALLING PROGRAM.
		add $a0, $t7, 0
		li $v0, 1
		syscall
		
	CommaPrint:
		beq $a3, 1, Exit
		la $a0, comma
		li $v0, 4
		syscall
		jr $ra

	Exit:
		li $v0, 10
		syscall
		
		
	
