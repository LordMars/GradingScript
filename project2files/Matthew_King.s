#######################################################
#######################################################
## AUTHOR: Matthew King                              ##
## COURSE: Computer Organization I                   ##
## PROGRAM: ASSIGNMENT 2                             ##
## FUNCTION: Converts Hexadecimal code to Decimal    ##
#######################################################
#######################################################

	.data #Data declaration component
	userInput: #location were valid entry is stored
		.space 1001 #1001 bytes, 1 byte per possible character, and an end-of-string marker; Space is maximum size
	
	notANumberMessage: #error message for numbers containing incorrect characters
		.asciiz "NaN"
	
	tooLargeMessage: #error message for numbers greater than 8 digits
		.asciiz "too large"
		
	formattingComma: #comma placed between outputs
		.asciiz ","
	
	outputDecimal: #string version of number (stored here because the 32 bit register represents 2s compliment vs unsigned)
		.space 10 #Largest expected value is 4294967295 (FFFFFFFF); 10 digits long
	
#####################################################
# MODULE: main                                      #
# PURPOSE: Initial driver for code                  #
# $s0 CONST End of string - END                     #
# $s1 CONST Maximum size of string - STRSIZE        #
# $s2 CONST Input Base - INBASE                     #
# $s3 CONST Output Base - OUTBASE                   #
# $s4 CONST Space - SPACE                           #
# $s5 CONST Comma - COMMA                           #
# $s6 address of current substring - subAddress		#
# $t0 Cumulative sum - cumulativeSum                #
# $t1 Address of decimal in string form - deciString#
#####################################################
	.text #Assembly instructions component
main: #Start of code
	#variables intialized
	li $s0, 10 #CONST END = 10
	li $s1, 8 #CONST STRSIZE = 8
	li $s2, 16 #CONST INBASE = 16
	li $s3, 10 #CONST OUTBASE = 10
	li $s4, 32 #CONST SPACE = 32
	li $s5, 44 #CONST COMMA = 44
	addi $sp, $sp, -4
	sw $zero, 0($sp) #start of stating that there are zero substring detected
	
input:
	li $a1, 1000 #Specify max size for read string read characters = ($a1 - 1) = 1000 max
	la $a0, userInput #Set destination for read string
	li $v0, 8 #Read String code loaded
	syscall #Read string from user
	la $s6, userInput
	
validityCheck:
	lb $t1, 0($s6)
	beq $t1, $zero, stringConversionEntryPoint

	add $a0, $s6, $zero
	jal CheckData #Verifies if userInput is a valid HEX value
	add $s6, $v1, $zero 
	
	bne $v0, $zero, decimalConversion #convert to decimal if input is valid
	add $a1, $v0, $zero #load invalid-number-code into argument1
	j validityCheck

decimalConversion:
	add $a0, $v0, $zero #pass the string's starting position as an argument
	jal subprogram_2 #convert the code to a decimal value
	add $t0, $v0, $zero #load the returned cumulative sum into $t0
	
	add $a0, $t0, $zero #load the cumulative sum as an argument
	add $a1, $v0, $zero #load valid-number-code into argument1
	j validityCheck
	
	
stringConversionEntryPoint:
	jal FlipStack
stringConversion:
	lw $t1, 0($sp) 
	addi $sp, $sp, 4
	beq $t1, $zero, exit
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	jal subprogram_3
	j stringConversion

	
exit:
	li $v0, 10 #Exit code loaded
	syscall	#Exit program
	
	
#####################################################
# MODULE: CheckData                                 #
# PURPOSE: Check if entered code is valid           #
# $a0 Starting address of string - argument1        #
# $t0 Current digit address - curAdd                #
# $t1 Current digit - curDigit                      #
# $t2 Digit counter - digitCount                    #
# $t3 Current invalid flag/digiInvalFlag  			#
#  "  Substring count - subCount					#
# $t4 Invalid number flag - invalFlag               #
# $t5 Current ascii limit - curLim                  #
# $t6 Value to compare char against - strCode       #
# $t7 Holds address of first digit - numStart       #
# $t8 Represents the string's pattern - strCode     #
# $v0 $t4, Invalid flag/starting number - returnVar1#
# $v1 starting address of next sub-string			#
#                                                   #
# NOTES:                                            #
# Code used to classify string is as follows:       #
# 0 - First read (no spaces or numbers)             #
# 1 - Contains only numbers (non-spaces)            #
# 2 - Contains only spaces                          #
# 3 - Contains number(s) followed by a space        #
#####################################################
	
