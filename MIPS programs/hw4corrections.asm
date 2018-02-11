##############################################################
# Homework #4
# name: MY_NAME
# sbuid: MY_SBU_ID
##############################################################

##############################################################
# DO NOT DECLARE A .DATA SECTION IN YOUR HW. IT IS NOT NEEDED
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
# Part I FUNCTIONS
##############################
check_char:
		#checks if char c is 'R', 'Y', or '.'. returns 1 if true, 0 if false. 
	push($s0)
	move $s0, $a0 			#s0 = c
	li $t0, 'R' 			#t0 = 'R'
	bne $s0, $t0, check_Y		#if c != 'R'
check_char_success:
	pop($s0)
	li $v0 1			#1 for true
	jr $ra
check_Y:
	li $t0, 'Y'			#t0 = 'Y'
	bne $s0, $t0, check_last	#if c!= 'Y'
	j check_char_success
check_last:
	li $t0, '.'			#t0 = '.'
	beq $s0, $t0, check_char_success	#if c = '.'
	li $v0 0
	pop($s0)
	jr $ra
set_slot:

#		int set_slot(slot[][] board, int num_rows, int num_cols, int row, int col, char c, int turn_num)

    # Define your code here
    ###########################################
    lw $t0, 0($sp)			#t0 = col
    lw $t1, 4($sp)			#t1 = c
    lw $t2, 8($sp)			#t2 = turn_num
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    push($s6)
    push($s7)
    move $s0, $a0			#s0 = board[][]
    move $s1, $a1			#s1 = num_rows
    move $s2, $a2			#s2 = num_cols
    move $s3, $a3			#s3 = row
    move $s4, $t0			#s4 = col
    move $s5, $t1			#s5 = c
    move $s6, $t2			#s6 = turn_num
    blez $s1, set_slot_error 		#if num_rows <= 0
    blez $s2, set_slot_error		#if num_cols <= 0
    bltz $s3, set_slot_error		#if row < 0
    addi $t0, $s1, -1			#t0 = num_rows - 1
    bgt $s3, $t0, set_slot_error	#if row > num_rows - 1
    bltz $s4, set_slot_error		#if col < 0
    addi $t0, $s2, -1			#t0 = num_cols - 1
    bgt $s4, $t0, set_slot_error	#if col > num_cols - 1
    move $a0, $s5			#a0 = c
    push($ra)
    jal check_char			#check if c = 'R', 'Y', or '.'
    pop($ra)
    move $t0, $v0			#t0 = result of check_char
    beqz $t0, set_slot_error		#if t0 = 0
    bltz $s6, set_slot_error		#if turn_num < 0
    li $t0 255
    bgt $s6, $t0, set_slot_error	#if turn_num > 255
    li $t1, 2				#size_of(obj) = 2
    mul $t0, $t1, $s2			#row_size = num_cols * size_of(obj)
    mul $t0, $t0, $s3			#t0 = row_size * row
    mul $t1, $t1, $s4			#t1 = sizeof(obj) * col
    add $s7, $s0, $t0			#s7 = obj_arr[row][col] = (row_size * row) + (size_of(obj) * col)
    add $s7, $s7, $t1
    sb $s5, ($s7)			#saves c into upper byte of slot object
    addi $s7, $s7, 1			#moves to lower byte of slot object
    sb $s6, ($s7)			#store turn_num into lower byte
    pop($s7)
    pop($s6)
    pop($s5)
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    li $v0 0				#return 0 for success
    jr $ra
set_slot_error:
    pop($s7)
    pop($s6)
    pop($s5)
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
	li $v0 -1			#return -1 for failure
	jr $ra
    ##########################################

