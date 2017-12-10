.data
    buffer: .space 9 # Reserves 8 Characters
    message:  .asciiz "Enter string"
    userInput: .space 8
  
.text
  
main:
     # Get User Input
     li $v0, 8 # prepare use data
     la $a0, userInput #want to print out value user input
     li $a1, 10 #prints
     syscall
  
     li $v0, 10      # end program
     #Displays Name
     li $v0, 4 #display text on screen.
     la $a0, userInput
     syscall
     
     # end program 
     li $v0, 10      
     syscall