CheckData:
	add $t7, $a0, $zero #default first-digit-position to start of string
	
	add $t0, $t7, $zero #points intially to start of string
	li $t8, 0 #starts number status as blank
	li $t4, 0 #innocent until proven guilty
	findSpaces:
		lb $t1, 0($t0) #loads new digit
		
		beq $t1, $s5, findSpacesEnd   #end process whenever read character is comma
		beq $t1, $s0, findSpacesEnd   #end process whenever read character is newline
		beq $t1, $zero, findSpacesEnd #end process whenever read character is NULL
		bne $t1, $s4, isNotSpace #if the read character is not a space
		isSpace:
			li $t6, 0 #load blank
			beq $t6, $t8, wasBlankAddSpace #branch if previously unset
			li $t6, 1 #load number
			beq $t6, $t8, wasNumAddSpace #branch if previously just number
			li $t6, 2 #load space
			beq $t6, $t8, wasSpaceAddSpace #branch if previously just space
			li $t6, 3 #load numAndSpace
			beq $t6, $t8, wasNumAndSpaceAddSpace #branch if previously just space
			
		isNotSpace:
			li $t6, 0 #load blank
			beq $t6, $t8, wasBlankAddNum #branch if previously unset
			li $t6, 1 #load number
			beq $t6, $t8, wasNumAddNum #branch if previously just number
			li $t6, 2 #load space
			beq $t6, $t8, wasSpaceAddNum #branch if previously just space
			li $t6, 3 #load numAndSpace
			beq $t6, $t8, wasNumAndSpaceAddNum #branch if previously just space
		#string also contains a space
		wasBlankAddSpace:
			li $t8, 2 #blank -> space
			j nextNo
		wasNumAddSpace:
			li $t8 3 #num -> numAndSpace
			sb $s0, 0($t0) #represent end of string with a newline
			j nextNo
		wasSpaceAddSpace:
			j nextNo #no change
		wasNumAndSpaceAddSpace:
			j nextNo #no change
			
		#string also contains a number
		wasBlankAddNum:
			li $t8, 1 #blank -> num
			add $t7, $t0, $zero #record starting address of actual
			j nextNo #no change
		wasNumAddNum:
			j nextNo #no change
		wasSpaceAddNum:
			li $t8, 1 #blank -> num
			add $t7, $t0, $zero #record starting address of actual number
			j nextNo 
		wasNumAndSpaceAddNum:
			li $t4, 1 #invalid; a space cannot exist between two numbers
			#j CheckDataEnd #no need to check any further once proven invalid
		
		nextNo:
			addi $t0, $t0, 1 #shift attention to next character
			j findSpaces #repeats filtering process for next character
	findSpacesEnd:
	sb $s0, 0($t0) #mark the end of valid code with the end-of-string value
	addi $v1, $t0, 1 #records starting address of next substring
	
	add $t0, $t7, $zero #shift attention back to the first number value in the string
	li $t2, 0
	checkDataLoop:
		lb $t1, 0($t0) #loads new digit 
		beq $t1, $s0, IsEmpty #If the value is End-of-String, check to see if the string is empty
		ifNotEnd: #if(curDigit != END)
			#is the digit a number
			li $t5, 47 #set curLim to "0" - 1
			slt $t3, $t1, $t5 #return 1 if digit is less than "0"
			bne $t3, $zero, AddToInvalFlag #digit is invalid as it is less than "0"
			li $t5, 57 #set curLim to "9"
			slt $t3, $t5, $t1 #return 1 if "9" is less than digit
			beq $t3, $zero, AddToInvalFlag #digit is between "0" and "9"
			
			#is the digit a valid upper-case letter
			li $t5, 64 #set curLim to "A" - 1
			slt $t3, $t1, $t5 #return 1 if digit is less than "A"
			bne $t3, $zero, AddToInvalFlag #digit is invalid as it is less than "A"
			li $t5, 70 #set curLim to "F"
			slt $t3, $t5, $t1 #return 1 if "F" is less than digit
			beq $t3, $zero, AddToInvalFlag #digit is between "A" and "F"
			
			#is the digit a valid lower-case letter
			li $t5, 96 #set curLim to "a" - 1
			slt $t3, $t1, $t5 #return 1 if digit is less than "a"
			bne $t3, $zero, AddToInvalFlag #digit is invalid as it is less than "a"
			li $t5, 102 #set curLim to "f"
			slt $t3, $t5, $t1 #return 1 if "f" is less than digit
			beq $t3, $zero, AddToInvalFlag #digit is between "a" and "f"
	AddToInvalFlag:
		or $t4, $t3, $t4 #updates overall flag based on current digit check
		bne $t4, $zero, IsNaN #ends loop early if invalid number is found
		addi $t0, $t0, 1 #shifts attention to next digit
		addi $t2, $t2, 1 #increment digit counter
		
		j checkDataLoop
		#bne $s1, $t2, checkDataLoop #while digitCount != STRSIZE
	IsEmpty:
		bne $t2, $zero, IsTooLarge #do not mark the flag if the string has at least 1 member
		li $t4, 1 #mark as invalid if empty
		j IsNaN
	IsTooLarge:
		slt $t3, $s1, $t2 #return 1 if max size is less than digit count
		beq $t3, $zero, CheckDataEnd #do not mark the flag if string is at most 8 members long
		li $t4, 2 #mark as invalid if too large
		
		lw $t3, 0($sp) #read number of detected substrings from top of stack
		addi $sp, $sp, 4
		addi $t3, $t3, 1 #increase the number of detected substrings by 1
		addi $sp, $sp, -4
		sw $zero, 0($sp) #loads filler number which will not be read
		addi $sp, $sp, -4
		sw $t4, 0($sp) #loads 2 to represent "Too Large" in the stack
		addi $sp, $sp, -4
		sw $t3, 0($sp) #save updated number of detected substrings
		
		j CheckDataEnd
	IsNaN:
		lw $t3, 0($sp) #read number of detected substrings from top of stack
		addi $sp, $sp, 4
		addi $t3, $t3, 1 #increase the number of detected substrings by 1
		addi $sp, $sp, -4
		sw $zero, 0($sp) #loads filler number which will not be read
		addi $sp, $sp, -4
		sw $t4, 0($sp) #loads 1 to represent NaN in the stack
		addi $sp, $sp, -4
		sw $t3, 0($sp) #save updated number of detected substrings 
		j CheckDataEnd
	CheckDataEnd:
		beq $t4, $zero, returnValid
		li $v0, 0 #set "start" to null if invalid
		j exitCheckData
		returnValid:
			
			add $v0, $t7, $zero #load starting postion into return register, $v0
		exitCheckData:
			jr $ra #end of function
	
