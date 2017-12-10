

# PROGRAM: Hello, World!
.data # Data declaration section
user_input: .space 1001		# Allocating space for user_input of entire 1000 character string + NULL $t3 will be my index

					
temp_string: .space 1001 #	Declaring an empty string. This string will take all input up until the comma. $t1 will be my index
hex_8_or_more: .space 1001 	# Declaring an empty string. This string will store a hex string with 8 or more valid hex_characters either ending with a comma or newline
							# $t0 will be my index
array_integers2C: .space 10 # This space will be used to store an array of integers for [0x80000000,0xFFFFFFFF]
							  #  in reverse. The length is always 10 because number of integers in this range is always 10.
							  #  $t7 will be my index for this when I store and when I print


print_NaNComma: .asciiz "NaN,"		# String for "NaN,"
print_NaN: .asciiz "NaN"		# String for "NaN"
print_too_largeC: .asciiz "too large,"
print_too_large: .asciiz "too large"



.text # Assembly language instructions

main: # Start of code section

li $v0, 8				
la $a0, user_input
li $a1, 1001				#Read as many as 1000 characters + NULL into user_input
syscall

# ##Print Newline
# li $v0, 11
# la $a0, '\n'
# syscall	

prep_init_temp_string:
li $t1, 0		# $t1 = 0	index for temp_string
init_temp_string:
beq $t1, 1001, after_init_temp_string
sb $zero, temp_string($t1)     # Initialize temp_string to NULL
addi $t1, $t1, 1
j init_temp_string
after_init_temp_string:

prep_init_hex_8_or_more:
li $t0, 0
init_hex_8_or_more:
beq $t0, 1001, after_init_hex_8_or_more
sb $zero, hex_8_or_more($t0) 			# Initialize hex_8_or_more to NULL
addi $t0, $t0, 1
j init_hex_8_or_more
after_init_hex_8_or_more:






prep_load_char:	
li $t3, 0		# $t3 = 0 index for user_input
li $t1, 0		# $t1 = 0	index for temp_string	
Load_Char:


lb $t5, user_input($t3)				# $t5 = user_input[$t3]


beq $t5, ',', when_comma	#If the character is a comma, store it and go to State_Machine
j when_not_commma
when_comma:
sb $t5, temp_string($t1)		# Here we store the comma and go to the state machine
j State_Machine

when_not_commma:
beq $t5, '\n', store_endl_enter_machine	#If the character is a newline store a newline in temp_string and enter the state machine
beq $t5, $zero, store_endl_enter_machine	#If the character is a NULL character store a newline in temp_string and enter the state machine


sb $t5 , temp_string($t1)		#Store the character that is not a comma, or \0 or \n in temp_string. Then it must be a space/tab or another character
addi $t1, $t1, 1 			# $t1++	   index for temp_string
addi $t3, $t3, 1			# $t3++ index for user_input
j Load_Char 				# Go back to Load_char to loop the next character




next_temp_string:	# After we are done making temp_string that ended in a comma empty 
					# we get the next temp_string via iterating through user_input
addi $t3, $t3, 1			# $t3++ to get the next char in input_string (which would be the value after the comma)
li $t1, 0					# we initialize the index for temp_string which is $t1 
j Load_Char



###Where my state_machine will be and hence where subprogram 2 and 3 and 1 are called

State_Machine:

li $t0, 0                  # Index of hex_8_or_more; $t0 = 0
li $t1, 0			# initialize temp_strings index to 0 $t1 = 0


state_0:
# Initial state where we read the first char from temp_string which could be of many forms "\n" | "FffF[space],"|
# "[space]FFf[space]," | "\," | "[sapce]\n" | "012345678\n"

lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, '\n', state_3 		# If the first character I see is a '\n' go to state_3

beq $t8, '\t', state_4		# If the first character is a space or a tab go to state_4
beq $t8, 32, state_4 

beq $t8, ',', state_1		# If the first character I see is a comma go to state_1

j state_5					# If I neither see a '\n' nor a [space] nor a ',' it must be a character. Go to state_5



state_1:
# We are in state_1
# We read our first comma either after temp_string was declared invalid
# Or after we read some spaces initially with nothing else
# After we read only our first comma


# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, $zero, state_2			# If the next character after the comma is NUL then go to state_2 hence 
								# the value we read from temp_string was ",\0" or "invalid,\0" or "[space],\0"	because temp_string is zero terminated
								# No other cases possible because temp_string is either comma terminated or '\n' terminated


state_2:
# We are in state_2
# See state_1 description


li $v0, 4
la $a0, print_NaNComma		# print("Nan,")
syscall

j after_State_Machine			# We then leave the state_machine and get the next temp_string




state_3:

# We are in state_3
# This means that $t8 = '\n' we have read a newline. Maybe after a space, 
# or after some invalid character was reached or just initially
# We just print("NaN") and exit the program


li $v0, 4
la $a0, print_NaN  # print("NaN")
syscall

j after_Load_Char # We stop our iteration of user_input because we've reached the end. and just exit the program




state_4:

# We are in state_4; we have read the first space or tab. Or we are still reading 
# spaces or tabs before a valid char, invalid char, comma or a newline

# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, '\t', state_4			# If the next character read is a space or tab stay in state_4
beq $t8, 32, state_4

beq $t8, ',', state_1			# If the next character read is a comma go to state_1
beq $t8, '\n', state_3			# If it is a newline go to state_3

j state_5						# If I neither see a [space] nor a ',' nor a '\n' it must be a character. Go to state_5



state_5:

# We are in state_5; we have read the first valid or invalid character
# or the first valid(s) or invalid character after initial [space]
# These occur before '\n' or comma never after



bge $t8, 48, check_less_equal_57		# If $t8 >= 48. If true check if $t8 <= 57

# else !($t8 >= 48) then $t8 < 48 but check if it's a '\t', '\n', 32(Space) or ',' first before assuming invalid
# because we read the next character too so it may not always be valid or invalid. We could read a series of 
# valid characters then a space or comma or newline whille iterating through temp_string

beq $t8, '\t', state_7					# If it's a '\t' go to state_7 
beq $t8, '\n', state_9					# If it's a '\n' go to state_9
beq $t8, 32, state_7					# If it's a space go to state_7
beq $t8, ',', state_8					# If it's a comma we deal with that in state_8

j state_6								# if none of the above then invalid; because it is invalid so we deal with that in state_6

check_less_equal_57:
ble $t8, 57, store_get_next_remain		# $t8 <= 57. Basically if $t8 >= 48 && $t8 <= 57; '0' to '9'; store it, get next char in temp_string and remain in state_5


bge $t8, 65, check_less_equal_70		# check $t8 >= 65. If true check $t8 <= 70
j state_6
check_less_equal_70:
ble $t8, 70, store_get_next_remain		# If $t8 <= 70 && $t8 >= 65 then it's in 'A' to 'F'; store it, get next char in temp_string and remain in state_5


bge $t8, 97, check_less_equal_102		# $t8 >= 97; If true check $t8 <= 102; Above case already handled when false.
j state_6
check_less_equal_102:
ble $t8, 102, store_get_next_remain		# If $t8 <= 102 && $t8 >= 97 then it's in 'a' to 'f'; store it, get next char in temp_string and remain in state_5

j state_6								# If !(t8 <= 102) then it is definitely invalid so we go to state_6












store_get_next_remain:
sb $t8, hex_8_or_more($t0)								# Store the validated character at the right address in hex_8_or_more
addi $t0, $t0, 1 			# $t0++ index of hex_8_or_more

# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

j state_5				# Remain in state_5 





state_6:
# We are now in state_6
# Here we read. We know that the temp_string is invalid because it could be like "FFf@," | "FF[space]F\n" 
# Since we know it is invalid we just keep reading the rest of the characters until we see a '\n' or a comma
# We should zero_out hex_8_or_more



keep_reading_characters_6:
addi $t1, $t1, 1
lb $t8, temp_string($t1)		# Get the next character


beq $t8, ',', state_1		# We just keep reading characters until we either hit a ',' or a '\n' to tell us what state to go to to either print("NaN,") or print("NaN")
beq $t8, '\n', state_3		# Hence we will stay in state_6 until we find a ',' or '\n'

