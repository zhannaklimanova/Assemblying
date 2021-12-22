.global _start

// Memory Initialization

// 2D Image INPUT: 10 x 10
row1Input:  .word 183, 207, 128, 30, 109, 0, 14, 52, 15, 210
row2Input:  .word 228, 76, 48, 82, 179, 194, 22, 168, 58, 116
row3Input:  .word 228, 217, 180, 181, 243, 65, 24, 127, 216, 118
row4Input:  .word 64, 210, 138, 104, 80, 137, 212, 196, 150, 139
row5Input:  .word 155, 154, 36, 254, 218, 65, 3, 11, 91, 95
row6Input:  .word 219, 10, 45, 193, 204, 196, 25, 177, 188, 170
row7Input:  .word 189, 241, 102, 237, 251, 223, 10, 24, 171, 71
row8Input:  .word 0, 4, 81, 158, 59, 232, 155, 217, 181, 19
row9Input:  .word 25, 12, 80, 244, 227, 101, 250, 103, 68, 46
row10Input: .word 136, 152, 144, 2, 97, 250, 47, 58, 214, 51

// Kernel INPUT: 5 x 5
row1Kernel: .word 1, 1, 0, -1, -1
row2Kernel: .word 0, 1, 0, -1, 0
row3Kernel: .word 0, 0, 1, 0, 0
row4Kernel: .word 0, -1, 0, 1, 0
row5Kernel: .word -1, -1, 0, 1, 1
    
// Result OUTPUT: 10 x 10
// You can also do row1Output .space
row1Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row2Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row3Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row4Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row5Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row6Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row7Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row8Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row9Output:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
row10Output: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	
	
// Constants Initialization
.equ iw, 10 // Image Width = 10
.equ ih, 10 // Image Height = 10
.equ kw, 5 // Kernel Width = 5
.equ kh, 5 // Kernel Height = 5
.equ kws, 2 // Kernel Width Stride = (Kernel Width - 1) / 2
.equ khs, 2 // Kernel Height Stride = (Kernel Height - 1) / 2
//.equ displacement, 0x000001f4 // gx[0] - fx[0]
//.equ row10InputAddress, 0x00000168 
//.equ row5KernelAddress, 0x000001e0
//.equ row10OutputAddress, 0x0000035c
//.equ rowOffset_gx_fx, #40 // number of word addresses it takes to move between rows in gx and fx
//.equ columnOffset_gx_fx, #4 // number of word addresses it takes to move between column in gx and fx
//.equ rowOffset_kx, #20 // number of word addresses it takes to move between rows in kx
//.equ columnOffset_kx, #4 // number of word addresses it takes to move between column in kx

// Program 
_start:

	// Variables Initialization
	MOV R0, #0 // int y = 0;
	MOV R1, #0 // int x = 0;
	MOV R2, #0 // int i = 0;
	MOV R3, #0 // int j = 0;
	MOV R4, #0 // int temp1 = 0;
	MOV R5, #0 // int temp2 = 0;
	MOV R6, #0 // int sum = 0;
	MOV R7, #0 // kx[j][i]
	MOV R8, #0 // fx[temp1][temp2]
	MOV R9, #0 // temporary storage 1
	MOV R10, #0 // tmporary storage 2


// Outer Loop
ih_loop:
	CMP R0, #10 // y < ih where ih = 10
	BGE STOP

	iw_loop:
		CMP R1, #10 // x < iw 
		BGE update_ih_loop
		
		MOV R6, #0 // int sum = 0;
		
		kw_loop:
		CMP R2, #5 // i < kw
		BGE update_iw_loop
		
			kh_loop: 
				CMP R3, #5 // j < kh
				BGE update_kw_loop
				
				
				// int temp1 = (x+j)-kws
				ADD R4, R1, R3 
				SUB R4, R4, #2
				
				// int temp2 = (y+i)-khs
				ADD R5, R0, R2
				SUB R5, R5, #2
				
				// If condition is true then continue; if false then branch to update_kh_loop
				//cond1:
					CMP R4, #0 // temp1 >= 0 
					BLT update_kh_loop

				//cond2: 
					CMP R4, #9 // temp1 <= 9 
					BGT update_kh_loop

				//cond3:
					CMP R5, #0 // temp2 >= 0
					BLT update_kh_loop

				//cond4:
					CMP R5, #9 // temp2 <= 9 
					BGT update_kh_loop

					// sum = sum + kx[j][i] * fx[temp1][temp2]
					// Determining address of kx[j][i]
					LDR R9, =row1Kernel
					MOV R10, #20
					MLA R9, R3, R10, R9 // row_beginning_address = (R3 * R10) + R9 = (j * 20) + base_address
					LDR R7, [R9, R2, LSL#2] // column_address = (R2 * 4) + R9 = (i * 4) + row_beginning_address

					// Determining address of fx[temp1][temp2]
					LDR R9, =row1Input
					MOV R10, #40
					MLA R9, R4, R10, R9 // row_beginning_address = (R4 * R10) + R9 = (temp1 * 4) + fx_beginning_address
					LDR R8, [R9, R5, LSL#2] // column = (R5 * 4) + R9 = (temp2 * 4) + row_beginning_address

					// Update sum
					MLA R6, R7, R8, R6 // sum = (kx[j][i] * fx[temp1][temp2]) + sum 
					
					B update_kh_loop
			
			
update_kh_loop:
	ADD R3, R3, #1 // j++
	B kh_loop
	
update_kw_loop:
	ADD R2, R2, #1 // i++
	MOV R3, #0 
	B kw_loop
	
update_iw_loop:
	// gx[x][y] = sum
	LDR R9, =row1Output // loading the first address of the output result
	MOV R10, #40 // rowOffset_gx_fx
	MLA R9, R1, R10, R9 // row_beginning_address = (R1 * R10) + R9 = (x * 4) + gx_beginning_address
	STR R6, [R9, R0, LSL#2] // column = (R0 * 4) + R9 = (y * 4) + row_beginning_address	

	MOV R3, #0 // reset kh loop
	MOV R2, #0 // reset kw loop
	ADD R1, R1, #1 // x++
	B iw_loop
	
update_ih_loop:
	MOV R3, #0 // reset kh loop counter
	MOV R2, #0 // reset kw loop counter
	MOV R1, #0 // reset iw loop counter
	ADD R0, R0, #1 // y++
	B ih_loop 


STOP:
	B STOP