get_slot:

		#(char piece, int turn) get_slot(slot[][] board, int num_rows, int num_cols, int row, int col)
    # Define your code here
    ###########################################
    lw $t0, 0($sp)			#t0 = col
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s7)
    move $s0, $a0			#s0 = board
    move $s1, $a1			#s1 = num_rows
    move $s2, $a2			#s2 = num_cols
    move $s3, $a3			#s3 = row
    move $s4, $t0			#s4 = col
    blez $s1, get_slot_error 		#if num_rows <= 0
    blez $s2, get_slot_error		#if num_cols <= 0
    bltz $s3, get_slot_error		#if row < 0
    addi $t0, $s1, -1			#t0 = num_rows - 1
    bgt $s3, $t0, get_slot_error	#if row > num_rows - 1
    bltz $s4, get_slot_error		#if col < 0
    addi $t0, $s2, -1			#t0 = num_cols - 1
    bgt $s4, $t0, get_slot_error	#if col > num_cols - 1
     li $t1, 2				#size_of(obj) = 2
    mul $t0, $t1, $s2			#row_size = num_cols * size_of(obj)
    mul $t0, $t0, $s3			#t0 = row_size * row
    mul $t1, $t1, $s4			#t1 = sizeof(obj) * col
    add $s7, $s0, $t0			#s7 = obj_arr[row][col] = (row_size * row) + (size_of(obj) * col)
    add $s7, $s7, $t1
    lb $v1, ($s7)			#load character into v0
    addi $s7, $s7, 1			#s7 = s7 + 1
    lb $v0, ($s7)			#load turn_num
    	pop($s7)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
    jr $ra
get_slot_error:
	pop($s7)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0, -1			#return (-1,-1) for error
	li $v1, -1			
	jr $ra
    ##########################################

clear_board:
	#int clear_board(slot[][] board, int num_rows, int num_cols)
    # Define your code here
    ###########################################
    push($s0)
    push($s1)
    push($s2)
    move $s0, $a0				#s0 = board
    move $s1, $a1				#s1 = num_rows
    move $s2, $a2				#s2 = num_cols
    blez $s1, clear_board_error 		#if num_rows <= 0
    blez $s2, clear_board_error		#if num_cols <= 0 
	li $t0, 0 				#row counter
	li $t1, 0				#column counter
clear_board_loop:
	beq $t0, $s1, clear_board_end		#if row == num_rows, end
	blt $t1, $s2, column_loop		#if col < num_cols
	li $t1, 0				#ti = 0
	addi $t0, $t0, 1			#row+= 1
	j clear_board_loop
	column_loop:
	move $a0, $s0				#a0 = board
	move $a1, $s1				#a1 = num_rows
	move $a2, $s2				#a2 = num_cols
	move $a3, $t0				#a3 = row
	li $t2, 0				#t2 = 0
	push($ra)
	push($t2)				#($sp) = 0
	li $t2, '.'				#t2 = '.'
	push($t2)				#($sp) = '.'
	push($t1)				#($sp) = col
	jal set_slot
	addi $sp, $sp, 12			#restore stack pointer
	pop($ra)
	addi $t1, $t1, 1			#increment column counter by 1
	j clear_board_loop
clear_board_end:
	pop($s2)
	pop($s1)
	pop($s0)
    li $v0, 0
    jr $ra
clear_board_error:
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0, -1
	jr $ra
    ##########################################
    


##############################
# Part II FUNCTIONS
##############################

load_board:
		
		# (int num_rows, int num_cols) load_board (slot[][] board, char[] filename)
		
    # Define your code here
    ##########################################
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    move $s0, $a0				#s0 = board
    move $s1, $a1				#s1 = filename
    move $a0, $s1				#a0 = filename
    li $a1, 0					#a1 = 0 (read-only)
    li $v0, 13					#v0 = 13 (for syscall)
    syscall
    bltz $v0, load_board_error			#if file descriptor < 0 (file error)
    move $s4, $v0				#s4 = file descriptor
    move $a0, $v0				#a0 = v0 (file descriptor, result of syscall 13)
    addi $sp, $sp, -5				#grow the stack by 5 bytes to make room for input buffer
    move $a1, $sp				#a1 = input buffer
    li $a2, 5					#max # of chars = 5
    li $v0 14					#v0 = 14 (read file)
    syscall
    lw $a0, ($sp)					#t0 = "rrcc\n"
    push($ra)
    jal parse_rrcc
    pop($ra)
    move $a0, $s4				#a0 = file descriptor for syscall 14
    move $s2, $v0				#s2 = row_num
    move $s3, $v1				#s3 = col_num
    blez $s2, restore_5			#if(row_num <= 0)
    blez $s3, restore_5			#if(col_num <= 0)
    li $a2, 9
    addi $sp, $sp, -4				#grow the stack by 4 more bytes to make room for next line
    move $a1, $sp				#$a1 = input buffer
    li $v0 14					#syscall 14