#####################################################
#-------------------subprogram_2--------------------#
# MODULE: CalcuateDecimal                           #
# PURPOSE: Converts Hex code to a decimal number    #
# $a0 Starting address of string - argument1        #
# $t0 Current digit address - curAdd                #
# $t1 Current digit - curDigit                      #
# $t2 Digit counter - digitCount                    #
# $t3 Exponent progress tracker - expCounter        #
# $t4 Multiplier - multiplier                       #
# $t5 Maximum exponent of current digit - expMax    #
# $t6 Digit decimal value - digiVal                 #
# $t7 Cumulative sum - cumulativeSum                #
# $t8 Temp const holder - tempConstHolder           #
# $v0 $t7, cumulative sum - returnVar1              #
#####################################################

subprogram_2:
	add $t0, $a0, $zero #sets digit address to leftmost slot
	li $t2, 0 #initializes digit counter to zero
	totalDigitsLoop:
		lb $t1, 0($t0) #loads new digit 
		beq $t1, $s0, totalDigitsLoopEnd #If the value is END
		beq $t2, $s1, totalDigitsLoopEnd #If counter = max string size
		addi $t0, $t0, 1 #shifts attention to next digit
		addi $t2, $t2, 1 #increment digit counter
		j totalDigitsLoop
	
	totalDigitsLoopEnd:
		sub	$t0, $t0, $t2 #resets pointer to start of string
		lb $t1, 0($t0) #loads new digit; loads 10 if empty string
	
		li $t7, 0 #cumulativeSum = 0
		addi $t5, $t2, -1 #starts expMax at maximum exponent (n-1)
		beq $t1, $s0, addDecimalDigitsLoopEnd #skips process and returns 0 if input is empty string
		addDecimalDigitsLoop:
			li $t3, 0 #expCounter = 0
			li $t4, 1 #multiplier = 1
			multiplierLoop: #calculates what power of 16 the digit is to be multiplied by
				bne $t3, $t5, prepareMultiplier #execute until the multiplier is multiplied by 16^expMax

				charToIntFunction: #identifies what the decimal value is of the given character
				
				addi $sp, $sp, -4 
				sw $ra, 0($sp) #save function return address to stack
				add $a0, $t1, $zero #load character to be converted
				jal subprogram_1 #convert character to decimal equivalent
				add $t1, $v0, $zero #load result of function into $t1
				lw $ra, 0($sp) #return function return address to original
				addi $sp, $sp, 4
				j applyMultiplier
				
			prepareMultiplier:
				mult $t4, $s2 #multiply by 16 (effectively raise by a power)
				mflo $t4 #load result of multiplier * 16
				addi $t3, $t3, 1 #increment exponent counter
				j multiplierLoop


				
			applyMultiplier: #multiplier actual decimal value by multiplier
				mult $t4, $t1 #multiplier * digit value
				mflo $t6 #loads result of multiplier * digit value
				add $t7, $t7, $t6 #adds digit decimal value to cumulativeSum
				addi $t5, $t5, -1 #lowers expMax ceiling
				li $t8, -1 #loads lowest expMax case
				beq $t8, $t5, addDecimalDigitsLoopEnd #exits if expMax drops below 0
				addi $t0, $t0, 1 #shifts attention to next digit
				lb $t1, 0($t0) #loads next digit
				
				j addDecimalDigitsLoop
		addDecimalDigitsLoopEnd:
		
			lw $t3, 0($sp) #read number of detected substrings from top of stack
			addi $sp, $sp, 4 
			addi $t3, $t3, 1 #increase the number of detected substrings by 1
			addi $sp, $sp, -4 
			sw $t7, 0($sp) #loads cumulativeSum into Stack
			addi $sp, $sp, -4 
			sw $zero, 0($sp) #loads code to indicate that number is valid
			addi $sp, $sp, -4 
			sw $t3, 0($sp) #loads updated number of substrings
			
			jr $ra #end of function
		
