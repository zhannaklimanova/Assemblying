.data
.equ PS2_DATA_REGISTER, 0xff200100
.equ PIXEL_BUFFER, 0xc8000000
.equ CHAR_BUFFER, 0xc9000000 


.text
.global _start
_start:
        bl      input_loop
end:
        b       end

@ TODO: copy VGA driver here.
VGA_draw_point_ASM: 
	PUSH {A1, V1, V2, V3, V4}
	LDR V4, =PIXEL_BUFFER
	MOV V1, A1
	LSL V1, V1, #1
	MOV V2, A2
	LSL V2, V2, #10
	ADD V3, V1, V2
	ADD V3, V3, V4
	STRH A3, [V3]
	POP {A1, V1, V2, V3, V4}
	BX LR
	
VGA_write_char_ASM:
	// Boundary value analysis
	/*
	CMP A1, #79
	BXGT LR
	CMP A2, #59
	BXGT LR
	*/
	// Actual code
	PUSH {A1, V1, V2, V3, V4}
	LDR V4, =CHAR_BUFFER
	MOV V1, A1
	MOV V2, A2
	LSL V2, V2, #7
	ADD V3, V1, V2
	ADD V3, V3, V4
	STRB A3, [V3]
	POP {A1, V1, V2, V3, V4}
	BX LR
	
VGA_clear_pixelbuff_ASM:
	PUSH {A1, A2, A3, V1, V2, V3}
	MOV A1, #0 // x
	MOV A2, #0 // y
	MOV A3, #0 // c
	
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
	ANDEQ V1, #255 	
	STREQB V1, [V3]
	MOVEQ A1, #1 // returning 1 to denote valid data
	// RVALID == 0
	CMP V2, #0 
	MOVEQ A1, #0
	
	POP {V1, V2, V3}
	BX LR

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
