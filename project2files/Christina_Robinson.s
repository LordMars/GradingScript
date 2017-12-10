.data
string: .space 1001
print_comma: .asciiz ", " 
error_NaN: .asciiz "NaN" 
error_TooLarge: .asciiz"Too Large" 
 
 
 
.text 
 
main: 
   addi $v0, $0, 8     #taking 1000 character input from user 
   la $a0, string 
   li $a1, 1001 
   syscall 
   
 
   la $s0, string 
 
loop_string: 
   addi $a0, $s0, 0   #initialize arguments, mem address of string, size of string 
   addi $a1, $0, 0 
loop: 
   lb $t0, 0($s0) 
   beq $t0, 0, subprogram_2_end     #if read comma, newline or null branch to subprogram 
   beq $t0, 10, subprogram_2_end 
   beq $t0, 44, call_subprogram_2 
   
   addi $s0, $s0, 1     #incrmenet memory address 
   addi $a1, $a1, 1     #increment size 
   j loop 
call_subprogram_2: 
   jal subprogram_2     #jumps to subprogram 2 with substring 
   
   addi $a0, $v0, 0     
   addi $a1, $v1, 0 
   
   jal subprogram_3 
   
   li $v0, 4 
   la $a0, print_comma 
   syscall 
   
   addi $s0, $s0, 1 
   
   j loop_string 
 
subprogram_2_end: 
   jal subprogram_2 
   
   add $a0, $v0, $0   #loads return values 
   add $a1, $v1, $0   
   
   jal subprogram_3 
   
   li $v0, 10   #exits program 
   syscall 
   
 
subprogram_1: 
   sub $a0, $a0, $a1 
   add $v0, $a0, 0     #loads return values 
   jr $ra 
   
subprogram_2: 
   addi $sp, $sp, -20   #allocates stack space 
   sw $ra, 0($sp)     #saves return address 
   sw $s0, 4($sp) 
   sw $s1, 8($sp) 
   sw $s2, 12($sp) 
   sw $s3, 16($sp) 
   li $v1,   0 
   
   beq $a1, 0, invalid   #if size is 0, invalid   
   bgt $a1, 8, error_TooLarge   #if greater than 8, too large 
 
 
   addi $s0, $a0, -1  
   add $s1, $a1, $0  
   li $s2, 0  
   li $s3, 0 
     
subprogram_1_loop: 
   beq $s2, $s1, subprogram_2_helper 
   addi $s2, $s2, 1 
   addi $s0, $s0, 1 
   
   lb $a0, 0($s0) 
   beq $a0, 32, spaces_check 
   
   blt $a0, 48, invalid 
   addi $a1, $0, 48 
   blt $a0, 58, is_valid 
   blt $a0, 65, invalid 
   addi $a1, $0, 55 
   blt $a0, 71, is_valid 
   blt $a0, 97, invalid 
   addi $a1, $0, 87 
   blt $a0, 103, is_valid 
   j invalid 
is_valid: 
   sll $s3, $s3, 4 
   jal subprogram_1 
   add $s3, $s3, $v0 
   j subprogram_1_loop 
invalid: 
   addi $v1, $0, 1 
   j subprogram_2_helper 
numerror_TooLarge: 
   addi $v1, $0, 2 
   j subprogram_2_helper 
spaces_check: 
   bne $s2, $s1, invalid 
subprogram_2_helper: 
   addi $v0, $s3, 0 
   lw $ra, 0($sp) 
   lw $s0, 4($sp) 
   lw $s1, 8($sp) 
   lw $s2, 12($sp) 
   lw $s3, 16($sp) 
   addi $sp, $sp, 20 
   jr $ra 
   
subprogram_3: 
   beq $a1, 1, subprogram_3_NaN 
   beq $a1, 2, subprogram_3_TooLarge 
   addi $t0, $0, 10 
   divu $a0, $t0 
   mflo $t1 
   beq $t1, $0, printing 
   mflo $a0 
   addi $v0, $0, 1 
   syscall 
   mfhi $a0 
printing: 
   addi $v0, $0, 1 
   syscall 
   jr $ra 
subprogram_3_NaN: 
   addi $v0, $0, 4 
   la $a0, error_NaN 
   syscall 
   jr $ra 
subprogram_3_TooLarge: 
   addi $v0, $0, 4 
   la $a0, error_TooLarge 
   syscall 
   jr $ra 
