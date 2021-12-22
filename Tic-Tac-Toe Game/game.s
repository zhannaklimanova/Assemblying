.equ PIXEL_BUFFER, 0xc8000000
.equ CHAR_BUFFER, 0xc9000000
.equ PS2_DATA_REGISTER, 0xff200100

win: .word 0b000000111, 0b000111000, 0b111000000, 0b001001001, 0b010010010, 0b100100100, 0b100010001, 0b001010100

.text
.global _start
_start:
	BL VGA_fill_ASM
	BL draw_grid_ASM 
	BL VGA_clear_charbuff_ASM
	MOV V6, #0 // keep track of player 1 squares
	MOV V7, #0 // keep track of player 2 pluses
loop:
	BL read_PS2_data_ASM // checking for 0 to start game 
	PUSH {R0-R12}
	POP {R0-R12}
	PUSH {R0-R12}
	POP {R0-R12}
	PUSH {R0-R12}
	POP {R0-R12}
	PUSH {R0-R12}
	POP {R0-R12}
	PUSH {R0-R12}
	POP {R0-R12}
	PUSH {R0-R12}
	POP {R0-R12}
	CMP A1, #0xF0
	BNE loop

	BL read_PS2_data_ASM
	CMP A1, #0x45
	BNE loop
	BL VGA_fill_ASM
	BL draw_grid_ASM 
	BL VGA_clear_charbuff_ASM
	MOV V6, #0 // keep track of player 1 squares
	MOV V7, #0 // keep track of player 2 pluses
	.loop_for_start_game:	
		.loop_player_1:
			BL Player_1_turn_ASM
			// Waiting for player 1 to write a number to draw square
			
			BL read_PS2_data_ASM // checking for 0 to start game 
			PUSH {R0-R12}
			POP {R0-R12}
			PUSH {R0-R12}
			POP {R0-R12}
			PUSH {R0-R12}
			POP {R0-R12}
			PUSH {R0-R12}
			POP {R0-R12}
			CMP A1, #0xF0
			BNE .loop_player_1			
			
			BL read_PS2_data_ASM // checking for values 1-9
			
			CMP A1, #-1
			BEQ .loop_player_1

			.test_values_player_1:
				PUSH {A1, V2, V3}
				CMP A1, #0x16 // square 1
				POPNE {A1, V2, V3}
				BNE .test_2
				MOV A1, #95 // x
				MOV A2, #56 // y
				// Checking that entry is valid
				AND V3, V7, #0b000000001
				CMP V3, #0b000000001
				BEQ .loop_player_1
				AND V3, V6, #0b000000001
				CMP V3, #0b000000001
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b000000001
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}				
				BEQ loop
				B .is_draw
				
				.test_2:
				PUSH {A1, V2, V3}
				CMP A1, #0x1E // square 2
				POPNE {A1, V2, V3}
				BNE .test_3
				MOV A1, #165 // x
				MOV A2, #56 // y
				// Checking that entry is valid
				AND V3, V7, #0b000000010
				CMP V3, #0b000000010
				BEQ .loop_player_1
				AND V3, V6, #0b000000010
				CMP V3, #0b000000010
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b000000010
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				BEQ loop
				B .is_draw


				.test_3:
				PUSH {A1, V2, V3}
				CMP A1, #0x26 // square 3
				POPNE {A1, V2, V3}
				BNE .test_4
				MOV A1, #233 // x
				MOV A2, #56 // y
				// Checking that entry is valid
				AND V3, V7, #0b000000100
				CMP V3, #0b000000100
				BEQ .loop_player_1
				AND V3, V6, #0b000000100
				CMP V3, #0b000000100
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b000000100
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .is_draw


				.test_4:
				PUSH {A1, V2, V3}
				CMP A1, #0x25 // square 4
				POPNE {A1, V2, V3}
				BNE .test_5
				MOV A1, #95 // x
				MOV A2, #125 // y
				// Checking that entry is valid
				AND V3, V7, #0b000001000
				CMP V3, #0b000001000
				BEQ .loop_player_1
				AND V3, V6, #0b000001000
				CMP V3, #0b000001000
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b000001000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .is_draw
				
				
				.test_5:
				PUSH {A1, V2, V3}
				CMP A1, #0x2E // square 5
				POPNE {A1, V2, V3}
				BNE .test_6
				MOV A1, #165 // x
				MOV A2, #125 // y
				// Checking that entry is valid
				AND V3, V7, #0b000010000
				CMP V3, #0b000010000
				BEQ .loop_player_1
				AND V3, V6, #0b000010000
				CMP V3, #0b000010000
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b000010000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .is_draw
				

				.test_6:
				PUSH {A1, V2, V3}
				CMP A1, #0x36 // square 6
				POPNE {A1, V2, V3}
				BNE .test_7
				MOV A1, #233 // x
				MOV A2, #125 // y
				// Checking that entry is valid
				AND V3, V7, #0b000100000
				CMP V3, #0b000100000
				BEQ .loop_player_1
				AND V3, V6, #0b000100000
				CMP V3, #0b000100000
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b000100000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .is_draw

				.test_7:
				PUSH {A1, V2, V3}
				CMP A1, #0x3D // square 7
				POPNE {A1, V2, V3}
				BNE .test_8
				MOV A1, #95 // x
				MOV A2, #194 // y
				// Checking that entry is valid
				AND V3, V7, #0b001000000
				CMP V3, #0b001000000
				BEQ .loop_player_1
				AND V3, V6, #0b001000000
				CMP V3, #0b001000000
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b001000000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .is_draw
				

				.test_8:
				PUSH {A1, V2, V3}
				CMP A1, #0x3E // square 8
				POPNE {A1, V2, V3}
				BNE .test_9
				MOV A1, #165 // x
				MOV A2, #194 // y
				// Checking that entry is valid
				AND V3, V7, #0b010000000
				CMP V3, #0b010000000
				BEQ .loop_player_1
				AND V3, V6, #0b010000000
				CMP V3, #0b010000000
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b010000000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .is_draw
				
			
				.test_9:
				PUSH {A1, V2, V3}
				CMP A1, #0x46 // square 9
				POPNE {A1, V2, V3}
				BNE .loop_player_1
				MOV A1, #233 // x
				MOV A2, #194 // y
				// Checking that entry is valid
				AND V3, V7, #0b100000000
				CMP V3, #0b100000000
				BEQ .loop_player_1
				AND V3, V6, #0b100000000
				CMP V3, #0b100000000
				BEQ .loop_player_1
				
				BL draw_square_ASM
				ADD V6, V6, #0b100000000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_1
				CMP A1, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .is_draw
				
		.is_draw:
			ORR R11, V6, V7
			LDR R12, =#0b111111111
			CMP R11, R12
			BLEQ draw_result_ASM
			CMP R11, R12
			BEQ loop
				

		.loop_player_0:
			BL Player_0_turn_ASM
			// Waiting for player 1 to write a number to draw square
			
			BL read_PS2_data_ASM // checking for 0 to start game 
			PUSH {R0-R12}
			POP {R0-R12}
			PUSH {R0-R12}
			POP {R0-R12}
			PUSH {R0-R12}
			POP {R0-R12}
			CMP A1, #0xF0
			BNE .loop_player_0			
			
			BL read_PS2_data_ASM // checking for values 1-9
			
			CMP A1, #-1
			BEQ .loop_player_0
			
			.test_values_player_0:
				PUSH {A1, V2, V3}
				CMP A1, #0x16 // square 1
				POPNE {A1, V2, V3}
				BNE .test_22
				MOV A1, #95 // x
				MOV A2, #56 // y
				// Checking that entry is valid
				AND V3, V6, #0b000000001
				CMP V3, #0b000000001
				BEQ .loop_player_0
				AND V3, V7, #0b000000001
				CMP V3, #0b000000001
				BEQ .loop_player_0
				
				
				BL draw_plus_ASM
				ADD V7, V7, #0b000000001
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1

				
				.test_22:
				PUSH {A1, V2, V3}
				CMP A1, #0x1E // square 2
				POPNE {A1, V2, V3}
				BNE .test_33
				MOV A1, #165 // x
				MOV A2, #56 // y
				// Checking that entry is valid
				AND V3, V6, #0b000000010
				CMP V3, #0b000000010
				BEQ .loop_player_0
				AND V3, V7, #0b000000010
				CMP V3, #0b000000010
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b000000010
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1
				

				.test_33:
				PUSH {A1, V2, V3}
				CMP A1, #0x26 // square 3
				POPNE {A1, V2, V3}
				BNE .test_44
				MOV A1, #233 // x
				MOV A2, #56 // y
				// Checking that entry is valid
				AND V3, V6, #0b000000100
				CMP V3, #0b000000100
				BEQ .loop_player_0
				AND V3, V7, #0b000000100
				CMP V3, #0b000000100
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b000000100
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1
				

				.test_44:
				PUSH {A1, V2, V3}
				CMP A1, #0x25 // square 4
				POPNE {A1, V2, V3}
				BNE .test_55
				MOV A1, #95 // x
				MOV A2, #125 // y
				// Checking that entry is valid
				AND V3, V6, #0b000001000
				CMP V3, #0b000001000
				BEQ .loop_player_0
				AND V3, V7, #0b000001000
				CMP V3, #0b000001000
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b000001000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1
				
				
				.test_55:
				PUSH {A1, V2, V3}
				CMP A1, #0x2E // square 5
				POPNE {A1, V2, V3}
				BNE .test_66
				MOV A1, #165 // x
				MOV A2, #125 // y
				// Checking that entry is valid
				AND V3, V6, #0b000010000
				CMP V3, #0b000010000
				BEQ .loop_player_0
				AND V3, V7, #0b000010000
				CMP V3, #0b000010000
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b000010000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				BEQ loop
				B .loop_player_1
				

				.test_66:
				PUSH {A1, V2, V3}
				CMP A1, #0x36 // square 6
				POPNE {A1, V2, V3}
				BNE .test_77
				MOV A1, #233 // x
				MOV A2, #125 // y
				// Checking that entry is valid
				AND V3, V6, #0b000100000
				CMP V3, #0b000100000
				BEQ .loop_player_0
				AND V3, V7, #0b000100000
				CMP V3, #0b000100000
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b000100000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1
				

				.test_77:
				PUSH {A1, V2, V3}
				CMP A1, #0x3D // square 7
				POPNE {A1, V2, V3}
				BNE .test_88
				MOV A1, #95 // x
				MOV A2, #194 // y
				// Checking that entry is valid
				AND V3, V6, #0b001000000
				CMP V3, #0b001000000
				BEQ .loop_player_0
				AND V3, V7, #0b001000000
				CMP V3, #0b001000000
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b001000000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1
				

				.test_88:
				PUSH {A1, V2, V3}
				CMP A1, #0x3E // square 8
				POPNE {A1, V2, V3}
				BNE .test_99
				MOV A1, #165 // x
				MOV A2, #194 // y
				// Checking that entry is valid
				AND V3, V6, #0b010000000
				CMP V3, #0b010000000
				BEQ .loop_player_0
				AND V3, V7, #0b010000000
				CMP V3, #0b010000000
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b010000000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1
				
			
				.test_99:
				PUSH {A1, V2, V3}
				CMP A1, #0x46 // square 9
				POPNE {A1, V2, V3}
				BNE .loop_player_0
				MOV A1, #233 // x
				MOV A2, #194 // y
				// Checking that entry is valid
				AND V3, V6, #0b100000000
				CMP V3, #0b100000000
				BEQ .loop_player_0
				AND V3, V7, #0b100000000
				CMP V3, #0b100000000
				BEQ .loop_player_0
				
				BL draw_plus_ASM
				ADD V7, V7, #0b100000000
				BL VGA_clear_charbuff_ASM
				BL testWin_Player_0
				CMP A2, #0
				POP {A1, V2, V3}
				
				BEQ loop
				B .loop_player_1

	
