.data
	user_input: .space      	1001			# We need space for 1000 characters and the endline char.
	too_large:  .asciiz		"too large"
	nan:	    .asciiz		"NaN"
	
.text
	main:
            li $v0, 8                           # Get input from user
            la $a0, user_input
            li $a1, 1001
            syscall
            
            la $s0, user_input                  # Get the address where the input string is stored

            addi $a2, $zero, 0                  # Initialize the offsets to 0
	        addi $a3, $zero, 0          	
    
            Loop4:
		    # Loop through the string keeping a start ($a2) and end index ($a3) for every sub-string
                add $t0, $a3, $s0               # Increment the address of the string
                lb $t1, 0($t0)                  # Get the current character
                beq $t1, 0, Convert             # If current char is endline char (0) --> Convert
                beq $t1, 10, Convert            # If current char is newline char (10) --> Convert
                bne $t1, 44, Increment          # If current char is NOT a coma --> Increment

                Convert:
                    jal subprogram_2            # Call subprogram 2
                    jal subprogram_3            # Call subprogram 3
                    j ResetStart                # Jump to ResetStart

                NotANumber:
                    li $v0, 4                   # Print "NaN"
                    la $a0, nan
                    syscall
                    j ResetStart

                TooLarge:
                    li $v0, 4                   # Print "too large"
                    la $a0, too_large
                    syscall
                
                ResetStart:
                    add $t0, $a3, $s0           # Increment the address of the user input
                    lb $a0, 0($t0)              # Get the character at $a3
                    beq $a0, 44, PrintComma     # If char is comma --> PrintComma ; else --> Exit
                    j Exit

                    PrintComma:
                        addi $a2, $a3, 1        # Set the start index to the end index plus 1
                        li $v0, 11              # Print the comma
                        syscall 

                Increment:
                    addi $a3, $a3, 1            # Increment the End index
                    j Loop4

            Exit:
			    # Exits the program
			    li $v0, 10
			    syscall

	subprogram_1:
        # Converts the hex char in argument $a2 to its decimal value
        # And returns the result in $v1

        add $t0, $zero, $a2                 # Copy the argument
        addi $t1, $zero, 87                 # Initialize the reference point to 87
        bgt $t0, 'f', NotANumber	    # If the char is greater than 'f' --> NotANumber
        bge $t0, 'a', Return1               # If char is within a to f --> Return1
        addi $t1, $zero, 55                 # Change the reference point to 55
        bgt $t0, 'F', NotANumber	    # If the char is greater than 'F' --> NotANumber
        bge $t0, 'A', Return1               # If char is within A to F --> Return 1
        addi $t1, $zero, 48                 # Change the reference point to 48
        bgt $t0, '9', NotANumber	    # If the char is greater than '9' --> NotANumber
        blt $t0, '0', NotANumber	    # If the char is greater than '0' --> NotANumber
        
        Return1:
            sub $v1, $t0, $t1               # Subtract the refernce from the character value  		
            jr $ra                          # and return the result in $v1
	
    subprogram_2:
        # Converts a hexadecimal substring to a decimal integer
        # Argument $a1 is the start index of the substring and $a2 is the end of the substring
        # The result is returned via the stack
        
        sw $ra, 0($sp)                      # Save return address of the caller function to stack
       
        add $t2, $zero, $a2                 # Copy the arguments
        add $t3, $zero, $a3

        Loop5:                              # Remove leading spaces and tabs from the substring
            add $t5, $s0, $t2               # Go to the first char address in the substring
            lb $t0, 0($t5)                  # Get the char at that address
            
            beq $t0, 32, IncrementStart     # If current char is a space --> IncrementStart
            beq $t0, 9, IncrementStart      # If current char us a tab --> IncrementStart
            beq $t2, $t3, NotANumber        # If substring is all spaces or tabs --> NaN            

            addi $t3, $t3, -1               # Decrement the end index by 1
            j Loop6                         # Go to Loop6
                        
            IncrementStart:
                addi $t2, $t2, 1            # Increment the start index
                j Loop5

        Loop6:                              # Remove lagging spaces and tabs from the substring
            add $t5, $s0, $t3               # Go to the last char address in the substring
            lb $t0, 0($t5)                  # Get the char at that address

            beq $t0, 32, DecrementEnd       # If current char is a space --> DecrementEnd
            beq $t0, 9, DecrementEnd        # If current char us a tab --> DecrementEnd

            sub $s1, $t3, $t2               # Get the len of the substring
            addi $t4, $zero, 0              # Initialize the result to zero
            j Loop1

            DecrementEnd:
                addi $t3, $t3, -1           # Decrement the end index
                j Loop6

        Loop1:                              # Convert the hex string to its decimal value
            add $t5, $s0, $t2               # Go to the next character address in the string
            lb $a2, 0($t5)                  # Get the character at that address
            jal subprogram_1         	    # Get the decimal value of the character
            sll $t4, $t4, 4                 # Shift the result left by 4
            or $t4, $t4, $v1                # Or the decimal value of the character with the result
            beq $t2, $t3, Return2           # If the current index is the last --> Return2
            addi $t2, $t2, 1                # Increment the offset            
            j Loop1
        
        Return2:
            bgt $s1, 7, TooLarge            # If the length of the string greater than 8 --> TooLarge
            lw $ra, 0($sp)	            # Get the old return address
            sw $t4, 0($sp)                  # Store the result on the stack
            jr $ra    
    
    subprogram_3:
        # Prints an unsigned decimal integer.
        # The stack is used to pass parameters.
        # No values are returned
        
        lw $t0, 0($sp)                      # Get the argument from the stack        

        addi $t1, $zero, 10                 # Set the divisor to 10
        addi $t4, $zero, 0                  # Initialize a counter to 0

        Loop2:                              # Get the digits
            divu $t0, $t1                   # $t0 / $t1 --> Remainder in HIGH, Quotient in LOW
            mflo $t0                        # Set the new Dividend to be the Quotient
            mfhi $t2                        # Get the Remainder (digit)

            la $t3, ($sp)                   # Store the address of the stack pointer in $t3
            add $t3, $t3, $t4               # Add the offset to the address
            sb $t2, 0($t3)                  # Store the remainder on the stack at the address of $t3
            beq $t0, $zero, Loop3           # If the Dividend is 0 --> Exit the loop to Loop3
            addi $t4, $t4, 1                # Increment the counter

            j Loop2

        Loop3:                              # Print the digits
            lb $a0, 0($t3)
            li $v0, 1
            syscall
            
            beq $t3, $sp, Return3           # If the address in $t3 == address in $sp --> Return3
            addi $t3, $t3, -1               # Decrement the address in $t3
            j Loop3        
        Return3:
            jr $ra	
