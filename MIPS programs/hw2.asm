
##############################################################
# Homework #2
# name: David Chen
# sbuid: 110586427
##############################################################
.macro push(%reg)
	addi	$sp,	$sp,	-4
	sw      %reg,	0($sp)
.end_macro

.macro pop(%reg)
	lw	%reg, 0($sp)
	addi	$sp,	$sp,	4
.end_macro
.text

##############################
# PART 1 FUNCTIONS
##############################

char2digit:
    #Define your code here
	############################################
	li $t0 57						#loads ASCII value for 9
	bgt $a0, $t0, error					#if input > 9, error
	li $t0 48						#loads ASCII value for 0
	blt $a0, $t0, error					#if input < 0, error
	addi $v0, $a0, -48 					#adds -48 to ACII value to convert
	############################################
	jr $ra
error:
	li $v0, -1
	jr $ra

memchar2digit:
    #Define your code here
	############################################
	lb $t0, ($a0)
	li $t1 57						#loads ASCII value for 9
	bgt $t0, $t1, error					#if input > 9, error
	li $t1 48						#loads ASCII value for 0
	blt $t0, $t1, error					#if input < 0, error
	addi $v0, $t0, -48 					#adds -48 to ACII value to convert
	############################################
	jr $ra
fromExcessk:
    #Define your code here
	############################################
	li $t0 0						#load ASCII value for 0
	blt $a0, $t0, excessk_error				#if value is less than 0, error
	ble $a1, $t0, excessk_error				#if excessk value is less than 0, error
	li $v0, 0						#0 for success
	sub $v1, $a0, $a1					#subtract the excess k from value
	############################################
    jr $ra
    
excessk_error:
	li $v0, -1						#-1 for failure
	move $v1, $a0						#store the value in second return value
	jr $ra

printNbitBinary:
    #Define your code here
	############################################
	li $t0, 32						#load 32
	bgt $a1, $t0, error					#if m > 32, return -1
	li $t0, 1						#load 1
	blt $a1, $t0, error					#if m < 1, return -1
	move $t1, $a1						#store m in t1
	li $t0 32						#load 32
	sub $t0, $t0, $t1					#t0 = 32 - m
	sllv $t0, $a0, $t0					#shift value left (32-m) bits
loop:	
	beqz $t1, finish						#while m > 0
		bltz $t0, print_1				#if value < 0, print '1'
		li $a0, 0					#print '0'
		li $v0, 1
		syscall
		sll $t0, $t0, 1					#shift value left one bit
		addi $t1, $t1, -1				#m = m-1
		j loop
print_1:
		li $a0, 1
		li $v0, 1
		syscall
		sll $t0, $t0, 1
		addi $t1, $t1, -1
		j loop
		
	############################################
finish:
	li $v0, 0
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

btof:
    #Define your code here
	############################################
	push($s0)
	push($s1)
	push($s3)
	push($s6)
	push($s7)
	move $s3, $a0						#store input into s3
	li $s0,	0						#initiate value to store number of places moved
	li $s1, 0					#initiate value to store the fraction part
	li $s6, 0						#initiate value to store the sign bit
	lb $t1, ($s3)
checksign:
	li $t0, 'N'						#store N into t0
	beq $t1, $t0, btof_error				#if first char is N (NaN) go to error
	#li $t0, '+'
	#beq $t0, $t1, check_special
	#li $t0, '-'
	#beq $t0, $t1, check_special
	j loop2
	
check_special:
	addi $s3, $s3, 1
	lb $t1, ($s3)
	li $t0, 'I'
	beq $t1, $t0, btof_error
	li $t0, '0'
	beq $t1, $t0, check_zero
	j loop2
check_zero:
	addi $s3, $s3, 1
	li $t0, '.'
	lb $t1, ($s3)
	beq $t1, $t0, final_check
	j loop2
final_check:
	addi $s3, $s3, 1
	li $t0, '0'
	lb $t1, ($s3)
	beq $t1, $t0, btof_error
	j loop2
