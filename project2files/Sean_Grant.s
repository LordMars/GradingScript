# MIPS-Programming-Assignment-2
#Fall 2017 Computer Organization I MIPS Assembly Assignment 2
# Sean Grant @02753064

.data
	str:	      
	.space 1001   
	str2:         
	.asciiz "NaN"
	str3:
	.ascii "too large"
	eachString: .word 0:10001 # array that holds each string that wasseperated by a comma
	decimalValue: .word 0:8   # array that will hold the decimal values of each hex digit
.text	
main: 
	   li $v0, 8              # system call code for reading an input string = 8	
	   la $a0, str            # loads the string entered into register $a0
	   li $a1, 10001          # tells the operating system that 1000 bytes were declared for the string
	   syscall	          # calls the operating system
	   add $t1, $a0, $zero    # t1 holds address of first char in string
	   addi $t3, $zero, 0     # eachString index = 0
	   addi $t6, $zero, 0     # initialize $t6 for its operation with the EndSwitch variable
	   addi $a3, $zero, 0     # VERY IMPORTANT - INITIALIZE THE SWTICH THAT ENDS THE ENTIRE PROGRAM
	   
##################################################### This following section copies characters into an array until a comma is read	   
	   
resetCounter:	add $t4, $zero, $zero # initializing the counter that counts how many characters are in the string
                add $t5, $zero, $zero               # initialize counter that will check for empty strings
                add $t3, $zero, $zero               # initialize the index for the individual string array
getEachString:  lb $t2, 0($t1)                      # load each character of the entered string into $t2
                beq $t2, 44, selectionProcess       # if the character is a comma, branch to the next section
                beq $t2, 0, FlipEndSwitch 
                beq $t2, 10, FlipEndSwitch              
continue:       sb $t2, eachString($t3)             # load each character into the eachString array
                addi $t4, $t4, 1                    # increment string counter
                addi $t3, $t3, 1                    # increment index for individual string array
                addi $t1, $t1, 1                    # increment index for the entire string entered by user
                seq $s2, $t2, 32	            # set $s2 to 1 if charcter is a space
                beq $s2, 1, emptyString             # if the character is a space, count the number of spaces
	        j getEachString                     # restart loop
	 
##################################################### following section checks for "too long" strings or empty strings  
	                      
selectionProcess: addi $t1, $t1, 1                  # incrment to the next character after the comma
                  beq $t4, 0, printNaN              # if the only character checked was a comma...print NaN
                  beq $t5, $t4, printNaN            # if the string is empty, print NaN          
                  sgt $s1, $t4, 8                   # checks for a string that is less than or equal to 8 characters
                  beq $s1, 1, printTooLong          # if string is larger than 8 characters, print "too long"
                  j StartLoop
                  
emptyString:      addi $t5, $t5, 1       # count how many spaces are in the string
                  j getEachString        # restart internal loop that checks each char in individual string
	             	        	          	        	        
########################################## Followig section checks for Hex characters	             	        	          	                
	             	        	          	        	        
StartLoop:   addi $t5, $zero, 0          # initialize $t5 which is the index for reading each char from string
CheckString: lb $t2, eachString($t5)     # loads each byte of the string into $t2 
             sge $s0, $t2, 48            # if the character we are looking at is '0' or above '0' then $s0 is set to the value 1
             sle $s1, $t2, 57            # if the character we are looking at is '9' or below '9' then $s1 is set to the value 1
             beq $s0, 1, Test1Condition2 # if $s0 is equal to 1, then the character is greater than or equal to '0'
             j Test2Condition1           # fails the first test, moves on to check the character against the second test 

Test1Condition2: bne $s1, 1, Test2Condition1 # if $s1 was not set, fails the first test. Moves on to check against the second test        
                 j NextChar                  # passes the first test, moves on to the next character in the string

Test2Condition1: sge $s2, $t2, 97            # if the character we are looking at is 'a' or above 'a' then $s2 is set to the value 1 
                 sle $s3, $t2, 102           # if the character we are looking at is 'f' or below 'f' then $s3 is set to the value 1         
                 beq $s2, 1, Test2Condition2 # if $s2 is equal to 1, then the character is greater than or equal to 'a' 
                 j Test3Condition1           # fails the second test, moves on to check the character against the third test

Test2Condition2: bne $s3, 1, Test3Condition1 # if $s3 was not set, fails the second test. Moves on to check against the third test
                 j NextChar                  # passes the second test, moves on to the next character in the string

Test3Condition1: sge $s4, $t2, 65            # if the character we are looking at is 'A' or above 'A' then $s4 is set to the value 1
                 sle $s5, $t2, 70            # if the character we are looking at is 'F' or below 'F' then $s5 is set to the value 1   
                 beq $s4, 1, Test3Condition2 # if $s4 is equal to 1, then the character is greater than or equal to 'A'
                 j printNaN                  # all three tests failed for this character, go to print the error message and exit the loop           