j keep_reading_characters_6			# basically in essence just remaining in state_6 and reading characters





state_7:

# We are in state_7. We have read a valid char or a series of valid char from temp_string but we hit either a space or a tab.
# We will either read more successive spaces or tabs and remain in this state or we read any character that is not a '\n', ',' or '\t'
# Then it is a character so we go to the invalid state_6


addi $t1, $t1, 1
lb $t8, temp_string($t1)		# Get the next character

beq $t8, 32, state_7 		# If we keep reading spaces or tabs we remain in state_7
beq $t8, '\t', state_7
beq $t8, ',', state_8		# If we read a comma we go to state_8
beq $t8, '\n', state_9		# If we read a newline we go to state_9

j state_6		# If none of the above are true then we definitely read a character but since we just read "valid_char[space]some_char" 
				# We know the entire string is invalid so we go to state_6 to handle that




state_8:

# We are in state_8 we read a "valid_char(s)[space]," or "valid_char(s)," 
# We will just store the comma as part of hex_8_string_or_more so we can know what to print when we intend on calling sub_2 and sub_3


sb $t8, hex_8_or_more($t0)							# Store the comma at the right address in hex_8_or_more[$t0]


prep_check_too_large_comme:
li $t0, 0				# Our index to iterate through hex_8_or_more
check_too_large_comma:
# If the index at which the comma is at in hex_8_or_more is > 8 then hex_8_or_more is too large so we print("too large,")
# hex_8_or_more[0] to hex_8_or_more[8] is fine with hex_8_or_more[7] being the 8th valid char and hex_8_or_more[8] being the comma.
# Anything greater then print("too large,")
lb $t8, hex_8_or_more($t0) # $t8 = hex_8_or_more[$t9]
beq $t8, ',', check_index_C	# When we hit a comma we check if the index > 8
addi $t0, $t0, 1
j check_too_large_comma

check_index_C:

bgt $t0, 8, tooLargeC_zero_Next_temp_string		# If the index is greater than 8, we print("too large,"), 
												# zero out hex_8_or_more and get the next_temp (we have to leave the state machine)
# Else we print hex_8_or_more with the comma and get the next temp_string

sub2_call_C:
la $a1, hex_8_or_more 		# assign the argument hex_8_or_more to the parameter $a1 of subProgram_2
addi $sp, $sp, -4    # allocate space to store return value from subProgram_2
jal subProgram_2 	# call subProgram_2
lw $s3, 0($sp)      # load the return value from the stack into $s3 
addi $sp, $sp, 4	# close the stack frame for the return value
after_sub2_call_C:

sub3_call_C:
addi $sp, $sp, -4  # open stack frame for parameter in subProgram_3
sw $s3, 0($sp) # store argument $s3 which holds the integer in to the stack frame for parameter for subProgram_3
jal subProgram_3 # call subProgram_3
addi $sp, $sp, 4  # close stack frame for parameter in subProgram_3
after_sub3_call_C:

COMMA:
li $v0, 11
la $a0, ','
syscall

j after_State_Machine


tooLargeC_zero_Next_temp_string:
li $v0, 4
la $a0, print_too_largeC		# Print("too large,")
syscall
j after_State_Machine




state_9:
# We are in state_9 so we read "valid_char(s)\n" or "valid_char(s)[space]\n"
# We will just store the '\n' as part of hex_8_string_or_more so we can know what to print when we intend on calling sub_2 and sub_3



sb $t8, hex_8_or_more($t0)							# Store the '\n' at the right address in hex_8_or_more


li $t9, 0				# Our index to iterate through hex_8_or_more
check_too_large_newline:

# If the index at which the newline is at in hex_8_or_more is > 8 then hex_8_or_more is too large so we print("Too large")
# hex_8_or_more[0] to hex_8_or_more[8] is fine with hex_8_or_more[7] being the 8th valid char and hex_8_or_more[8] being the comma.
# Anything greater then print("Too large,")

lb $t8, hex_8_or_more($t9) # $t8 = hex_8_or_more[$t9]
beq $t8, '\n', check_index_N	# When we hit a newline we check if the index > 8
addi $t9, $t9, 1
j check_too_large_newline