btof_error:
	li $v0 -1
	li $v1 -1
	jr $ra
loop2:	addi $s3, $s3, 1						#shift input to the left by 1
	lb $t0, ($s3)						#load current byte of input
	li $t7, '.'
	beq $t0, $t7, calculate_exponent			#once the period is reached, calculate exponent
	addi $s0, $s0, 1					#add 1 to number of places
	#sll $s3, $s3, 1						#shift input to the left by 1

	move $a0, $t0						#move current byte into a0 to convert into digit
	move $s5, $ra						#store ra into s5 to save jump to main
	jal char2digit						#convert from ASCII to digit
	move $ra, $s5						#return ra to original value
	#lb $t0, ($s1)						#load byte of result
	move $s1, $v0						#store digit into result
	sll $s1,$s1, 1						#shift result left for next digit
	j loop2
calculate_exponent:
	addi $s0, $s0, 127					#add 127(excess k of single point) to number of places moved
	j convert_to_binary
calculate_fraction:
	li $s7, '\0'						#load terminating character
	addi $s3, $s3, 1						#shift left once because current character is '.'
	lb $t1, ($s3)						#load current character
fraction_loop:	beq $t0, $t1, end					#once terminating char is reached, finish
		move $a0, $t1					#move current character into a0 to convert
		move $s5, $ra					#store ra into s5 to save jump to main
		jal char2digit					#convert ASCII to digit
		move $ra, $s5					#return ra to original value
		#lb $t0, ($s1)					#load byte of result
		move $s1, $v0					#move digit into result
		sll $s1,$s1, 1					#shift value left
		sll $s3,$s3, 1					#shift result left
		j fraction_loop
	
	############################################
end:
	#s6 = sign bit, s4 = exponent bit, s1 = mantissa
	la $v1 result						#prepare v0 to store final result
	li $t0 8						#i = 8
	lb $t1, ($v1)						#get first char of result
	move $t1, $s6						#put in sign bit
	sll $v1, $v1, 1						#shift result left by 1
loop3:	beqz $t0, continue					#while i > 0
	move $v1, $s4						#store current byte of exponent bit
	sll $s4, $s4, 1						#shift exponent bit left by 1
	sll $v1, $v1, 1						#shift result left by 1
	addi $t0, $t0, -1					#i = i-1
	j loop3
continue:
	li $t0 23						#i = 23
	sll $v1, $v1, 1						#shift to next empty space in result
loop4: 	beqz $t0, last						#while i > 0
	#lb $t1, ($v0)						#load current byte of result
	move $v1, $s1						#store current byte of mantissa 
	sll $s1, $s1, 1						#shift mantissa left by 1
	sll $v1, $v1, 1						#shift result left by 1
	addi $t0, $t0, -1					#i = i -1
	j loop4
last:
	pop($s7)
	pop($s6)
	pop($s3)
	pop($s1)
	pop($s0)
	li $v0, 0
	jr $ra

convert_to_binary:
	li $t0, 8						#load 8 to ready loop
	li $s4, 0						#ready s4 to store result (exponent part)
	li $t1, 2						#load 2 for division
binary_loop:	beqz $t0, calculate_fraction				#while ( t0 > 0)
	li $t2, 8 						#load 8 for subtraction
	sub $t2, $t2, $t0					#t2 = 8 - iterator
	add $s4, $s4, $t2					#increment result
	div $s0, $t1						#divide by 2
	#lb $t4, ($s4)						#load current byte of result
	mfhi $s4						#store remainder
	addi $t0, $t0, -1					# t0 = t0 - 1
	mflo $s0						#move quotient to s0
	j binary_loop
	
	
print_parts:
    #Define your code here
	############################################
	# DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
	li $v0, 1
	############################################
    jr $ra

print_binary_product:
    #Define your code here
	############################################
	# DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
	li $v0, 1
	############################################
    jr $ra



#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
	

	result: .float 0
#place all data declarations here