Test3Condition2: bne $s5, 1, printNaN        # if $s5 was not set, fails the third test. prints the error message
                 j NextChar                  # otherwise it passes the third test, moves on to the next character        

NextChar:  addi $t5, $t5, 1                  # increments the register in order to read the next byte of the string
           beq $t5, $t4, EndHexCheck         # EXITS LOOP if the number of characters is equal to the string index
	   j CheckString                     # jump back to the beginning of the loop

############################################## Following section controls which subroutine is entered next and when to set exit switch
	  	  	  
EndHexCheck: jal subProgram2	  	       	        	           	        	            	        	           	        	            	        	           	        	        	       	        	           	        	            	        	           	        	            	        	           	        	        
             jal subProgram3           	        	           	        	           	        	        	             	        	           	        	           	        	        
	     j resetCounter 
	            	        	           	              	        	           	        	           	        	           	        	           	        	               
FlipEndSwitch: addi $a3, $zero, 1
               j selectionProcess
	        	        
########################################### subprogram2 converts each he character into ints decimal value by checking to see hex character
#                                           it is and then calls subprogram1 to do the conversion of each character	        	        	        
	        	        	        	        	        
subProgram2:  add $t0, $ra, $zero         # copies the return address to $t0
              addi $t5, $zero, 0          # initilize $t5 which is the index for each char in the string 
	      addi $t7, $zero, 0          # initilize $t7 which is the index for loading the ACTUAL values into the decimalValues array
CheckString2: addi $t8, $zero, 0          # initilize $s5 ====> Flag is set when digit 0 - 9 is found in the string
              addi $s6, $zero, 0          # initilize $s6 ====> Flag is set when digit a - f is found in the string
              addi $s7, $zero, 0          # initilize $s7 ====> Flag is set when digit A - F is found in the string
              beq $t5, $t4, AddTheValues  # EXITS LOOP if the number of characters is equal to the string index
              lb $t2, eachString($t5)     # loads each byte of the string into $t2 
              sge $s0, $t2, 48            # if the character we are looking at is '0' or above '0' then $s0 is set to the value 1
              sle $s1, $t2, 57            # if the character we are looking at is '9' or below '9' then $s1 is set to the value 1
              beq $s0, 1, Test1Part2      # if $s0 is equal to 1, then the character is greater than or equal to '0'
              j Test2Part1                # fails the first test, moves on to check the character against the second test 
	   
Test1Part2: bne $s1, 1, Test2Part1        # if $s1 was not set, fails the first test. Moves on to check against the second test
            addi $t8, $zero, 1            # FIRST TEST PASSED ==> set flag to indicate this is a 0 - 9 character
            jal subProgram1               # go to subprogram that gets the individual value of each hex char    
            j CheckString2                # restart loop    

Test2Part1: sge $s2, $t2, 97              # if the character we are looking at is 'a' or above 'a' then $s2 is set to the value 1 
            sle $s3, $t2, 102             # if the character we are looking at is 'f' or below 'f' then $s3 is set to the value 1         
            beq $s2, 1, Test2Part2        # if $s2 is equal to 1, then the character is greater than or equal to 'a' 
            j Test3Part1                  # fails the second test, moves on to check the character against the third test

Test2Part2: bne $s3, 1, Test3Part1        # if $s3 was not set, fails the second test. Moves on to check against the third test
            addi $s6, $zero, 1            # SECOND TEST PASSED ==> set flag to indicate this is a a - f character
            jal subProgram1               # go to subprogram that gets the individual value of each hex char
            j CheckString2                # restart loop

Test3Part1: sge $s4, $t2, 65            # if the character we are looking at is 'A' or above 'A' then $s4 is set to the value 1
            sle $s5, $t2, 70            # if the character we are looking at is 'F' or below 'F' then $s5 is set to the value 1   
            beq $s4, 1, Test3Part2      # if $s4 is equal to 1, then the character is greater than or equal to 'A'
            j printNaN                  # all three tests failed for this character, go to print the error message and exit the loop           

Test3Part2: bne $s5, 1, printNaN        # if $s5 was not set, fails the third test. prints the error message
            addi $s7, $zero, 1          # THIRD TEST PASSED ==> set flag to indicate this is a A - F character
            jal subProgram1             # go to subprogram that gets the individual value of each hex char
            j CheckString2              # restart loop

######################################### Section branches to th correct label that adds up the decimal values based on
#                                         how many digits were in the hex number	   
	   	   	   
