#here is the repo to this assignment 
# https://github.com/vijayko/MIPS-programming-project-2

.data 
    max_input: .space 10000
    not_valid: .asciiz "NaN"
    too_large: .asciiz "too large"
.text
    main: 
      #Taking the user input for hexademical numbers 
            li $v0, 8
            la $a0, max_input 
            li $a1, 1001
            syscall 

           #Loading the input to a regsiter for conversion to decimal 
            la $s0, max_input 
            li $s1, 0       #start pointer 
            li $s2, 0     #end pointer 

        word_list: 
            la $s1, ($s2)

        substring: 
            add $t1, $s0, $s2   #iterator 
            lb $t2, 0($t1)    #loading the current character 

            #a few criteron to exit the loop while iterating through the substrings
            beq $t2, 0, end_substring
            beq $t2, 10, end_substring
            beq $t2, 44, end_substring

            #Increasing the count of the iterator 
            add $s2, $s2, 1
            j substring

        end_substring:
          #toading arguments to make a subprogram_2 call 
            la $a0, ($s1)
            la $a1, ($s2)

            #calling subprogram2 using jump-and-link 
            jal subprogram_2

            #calling subprogram3 using jump-and-link 
            jal subprogram_3

            #note: the return values of the subprogram2 stays in the stack which is used by the subprogram3 

            #ending the strings with end character and newline character
            beq $t2, 0, end_wl 
            beq $t2, 10, end_wl

            addi $s2, $s2, 1  # $s2 += 1

            #formatting the print values with comma
            li $v0, 11
            li $a0, 44
            syscall 
            j word_list 
        end_wl: 
          #This following set of lines is to end the program 
            li $v0, 10 
            syscall 


        subprogram_2:
            la $s7, ($ra) #loading the value from $ra to register $s7
            la $t9, ($a0) #loading the value from $a0 to register $t9

            addi $t8, $a1, 0 #storing the end address
            la $t7, max_input  #loading the first address of the user input 

            #In the following clear_front and clear_back, I am trying to remove the spaces from the front and the back of the string 
            clear_front: 
                beq $t9, $t8, end_deletion  #exiting the loop 
                add $t6, $t7, $t9     
                lb $t5, ($t6)
                #keep looping if there is still space 
                beq $t5, 32, addup 
                beq $t5, 9, addup
                j clear_back #clearing the spaces from the end if the current char is not a space. 
            addup: 
                addi $t9, $t9, 1 
                j clear_front

            clear_back: 
                beq $t9, $t8, end_deletion
                add $t6, $t7, $t8 
                addi $t6, $t6, -1 
                lb $t5, ($t6)
                beq $t5, 32, adddown 
                beq $t5, 9, adddown 
                j end_deletion
            adddown: 
                addi $t8, $t8, -1 
                j clear_back

            end_deletion: 
                beq $t9, $t8, not_a_number # if there is no character in a string, it's a NAN
                li $t4, 0            # first decimal value 
                li $s6, 0            #length of the string 

            convert: 
              #converting the characters calling the subprogram1 and the returned values will be in $v0 and $v1
                beq $t9, $t8, end_convert 
                add $t6, $t7, $t9 
                lb $t5, ($t6)
                la $a0, ($t5)
                jal sub_program1 
                bne $v0, 0, continue 
                j not_a_number 
            continue: 
              #converting the hexadcimal to decimal using sll command 
              #shift of 4 bits to left is to raise the power of 16
                sll $t4, $t4, 4 
                sub $t6, $t5, $v1 
                add $t4, $t4, $t6
                addi $s6, $s6, 1 
                addi $t9, $t9, 1
                j convert
            end_convert:
                bgt $s6, 8, large_num #if length of a valid string is greater than 8, then it's TOO large to deal with 
                li $v0, 1 
                j end_string
            large_num:
            #Throw a message to tell about a large number situation 
                li $v0, 0 
                la $t4, too_large
                j end_string
            not_a_number: 
            #throwing a message for invalid character 
                li $v0, 0 
                la $t4, not_valid
            end_string: 
            #loading the stack with return values 
                addi $sp, $sp, -4 
                sw $t4, ($sp)
                addi $sp, $sp, -4 
                sw $v0, ($sp)
                la $ra, ($s7)
                jr $ra
      sub_program1: 
          blt $a0, 48, invalid #invaild if ascii value is less than 48, ascii value of 0 is 48
          addi $v1, $0, 48  #storing the ascii value to $v1
          blt $a0, 58, valid  #making sure the character is less than or equal to "9"
          #With this block of code, basically I am trying to filter out the valid character for the conversion
          blt $a0, 65, invalid #invalid if the character is less than "A" in the ascii table
          addi $v1, $0, 55  
          blt $a0, 71, valid 
          blt $a0, 97, invalid 
          addi $v1, $0, 87 
          blt $a0, 103, valid 
          bgt $a0, 102, invalid #invalid if ascii character is greater than 'f'

        valid: 
          li $v0, 1
          jr $ra 
        invalid: 
          li $v0, 0 
          jr $ra 

      subprogram_3:
      #loading the arguments from the stack 
        lw $t8, ($sp)
        addi $sp, $sp, 4
        lw $t7, ($sp)
        beq $t8, 0, not_okay #if $t8 equals 0, the string is not valid 

        #unsigned division by 10 to avoid overflow 
        li $t6, 10 
        divu $t7, $t6
        li $v0, 1 
        mflo $a0
        beq $a0, 0, foo #not ready to print
        syscall 
      foo: 
        mfhi $a0 
        syscall 
        j exit
      not_okay: 
      #block of code for invalid string 
        li $v0, 4 
        la $a0, ($t7)
        syscall 
      exit: 
      #Returning back to the main function 
        jr $ra 
