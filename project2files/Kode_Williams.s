# MIPS Assignment 2
# Author: Kode Williams
# Date: December 1, 2017

 


.data

	error: 			.asciiz "NaN"    #error message for invalid hexadecimal
	too_large_msg: 	.asciiz "Too large"
	newline: 				.asciiz "\n"			  #stores new line for output
	input: 					.space 1001				#space for characters (1000 + 1)
	
	
.text
main:

getInput:
		la $a0, input
		li $a1, 1001
		li $v0, 8
		syscall

loop:

    jal locate_pointers
    
    # Copy pointers into saved registers
    add $s0, $zero, $v0               
    add $s1, $zero, $v1                
   
   	# Copy pointers into address registers for validation
    add $a0, $zero, $v0                
    add $a1, $zero, $v1                
    
    jal validation
    
    # Copy pointers into saved registers
    add $s2, $zero, $v0                 
    add $s3, $zero, $v1                 
    
    # Copy pointers into address registers for conversion
    add $a0, $zero, $s0                 
    add $a1, $zero, $s1                 
    add $a2, $zero, $s3                
    add $a3, $zero, $s2                
    jal subprogram_2
    
    # Copy pointer into address register for output
    add $a0, $zero, $s2                 
    jal subprogram_3                    
    
    addi $a0, $s1, 1                    
    j loop


end:
		li $v0, 10
		syscall


locate_pointers:
		# Copy the address of the first character to a temporary register
    add $t0, $zero, $a0                 

  locate_start:
  	# Load current character starting with first
    lb $t1, 0($t0)                     
    beq $t1, 10, end            
    beq $t1, 0, end            
    beq $t1, 32, start_forward		# Move to next if space
    beq $t1, 44, start_forward		# Move to next if comma
		
		# Set next character to start locating end pointer at this stage
    addi $t2, $t0, 1                    
    
  locate_comma:
    lb $t1, 0($t2)                    
    beq $t1, 10, go_back              
    beq $t1, 0, go_back              
    bne $t1, 44, end_forward 
    addi $t2, $t2, -1                  
    
  go_back:
    lb $t1, 0($t2)                     
    beq $t1, 32, end_back         
    beq $t1, 0, end_back 
    beq $t1, 10, end_back
    add $v0, $zero, $t0                 
    add $v1, $zero, $t2                 
    jr $ra

  start_forward:
    addi $t0, $t0, 1        # Move start ptr to next char           
    j locate_start						# Restart search for valid start ptr

  end_forward:
    addi $t2, $t2, 1      	# Move the end pointer to next char             
    j locate_comma					# Continue searching for valid chars to end substring

  end_back:
    addi $t2, $t2, -1       # Move current end pointer to previous character          
    j go_back


# After locating pointers, validate the strings
validation:
    add $t2, $zero, $zero
    
  is_valid:
     
    lb $t1, 0($t0)
    bge $t1, 103, nan          
    bge $t1, 96, nextChar        
    bge $t1, 71, nan         
    bge $t1, 64, nextChar         
    bge $t1, 58, nan         
    bge $t1, 47, nextChar
    # If it gets to this point, it is not a valid number        
    j nan

  nextChar:
    addi $t0, $t0, 1    		# Set the next character                
    addi $t2, $t2, 1       	# Increment the current length           
    bgt $t0, $a1, valid   	# Checks to see if registers line up yet            
    j is_valid
     
  nan:
    addi $v0, $zero, 1                 
    addi $v1, $zero, 0                 
    jr $ra
     
  too_large:
    addi $v0, $zero, 2                  
    addi $v1, $zero, 0                 
    jr $ra
  
  valid:
    bgt $t2, 8, too_large      
    addi $v0, $zero, 3                  
    add $v1, $zero, $t2                 
    jr $ra
     
return:
    jr $ra  

subprogram_1:
  addi $v0, $zero, 1                 
    addi $t3, $zero, 16                 

  get_value:
    bge $a2, 96, lowercase                  
    bge $a2, 64, uppercase                
    bge $a2, 47, number                 

  lowercase:
    addi $t0, $a2, -87                  
    j get_exponent

  uppercase:
    addi $t0, $a2, -55                 
    j get_exponent

  number:
    addi $t0, $a2, -48                  
    j get_exponent

  get_exponent:
    sub $t1, $a0, $a1                  
    addi $t1, $t1, -1                   

  power:
    beq $t1, $zero, multiply            

    mult $v0, $t3                      
    mflo $v0                           

    addi $t1, $t1, -1                   
    j power

  multiply:
    mult $v0, $t0                     
    mflo $v0                            

    jr $ra 

subprogram_2:
    bne $a3, 3, return                  
    add $t0, $zero, $a0                 
    add $t1, $zero, $a1                 
    add $t2, $zero, $a2                 
    add $s6, $zero, $zero              
    add $t4, $zero, $t0                 
    add $t9, $zero, $zero               
    
    add $s5, $zero, $ra                
     
  convert:
    add $a0, $zero, $t2                 
    add $a1, $zero, $s6                 
    lb $a2, 0($t4)                      

    jal subprogram_1                    
    
    add $t9, $t9, $v0                   
    addi $t4, $t4, 1                    
    addi $s6, $s6, 1                   
    
    blt $s6, $t2, convert     
  
  done:
    addi $sp, $sp, -4                  
    sw $t9, 0($sp)                      

    add $ra, $zero, $s5                 
    jr $ra


subprogram_3:
         
    beq $a0, 1, print_NaN               
    beq $a0, 2, print_too_large          
    beq $a0, 3, print_number
    addi $t7, $t7, 1        
    jr $ra

  print_NaN:
  	la $a0, error                                               
    li $v0, 4                                                                        
    syscall
    la $a0, 44                    
    li $v0, 11                                                                                            
    syscall
    jr $ra

  print_too_large:
  	la $a0, too_large_msg            
    li $v0, 4
    syscall
    la $a0, 44                    
    li $v0, 11                                                                                            
    syscall
    jr $ra

  print_number:
		addi $t0, $zero, 10000      
    lw $t1, 0($sp)                        
    addi $sp, $sp, 4                                      
     
    divu $t1, $t0                         
    mflo $t2                          
    mfhi $t3                            
   
    beq $t2, $zero, print_remainder     
    
  print_quotient:
    add $a0, $zero, $t2                                                      
    li $v0, 1                                                                                            
    syscall

  print_remainder:
    add $a0, $zero, $t3                                                         
    li $v0, 1                                                                 
    syscall
		la $a0, 44                   
    li $v0, 11                                                                                           
    syscall
    jr $ra