AddTheValues:   add $t8, $zero, $zero        # initialize $t8, index of
                beq $t4, 1, oneElement       
                beq $t4, 2, twoElements      
                beq $t4, 3, threeElements    
                beq $t4, 4, fourElements     
                beq $t4, 5, fiveElements     # branch to different sub functions based on the length of string
                beq $t4, 6, sixElements
                beq $t4, 7, sevenElements
                beq $t4, 8, eightElements

oneElement: add $t9, $zero, $zero            # initialize $t9, index of
            lb $t5, decimalValue($t9)        # loads the value from array element
            add $t8, $t5, $zero              # calculate sum
            addi $sp, $sp, -4                # PUSH $t8 (total value) ONTO THE STACK
            sw $t8, 0($sp)                   # PUSH $t8 (total value) ONTO THE STACK
            add $ra, $t0, $zero              # get the return address for the firt subprogram call
            jr $ra                           # return to calling subprogram
        

twoElements: add $t9, $zero, $zero        
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 16            # use this register to multiply by 16
             multu $t5, $t6                 # multiply value by 16
             mflo $t8                       # put result in $t8
             addi $t9, $t9, 1               # increment $t9
             lb $t5, decimalValue($t9)      # loads the value from array element
             add $t8, $t8, $t5              # calculate sum
             addi $sp, $sp, -4              # PUSH $t8 (total value) ONTO THE STACK
             sw $t8, 0($sp)                 # PUSH $t8 (total value) ONTO THE STACK
             add $ra, $t0, $zero            # get the return address for the firt subprogram call
             jr $ra                         # return to calling subprogram
             
threeElements: add $t9, $zero, $zero
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 256           # multiply value by 256 which is in $t6
             multu $t5, $t6                 # multiply the value by 256
             mflo $t8                       # store result in $t8 
             addi $t9, $t9, 1               # increment $t9
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 16
             multu $t5, $t6
             mflo $t7     
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             add $t8, $t8, $t5              # calculate sum
             addi $sp, $sp, -4              # PUSH $t8 (total value) ONTO THE STACK
             sw $t8, 0($sp)                 # PUSH $t8 (total value) ONTO THE STACK
             add $ra, $t0, $zero            # get the return address for the firt subprogram call
             jr $ra                         # return to calling subprogram

fourElements: add $t9, $zero, $zero
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 4096          # mulitply corresponding  value by 4096
             multu $t5, $t6                 # multiply value by 4096
             mflo $t8                       # store result in $t8
             addi $t9, $t9, 1               # Increment $t9
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 256
             multu $t5, $t6 
             mflo $t7
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 16  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             add $t8, $t8, $t5              # calculate sum
             addi $sp, $sp, -4              # PUSH $t8 (total value) ONTO THE STACK
             sw $t8, 0($sp)                 # PUSH $t8 (total value) ONTO THE STACK
             add $ra, $t0, $zero            # get the return address for the firt subprogram call
             jr $ra                         # return to calling subprogram

fiveElements: add $t9, $zero, $zero
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 65536         # add cooresponding value to 65536
             multu $t5, $t6                 # carry out the multiplication
             mflo $t8                       # store result in $t8
             addi $t9, $t9, 1               # increment $t9
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 4096
             multu $t5, $t6 
             mflo $t7
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 256  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 16  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1 
             lb $t5, decimalValue($t9)      # loads the value from array element    
             add $t8, $t8, $t5              # calculate sum  
             addi $sp, $sp, -4              # PUSH $t8 (total value) ONTO THE STACK
             sw $t8, 0($sp)                 # PUSH $t8 (total value) ONTO THE STACK
             add $ra, $t0, $zero            # get the return address for the firt subprogram call
             jr $ra                         # return to calling subprogram

sixElements: add $t9, $zero, $zero
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 1048576       # add cooresponding value to 1048576
             multu $t5, $t6                 # carry out the multiplication
             mflo $t8                       # store result in $t8
             addi $t9, $t9, 1               # increment $t9
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 65536
             multu $t5, $t6 
             mflo $t7
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 4096  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 256  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1 
             lb $t5, decimalValue($t9)      # loads the value from array element  
             addi $t6, $zero, 16  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1  
             lb $t5, decimalValue($t9)      # loads the value from array element        
             add $t8, $t8, $t5              # calculate sum 
             addi $sp, $sp, -4              # PUSH $t8 (total value) ONTO THE STACK
             sw $t8, 0($sp)                 # PUSH $t8 (total value) ONTO THE STACK
             add $ra, $t0, $zero            # get the return address for the firt subprogram call
             jr $ra                         # return to calling subprogram


