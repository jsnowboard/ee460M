	andi $2, $2, 0
	addi $2, $2, 7
rst:	andi $1, $1, 0
loop:	addi $1, $1, 1
	beq $1, $2, rst
	j loop
