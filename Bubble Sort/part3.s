// Memory Initialization
array: .word -1, 23, 0, 12, -7 // original -1, 23, 0, 12, -7
.equ size, 5 // size of array to be sorted

.global _start
_start:
	
	// Variable Initialization
	LDR R0, =size // size of the array
	MOV R1, #4 // temporarily initialize R1 to word size
	MUL R3, R0, R1 // last address without beginning address offset
	LDR R1, =array // pointer to the first address of the array
	ADD R3, R3, R1 // maximum address; anything above and including is IOB
	ADD R2, R1, #4 // pointer to the second address of the array
	MOV R4, #0 // *(ptr + i)
	MOV R5, #0 // *(ptr + i + 1)
	
// Bubble Sort
loop:
	CMP R1, R3
	BGE STOP
	
	CMP R2, R3
	BGE update_address

	LDR R4, [R1]
	LDR R5, [R2]
	CMP R4, R5
	BGT swap
	
	ADD R2, R2, #4
	B loop

swap:
	STR R5, [R1]
	STR R4, [R2]
	ADD R2, R2, #4
	B loop
	
update_address:
	ADD R1, R1, #4 
	ADD R2, R1, #4  // R2 is always a word ahead of R1
	B loop

STOP:
	B STOP