sevenElements: add $t9, $zero, $zero
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 16777216      # add cooresponding value to 16777216
             multu $t5, $t6                 # carry out the multiplication
             mflo $t8                       # store result in $t8
             addi $t9, $t9, 1               # increment $t9
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 1048576
             multu $t5, $t6 
             mflo $t7
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 65536  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 4096 
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1 
             lb $t5, decimalValue($t9)      # loads the value from array element  
             addi $t6, $zero, 256  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1  
             lb $t5, decimalValue($t9)      # loads the value from array element 
             addi $t6, $zero, 16  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1 
             lb $t5, decimalValue($t9)       
             add $t8, $t8, $t5              # calculate sum 
             addi $sp, $sp, -4              # PUSH $t8 (total value) ONTO THE STACK
             sw $t8, 0($sp)                 # PUSH $t8 (total value) ONTO THE STACK
             add $ra, $t0, $zero            # get the return address for the firt subprogram call
             jr $ra                         # return to calling subprogram


eightElements: add $t9, $zero, $zero
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 268435456     # add cooresponding value to 268435456
             multu $t5, $t6                 # carry out the multiplication
             mflo $t8                       # store result in $t8
             addi $t9, $t9, 1               # increment $t9
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 16777216
             multu $t5, $t6 
             mflo $t7
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 1048576  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1
             lb $t5, decimalValue($t9)      # loads the value from array element
             addi $t6, $zero, 65536 
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1 
             lb $t5, decimalValue($t9)      # loads the value from array element  
             addi $t6, $zero, 4096  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1  
             lb $t5, decimalValue($t9)      # loads the value from array element 
             addi $t6, $zero, 256  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1 
             lb $t5, decimalValue($t9)
             addi $t6, $zero, 16  
             multu $t5, $t6 
             mflo $t7   
             add $t8, $t8, $t7              # calculate sum
             addi $t9, $t9, 1   
             lb $t5, decimalValue($t9)    
             add $t8, $t8, $t5              # calculate sum 
             addi $sp, $sp, -4              # PUSH $t8 (total value) ONTO THE STACK
             sw $t8, 0($sp)                 # PUSH $t8 (total value) ONTO THE STACK
             add $ra, $t0, $zero            # get the return address for the firt subprogram call
             jr $ra                         # return to calling subprogram
	   
################################################ subprogram1 converts each hex character to its decimal number and saves it in an array
	   	   
subProgram1:  beq $t8, 1, decimalDigitFound    # if a 0 - 9 char was found...
              beq $s6, 1, lowercaseFound       # if a a - f char was found...
              beq $s7, 1, uppercaseFound       # if a A - F char was found...
decimalDigitFound: addi $t6, $t2, -48          # gets the actual decimal value of the character if its between 0-9
                   sb $t6, decimalValue($t7)   # stores the value in array
                   addi $t7, $t7, 1            # increment to the next element in the array
                   addi $t5, $t5, 1            # increment to the next char
                   j CheckString2              # return to calling subprogram
                   
lowercaseFound:    addi $t6, $t2, -87          # gets the actual decimal value of the character if its between 0-9
                   sb $t6, decimalValue($t7)   # stores the value in array
                   addi $t7, $t7, 1            # increment to the next element in the array
                   addi $t5, $t5, 1            # increment to the next char
                   j CheckString2              # return to calling subprogram
 
uppercaseFound:    addi $t6, $t2, -55          # gets the actual decimal value of the character if its between 0-9
                   sb $t6, decimalValue($t7)   # stores the value in array
                   addi $t7, $t7, 1            # increment to the next element in the array
                   addi $t5, $t5, 1            # increment to the next char
                   j CheckString2              # return to calling subprogram

################################# subprogram3 prints out the corresponding statement or decimal value

subProgram3:  lw $t8, 0($sp)    # POP THE TOTAL VALUE OFF THE STACK AND STORE IT IN $t8  
              addi $sp, $sp, 4  # POP THE TOTAL VALUE OFF THE STACK AND STORE IT IN $t8
              li $v0, 1         # Call code to print an integer
              la $a0, ($t8)     # prints the integer is $t8
              syscall           # call to OS
              li $v0, 11        # Call code to print a character
              la $a0, ','       # print a comma
              syscall           # call to OS
              beq $a3, 1, EndOfCode
              jr $ra
printNaN:       li $v0, 4     # call code to print a string
	        la $a0, str2  # print error message
	        syscall	      # call OS
	        li $v0, 11    # call code to rint out a character
	        li $a0, ','   # print comma  
	        syscall       # call OS
	        beq $a3, 1, EndOfCode
	        j resetCounter  
printTooLong:   li $v0, 4     # call code to print a string
	        la $a0, str3  # print error message
	        syscall	      # call OS
	        li $v0, 11    # call code to rint out a character
	        li $a0, ','   # print comma  
	        syscall       # call OS
	        beq $a3, 1 EndOfCode
	        j resetCounter 
	        
EndOfCode:      li $v0, 10
	        syscall  