check_index_N:
bgt $t9, 8, tooLarge_exit_program		# If the index $t9 > 8 then print("too large") and exit the program
# Else print hex_8_or_more


sub2_call_N:
la $a1, hex_8_or_more 		# assign the argument hex_8_or_more to the parameter $a1 of sub_program 2
addi $sp, $sp, -4    # allocate space to store return value from sub_2
jal subProgram_2 	# call subProgram_2
lw $s3, 0($sp)      # load the return value from the stack into $s3 
addi $sp, $sp, 4	# close the stack frame for the return value
after_sub2_call_N:

sub3_call_N:
addi $sp, $sp, -4  # open stack frame for parameter in subProgram_3
sw $s3, 0($sp) # store argument $s3 which holds the integer in to the stack frame for parameter for subProgram_3
jal subProgram_3 # call subProgram_3
addi $sp, $sp, 4  # close stack frame for parameter in subProgram_3
after_sub3_call_N:

j after_Load_Char # After printing then we are done


tooLarge_exit_program:		
li $v0, 4
la $a0, print_too_large 	#print("too large")
syscall
j after_Load_Char			# and exit the program







after_State_Machine:


prep_Make_all_zero:
li $t1, 0  # Re-initialize $t1 temp_string's index to 0
Make_all_zero:
lb $t6, temp_string($t1)
beq $t6, $zero, after_Make_all_zero	# zero out temp_string								 							
sb $zero, temp_string($t1)			
addi $t1, $t1, 1				# $t1 += 1
j Make_all_zero					# Go back to loop header
after_Make_all_zero:


prep_Make_hex_zero:
li $t0, 0  # initalize index $t0 to iterate hex_8_or_more as 0
Make_hex_8_zero:
beq $t0, 1001, next_temp_string 	# then get the next temp_string
sb $zero, hex_8_or_more($t0)			# Keep iterating through that
addi $t0, $t0, 1
j Make_hex_8_zero



store_endl_enter_machine:
li $t5, '\n'				# Load a newline into the temp_string[$t1]; this will help us when we are validating
sb $t5, temp_string($t1)
j State_Machine




after_Load_Char:




Exit:
li $v0, 10	#Call code for exiting program
syscall # Exit program



subProgram_1:

# Converts a single hexadecimal character to decimal
# Is called in subProgram_2
# takes in argument $a0 a hexadecimal character which is a byte '0' - '9'; 'A' - 'F'; 'a' - 'f'
# returns $v0 a decimal digit of the hexadecimal character
bge $a0, 48, check_LE_57
# No else block will ever be reached. Because $a0 will always be a valid hex character.
check_LE_57:
ble $a0, 57, val_48_to_57		# $a0 <= 57. Basically if $a0 >= 48 && $a0 <= 57; '0' to '9'; subtract 48 to get the decimal value
j check_GE_65			# Else check $a0 >= 65
val_48_to_57:
addi $v0, $a0, -48 		# $v0 = $a0 - 48
j sub_1_return			# return back to caller



check_GE_65:
bge $a0, 65, check_LE_70		# check $a0 >= 65. If true check $a0 <= 70
# No else block will ever be reached. Because $a0 will always be a valid hex character.
check_LE_70:
ble $a0, 70, val_65_70		# If $a0 >= 65 && $a0 <= 70  ; 'A' to 'F'; subtract 55 to get the decimal value
j check_GE_97 				# else check if $a0 >= 97
val_65_70:
addi $v0, $a0, -55 # $v0 = $a0 - 55
j sub_1_return	# retun back to caller


check_GE_97:
bge $a0, 97, check_LE_102		# $a0 >= 97; If true check $t8 <= 102; Above case already handled when false.
# No else block will ever be reached. Because $a0 will always be a valid hex character.
check_LE_102:
ble $a0, 102, val_97_to_102		# If  $a0 >= 97 && $a0 <= 102;'a' to 'f'; subtract 87 to get the decimal value
# No else block will ever be reached. Because $a0 will always be a valid hex character.
val_97_to_102:
addi $v0, $a0, -87 # $v0 = $a0 - 87
j sub_1_return	# retun back to caller


sub_1_return:
jr $ra


subProgram_2:

# Converts either a comma terminated hex string to a decimal or a endl terminated hex string to its decimal equivalent
# Takes in argument in $a1 which is the memory address of the array of hexadecimal characters either ending with a comma or a newline
# calls subProgram_1.
# uses $a1 as parameter
# other registers used are: $t4, $s1, $s2, $v0
# Returns the decimal value to the stack

addi $sp, $sp, -4		# Creat space for stack to allocate $ra
sw $ra, 0($sp)			# Store return address of stack there will be useful later when we want to call and return from sub one
li $t4, 0				# Initialize value $t4 = 0

Loop_hex_8:

lb $s1, 0($a1)          # load element at $a1[0] to $s1 to be used in sub1_call. This is our single hex character from our hex_8
lb $s2, 1($a1)          # Load element at $a1[1] to $s2. If this value is a comma add only and return add else add and sll 4

sub1_call:
move $a0, $s1 	# assign the argument $s1 to the parameter $a0 of subProgram_1
jal subProgram_1	# Call subProgram_1
move $s0, $v0	# return value from $v0 and store in $s0
after_sub1_call:


# If value at address + 1 is a comma or newline just add and return, else add and shift to the left
beq $s2, ',', just_add_return
beq $s2, '\n' just_add_return
j add_shift

just_add_return:
addu $t4, $t4, $s0 		# $t4 += $s0 basically value += sub1($s1); where $s1 is value at [hex_8 + offset]  which was loaded into $a1

lw $ra, 0($sp)         # get sub_2 return address from the stack again
addi $sp, $sp, 4       # Close sub_2 return address stack frame

sw $t4, 0($sp)        # result value is stored into the space allocated in the call of subProgram_2
jr $ra  			# return 


add_shift:
addu $t4, $t4, $s0 		# $t4 += $s0 basically value += subProgram_1($s1); where $s1 is value at [hex_8 + offset]  which was loaded into $a1
sll $t4, $t4, 4         # shift $t4 4 bits to the left and store in $t4 hence 0x0000002A become 0x000002A0 after operation

addi $a1, $a1, 1      	# increment $a1 so we get the next character in hex_8
j Loop_hex_8



subProgram_3:
# Takes in a decimal integer value in the stack parameter and prints it out
# Does not return anything
# Registers used: $s4, $t4, $t7, $s6
# Use array_integers2C to hold the values after mod iterations and prints those values when the parameter passed is negative
lw $s4 0($sp)		# Load the parameter from the stack into $s4
bltz $s4, negative_handler		# If the value is negative [0x80000000,0xFFFFFFFF] do divu $s4, 10, print rem and $s4 = quo until $s4 = 0
j regular_handler      # else print normally for [0x00000000,0x7FFFFFFF] 

negative_handler:
# Handling negative values
prep_LoopDiv2C:
li $t4, 10   # $t4  = 10
li $t7, 9	# $t7 = 9
LoopDiv2C:
divu $s4, $t4  # $s4 / 10 (unsigned) quotient stored in low and remainder stored in high
mflo $s4		# $s4 = $s4 // 10 Quotient stored here
mfhi $s5		# remainder stored here
sb $s5, array_integers2C($t7)  # array_integers_2CR[$t7] = $s5
beq $s4, $zero, after_LoopDiv2C # If the quotient is 0 then we have reached done Most Sig Digit mod 10 and assigned it to $s5 so we leave the loop 
#Else
addi $t7, $t7, -1  # Decrement index 
j LoopDiv2C 	   # Get next integer
after_LoopDiv2C:

prep_print_array_integers2C:
li $t7, 0 # $t7 index for array_integers_
print_array_integers2C:
beq $t7, 10, sub_3_return  # return when index $t7 > 9 because we are done printing
lb $s6, array_integers2C($t7)  # $s6 = array_integers2C[$t7]

li $v0, 1
move $a0, $s6		# Print value in $s6
syscall

addi $t7, $t7, 1 	# $t7++
j print_array_integers2C


regular_handler:
# just print the integer as normal
li $v0, 1
move $a0, $s4		# print the integer in $s4 which is our integer we got from the stack at $s0
syscall
j sub_3_return


sub_3_return:
jr $ra    # return to caller
