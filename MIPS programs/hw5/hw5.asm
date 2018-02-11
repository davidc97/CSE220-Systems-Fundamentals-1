#Homework #5
#name: David Chen
#sbuid: 110586427
.macro push(%reg)
	addi	$sp,	$sp,	-4
	sw      %reg,	0($sp)
.end_macro

.macro pop(%reg)
	lw	%reg, 0($sp)
	addi	$sp,	$sp,	4
.end_macro
.text
equals:					#can assume length is equal
	move $t0, $a0
	move $t1, $a1
equals_loop:
	lb $t2, ($t0)
	lb $t3, ($t1)
	beq $t2, $0, equals_true
	bne $t2, $t3, equals_false
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j equals_loop
equals_true:
	li $v0 1
	jr $ra
equals_false:
	li $v0 0
	jr $ra
convert_to_upper_and_get_length:
	
	push($s0)
	push($s1)
	li $s1, 0	 	#s1 = length
	move $s0, $a0		#s0 = str to convert
	li $t0, 90		#t0 = 90 ('Z')
	li $t7, 42		#t7 = 42 ('*')
	li $t1, 0 		#t1 = i
convert_to_upper_loop:
	add $t2, $s0, $t1	#increase address of str to next char
	lb $t3, ($t2)		#get char in t2
	beq $t3, $0, convert_to_upper_end	#if char = null
	addi $t1, $t1, 1		#increment i
	addi $s1, $s1, 1		#increment length count
	beq $t3, $t7, convert_to_upper_loop		#if t3 = '*'
	ble $t3, $t0, convert_to_upper_loop		#if t3 < 90 ('Z')
	addi $t3, $t3, -32	#convert to upper
	sb $t3, ($t2)		#save into str
	j convert_to_upper_loop
convert_to_upper_end:
	move $v0, $s0
	move $v1, $s1
	pop($s1)
	pop($s0)
	jr $ra
match_glob:

# (boolean, int) match_glob(char[] seq, char[] pat)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($ra)
	jal convert_to_upper_and_get_length			#convert seq to uppercase
	pop($ra)
	move $s0, $v0			#s0 = seq
	move $s1, $v1			#s1 = seq.length
	move $a0, $a1
	push($ra)
	jal convert_to_upper_and_get_length			#convert pat to uppercase
	pop($ra)
	move $s2, $v0			#s2 = pat
	move $s3, $v1			#s3 = pat.length
	li $t0, '*'			#t0 = *
	lb $t1, ($s2)			#t1 = first char of pat
	bne $t1, $t0, glob_continue 			#if pat[0].equals('*')
	li $t1 1
	beq $s3, $t1, match_glob_end1			#if pat.length = 1, (if pat = '*' only)
glob_continue:
	move $a0, $s0
	move $a1, $s2
	push($ra)
	jal equals					#pat = seq (?)
	pop($ra)
	bnez $v0, match_glob_end2			#if pat = seq
	beqz $s1 match_glob_end3			#if seq.length == 0
	beqz $s3 match_glob_end3			#if pat.length == 0
	lb $t0, ($s0)					#t0 = seq[0]
	lb $t1, ($s2)					#t1 = pat[0]
	beq $t0, $t1, match_glob_recursive			#if seq[0] == pat[0]
	li $t0, '*'
	bne $t0, $t1, match_glob_end3			#if pat[0] != '*'
	addi $t0, $s2, 1				#t0 = pat.substring(1)
	move $a0, $s0
	move $a1, $t0
	push($ra)
	jal match_glob					#match_glob(seq, pat.substring(1)
	pop($ra)
	move $t0, $v0					#t0 = match_found(?)
	move $t1, $v1					#t1 = glob_len1
	li $t7, 1
	bne $t0, $t7, match_glob_recursive2					#if  !match_found
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra 
match_glob_recursive2:
	addi $t0, $s0, 1				#t0 = seq.substring(1)
	move $a0, $t0
	move $a1, $s2
	push($ra)
	jal match_glob					#match_glob(seq.substring(1), pat)
	pop($ra)
	addi $v1, $v1, 1				#v1 = glob_len2 + 1
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
match_glob_recursive:
	addi $t0, $s0, 1				#t0 = seq.substring(1)
	addi $t1, $s2, 1				#t1 = pat.substring(1)
	move $a0, $t0
	move $a1, $t1
	push($ra)
	jal match_glob					#match_glob(seq.substring(1), pat.substring(1)
	pop($ra)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
	
match_glob_end1:			#returns (true, seq.length())
	li $v0, 1
	move $v1, $s1
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
match_glob_end2:			#returns (true, 0)
	li $v0, 1
	li $v1, 0
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
match_glob_end3:			#returns (false, 0)
	li $v0, 0
	li $v1, 0
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
	
###################################################################

save_perm:
	push($s0)
	push($s1)
	push($s2)
	move $s0, $a0				#s0 = dst
	move $s1, $a1				#s1 = seq
	li $s2, 0				#s2 = counter
