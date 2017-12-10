# Deeshai Escoffery


#Begin

#Temporary Registers:
# $s0 - Character's first address in input.
# $s2 - Current string's start address.
# $s4 - Current string's end address.
# $s1 - Current string'd length is tracked her.
# $t2 -Current byte is tracked here.
# $t3 - The length is tracked here
# $t4 - Index is tracked here
# $s3 - Holds string's validity: 1- NaN, 2- Too Large, 3- Decimal Value 
# $s5 - Total sum is stored here

.data

    error_msg: .asciiz "NaN"    #error message for invalid hexadecimal
    too_large_msg: .asciiz "too large"
    output_line: .asciiz "\n"             #stores new line for output
    input: .space 1001              #space for characters (1000 + 1)
    
    
.text
main:
    jal input_data  #jump and link input_data to main

loop:

    jal find_start_end  #jump and link find_start_end to loop
    
    add $s0, $zero, $v0           #start pointer is stored here    
    add $s1, $zero, $v1          #end point is stored here      
    
   
   #Set register arguments for validity_check
   
    add $a0, $zero, $v0                #$a0 is set to start pointer
    add $a1, $zero, $v1                #$a1 is set to end pointer
    
    jal validity_check 			#jump and link validity_check to loop
    
    
    add $s2, $zero, $v0    		#Validity of string is stored.             
    add $s3, $zero, $v1                 #Length of string is stored.
    
   #Set register argument for subprogram2
   
    add $a0, $zero, $s0              #$a0 is set to start pointer.   
    add $a1, $zero, $s1               #$a1 is set to end pointer.  
    add $a2, $zero, $s3                #$a2 is set to string length.
    add $a3, $zero, $s2                #$a3 is set to string validity.
    jal subprogram2			#jump and link to subprogram2 to loop
    
    
 #Set register argument for subprogram3
    
    add $a0, $zero, $s2       		#$a0 is set to string validity           
    jal subprogram3                     #jump and link to subprgam3 to loop
    
    addi $a0, $s1, 1     		#Start pointer = End pointer               
    j loop				#Jump to beginning of loop
    
    
  end:					#end program
    li $v0, 10                         #end
    syscall


  input_data:
    la $a0, input                
    li $v0, 4
    syscall           
                      
    la $a0, input                                                                                 
    li $a1, 1000                                                                
    li $v0, 8                                                                 
    syscall                             
    
    jr $ra

#####################find_start_end#########################
#Detects start and end of a string

#Argument registers:
#$a0 - Points to start of string

#Temoporary registers:
#$t0 - holds current location
#$t1 - holds the byte at current location
#$t2 - holds the end of the string

#Return Registers:
#$v0 - Start of string pointer
#$v1 - End of string pointer

#Pre: None
#Post: $v0 contains the return value.
#Called by: subprogram2
#Calls: None


find_start_end:
    add $t0, $zero, $a0       #$t0 is set to the start of the string             

  start:  
    lb $t1, 0($t0)     		#Load char at the start.                 
    beq $t1, 10, end         	#New line = end programming.   
    beq $t1, 0, end            		#Null Character = end program.
    beq $t1, 32, incr_start_ptr		#Space = shift right.
    beq $t1, 44, incr_start_ptr		#Comma = shift right.
  
    addi $t2, $t0, 1  			#End pointer = start pointer + 1.                  
    
  comma:				#Find comma
    lb $t1, 0($t2) 			#Character at end is loaded        		           
    beq $t1, 10, shift_left              #If new line, shift left/ step back.
    beq $t1, 0, shift_left              #If null/0, shift left.
    bne $t1, 44, incr_last_ptr          #If not a comma, shift right/step forward.
  
    addi $t2, $t2, -1                  #Endpointer = Endpointer - 1 (Decrement end pointer)
    
  shift_left:
    lb $t1, 0($t2)   			#Character is loaded at end pointer.                  
    beq $t1, 32, decr_last_ptr         #If space, decrement end pointer.
    beq $t1, 0, decr_last_ptr 		#If null, decrement end pointer.
    beq $t1, 10, decr_last_ptr 		#If new line, decrement pointer.

    add $v0, $zero, $t0              #$v0 is set to start pointer.           
    add $v1, $zero, $t2              #$v1 is set to end pointer.
    jr $ra

  incr_start_ptr:
    addi $t0, $t0, 1   			#StartPointer = StartPointer + 1 (Increment start pointer)                 
    j start				#jump to start

  incr_last_ptr:		
    addi $t2, $t2, 1            	#EndPointer = EndPointer + 1  (Increment end pointer)     
    j comma				#jump to comma

  decr_last_ptr:
    addi $t2, $t2, -1       		#EndPointer = EndPointer - 1 (Decrement end pointer)            
    j shift_left			#jump to shift_left


 ######################validity_check##########################