end: B end
	
	
.text	

testWin_Player_1: 
	PUSH {R8, V6, R11, LR}
	
	LDR R11, =win
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+4
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+8
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
//  POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+12
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+16
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+20
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+24
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+28
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V6, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A1, #0
	BLEQ player_1_win_result_ASM
	POP {R8, V6, R11, LR}	
	BX LR
	
testWin_Player_0: 
	PUSH {R8, V7, R11, LR}
	
	LDR R11, =win
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+4
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+8
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
//  POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+12
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+16
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+20
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+24
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
//	POPEQ {R8, V6, R11}	
//	BXEQ LR

	LDR R11, =win+28
	LDR R8, [R11]
	//PUSH {R8}
	AND R11, V7, R8
	CMP R8, R11
	//POP {R8}
	MOVEQ A2, #0
	BLEQ player_0_win_result_ASM
	POP {R8, V7, R11, LR}	
	BX LR
	
VGA_draw_point_ASM: 
	PUSH {V1, V2, V3, V4}
	LDR V4, =PIXEL_BUFFER
	MOV V1, A1
	LSL V1, V1, #1
	MOV V2, A2
	LSL V2, V2, #10
	ADD V3, V1, V2
	ADD V3, V3, V4
	STRH A3, [V3]
	POP {V1, V2, V3, V4}
	BX LR

