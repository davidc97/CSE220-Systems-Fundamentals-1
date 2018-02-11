# Homework #1
# name: David Chen
# sbuid: 110586427

#Helper macro for grabbing command line arguments
.macro load_args
sw $a0, numargs
lw $t0, 0($a1)
sw $t0, integer
lw $t0, 4($a1)
sw $t0, fromBase
lw $t0, 8($a1)
sw $t0, toBase
.end_macro


.text
.globl main
main:
	load_args()     			#Only do this once
	
	#Checks if numargs = 3
	li $t0 3
	lw $t1 numargs
	bne $t0, $t1, Error
	#Checks fromBase and toBase
	lw $t0 fromBase
	lw $t1 toBase
	lb $t2, 1($t0) 				#tens digit of fromBase(if it exists) 
	bne $t2, $zero, Error			#checks if fromBase is one character
	lb $t3, 1($t1)				#tens digit of toBase(if it exists)
	bne $t3, $zero, Error			#checks if toBase is one character
	lb $s0, ($t0)				#stores fromBase for later use
	lb $s1, ($t1)				#stores toBase for later use
	li $t0 50
	#check if fromBase and toBase are less than 2
	blt $s0, $t0, Error
	blt $s1, $t0, Error
	#check if fromBase and toBase are greater than 9
	li $t1 57
	bgt $s0, $t1, greater_than_9_fromBase
return:	bgt $s1, $t1, greater_than_9_toBase
	addi $s1, $s1, -48			#convert from ASCII to digit value for later
	j main_2
greater_than_9_fromBase:
	#check if fromBase is less than A
	li $t0 65
	blt $s0, $t0, Error
	#check if fromBase is greater than F
	li $t0 70
	bgt $s0, $t0, Error
	j return
greater_than_9_toBase:
	#check if toBase is less than A
	li $t0 65
	blt $s1, $t0, Error
	#check if toBase is greater than F
	li $t0 70
	bgt $s1, $t0, Error
	addi $s1, $s1, -55			#convert from ASCII to digit value
	j main_2
main_2:
	#check if integer can be represented in fromBase
	lw $s2 integer 				#store integer address
	li $s6 -1				#initialize s6 to store number of digits in integer with an offset of 1
	li $t0 0				#set iterator to 0
loop:	add $t1, $s2, $t0			#increment integer to next character
	lb $t2, 0($t1)				#load integer[t1] into t2
	beq $t2, $zero, continue		#check if t2 is null
	bge $t2, $s0, Error			#check if t2 is greater than fromBase
	addi $t0, $t0, 1			#increment t0
	addi $s6, $s6, 1			#increment s6
	j loop
continue:
	#convert fromBase to ASCII
	li $t0 57				#check if frombase is greater than 9
	bgt $s0, $t0, convert_A_to_F
	addi $s0, $s0, -48
	b convert_to_base_10
convert_A_to_F:
	addi $s0, $s0, -55

convert_to_base_10:
	li $s3 1				#s3 is the iterator
	li $s4 0				#s4 holds the result
	li $s7 0				#s7 holds the current character
	li $s5 1				#s5 holds fromBase ^x
	add $t0, $s2, $s6			#increment integer to the rightmost digit
	lb $a0, ($t0)				#gets the first character in integer
	jal convert
	add $s4, $s4, $v0			#adds first character to the result
	
loop2:
	addi $s6, $s6, -1			#decrease s6 by 1
	add $t1, $s2, $s6			#increment integer to next character 
	lb $a0, 0($t1)				#load integer[t1] into a0
	beq $a0, $zero, convert_to_toBase	#if end of integer is reached, convert it to toBase
	jal convert
	mul $s5, $s5, $s0			#multiples current power by fromBase
	mul $t0, $v0, $s5			#t0 = current char * fromBase ^x
	add $s4, $s4, $t0			#s4 = s4 + t0
	addi $s3, $s3, 1			#s3 += 1
	j loop2	
	
convert_to_toBase:
	li $t0 0				#i = 0
	li $t1 32				#j = 32
	la $t7 buffer				#load buffer address
	addi $t7, $t7, 31			#buffer + 31 to access last position
loop3:
	beq $t0, $t1, print			#for(i < j)
	beq $s4, 0, print			#if the divisor is 0, print
	div $s4, $s1				#divide the converted nunmber by toBase
	mflo $s4				#quotient
	mfhi $t2				#remainder
	li $t5 9
	bgt $t2, $t5, convert_AF		#if remainder > 9 convert to A-F
	addi $t2, $t2, 48			#convert to ASCII
	b store
convert_AF: addi $t2, $t2, 55
store:	sb $t2, 0($t7)				#store byte into buffer position
	addi $t7, $t7, -1			#subtract 1 from buffer
	addi $t0, $t0, 1			#increment loop
	j loop3
	
print:
	la $a0, buffer
	li $v0 4
	syscall
	j end_switch

Error:						#Print Err_string
	la $a0 Err_string
	li $v0 4
	syscall
	j end_switch

end_switch:					# terminate program
	li $v0 10
	syscall
convert: li $t0 57
	bgt $a0, $t0, A_to_F
	addi $v0, $a0, -48
	jr $ra
A_to_F: addi $v0, $a0, -55
	jr $ra
.data
.align 2

	numargs: .word 0
	integer: .word 0
	fromBase: .word 0
	toBase: .word 0
	Err_string: .asciiz "ERROR\n"
	
	# buffer is 32 space characters
	buffer: .ascii "                                "
	newline: .asciiz "\n"
	
