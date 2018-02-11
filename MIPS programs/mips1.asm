.text
.globl main

main: 
	# prints hello world
	la $a0, str
	li $v0, 4
	syscall
	
	# quits program
	li $v0, 2
	syscall
.data
i: .word 5
str: .asciiz "Hello World!"