#Checks if a string is a valid hexadecimal (Both 8 characters or less and more than 8 characters)

#Argument registers used:
#$a0 - Start of the string pointer
#$a1 - End of the string pointer

#Temporary registers:
#$t0 - current position pointer
#$t1 - current positon of byte
#$t2 - current character index

#Return registers:
#$v0 - String's validity.   

#Pre: None
#Post: $v0 contains the return value, $v1 contains the length of string
#Called by: main
#Calls: None
    
validity_check:
    add $t2, $zero, $zero    #$t2 is initialized to 0.
                

  is_valid:
     
    lb $t1, 0($t0)      #Byte is loaded at $t0.               
     
 #Check character validity
    bge $t1, 103, not_a_number    #if greater than 103, not a number.       
    bge $t1, 96, incrChar        #if greater than 96, valid lower case.
    bge $t1, 71, not_a_number     #if greater than 71, not a number.     
    bge $t1, 64, incrChar         #if greater than 64, valid uppercase.
    bge $t1, 58, not_a_number      #if greater than 58, not a number.   
    bge $t1, 47, incrChar         #if greater than 47, valid number
    j not_a_number			#jump to not_a_number

  incrChar:
    addi $t0, $t0, 1           		#Increment pointer.         
    addi $t2, $t2, 1                  	#Increment index.
    bgt $t0, $a1, valid                #If pointer is past end, then string is valid hex.
    j is_valid				#Jump to hex.
     
  not_a_number:
    addi $v0, $zero, 1              #Validity set   
    addi $v1, $zero, 0               #Length = 0  
    jr $ra				#jump to register $ra.
     
  too_large:
    addi $v0, $zero, 2       	#Validity set           
    addi $v1, $zero, 0           #Length = 0      
    jr $ra			#jump to register $ra
  
  valid:
    bgt $t2, 8, too_large      #If length greater than 8, it is a valid hex that is too large/long.
    addi $v0, $zero, 3          #Validity set        
    add $v1, $zero, $t2          #Length set to $t2.       
    jr $ra			#jump to register $ra.
     
return:				#returns decimal value
    jr $ra  			#jumps to register $ra.


#subprogram1
#Assuming that the hex character is valid, it is converted to a decimal.

#Argument registers:
#$a0 - Length.
#$a1 - Character index.
#$a2 - ASCII char.

#Temporary registers:
#$t0 - hexadecimal value
#$t1 - exponent
#$t3 - Holds decimal value of base 16.

#Pre: None
#Post: $v0 contains the return value.
#Called by: subprogram2
#Calls: None

subprogram1:
    addi $v0, $zero, 1     #$v0 is initialized to 1            
    addi $t3, $zero, 16     #$t3 is initialized to 16            

  ascii_to_hex:
    bge $a2, 96, lower     	  #If branch is lowercase, jump to lower           
    bge $a2, 64, upper              #if branch is upercase, jump to lower  
    bge $a2, 47, number                #if branch is number, jump to number 

  lower:
    addi $t0, $a2, -87        		#Decimal value is stored in $t0.          
    j calc_exp				#Jump to calc_exp

  upper:
    addi $t0, $a2, -55                 #Decimal values is stored in $t0.
    j calc_exp				#Jump to calc_exp

  number:
    addi $t0, $a2, -48                  #Decimal values is stored $t0.
    j calc_exp				#Jump to calc_exp

  calc_exp:
    sub $t1, $a0, $a1                  #Exponent = length - index
    addi $t1, $t1, -1                  #Expontent = Exponent - 1 

  raise_to_exp:
    beq $t1, $zero, multiply            #If Exponent = 0, move forward

    mult $v0, $t3                      #Exponent * Base
    mflo $v0                           #$v0 stores the answer

    addi $t1, $t1, -1                   #Exponent = Exponent - 1
    j raise_to_exp			#Jump to raise_to_exp

  multiply:
    mult $v0, $t0                     #(Base^exponent) * decimal (Base rased to exponent * decimal value)
    mflo $v0                          #$v0 stores the result
			
    jr $ra                    		#jump to register $ra.