load_board_loop:
	move $a0, $s4				#a0 = file descriptor
	syscall
	bltz $v0, restore_5			#if v0 < 0, then file error
	beqz $v0, load_board_end		#if end-of-file
	lw $a0, ($sp)
	push($ra)
	jal parse_rrcc
	pop($ra)
	move $t0, $v0				#t0 = row
	move $t1, $v1				#t1 = col
	push($ra)
	jal parse_ttt
	pop($ra)
	lb $t2, 4($sp)				#t2 = piece
	move $t3, $v0				#t3 = turn number
	move $a0, $s0				#a0 = board
	move $a1, $s2				#a1 = num_rows
	move $a2, $s3				#a2 = num_cols
	move $a3, $t0				#a3 = row
	push($ra)
	push($t3)				#push turn count onto stack
	push($t2)				#push piece onto stack
	push($t1)				#push col onto stack
	jal set_slot
	addi $sp, $sp, 12			#restore stack pointer
	pop($ra)
	bltz $v0, restore_9		#if set_slot result < 0
	j load_board_loop
load_board_end:
	addi $sp, $sp, 9			#restore stack pointer from the 9 byte buffer
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0, 16				#syscall 16 to close file
	move $a0, $s4				#file descriptor to close
	syscall
	move $v0, $s2				#v0 = num_rows
	move $v1, $s3				#v1 = num_cols
	jr $ra
restore_5:
	addi $sp, $sp, 5			#restore stack pointer from 5 byte buffer
	j load_board_error
restore_9:
	addi $sp, $sp, 9			#restore stack pointer from 9 byte buffer
load_board_error:
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0, -1
	li $v1, -1
	jr $ra
    ##########################################
parse_rrcc:
	lb $t0, ($a0)				#t0 = 1st r
	lb $t1, 1($a0)				#t1 = 2nd r
	lb $t2, 2($a0)				#t2 = 1st c
	lb $t3, 3($a0)				#t3 = 2nd c
	addi $t0, $t0, -48			#convert from ASCII to decimal
	addi $t1, $t1, -48
	addi $t2, $t2, -48
	addi $t3, $t3, -48
	li $t4, 10				#t4 = 10
	mul $t0, $t0, $t4			# t0 = tens place * 10
	add $v0, $t0, $t1			#v0 = tens place + ones place
	mul $t1, $t2, $t4			#t1 = tensplace of c * 10
	add $v1, $t1, $t3			#v0 = tens place (c) + ones place(c)
	jr $ra
parse_ttt:
	lb $t0, 5($a0)				#t0 = 1st t
	lb $t1, 6($a0)				#t1 = 2nd t
	lb $t2, 7($a0)				#t2 = 3rd t
	addi $t0, $t0, -48			#convert from ASCII to decimal
	addi $t1, $t1, -48
	addi $t2, $t2, -48
	li $t3, 100				#t3 = 100
	mul $t0, $t0, $t3			#t0 = hundreds place * 100
	li $t3, 10
	mul $t1, $t1, $t3			#t1 = tens place * 100
	add $v0, $t0, $t1			#result = hundreds + tens + ones
	add $v0, $v0, $t2
	jr $ra
save_board:

		#int save_board(slot[][] board, int num_rows, int num_cols, char[] filename)
    # Define your code here
    ###########################################
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    push($s6)
    push($s7)
    move $s0, $a0					#s0 = board
    move $s1, $a1					#s1 = num_rows
    move $s2, $a2					#s2 = num_cols
    move $s3, $a3					#s3 = filename
    move $a0, $s3					#a0 = filename
    blez $s1, save_board_error				#if num_rows <= 0
    blez $s2, save_board_error				#if num_cols <= 0
    li $a1, 1						#a1 = 1 (write-only with create)
    li $v0 13						#syscall 13 to open file
    syscall
    bltz $v0, save_board_error				#if file descriptor < 0
    move $s4, $v0					#s4 = file descriptor
	addi $sp, $sp, -5				#create 5 byte buffer on the stack
first_line:
	move $a0, $s1
	move $a1, $s2
	move $a2, $sp
	push($ra)
	jal write_rrcc
	pop($ra)
	li $t0, '\n'					#t0 = \n
	sb $t0, 4($sp)					#end first line with \n
	li $v0 15					#syscall 15 to write file
	move $a0, $s4					#a0 = file descriptor
	move $a1, $sp					#a1 = output buffer
	li $a2, 5					#a2 = 5 (5 characters to write)
	syscall
	bltz $v0, save_board_error_5			#if v0 < 1 file error
	addi $sp, $sp, -4				#create a total of 9 byte buffer on the stack
	li $s5, 0					#s5 = offset from base address
	li $s3, 0					#s3 = number of slots found