VGA_fill_ASM:
	PUSH {A1, A2, A3, V1, V2, V3}
	MOV A1, #0 // x
	MOV A2, #0 // y
	LDR A3, =#0 // c
	
	y_outer_loop:
		CMP A2, #240 // y outer loop
		BEQ continue
		x_inner_loop:
			CMP A1, #320 // x inner loop
			ADDEQ A2, A2, #1
			MOVEQ A1, #0
			BEQ y_outer_loop
			PUSH {LR}
			BL VGA_draw_point_ASM
			POP {LR}
			ADD A1, A1, #1
			B x_inner_loop
	
	continue:	
	POP {A1, A2, A3, V1, V2, V3}
	BX LR
	
draw_grid_ASM:
	// Line Left
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #207 // height
	mov     r2, #5 // width
	mov     r1, #17 // y
	ldr     r0, =126 // x
	PUSH {R1, R2, LR}
	bl      draw_rectangle
	POP {R1, R2, LR}
	// Line Right
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #207 // height
	mov     r2, #5 // width
	mov     r1, #17 // y
	ldr     r0, =195 // x
	PUSH {R1, R2, LR}
	bl      draw_rectangle
	POP {R1, R2, LR}
	// Line Top
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #5 // height
	mov     r2, #207 // width
	mov     r1, #86 // y
	ldr     r0, =57 // x
	PUSH {R1, R2, LR}
	bl      draw_rectangle
	POP {R1, R2, LR}

	// Line Top
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #5 // height
	mov     r2, #207 // width
	mov     r1, #155 // y
	ldr     r0, =57 // x
	PUSH {R1, R2, LR}
	bl      draw_rectangle
	POP {R1, R2, LR}
	BX LR

