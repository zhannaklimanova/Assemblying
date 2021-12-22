.equ PIXEL_BUFFER, 0xc8000000
.equ CHAR_BUFFER, 0xc9000000 
.global _start
_start:
/*
		MOV A1, #16 // x
		MOV A2, #17 // y 
		LDR A3, =#0b000001111110001 // c: pixels 0-4blue, 5-10green, 11-15red
		*/
        bl       draw_test_screen
end:
        b       end

@ TODO: Insert VGA driver functions here.
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
	
VGA_write_char_ASM:
	// Boundary value analysis
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

draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071