next_line:
	move $a0, $s1					#a0 = num_rows
	move $a1, $s2					#a1 = num_cols
	add $t0, $s0, $s5				#t0 = board address + offset
	move $a2, $t0					#a2 = board
	push($ra)
	jal find_slots
	pop($ra)
	bltz $v0, save_board_end			#if v0 = -1, no slots found
	addi $s3, $s3, 1				#num_slots_found += 1
	lb $s6, 0($v0)					#s6 = row
	lb $s7, 4($v0)					#s7 = col
	move $a0, $s6					#a0 = row
	move $a1, $s7					#a1 = col
	push($ra)
	jal write_rrcc					#writes rrcc into the line
	pop($ra)
	add $s5, $s5, $v1					#v2 = offset from board address
	move $a0, $s0					#a0 = board
	move $a1, $s1					#a1 = num_rows
	move $a2, $s2					#a2 = num_cols
	move $a3, $s6					#a3 = row
	push($ra)
	addi $sp, $sp, -4				#move stack pointer
	sw   $s7, ($sp)					#sp = col
	jal get_slot
	addi $sp, $sp, 4				#restore stack pointer
	pop($ra)
	sb $v0, 4($sp)					#write piece into output buffer
	move $a0, $v1					#a0 = turn_number
	move $a1, $sp					#a1 = output buffer
	push($ra)
	jal write_ttt
	pop($ra)
	li $t0, '\n'
	sb $t0, 8($sp)					#end with new line
	li $v0, 15
	move $a0, $s4					#a0 = file descripter
	move $a1, $sp					#a1 = output buffer
	li $a2, 9					#a2 = 9 characters to write
	syscall						#syscall 15 to write file
	j next_line
save_board_end:
	addi $sp, $sp, 9				#restore stack pointer
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	move $v0, $s3					#return number of slots with pieces found
	jr $ra

find_slots:
	# (row, col) find_slots(int num_rows, int num_cols, slot[][] board)
	push($s0)
	push($s1)
	push($s2)
	move $s0, $a0					#s0 = num_rows
	move $s1, $a1					#s1 = num_cols
	move $s2, $a2					#s2 = board
	li $t7 0					#t7 = row counter
	li $t6 0					#t6 = column counter
	li $t5 0					#t5 = offset counter
slots_row_loop:
	beq $t7, $s0, slot_not_found					#if row = num_rows, end function
	blt $t6, $s1, slots_col_loop			#if col < num_col
	li $t6, 0					#col = 0
	addi $t7, $t7, 1				#row = row + 1
	j slots_row_loop
slots_col_loop:
	lb $t0, 0($s2)					#t0 = slot(piece)
	li $t1, 'R'					#t1 = R
	beq $t0, $t1, slot_found			#if piece = 'R'
	li $t1, 'Y'
	beq $t0, $t1, slot_found			#if piece = 'Y'
	addi $s2, $s2, 2				#move to next slot in board
	addi $t5, $t5, 2				#increment offset counter
	addi $t6, $t6, 1				#col = col + 1
	j slots_row_loop
slot_found:
#check if storing two values in v0 is possible
	pop($s2)
	pop($s1)
	pop($s0)
	sb $t7, 0($v0)					#store row in v0
	sb $t6, 4($v0)					#store col in v0 with offset 4
	move $v1, $t5					#v1 is offset from beginning address
	jr $ra
slot_not_found:
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0, -1
	li $v1, -1
	jr $ra
write_ttt:
	li $t0, 100					#t0 = 100
	div $a0, $t0					#turn_number / 100
	mflo $t0					#t0 = hundreds digit
	mfhi $t1					#t1 = tens and ones digit
	li $t7, 10					#t7 = 10
	div $t1, $t7					#turn_number(tens and ones) /10
	mflo $t1					#t1 = tens digit
	mfhi $t2					#t2 = ones digit
	addi $t0, $t0, 48				#convert to ASCII
	addi $t1, $t1, 48
	addi $t2, $t2, 48
	sb $t0, 5($a1)
	sb $t1, 6($a1)
	sb $t2, 7($a1)
	li $v0 0
	jr $ra    