#subprogram2
#Converts hexadecimal string to a decimal.
#Calls subprogram1, and adds the value of each converted character to a sum. The total value is then returned.

#Argument registers:
#$a0 - Start of string pointer
#$a1 - End of string pointers
#$a2 - Length.
#$a3 - String's validity

#Temporary registers:
#$t0 - Start of string pointer.
#$t1 - End of string pointer.
#$t2 - Length.
#$t4 - Current position pointer
#$t9 - Decimal value of char.
#$s6 - Character index.

#Pre: None
#Post: $sp contains the return value.
#Returns: the decimal value of the hexadecimal string.
#Called by: main
#Calls: subprogram1

subprogram2:
    bne $a3, 3, return      #If not valid then return            
    add $t0, $zero, $a0      #Copy pointer to string's start           
    add $t1, $zero, $a1      #Copy pointer to string's end           
    add $t2, $zero, $a2       #Length of string is copied          
    add $s6, $zero, $zero      #Index initialized to 0.        
    add $t4, $zero, $t0         #Pointer set to current position.        
    add $t9, $zero, $zero       #Decimal value is initialized        

    
    
    add $s5, $zero, $ra          #Preserve the return address. Calls start_end_function.      
     
  hexadecimal_conversion: 
  
      #Set arguments ofr subprogram1    
    
    add $a0, $zero, $t2     #$a0 stores length.            
    add $a1, $zero, $s6      #$a1 stores index.           
    lb $a2, 0($t4)            #Current character is called in $a2.          

    jal subprogram1   		#Call subprogram1.                 
    
    add $t9, $t9, $v0                  #Store results from subprogram1. 

    
    addi $t4, $t4, 1                   #Index = index + 1 
    addi $s6, $s6, 1                   #Move pointer forward.
    
    blt $s6, $t2, hexadecimal_conversion    #If index < length, then jump to hexadecimal_conversion.  
  
  done:
    addi $sp, $sp, -4            #4 bytes space are allocated on stack      
    sw $t9, 0($sp)                #Sum is pused onto stack      

    add $ra, $zero, $s5             #Return address is reset    
    jr $ra				#jump to register $ra

#subprogram3
#Displays results (decimal or NaN message or too large message)

#Argument registers:
#$a0 - Current string's validity.
#$sp - String's decimal value.

#Temporary registers:
#$t1 - Stores decimal constant 10000.
#$t2 - Decimal value of hex.
#$t3 - Quotient.
#$t4 - Remainder.
#Pre: None
#Post: None
#Returns: None
#Called by: main
#Calls: None



subprogram3:           
    beq $a0, 1, print_NaN               #If validity = 1, jump to print_NaN
    beq $a0, 2, print_too_large          #If validity = 2, jump to pint_too_large.
    beq $a0, 3, print_decimal          #If validity = 3, jump to print_decimal.
    jr $ra				#jump to register $ra.

  print_NaN:

    la $a0, error_msg                     #Print error_msg                         
    li $v0, 4                                                                        
    syscall
    la $a0, 44                   #Print comma
    li $v0, 11                                                                                           
    syscall
    jr $ra				#jump to register $rs

  print_too_large:
    la $a0, too_large_msg            #Print too_large_msg
    li $v0, 4
    syscall
    la $a0, 44                   #Print comma
    li $v0, 11                                                                                           
    syscall
    jr $ra			#jump to register $rs

  print_decimal:
  
    addi $t0, $zero, 10000     #Store 10000 in $t0
    lw $t1, 0($sp)               #Decimal is loaded from stack.         
    addi $sp, $sp, 4              #The space onth stack is deallocated.                        
     
    divu $t1, $t0                    #Split hex in two by dividing unisgned integer by 10000     
    mflo $t2                         #Save quotient in mflo 
    mfhi $t3                          #Save remainder in mfhi 
    
    beq $t2, $zero, print_remainder     #If quotient = 0, print remainder only 
    
  print_quotient:
    add $a0, $zero, $t2                 #Print quotient                                   
    li $v0, 1                                                                                        
    syscall

  print_remainder:
    add $a0, $zero, $t3                 #Print remainder                                        
    li $v0, 1                                                                 
    syscall
    la $a0, 44                   #Print comma
    li $v0, 11                                                                                           
    syscall
    

    jr $ra				#jump to register $rs