###########################################################
#----------------------subprogram_1-----------------------#
# MODULE: TranslateCharToInt                              #
# PURPOSE: Converts individual character to decimal value #
# $a0 character to convert - curChar                      #
# $t1 $a0 character to convert - curChar                  #
# $t8 Current character limit - curLim                    #
# $v0 $t1, converted character - returnVar1               #
###########################################################			
subprogram_1:
	add $t1, $a0, $zero
	li $t8, 58 #set curLim to "9" + 1
	slt $t8, $t8, $t1  #return 1 if "9" is less than digit
	bne $t8, $zero, notDigit #character is a letter in "A-F"/"a-f"
	addi $t1, $t1, -48 #lower value so that "0" = 0
	j subprogram_1End 
	notDigit:
		li $t8, 71 #set curLim to "F" + 1
		slt $t8, $t8, $t1 #return 1 if "9" is less than digit
		bne $t8, $zero, notUpper #character is a letter in "a-f"
		addi $t1, $t1, -55 #lower value so that "A" = 10
	j subprogram_1End
	notUpper:
		li $t8, 103 #set curLim to "f" + 1
		slt $t8, $t8, $t1 #return 1 if "9" is less than digit
		addi $t1, $t1, -87 #lower value so that "a" = 10	
	subprogram_1End:
		add $v0, $t1, $zero #load decimal value into return register
		jr $ra #end of function

		
###########################################################
# MODULE: FlipStack					                      #
# PURPOSE: reverses stack order of stack elements		  #
# $t0 number of substrings/size of stack - subCount		  #
# $t1 temporary constant holder - tempConstHolder		  #
# $t2 substring counter 								  #
# $t3 swap address 1 									  #
# $t4 swap address 2									  #
# $t5 temporary content holder 1						  #
# $t6 temporary content holder 2						  #
###########################################################