write_rrcc:
	li $t0, 10					#t0 = 10
	div $a0, $t0					# row div by 10
	mflo $t1					#t1 = tens place
	mfhi $t2					#t2 = ones place
	addi $t1, $t1, 48				#convert to ASCII
	addi $t2, $t2, 48				#convert to ASCII
	sb $t1, 0($a2)					# save tens digit of r
	sb $t2, 1($a2)					#save ones digit of r
	div $a1, $t0					#col div by 10
	mflo $t1					#t1 = tens place
	mfhi $t2					#t2 = ones place
	addi $t1, $t1, 48				#convert to ASCII
	addi $t2, $t2, 48				#convert to ASCII
	sb $t1, 2($a2)					#save tens digit of col
	sb $t2, 3($a2)					#save ones digit of col
	li $v0 0
	jr $ra
save_board_error_5:
	addi $sp, $sp, 5				#restore stack pointer
save_board_error:
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0, -1					#return -1 for error
	jr $ra
    ##########################################
validate_board:

	#byte validate_board(slot[][] board, int num_rows, int num_cols)
	
    # Define your code here
    ###########################################
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    push($s6)
    push($s7)
    move $s0, $a0				#s0 = board
    move $s1, $a1				#s1 = num_rows
    move $s2, $a2				#s2 = num_cols
    li $s3, 0					#s3 = bit vector
bit7:
	sll $s3, $s3, 1
bit6:
	sll $s3, $s3, 1
bit5:
	sll $s3, $s3, 1
bit4:
	sll $s3, $s3, 1
bit3:
	sll $s3, $s3, 1
bit2:
	mul $t0, $s1, $s2
	li $t1 255
	ble $t0, $t1, bit2_0
	addi $s3, $s3, 1
bit2_0:	sll $s3, $s3, 1
bit1:
	li $t0 4
	bge $s2, $t0, bit1_0			#if num_cols >= 4
	addi $s3, $s3, 1
bit1_0:	sll $s3, $s3, 1
bit0:
	li $t0 4
	bge $s1, $t0, bit0_0			#if num_rows >= 4
	addi $s3, $s3, 1
bit0_0:	move $v0, $s3
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
    ##########################################

##############################
# Part III FUNCTIONS
##############################

display_board:

	#int display_board(slot[][] board, int num_rows, int num_cols)
	
    # Define your code here
    ###########################################
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	move $s0, $a0					#s0 = slot[][] board
	move $s1, $a1					#s1 = int num_rows
	move $s2, $a2					#s2 = int num_cols
	bltz $s1, display_board_error			#if num_rows < 0
	bltz $s2, display_board_error			#if num_cols < 0
	li $s3 0					#s3 = row counter
	li $s4 0					#s4 = col counter
	li $s5 0					#s5 = piece counter
display_loop:
	beq $s3, $s1, display_board_end			#if row = num_rows
	blt $s4, $s2, display_loop2			#if col < num_cols
	li $s4 0					#col = 0
	addi $s3, $s3, 1				#row += 1
	li $v0 11
	li $a0 '\n'					#print new line
	syscall
	j display_loop
display_loop2:
	move $a0, $s0					#a0 = board
	move $a1, $s1					#a1 = num_rows
	move $a2, $s2					#a2 = num_cols
	move $a3, $s3					#a3 = row
	push($ra)
	addi $sp, $sp, -4				#move stack pointer
	sw $s4, ($sp)					#store col into stack
	jal get_slot
	addi $sp, $sp, 4
	pop($ra)
	li $t0, '.'					#t0 = '.'
	bne $v0, $t0, contains_piece			#if piece != '.'
print_piece:
	move $a0, $v0					#a0 = piece
	li $v0 11					#syscall 11
	syscall
	addi $s4, $s4, 1				#col += 1
	j display_loop
contains_piece:
	addi $s5, $s5, 1				#pieces += 1
	j print_piece
display_board_end:
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	move $v0, $s5					#return # of pieces
	jr $ra
display_board_error:
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0 -1
	jr $ra
    #########################################