.colors:
        .word   65535	
draw_rectangle:	
	push    {r4, r5, r6, r7, r8, r9, r10, lr}
	ldr     r7, [sp, #44]
	add     r9, r1, r3
	cmp     r1, r9
	popge   {r4, r5, r6, r7, r8, r9, r10, pc}
	mov     r8, r0
	mov     r5, r1
	add     r6, r0, r2
	b       .line_L2
	.line_L5:
	add     r5, r5, #1
	cmp     r5, r9
	popeq   {r4, r5, r6, r7, r8, r9, r10, pc}
	.line_L2:
	cmp     r8, r6
	movlt   r4, r8
	bge     .line_L5
	.line_L4:
	mov     r2, r7
	mov     r1, r5
	mov     r0, r4
	PUSH {LR}
	bl      VGA_draw_point_ASM
	POP {LR}
	add     r4, r4, #1
	cmp     r4, r6
	bne     .line_L4
	b       .line_L5
	BX LR
	
draw_plus_ASM:
	// PLUS
	// Top-Bottom
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #32 // height
	mov     r2, #3 // width
	SUB     r1, r1, #16 // y
	PUSH {A1, A2, LR}
	bl      draw_rectangle
	POP {A1, A2, LR}

	// Left-Right
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #3 // height
	mov     r2, #32 // width
	ADD     r1, r1, #16 // y
	SUB     r0, r0, #15 // x
	PUSH {A1, A2, LR}
	bl      draw_rectangle
	POP {A1, A2, LR}
	BX LR

draw_square_ASM:
	// Square
	// Top
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #3 // height
	mov     r2, #32 // width
	SUB     r1, #16// y
	SUB     r0, #15 // x
	PUSH {A1, A2, LR}
	bl      draw_rectangle
	POP {A1, A2, LR}

	// Left
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #32 // height
	mov     r2, #3 // width
	PUSH {A1, A2, LR}
	bl      draw_rectangle
	POP {A1, A2, LR}

	// Bottom
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #3 // height
	mov     r2, #32 // width
	ADD     r1, #16// y
	ADD     r0, #15 // x
	ADD     r1, #16// y
	SUB     r0, #15 // x
	PUSH {A1, A2, LR}
	bl      draw_rectangle
	POP {A1, A2, LR}

	// Right
	ldr     r3, .colors
	str     r3, [sp] // color 
	mov     r3, #32 // height
	mov     r2, #3 // width
	SUB     r1, #16// y
	ADD     r0, #15 // x
	SUB     r1, #16// y
	ADD     r0, #14 // x
	PUSH {A1, A2, LR}
	bl      draw_rectangle
	POP {A1, A2, LR}
	BX LR

@ TODO: insert PS/2 driver here.
read_PS2_data_ASM:
	PUSH {V1, V2, V3}
	MOV V3, A1 // temporarily moving input argument into variable register
	LDR A1, =PS2_DATA_REGISTER
	LDR V1, [A1]
	LSR V2, V1, #15 // [0xff200100] >> 15: getting RVALID
	AND V2, #1
	
	CMP V2, #1 // if RVALID == 1
	// RVALID = 1
	ANDEQ A1, V1, #255 	
	// RVALID == 0
	CMP V2, #0 
	MOVEQ A1, #-1
	
	POP {V1, V2, V3}
	BX LR

Player_0_turn_ASM:
	push    {R0, R1, R2, lr}
	mov     r2, #80 
	mov     r1, #1
	mov     r0, #1
	bl      VGA_write_char_ASM
	mov     r2, #108
	mov     r1, #1
	mov     r0, #2
	bl      VGA_write_char_ASM
	mov     r2, #97
	mov     r1, #1
	mov     r0, #3
	bl      VGA_write_char_ASM
	mov     r2, #121
	mov     r1, #1
	mov     r0, #4
	bl      VGA_write_char_ASM
	mov     r2, #101
	mov     r1, #1
	mov     r0, #5
	bl      VGA_write_char_ASM
	mov     r2, #114
	mov     r1, #1
	mov     r0, #6
	bl      VGA_write_char_ASM
	mov     r2, #32
	mov     r1, #1
	mov     r0, #7
	bl      VGA_write_char_ASM
	
	mov     r2, #48
	mov     r1, #1
	mov     r0, #8
	bl      VGA_write_char_ASM
	mov     r2, #32
	mov     r1, #1
	mov     r0, #9
	bl      VGA_write_char_ASM
	
	mov     r2, #84
	mov     r1, #1
	mov     r0, #10
	bl      VGA_write_char_ASM
	mov     r2, #117
	mov     r1, #1
	mov     r0, #11
	bl      VGA_write_char_ASM
	mov     r2, #114
	mov     r1, #1
	mov     r0, #12
	bl      VGA_write_char_ASM
	mov     r2, #110
	mov     r1, #1
	mov     r0, #13
	bl      VGA_write_char_ASM
	pop     {R0, R1, R2, LR}
	BX LR
	
Player_1_turn_ASM:
	push    {R0, R1, R2, lr}
	mov     r2, #80 
	mov     r1, #1
	mov     r0, #1
	bl      VGA_write_char_ASM
	mov     r2, #108
	mov     r1, #1
	mov     r0, #2
	bl      VGA_write_char_ASM
	mov     r2, #97
	mov     r1, #1
	mov     r0, #3
	bl      VGA_write_char_ASM
	mov     r2, #121
	mov     r1, #1
	mov     r0, #4
	bl      VGA_write_char_ASM
	mov     r2, #101
	mov     r1, #1
	mov     r0, #5
	bl      VGA_write_char_ASM
	mov     r2, #114
	mov     r1, #1
	mov     r0, #6
	bl      VGA_write_char_ASM
	mov     r2, #32
	mov     r1, #1
	mov     r0, #7
	bl      VGA_write_char_ASM
	
	mov     r2, #49
	mov     r1, #1
	mov     r0, #8
	bl      VGA_write_char_ASM
	mov     r2, #32
	mov     r1, #1
	mov     r0, #9
	bl      VGA_write_char_ASM
	
	mov     r2, #84
	mov     r1, #1
	mov     r0, #10
	bl      VGA_write_char_ASM
	mov     r2, #117
	mov     r1, #1
	mov     r0, #11
	bl      VGA_write_char_ASM
	mov     r2, #114
	mov     r1, #1
	mov     r0, #12
	bl      VGA_write_char_ASM
	mov     r2, #110
	mov     r1, #1
	mov     r0, #13
	bl      VGA_write_char_ASM
	pop     {R0, R1, R2, LR}
	BX LR

player_1_win_result_ASM: // Player-1 Wins
	PUSH {LR}
	BL VGA_clear_charbuff_ASM
	POP {LR}
	push    {R0, R1, R2, lr}
	mov     r2, #80 
	mov     r1, #1
	mov     r0, #1
	bl      VGA_write_char_ASM
	mov     r2, #108
	mov     r1, #1
	mov     r0, #2
	bl      VGA_write_char_ASM
	mov     r2, #97
	mov     r1, #1
	mov     r0, #3
	bl      VGA_write_char_ASM
	mov     r2, #121
	mov     r1, #1
	mov     r0, #4
	bl      VGA_write_char_ASM
	mov     r2, #101
	mov     r1, #1
	mov     r0, #5
	bl      VGA_write_char_ASM
	mov     r2, #114
	mov     r1, #1
	mov     r0, #6
	bl      VGA_write_char_ASM
	mov     r2, #45
	mov     r1, #1
	mov     r0, #7
	bl      VGA_write_char_ASM
	
	mov     r2, #49
	mov     r1, #1
	mov     r0, #8
	bl      VGA_write_char_ASM
	mov     r2, #32
	mov     r1, #1
	mov     r0, #9
	bl      VGA_write_char_ASM
	
	mov     r2, #87
	mov     r1, #1
	mov     r0, #10
	bl      VGA_write_char_ASM
	mov     r2, #105
	mov     r1, #1
	mov     r0, #11
	bl      VGA_write_char_ASM
	mov     r2, #110
	mov     r1, #1
	mov     r0, #12
	bl      VGA_write_char_ASM
	mov     r2, #115
	mov     r1, #1
	mov     r0, #13
	bl      VGA_write_char_ASM
	pop     {R0, R1, R2, LR}
	BX LR
	
	
player_0_win_result_ASM: // Player 0 wins
	PUSH {LR}
	BL VGA_clear_charbuff_ASM
	POP {LR}
	push    {R0, R1, R2, lr}
	mov     r2, #80 // P
	mov     r1, #1
	mov     r0, #1
	bl      VGA_write_char_ASM
	mov     r2, #108 // l
	mov     r1, #1
	mov     r0, #2
	bl      VGA_write_char_ASM
	mov     r2, #97 // a
	mov     r1, #1
	mov     r0, #3
	bl      VGA_write_char_ASM
	mov     r2, #121 // y
	mov     r1, #1
	mov     r0, #4
	bl      VGA_write_char_ASM
	mov     r2, #101 // e
	mov     r1, #1
	mov     r0, #5
	bl      VGA_write_char_ASM
	mov     r2, #114 // r
	mov     r1, #1
	mov     r0, #6
	bl      VGA_write_char_ASM
	mov     r2, #45 // -
	mov     r1, #1
	mov     r0, #7
	bl      VGA_write_char_ASM
	mov     r2, #48 // 0
	mov     r1, #1
	mov     r0, #8
	bl      VGA_write_char_ASM
	mov     r2, #32 // space
	mov     r1, #1
	mov     r0, #9
	bl      VGA_write_char_ASM
	
	mov     r2, #87 // W
	mov     r1, #1
	mov     r0, #10
	bl      VGA_write_char_ASM
	mov     r2, #105 // i
	mov     r1, #1
	mov     r0, #11
	bl      VGA_write_char_ASM
	mov     r2, #110 // n
	mov     r1, #1
	mov     r0, #12
	bl      VGA_write_char_ASM
	mov     r2, #115 // s
	mov     r1, #1
	mov     r0, #13
	bl      VGA_write_char_ASM
	pop     {R0, R1, R2, LR}
	BX LR
	
	
draw_result_ASM: // Player 0 wins
	PUSH {LR}
	BL VGA_clear_charbuff_ASM
	POP {LR}
	push    {R0, R1, R2, lr}
	mov     r2, #68 // D
	mov     r1, #1
	mov     r0, #8
	bl      VGA_write_char_ASM
	mov     r2, #114 // r
	mov     r1, #1
	mov     r0, #9
	bl      VGA_write_char_ASM
	
	mov     r2, #97 // a
	mov     r1, #1
	mov     r0, #10
	bl      VGA_write_char_ASM
	mov     r2, #119 // w
	mov     r1, #1
	mov     r0, #11
	bl      VGA_write_char_ASM
	pop     {R0, R1, R2, LR}
	BX LR

VGA_write_char_ASM:
	CMP A1, #79
	BXGT LR
	CMP A2, #59
	BXGT LR
	// Actual code
	PUSH {V1, V2, V3, V4}
	LDR V4, =CHAR_BUFFER
	MOV V1, A1
	MOV V2, A2
	LSL V2, V2, #7
	ADD V3, V1, V2
	ADD V3, V3, V4
	STRB A3, [V3]
	POP {V1, V2, V3, V4}
	BX LR
	
VGA_clear_charbuff_ASM:
	PUSH {A1, A2, A3, V1, V2, V3}
	MOV A1, #0 // x
	MOV A2, #0 // y
	MOV A3, #0 // c
	
	outer_loop:
		CMP A2, #60 // y outer loop
		BEQ continue2
		inner_loop:
			CMP A1, #80 // x inner loop
			ADDEQ A2, A2, #1
			MOVEQ A1, #0
			BEQ outer_loop
			PUSH {LR}
			BL VGA_write_char_ASM
			POP {LR}
			ADD A1, A1, #1
			B inner_loop
	
	continue2:	
	POP {A1, A2, A3, V1, V2, V3}
	BX LR
	

