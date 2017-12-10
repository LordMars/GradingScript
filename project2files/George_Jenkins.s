.data

naN: .asciiz "NaN"
tooLarge: .asciiz "too large"
word: .asciiz "test"
camma: .asciiz ","
space: .asciiz ""
newLine: .asciiz "\n"
errorMessage: .asciiz "Error \n"
userInput: .space 1000

.text

main:
		
	la $a0, userInput
	la $a1, 1001
	li $v0, 8
	syscall
		
		
		
la $a0, newLine
li $v0, 4
#syscall
		
	#$s0(stores string) $s1(gets decimals added to it) $s2(stores bytes) 
	#$s3(number of chars) $s4(stores decimal when displaying) 
	#$s5 (is 1 when there is another number in input and 0 otherwise. Value gets checked after one conversion)
	#$s6 stores user input and gets its offset changed to move to next string
	#s7 stores 1 if there hex is not a number 0 otherwise
		
	#start conversion. 
	la $s6, userInput
startProcess:
	move $s0, $s6
	addi $s1, $zero, 0
	addi $s3, $zero, 0	
		
	#count number of chars in string
	countLoop:
		lb $t1, 0($s0)
		beq $t1, 44, acknowledgeNextNumber #a camma was reached
		beq $t1, 32, dontCountSpaceOrEnter
		beq $t1, 10, dontCountSpaceOrEnter
		beq $t1, 9, dontCountSpaceOrEnter#skip tab
		addi $s5, $zero, 0 #set acknowledgment of camma to none
		beqz $t1, doneCounting
		beq $t1, 10, doneCounting
		addi $s3, $s3, 1
			dontCountSpaceOrEnter:
			addi $s0, $s0, 1	
			j countLoop
			acknowledgeNextNumber:
				addi $s5, $zero, 1
				j doneCounting
				
	doneCounting:
	
	
	#if there was no char skip a bunch of code
	bnez $s3, charDetected
	la $a0, naN
	li $v0, 4
	syscall
	j skipDisplayDecimal
	charDetected:
	
													
	move $s0, $s6 #reset $s0 to input
		
	addi $s7, $zero, 0 #set register that detects NaN to 0
	addi $t7, $zero, 0 #set register that detects tab to 0
			
stringConversion: #my subprogram 2
		
	lb $s2, 0($s0)
		
	beqz $s2, doneStringConversion #if this is 0 the program has converted all chars 
	beq $s2, 10, doneStringConversion #if this is 10 the program has converted all chars 
		
	jal charConversion 
	
			addi $s3, $s3, -1 #reduce count of chars
		
			skipSpace:
			addi $s0, $s0, 1 #add to adddress of string
			
			j stringConversion
			
		doneStringConversion:
			#store in stack
			addi $t0, $zero, 10
			addi $sp, $sp, -8
			la $s2, ($s1)
			
			divu $s2, $t0
			mflo $s2
			sw $s2, 4($sp)
			
			mfhi $s2
			sb $s2, 0($sp)
			#end store in stack
			
			
			beqz $s7, noError #skip this if there was no error
			la $a0, naN
			li $v1, 4
			syscall
			j skipDisplayDecimal
			noError:
		
			beqz $t7, noError2#skip this if there was no error
			la $a0, tooLarge
			li $v1, 4
			syscall
			j skipDisplayDecimal
			noError2:
		
		jal displayDecimal #display decimal
		skipDisplayDecimal:
		
		#see if there was a camma after the number that was just converted. $s5 is 0 if there wasn't
		beqz $s5, done
		addi $s0, $s0, 1#add 1 to move past camma
		move $s6, $s0  #increase offset by number of chars to start at next word
		
		la $a0, camma
		li $v0, 4
		syscall
		
		j startProcess
		
		done:
		
	li $v0, 10
	syscall

				
charConversion:	#my subprogram 1	
			add $t5, $zero, $ra #store $ra because it will change below
			beq $s2, 9, skipSpace #ignore tab				
			beq $s2, 32, skipSpace #ignore space
			bgt $s3, 8, error2 # too large 
			beq $s2, 44, doneStringConversion
			blt $s2, 48, error
			blt $s2, 58, number
			blt $s2, 65, error
			blt $s2, 71, uppercase
			blt $s2, 97, error
			blt $s2, 103, lowercase
			j error
		  
			lowercase:
				addi $s2, $s2, -87
				jal calcMultiple
				add $s1, $s1, $s2 
				
				j doneCharConversion
			uppercase:
				addi $s2, $s2, -55
				jal calcMultiple
				add $s1, $s1, $s2
				j doneCharConversion
			number:
				addi $s2, $s2, -48
				jal calcMultiple
				add $s1, $s1, $s2
				j doneCharConversion
			error:
				addi $s7, $zero, 1 #set to 1 to signal NaN detected. string will finish being converted however
				j doneCharConversion	
			error2:		
				addi $t7, $zero, 1 #set to 1 to signal too large detected. string will finish being converted however
				j doneCharConversion
																																						
			doneCharConversion:
			jr $t5

displayDecimal: #my subprogram 3
			lw $t4, 4($sp)
			beqz $t4, skipDisplayQuotient
			la $a0, ($t4)
			li $v0, 1
			syscall
			skipDisplayQuotient:
			lw $t5, 0($sp)
			la $a0, ($t5)
			li $v0, 1
			syscall
			
			addi $sp, $sp, 8
			
			
				
		jr $ra		
								
calcMultiple:
	addi $t0, $zero, 1 #becomes the multiple of 16
	addi $t1, $zero, 16 #simply equals 16
	addi $t2, $zero, 0 #counts loops
	calcLoop:
		addi $t2, $t2, 1
		beq $t2, $s3, endCalcLoop
		mult $t0, $t1
		mflo $t0
		j calcLoop
	endCalcLoop:
	mult $s2, $t0
	mflo $s2
	jr $ra				
	
