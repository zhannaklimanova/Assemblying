.data
.equ LED_MEMORY, 0xFF200000 // LED data registers in memory
.equ HEX0_3_MEMORY, 0xFF200020 // Seven-segment data register in memory
.equ HEX4_5_MEMORY, 0xFF200030 // Seven-segment data register in memory
.equ TIMER_MEMORY, 0xFFFEC600 // Cortex-A9 private timer registers in memory

.text // program
.global _start
_start:
	// Setting up the input arguments
	LDR A1, =#200000000 // Initial count value of 1 second
	MOV A2, #3 // bit E = 1 starts timer; bit A = 1 loops timer
	MOV V7, #0 // initialize counter from 0-15
	
	BL ARM_TIM_config_ASM 
	
	// Setting up input arguments for HEX displays 
	MOV A1, #1 // using only HEX0
	MOV A2, #0 // the values displays from 0-15
	.text // main loop
	loop:
		CMP A2, #16
		MOVEQ A2, #0
		PUSH {A1}
		BL ARM_TIM_read_INT_ASM
		CMP A1, #1 // checking F-bit to know whether the timer period has expired (reached 0)
		ADDEQ A2, #1
		BLEQ ARM_TIM_clear_INT_ASM
		POP {A1}
		BL HEX_write_ASM
		BL write_LEDs_ASM
		B loop
	

.text // Cortex-A9 private timer subroutines
/*
The subroutine is used to configure the timer. 
Argument A1 is used to pass the initial count value.
Argument A2 is used to pass the configuration bits stored in control register.
*/
ARM_TIM_config_ASM: 
	PUSH {V1}
	LDR V1, =TIMER_MEMORY
	STR A1, [V1] // storing the initial count value in timer load register
	STR A2, [V1, #8] // storing config bits in control register
	POP {V1}
	BX LR
	
/*
The subroutine returns the “F” value (0x00000000 or 0x00000001)
from the ARM A9 private timer Interrupt status register.
*/
ARM_TIM_read_INT_ASM: 
	PUSH {V1}
	LDR V1, =TIMER_MEMORY
	LDR A1, [V1, #12]
	AND A1, A1, #1 // only considering the 1st bit in the register
	POP {V1}
	BX LR
/*
The subroutine clears the “F” value in the ARM A9 private 
timer Interrupt status register. The F bit is cleared to 
0 by writing a 0x00000001 into the Interrupt status register.
*/
ARM_TIM_clear_INT_ASM: 
	PUSH {V1}
	LDR V1, =TIMER_MEMORY
	LDR A1, [V1, #12]
	AND A1, A1, #1
	STR A1, [V1, #12]
	POP {V1}
	BX LR
	
.text // HEX display subroutine
/*
Receives the HEX displays indices in register R0 and an integer value 
between 0-15 in register R1 arguments. Based on the value in R1,
the subroutine displays the corresponding hexadecimal digit 
(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, F) on the seven-segment 
display.
*/
HEX_write_ASM:
	LDR A3, =HEX0_3_MEMORY // storing the HEX displays register memory location
	AND A1, #63 // only considering the first 6 bits since only 6 HEX displays
	PUSH {V1, V2} // callee-save convention
	
	MOV V1, #0b00000001 // starting with HEX0
	MOV V2, #0 // i counter and HEX display index (0, 1, 2, 3)
	MOV A4, #0 // HEX segments bits
	
	loop_update_HEX_0_3:
		CMP V2, #4 // test if first loop iteration has finished
		ADDEQ V2, V2, #1 // i++
		BEQ initialize_values // test if HEX0-HEX3 displays have been set				
		TST A1, V1
		LSLEQ V1, #1
		ADDEQ V2, V2, #1 // i++
		BEQ loop_update_HEX_0_3
		PUSH {LR}
		BL write_HEX_value
		POP {LR}
		STRB A4, [A3, V2]
		LSL V1, #1
		ADD V2, V2, #1 // i++
		B loop_update_HEX_0_3
	
	initialize_values:
		LDR A3, =HEX4_5_MEMORY
		MOV V2, #0
		
	loop_update_HEX_4_5:
		CMP V2, #2 // test if first loop iteration has finished
		ADDEQ V2, V2, #1 // i++
		POPEQ {V1, V2} // callee-save convention
		BXEQ LR // test if HEX0-HEX3 displays have been set				
		TST A1, V1
		LSLEQ V1, #1
		ADDEQ V2, V2, #1 // i++
		BEQ loop_update_HEX_4_5
		PUSH {LR}
		BL write_HEX_value
		POP {LR}
		STRB A4, [A3, V2]
		LSL V1, #1
		ADD V2, V2, #1 // i++
		B loop_update_HEX_4_5
	
	write_HEX_value:
		CMP A2, #0
		MOVEQ A4, #0b00111111
		BXEQ LR
		CMP A2, #1
		MOVEQ A4, #0b000000110
		BXEQ LR
		CMP A2, #2
		MOVEQ A4, #0b01011011
		BXEQ LR
		CMP A2, #3
		MOVEQ A4, #0b01001111
		BXEQ LR
		CMP A2, #4
		MOVEQ A4, #0b01100110
		BXEQ LR
		CMP A2, #5
		MOVEQ A4, #0b01101101
		BXEQ LR
		CMP A2, #6
		MOVEQ A4, #0b01111101
		BXEQ LR
		CMP A2, #7
		MOVEQ A4, #0b00000111
		BXEQ LR
		CMP A2, #8
		MOVEQ A4, #0b01111111
		BXEQ LR
		CMP A2, #9
		MOVEQ A4, #0b01100111
		BXEQ LR
		CMP A2, #10
		MOVEQ A4, #0b01110111
		BXEQ LR
		CMP A2, #11
		MOVEQ A4, #0b01111100
		BXEQ LR
		CMP A2, #12
		MOVEQ A4, #0b00111001
		BXEQ LR
		CMP A2, #13
		MOVEQ A4, #0b01011110
		BXEQ LR
		CMP A2, #14
		MOVEQ A4, #0b01111001
		BXEQ LR
		CMP A2, #15
		MOVEQ A4, #0b01110001
		BXEQ LR

.text // LED subroutine
/*
Writes the state of the LEDs (On/Off state) in R0 to the LEDs memory location.
*/	
write_LEDs_ASM:
	PUSH {V1}
	LDR V1, =LED_MEMORY // reads value from memory location
	STR A2, [V1] // stores R0 data into I/O register 
	POP {V1}
	BX LR
	
.end
