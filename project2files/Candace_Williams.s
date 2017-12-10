.data
char_array: .space 1001 #allocates space for 1000 characters and 1 NULL
invalid_hex: .asciiz "NaN" #for substrings with invalid characters
hex_too_large: .asciiz "too large" #for substrings with 8+ characters
comma: .asciiz ","

.text
	main: 
		addi $sp, $sp, -60
		li $v0, 8 #receives input
		la $a0, char_array #loads buffer into address
		li $a1, 1001 # allocates buffer space for string
		syscall

		addi $t0, $0, 0 #initializes as starting index
		addi $t1, $0, 0 #initializes ending index to zero

		la $t2, char_array #stores string address into register
		lb $t3,0($t2) #loads first index of string
		beq $t3, 10, Invalid #looks for new line character at first index$t0, $t0, 0 #initializes starting index to zero
	
		Check_Substring:
			lb $t3, 0($t2) #loads first index of string
			beq $t3, 0, Call_SubProgram_2 #checks for null, then jumps to evaluate substring
			beq $t3, 10, Call_SubProgram_2 #looks for new line character, then jumps to evaluate substring
			beq $t3, 44, Call_SubProgram_2 #looks for comma, then jumps to evaluate substring
			addi $t2, $t2, 1 #points to next character in string
			beq $t3, 32, Check_Substring #to skip spaces
      		addi $t1, $t1, 1 #ending index increments
			j Check_Substring #jumps to continues loop

		Call_SubProgram_2: 
			sw $t0, 4($sp) #stores current starting index
			sw $t1, 8($sp)	#stores current ending index
			sw $t2, 12($sp)	#stores current byte address
			sw $t3, 16($sp)	#stores current character
			jal SubProgram_2 #jumps to SubProgram_2
			jal SubProgram_3 #jumps to SubProgram_3

			lw $t0, 4($sp) #loads current starting index
			lw $t1, 8($sp) #loads current ending index
			lw $t2, 12($sp)	#loads current byte address
			lw $t3, 16($sp)	#loads current character
			
			beq $t3, 10, End_Program #Exits program if starting character is NULL
			beq $t3, 0, End_Program #Exits Program if starting character is newline

			add $t0, $t1, 1 #updates starting index
			add $t1, $t1, 1 #updates ending index
			add $t2, $t2, 1 #updates new substring
			j Check_Substring #loops to check new substring



		SubProgram_2:
			sw $ra, 20($sp)	#saves return PC of SubProgram_2 to main
			
			lw $t0, 4($sp) #loads starting index
			lw $t1, 8($sp) #loads ending index
			la $t2, char_array #load address of string 
			li $t3, 0 #register for reading chars

			beq $t0, $t1, Exit_SubProgram_2_with_Empty_String
			
			add $t2, $t2, $t0 #updates starting index
			add $t4, $0, $0 #stores the sum for the hex 
			sub $t5, $t1, $t0 #stores shift position by subtracting ending from start
			bgt $t5, 8, Hex_Too_Large #if substring is more than 8 characters
			sw $t5, 56($sp)	#stores length of substring onto stack
			la $s0, invalid_hex	#for checking invalid subprogram1 return
			
			Find_Hex_Sum: 
				beq $t0, $t1, Exit_SubProgram_2_with_Sum
				lb $t3, 0($t2) #loads chars of substring


				sw $t0, 24($sp)
				sw $t1, 28($sp)
				sw $t2, 60($sp)
				sw $t3, 32($sp)
				sw $t4, 36($sp)
				sw $t5, 40($sp)
				jal SubProgram_1
				#v1 contains translated value or NaN

				lw $t0, 24($sp)
				lw $t1, 28($sp)
				lw $t2, 60($sp)
				lw $t3, 32($sp)
				lw $t4, 36($sp)
				lw $t5, 40($sp)
				
				beq $s0, $v1, Exit_SubProgram_2_with_NaN	#for invalid substring
				add $t4, $t4, $v1

				addi $t0, $t0, 1#increments starting index
				addi $t2, $t2, 1#increments byte address
				addi $t5,$t5, -1#decrements shift amount/length
				j Find_Hex_Sum

		SubProgram_1:
			sw $ra, 44($sp)	#return PC of SubProgram_2 to Subprogram_1
			lw $t1, 32($sp) #loads character to be translated
			lw $t2, 40($sp) #loads shift amount/length

			#beq $t1, 32, Exit_SubProgram_1 #doesn't increment if character is a space
			blt $t1, 48, Invalid #checks if character is before 0 in ASCII chart
			blt $t1, 58, Translate_Number #checks if character is between 48 and 57
			blt $t1, 65, Invalid #checks if character is between 58 and 64
			blt $t1, 71, Translate_UpperCase #checks if character is between 65 and 70
			blt $t1, 97, Invalid #checks if character is between 71 and 96
			blt $t1, 103, Translate_LowerCase #checks if character is between 97 and 102
			blt $t1, 128, Invalid #checks if character is between 103 and 127

		Exit_SubProgram_1:
			lw $ra, 44($sp)
			jr $ra

		Exit_SubProgram_2_with_Sum:
			lw $ra, 20($sp)
			sw $t4, 48($sp)	#returns sum/value of substring on stack

			jr $ra
			
		Exit_SubProgram_2_with_NaN:
			lw $ra, 20($sp)

			sw $v1, 48($sp)	# puts NaN as return value of Subprogram 2

			jr $ra
		
		Exit_SubProgram_2_with_TooLarge:
			lw $ra, 20($sp)
			sw $v1, 48($sp)	# puts NaN as return value of Subprogram 2
			jr $ra

		Exit_SubProgram_2_with_Empty_String:
			lw $ra, 20($sp)
			la $v1, invalid_hex
			la $a0, invalid_hex
			li $v0, 4 #prints NaN for empty string
			syscall
			la $a0, comma #prints comma after
			li $v0, 4
			syscall
			sw $v1, 48($sp)	# puts NaN as return value of Subprogram 2
			jr $ra
			
		Hex_Too_Large:
			la $a0, hex_too_large #loads string
			li $v0, 4 #prints too large for string
			syscall
			la $a0, comma
			li $v0, 4
			syscall
			la $v1, hex_too_large
			j Exit_SubProgram_2_with_TooLarge

		Invalid:
			la $a0, invalid_hex #loads string
			li $v0, 4 #prints NaN for string
			syscall	
			la $a0, comma
			li $v0, 4
			syscall
			la $v1, invalid_hex #loads "NaN" memory address into $v1
			j Exit_SubProgram_1

		Translate_Number:
			sub $t1, $t1, 48 #subtracts 48 from the ASCII value
			addi $t2, $t2, -1
			li $t3, 4
			mult $t2, $t3
			mflo $t4	#shift left amount (position -1 ) *4

			sllv $t1, $t1, $t4 #shifts hex value to represent position in 

			li $v1, 0	#return register for Subprogram_1
			add $v1, $v1, $t1 #adds hex value to the sum
			j Exit_SubProgram_1

		Translate_LowerCase:
			sub $t1, $t1, 87 #subtracts 48 from the ASCII value
			addi $t2, $t2, -1
			li $t3, 4
			mult $t2, $t3
			mflo $t4	#shift left amount (position -1 ) *4

			sllv $t1, $t1, $t4 #shifts hex value to represent position in 

			li $v1, 0	#return register for Subprogram_1
			add $v1, $v1, $t1 #adds hex value to the sum
			j Exit_SubProgram_1

		
		Translate_UpperCase:
			sub $t1, $t1, 55 #subtracts 48 from the ASCII value
			addi $t2, $t2, -1
			li $t3, 4
			mult $t2, $t3
			mflo $t4	#shift left amount (position -1 ) *4

			sllv $t1, $t1, $t4 #shifts hex value to represent position in 

			li $v1, 0	#return register for Subprogram_1
			add $v1, $v1, $t1 #adds hex value to the sum
			j Exit_SubProgram_1

		SubProgram_3:
			sw $ra, 52($sp)
			lw $t0, 48($sp) #load sum to print
			la $s0, invalid_hex
			beq $t0, $s0, Exit_SubProgram_3 #prevents printing of "NaN" as number
			la $s0, hex_too_large
			beq $t0, $s0, Exit_SubProgram_3 #prevents printing of "NaN" as number
			
			lw $t1, 56($sp) #loads length of substring
			beq $t1, 8, SubProgram_3_2s_Complement

			add $a0, $t0, $0
			li $v0, 1 #prints sum
			syscall

			la $a0, comma
			li $v0, 4
			syscall
			j Exit_SubProgram_3

		SubProgram_3_2s_Complement:
			li $s1, 10000 #stores 10000 in $s0
			divu $t0, $s1 #divides sum by multiple of 10 (10000)

			mflo $a0 #stores quotient
			li $v0, 1 #prints quotient
			syscall

			mfhi $a0 #stores remainder
			li $v0, 1 #prints remainder
			syscall

			la $a0, comma #loads comma to be printed
			li $v0, 4 #prints comma value
			syscall

			j Exit_SubProgram_3

		Exit_SubProgram_3:

			lw $ra, 52($sp)
			jr $ra

		End_Program:
			li $v0,10 #ends program
			syscall
