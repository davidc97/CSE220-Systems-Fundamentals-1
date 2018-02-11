##############################################################
# Homework #3
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
# FUNCTIONS
##############################

findStringLength:
	push($s0)
	push($s1)
	li $s0, 0						#s0 = result
	move $t0, $a0
stringLengthLoop:
	lb $s1, ($t0)						#s1 = current char
	beq $s1, $zero, length_found
	addi $s0, $s0, 1
	addi $t0, $t0, 1
	j stringLengthLoop
length_found:
	move $v0, $s0
	pop($s1)
	pop($s0)
	jr $ra
indexOf:
    # Define your code here
    ###########################################

	li $t0, 0
	blt $a2, $t0, not_found							#if startIndex < 0, return -1
	move $t2, $a0
	move $t0, $a2								#store startIndex in t0 which will store the result index
	add $t2, $t2, $a2							#shift str to startIndex
indexOf_loop:	
	lb $t1, ($t2)								#get current char from str
	beq $t1, $zero, not_found						#if current char = null, then char was not found
	beq $t1, $a1, index_found						#if current char = ch, return index of ch
	addi $t2, $t2, 1								#shift str to next char
	addi $t0, $t0, 1							#increment result index by 1
	j indexOf_loop
index_found:
	move $v0, $t0
	jr $ra
not_found:
	li $v0, -1								#return -1 if char wasn't found or startIndex < 0
	jr $ra
    ##########################################

replaceAllChar:
    # Define your code here
    ###########################################
    	lb $t0, ($a0)				
	beq $t0, $zero, empty_str_or_pattern							#if str is empty return (str, -1)
	lb $t0, ($a1)
	beq $t0, $zero, empty_str_or_pattern							#if pattern is empty return (str, -1)
	push($ra)
	jal findStringLength
	pop($ra)
	push($s0)
	move $s0, $v0										#store string Length in s0
	li $t2 -1
	mul $s0, $s0, $t2									#multiply string length by -1 for later use
	li $t5, 0								#t5 = number of chars changed
	move $t7, $a1										#put pattern in t7
	push($s1)
	move $s1, $a0										#put str in s0
replaceAllChar_loop:
	lb $a0, ($s1)										#load char
	beq $a0, $zero, replaceAllChar_end					#if char = null		
	push($ra)								#store ra in stack
	jal replaceAllChar_helper						#check if any char in pattern matches current char
	pop ($ra)								#restore ra
	move $a1, $t7										#restore a1
	add $t5, $t5, $v1							#increment number of chars changed
	sb $v0, ($s1)								#save replacement
	addi $s1, $s1, 1							#increment str
	j replaceAllChar_loop
replaceAllChar_end:
	add $v0, $t0, $s0							#bring str back to beginning of address 
	move $v1, $t5
	pop($s1)
	pop($s0)
	jr $ra
replaceAllChar_helper:
	lb $t1, ($a1)								#get first char in pattern
	beq $t1, $zero, end_fail							#if current char = null
	beq $a0, $t1, end_success							#if current char in str = current char in pattern
	addi $a1, $a1, 1							# increment pattern
	j replaceAllChar_helper
end_success:
	li $v1 1
	move $v0 $a2								#return replacement
	jr $ra
end_fail:
	li $v1 0
	move $v0 $a0								#return character
	jr $ra
	
	
empty_str_or_pattern:
	#return str, -1
	move $v0, $a0
	li $v1, -1
	jr $ra
	##########################################

countOccurrences:
    # Define your code here
    ###########################################
    push($s0)
    push($s1)
    push($s2)
    li $s0 0						#s0 = result
    move $s1, $a0					#s1 = str to search through
    move $s2, $a1					#s2 = searchChars
cOLoop:
	lb $a0, ($s1)					#get current char
	beq $a0, $zero, cOend				#if char = 0
	move $a1, $s2					#refresh searchChars to beginning
	push($ra)					#store ra
	jal countOccurrences_helper			#checks if any searchChars match current letter
	pop($ra)					#restore ra
	add $s0, $s0, $v0				#increments result if a match was found
	addi $s1, $s1, 1				#increment str
	j cOLoop
cOend:
	move $v0 $s0
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
countOccurrences_helper:
	lb $t1, ($a1)								#get first char in searchChars
	beq $t1, $zero, cOhelperEnd_fail							#if current char = null
	beq $a0, $t1, cOhelperEnd_success							#if current char in str = current char in searchChars
	addi $a1, $a1, 1							# increment searchChars
	j countOccurrences_helper
cOhelperEnd_fail:
	li $v0 0
	jr $ra
cOhelperEnd_success:
	li $v0 1
	jr $ra
    ##########################################

replaceAllSubstr:
    # Define your code here
    ###########################################
    lb $t0, ($a2)
    beq $t0, $zero, empty_end			#if str is empty, return (dst, -1)
    lb $t0, ($a3)
    beq $t0, $zero, empty_end			#if str is empty, return (dst, -1)
    lw $t0, ($sp)				#load replaceStr in t0
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    push($s6)
    push($s7)
    li $s6 0					#s6 = number of replacements
    li $s7 0 					#s7 = number of spaces to move back
    move $s0, $t0				#s0 = replaceStr
    move $s1, $a0				#s1 = dst
    move $s2, $a1				#s2 = dstLen
    move $s3, $a2				#s3 = str
    move $s4, $a3				#s4 = searchChars
    #puts into a0 a1 for countOccurrences
    move $a0, $s3				
    move $a1, $s4
    push($ra)					#save ra
    jal countOccurrences
    pop($ra)					#restore ra
    move $t3, $v0				#t2 = occurences of searchChars in str
    move $a0, $s3				#a0 = str
    push($ra)
    jal findStringLength
    pop($ra)
    move $t1, $v0				#t1 = str.length
    sub $t1, $t1, $t3				#t1 = str.length - occurences of searchChars
    move $a0, $s0				#put replaceStr into a0 for string length
    push($ra)
    jal findStringLength
    pop($ra)
    move $t7, $v0				#store string length of replaceStr in t7
    mul $t2, $t7, $t3				#t2 = replaceStr.length * occurences of searchChars
    add $s5, $t2, $t1				#s5 = str.length - occurrences of searchChars + replaceStr.length * occurrences of searchChars
    addi $s5, $s5, 1				#add 1 for null terminator
    move $a0, $s1
    bgt $s5, $s2, empty_end			#if finalstrlength > dstLen