drop_piece:
    # Define your code here
    
	#int drop_piece(slot[][] board, int num_rows, int num_cols, int col, char piece, int turn_num)
	
    ###########################################
    lw $t0, 0($sp)					
    lw $t1, 4($sp)					
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    push($s6)
    move $s0, $a0					#s0 = board
    move $s1, $a1					#s1 = num_rows
    move $s2, $a2					#s2 = num_cols
    move $s3, $a3					#s3 = col
    move $s4, $t0					#s4 = piece
    move $s5, $t1					#s5 = turn_num
    bltz $s1, drop_piece_error				#if num_rows < 0
    bltz $s2, drop_piece_error				#if num_cols < 0
    bltz $s3, drop_piece_error				#if col < 0
    addi $t0, $s2, -1					#t0 = num_cols - 1
    bgt $s3, $t0, drop_piece_error			#if col > num_col-1
    li $t0, 'R'						#t0 = R
    beq $s4, $t0, continue					#if piece = R
    li $t0, 'Y'						#t0 = Y
    bne $s4, $t0, drop_piece_error			#if piece != Y
continue:
	li $t0 255					#t0 = 255
	bgt $s5, $t0, drop_piece_error			#if turn_num > 255
	li $s6 0					#s6 = row counter
drop_piece_loop:
	beq $s6, $s1, drop_piece_error			#if row = num_rows
	move $a0, $s0					#a0 = board
	move $a1, $s1					#a1 = num_rows
	move $a2, $s2					#a2 = num_cols
	move $a3, $s6					#a3 = row
	push($ra)
	addi $sp, $sp, -4				#make room for col
	sw $s3, ($sp)					#store col on stack
	jal get_slot
	addi $sp, $sp, 4				#restore stack pointer
	pop($ra)
	li $t0, '.'
	beq $v0, $t0, place_piece					#if piece is empty
	addi $s6, $s6, 1				#s6 += 1
	j drop_piece_loop
place_piece:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s6
	push($ra)
	push($s5)
	push($s4)
	push($s3)
	jal set_slot
	addi $sp, $sp, 12				#restore stack pointer
	pop($ra)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0 0
	jr $ra

drop_piece_error:
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0 -1
	jr $ra
        
    ##########################################

undo_piece:

	#(char piece, int turn_num) undo_piece(slot[][] board, int num_rows, int num_cols)
    ###########################################
 	push($s0)
 	push($s1)
 	push($s2)
 	push($s3)
 	push($s4)
 	push($s5)
 	push($s6)
 	push($s7)
 	move $s0, $a0				#s0 = board
 	move $s1, $a1				#s1 = num_rows
 	move $s2, $a2				#s2 = num_cols
 	bltz $s1, undo_piece_error
 	bltz $s2, undo_piece_error
 	addi $s3, $s1, -1			#s3 =row counter = num_rows - 1 (count from top)
 	li $s4 0				#s4 =col counter
 	li $s5 0				#s5 = latest turn counter
undo_piece_loop:
	bltz $s3, undo_piece_end		#if row counter < 0
	blt $s4, $s2, undo_piece_cloop		#if col < num_cols
	li $s4, 0
	addi $s3, $s3, -1
undo_piece_cloop:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	push($ra)
	addi $sp, $sp, -4
	sw $s4, ($sp)
	jal get_slot
	addi $sp, $sp, 4
	pop($ra)
	blt $v1, $s5, less_than			#if turn < largest turn counter
	move $s5, $v1				#set largest turn counter = turn
	move $s6, $s3				#s6 = row of largest turn
	move $s7, $s4				#s7 = col of largest turn
less_than:
	addi $s4, $s4, 1			#col += 1
	j undo_piece_loop
	
	
undo_piece_end:
	beqz $s5, undo_piece_error		#if largest turn = 0 then board is empty
	li $t0 0
	li $t1 '.'
	push($t0)				#store turn_num on stack
	push($t1)
	push($s7)
	push($ra)
	move $a3, $s6
	jal set_slot				#set the slot with the largest turn count to '.' 0
	pop($ra)
	addi $sp, $sp, 12			#restore sp
	push($ra)
	addi $sp, $sp, -4
	sw $s7 ($sp)
	jal get_slot				#get slot of largest turn to get the piece
	addi $sp, $sp, 4
	pop($ra)
	move $v1, $s5				#v1 = turn number of piece removed
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
	
undo_piece_error:
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0 '.'
	li $v1 -1
	jr $ra
    ##########################################
    jr $ra

check_winner:
    # Define your code here
    ###########################################
    
    li $v0, 'R'
    jr $ra
    ##########################################
##############################
# EXTRA CREDIT FUNCTION
##############################


check_diagonal_winner:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, '.'
    ##########################################
    jr $ra



##############################################################
# DO NOT DECLARE A .DATA SECTION IN YOUR HW. IT IS NOT NEEDED
##############################################################