save_perm_loop:
	lb $t1, ($s1)				#t1 = seq[0]
	beq $t1, $0, save_perm_end		#if seq[0] = null
	li $t0 2
	beq $s2, $t0, save_perm_hyphen		#if counter = 2
		sb $t1, ($s0)				#s0[0] = seq[0]
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		addi $s2, $s2, 1
		j save_perm_loop
save_perm_hyphen:
	li $t0 '-'
	sb $t0, ($s0)			#dst[0] = '-'
	addi $s0, $s0, 1
	li $s2, 0
	j save_perm_loop
save_perm_end:
	li $t0 '\n'
	sb $t0, ($s0)			#dst[0] = '\n'
	addi $s0, $s0, 1
	move $v0, $s0
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra

construct_candidates:
	
		#int construct_candidates(char[] candidates, char[] seq, int n)
		
	push($s0)
	push($s1)
	push($s2)
	move $s0, $a0				#s0 = candidates
	move $s1, $a1				#s1 = seq
	move $s2, $a2				#s2 = n
	li $t0, 2
	div $s2, $t0				#divide n/2
	mfhi $t0				#t0 = n%2
	li $t1 0
	beq $t0, $t1, candidates_any		#if n%2 == 0 branch
		addi $s2, $s2, -1		#s2 = n - 1
		add $s1, $s1, $s2		#seq = seq + n - 1
		lb $t7, ($s1)			#t7 = seq[n-1]
		li $t0, 'A'
		bne $t7, $t0, cand_T		#if seq[n-1] != A
			li $t0 'T'
			sb $t0, ($s0)		#candidates[0] = 'T'
			li $v0 1
			pop($s2)
			pop($s1)
			pop($s0)
			jr $ra
cand_T:
		li $t0, 'T'
		bne $t7, $t0, cand_C
			li $t0 'A'
			sb $t0, ($s0)
			li $v0 1
			pop($s2)
			pop($s1)
			pop($s0)
			jr $ra
cand_C:
		li $t0, 'C'
		bne $t7, $t0, cand_G
			li $t0 'G'
			sb $t0, ($s0)
			li $v0 1
			pop($s2)
			pop($s1)
			pop($s0)
			jr $ra
cand_G:
		li $t0, 'C'
		sb $t0, ($s0)
		li $v0 1
		pop($s2)
		pop($s1)
		pop($s0)
		jr $ra
candidates_any:
	li $t0, 'A'
	li $t1, 'C'
	li $t2, 'G'
	li $t3, 'T'
	sb $t0, 0($s0)		#candidates[0] = A
	sb $t1, 1($s0)		#candidates[1] = C
	sb $t2, 2($s0)		#candidates[2] = G
	sb $t3, 3($s0)		#candidates[3] = T
	li $v0 4
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra
	
permutations:
	
	#	(int, char[]) permutations(char[] seq, int n, char[] res, int length)
	
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	push($s6)
	move $s0, $a0				#s0 = seq
	move $s1, $a1				#s1 = n
	move $s2, $a2				#s2 = res
	move $s3, $a3				#s3 = length
	li $s4, 0
	li $s5, 0
	li $t0, 0
	beq $s3, $t0, permutations_error	#if length = 0
		li $t0, 2
		div $s3, $t0				#length/2
		mfhi $t0				#t0 = remainder
		li $t1 1
	beq $t0, $t1, permutations_error	#if length%2 = 1
	
	bne $s1, $s3, permutations_recursive	#if n != length
		#add_null(Seq, length + 1)
		add $t0, $s0, $s3		#t0 = seq + length
		li $t7, 0
		sb $t7, ($t0)			#saves null_terminator to seq[length+1]
		move $a0, $s2
		move $a1, $s0
		push($ra)
		jal save_perm			#save_perm(res, seq)
		pop($ra)
		move $v1, $v0			#return (0, next) (next is in v0)
		li $v0, 0
		pop($s6)
		pop($s5)
		pop($s4)
		pop($s3)
		pop($s2)
		pop($s1)
		pop($s0)
		jr $ra
permutations_recursive:
	la $s6, candidates			#s6 = candidates[4]
	move $a0, $s6
	move $a1, $s0
	move $a2, $s1
	push($ra)
	jal construct_candidates		#construct_candidates(candidates, seq, n)
	pop($ra)
	move $s4, $v0				#s4 = int ncand
	li $s5 0				#s5 = int i
permutations_loop:
	bge $s5, $s4, permutations_end		#if i = ncand
		add $t0, $s0, $s1		#t0 = seq + n
		add $t6, $s6, $s5		#t6 = candidates + i
		lb $t6, ($t6)			#t6 = candidates[i]
		sb $t6, ($t0)			#seq[n] = candidates[i]
		move $a0, $s0
		addi $t0, $s1, 1		#t0 = n + 1
		move $a1, $t0
		move $a2, $s2
		move $a3, $s3
		push($ra)
		jal permutations		#permutations(seq, n+1, res, length)
		pop($ra)
		move $s2, $v1			#res = result of permutations
		addi $s5, $s5, 1		#i++
		j permutations_loop
permutations_end:
	li $v0, 0
	move $v1, $s2
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra					#return (0, res)
permutations_error:
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	li $v0, -1
	li $v1, 0
	jr $ra					#return (-1, 0)
	
.data
candidates: .space 4