rASLoop:
	lb $a0, ($s3)				#get current char in str
	beq $a0, $0, rAS_end			#if char = null
	addi $s3, $s3, 1			#increment str
	move $a1, $s4				#move searchChars to a1 for helper function
	move $a2, $s0				#move replaceStr to a2
	push($ra)
	jal rAS_helper
	pop($ra)
	add $s6, $s6, $v1				#increment number of replacements
	li $t0 1
	beq $v1, $t0, rASstore		#if success (v1 = 1)
	sb $v0, ($s1)				#store char in str into dst
	addi $s1, $s1, 1			#increment dst
	addi $s7, $s7, 1			#increment # of spaces to move back to starting address
	j rASLoop
rAS_helper:
	lb $t1, ($a1)								#get first char in pattern
	beq $t1, $0, rASend_fail							#if current char = null
	beq $a0, $t1, rASend_success							#if current char in str = current char in pattern
	addi $a1, $a1, 1							# increment pattern
	j rAS_helper
rASstore:
	lb $t0, ($s0)							#get first char of replaceStr
	beq $t0, $zero, rASstoreEnd
	sb $t0, ($s1)							#store it into dst
	addi $s0, $s0, 1						#increment replace str
	addi $s1, $s1, 1						#increment dst
	addi $s7, $s7, 1						#increment # of spaces to move back to starting address
	j rASstore
rASstoreEnd:
	sub $s0, $s0, $t7
	j rASLoop
rASend_success:
	li $v1 1
	move $v0 $a2								#return replacement
	jr $ra
rASend_fail:
	li $v1 0
	move $v0 $a0								#return character
	jr $ra
	
rAS_end:
	sb $0, ($s1)
	sub $s1, $s1, $s7			#move dst back to starting address
	move $v0, $s1
	move $v1, $s6
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
empty_end:
	#return (dst,-1)
	move $v0, $a0
	li $v1, -1
	jr $ra
    ##########################################

split:
    # Define your code here
    # reminder: int indexOf(char[] str, char ch, int startIndex)
    # (int, int) split (int[] dst, int dstLen, char[] str, char delimiter)
    ###########################################
	lb $t0, ($a2)				
	beq $t0, $zero, splitEmptyEnd 				#if string is empty return (0,-1)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	li $s4 1						#s4 = current number of addresses in dst (1 because there's always at least 1 if string is not empty)
	li $s5 0						#s5 = number of spaces to move dst back
	move $s0 $a0						#s0 = dst
	move $s1 $a1						#s1 = dstLen
	move $s2 $a2						#s2 = str
	move $s3 $a3						#s3 = delimiter
	sw $s2, ($s0)						#store first byte of str into dst (always here)
	addi $s0, $s0, 4					#move to next spot in dst
	addi $s5, $s5, 4					#increment # of spaces to move back
	#move into proper registers to call indexOf
	move $a0, $s2
	move $a1, $s3
	li $a2 0
	push($ra)
	jal indexOf
	pop($ra)
	li $t0, -1
	beq $v0, $t0, split_end					#if there are no delimiters, then return (1, 0)
splitloop:
	beq $s4, $s1, split_end_incomplete					#if number of addresses = dstLen, then the entire string was not yet tokenized
	push($ra)
	jal indexOf
	pop($ra)
	li $t0 -1
	beq $v0, $t0, split_end					#if delimiter isn't in str, jump to the end
	li $t0 0
	beq $v0, $t0, split_delimBeg				#if index = 0
	add $s2, $s2, $v0					#move str to the address of the index of delimiter
	sb $0, ($s2)						#replace delimiter with null terminator in str
	sw $s2, ($s0)						#store the address in dst
	sub $s2, $s2, $v0					#move str back to starting address
	addi $s0, $s0, 4					#increment dst
	addi $s4, $s4, 1					#currentAddress number + 1
	addi $t0, $v0, 1					#add 1 to the index
	addi $s5, $s5, 4					#add 1 to s5
	move $a2, $t0						#startIndex = indexOf last delimiter + 1
	j splitloop
split_delimBeg:
	addi $s2, $s2, 1					#get 2nd place of str
	sw $s2, ($s0)						#store it in dst
	addi $s2, $s2, -1					#put str back to starting address
	sb $zero, ($s2)						#replace delimiter with null terminator in str
	addi $s0, $s0, 4					#increment dst by 1
	addi $s4, $s4, 1
	addi $t0, $v0, 1
	addi $s5, $s5, 4
	move $a2, $t0
	j splitloop
split_end_incomplete:
	sub $s0, $s0, $s5					#move dst back to the beginning
	move $v0, $s4
	li $v1, -1
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
split_end:
	sub $s0, $s0, $s5					#move dst back to the beginning
	move $v0, $s4
	li $v1, 0
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
splitEmptyEnd:
	li $v0, 0
	li $v1, -1
	jr $ra
    ##########################################