FlipStack:
	lw $t0, 0($sp) #read number of substrings
	addi $sp, $sp, 4
	
	add $t3, $sp, $zero #set swap address 1 initial site to start of content
	li $t2, 1 #counter = 1
	li $t1, 2 #counter  < stackSize/2
	
	subu $t4, $t0, $t2 #displacement = stackSize - counter
	li $t1, 2 #no. of elements per unit
	mult $t4, $t1 #displacement = (stackSize - counter)*(elements per unit)
	mflo $t4 #load result
	li $t1, 4 #wordsize
	mult $t4, $t1 #displacement = (stackSize - counter)*(elements per unit)*(wordsize)
	mflo $t4 #load result
	add $t4, $t3, $t4 #swap address 2 = swap address 1 + displacement
		
	SwapLoop:
		li $t1, 2 
		divu $t0, $t1 #stackSize/2
		mflo $t1 #load result
		
		slt $t1, $t1, $t2 #return 1 if half-of-stack-size is less than counter
		bne $t1, $zero SwapLoopEnd #end loop if half-of-stack-size >= counter
		
		#swap validity codes
		lw $t5, 0($t3) #load code a address 1
		lw $t6, 0($t4) #load code at address 2
		sw $t5, 0($t4) #overwrite address 2 content with address 1 content
		sw $t6, 0($t3) #overwrite address 1 content with address 2 content
		
		addi $t3, $t3, 4 #shift address 1 to the decimal component
		addi $t4, $t4, 4 #shift address 2 to the decimal component
		
		#swap decimal values
		lw $t5, 0($t3) #load code a address 1
		lw $t6, 0($t4) #load code at address 2
		sw $t5, 0($t4) #overwrite address 2 content with address 1 content
		sw $t6, 0($t3) #overwrite address 1 content with address 2 content
		
		addi $t3, $t3, 4 #shift attention to next unit
		addi $t4, $t4, -12 #shift attention to previous unit
		addi $t2, $t2, 1 #counter++
		j SwapLoop #repeat loop while counter < stackSize/2
	SwapLoopEnd:
		addi $sp, $sp, -4 
		sw $t0, 0($sp) #save number of substrings
		
		jr $ra #end of function

		
###########################################################
#----------------------subprogram_3-----------------------#
# MODULE: ConvertDecimalStackToString                     #
# PURPOSE: Stringifies decimal so it is read as unsigned  #
# $t0 number of substrings left                           #
# $t1 Status of decimal - deciStat                        #
# $t2 Decimal to convert - deciVal                        #
# $t3 Destination string of converted decimal - deciString#
# $t4 deciVal mod 10 - modResult                          #
# $t5 temporary comparison holder						  #
###########################################################

subprogram_3:
	lw $t0, 0($sp) #read number of substrings
	addi $sp, $sp, 4
	lw $t1, 0($sp) #read status of substring from stack
	addi $sp, $sp, 4
	lw $t2, 0($sp) #read number from stack
	addi $sp, $sp, 4
	
	bne $t1, $zero, invalidDecimal #output is code dependent if decimal is not valid
	validDecimal:
		la $t3, outputDecimal #sets destnation string of decimal conversion
		addi $t3, $t3, 9 #shift attention to the end of the string
		addToString:
			divu $t2, $s3 #obtain the rightmost decimal digit of the decimal
			mfhi $t4 #load rightmost digit
			mflo $t2 #load decimal without the rightmost digit
			addi $t4, $t4, 48 #raise value so that 0 = "0", 1 = "1", etc.
			sb $t4, 0($t3) #save character-digit in the string
			addi $t3, $t3, -1 #shift attention to the space left of previous
			bne $t2, $zero, addToString #repeat until there are no digits remaining
		addi $t3, $t3, 1 #readjust pointer to start of the string
		add $a0, $t3, $zero #Set output source to cumulativeSum
		j PrintNumber #jump to output statement
	invalidDecimal:
		li $t5, 1
		bne $t5, $t1, isTooLarge 
		isNaN: #code 1 translates to NaN
			la $a0, notANumberMessage #Set output source to NaN message
			j PrintNumber #jump to output statement
		isTooLarge: #code 2 translates to "too large"
			la $a0, tooLargeMessage #Set output source to "too large" message
			j PrintNumber #jump to output statement
	PrintNumber:
		addi $t0, $t0, -1 #decrease substring count by 1
		addi $sp, $sp, -4 
		sw $t0, 0($sp) #save updated number of substrings
		li $v0, 4 #Output String code loaded
		syscall	#Output message
		beq $t0, $zero, subprogram_3End #no comma if last number
		la $a0, formattingComma #place comma between numbers
		li $v0, 4 #Output String code loaded
		syscall	#Output message
	
	subprogram_3End:
		jr $ra #end of function
