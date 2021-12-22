.data
.equ LED_MEMORY, 0xFF200000 // LED data registers in memory
.equ HEX0_3_MEMORY, 0xFF200020 // Seven-segment data register in memory
.equ HEX4_5_MEMORY, 0xFF200030 // Seven-segment data register in memory
.equ PB_DATA_MEMORY, 0xFF200050 // Push button data register in memory
.equ PB_EDGECAPTURE_MEMORY, 0xFF20005C // Push buttons edgecapture register in memory
.equ TIMER_MEMORY, 0xFFFEC600 // Cortex-A9 private timer registers in memory

.text // program
.global _start
_start:
	// Setting up the input arguments
	LDR A1, =#2000000 // Initial count value of 1 second
	MOV A2, #2 // bit E = 1 starts timer; bit A = 1 loops timer
	MOV V1, #0
	MOV V2, #0
	MOV V3, #0
	MOV V4, #0
	MOV V5, #0
	MOV V6, #0
	
	BL ARM_TIM_config_ASM 
	
	// Setting up input arguments for HEX displays 
	MOV A1, #1 // using only HEX0
	MOV A2, #0 // the values displays from 0-15
	.text // main loop
	loop: // WHEN TIMER IS SLOWED DOWN THE HEX0 displays things at weird time intervals (b/c other things stored there)
		// Testing pushbuttons	
		
		PUSH {A1, A2, V1, V2, V7, LR}
		BL read_PB_edgecp_ASM // returns value into A1
		MOV V7, A1
		
		PUSH {A1, A2, V1, V7}
		AND A2, V7, #1 // Testing only for RESET
		CMP A2, #1
		MOVEQ A1, #63
		MOVEQ A2, #0 // Putting all HEX values to 0
		BLEQ HEX_write_ASM
		BLEQ PB_clear_edgecp_ASM
		POPEQ {A1, A2, V1, V7}
		POPEQ {A1, A2, V1, V2, V7, LR}
		BEQ _start
		PUSHEQ {A1, A2, A3, A4, V1, V2, V3, V4, V5, V6, LR}

		POPEQ {A1, A2, A3, A4, V1, V2, V3, V4, V5, V6, LR}
		POP {A1, A2, V1, V7}
		
		PUSH {A1, A2, V1, V7, LR}
		AND A2, A1, #4 // Testing only for START
		CMP A2, #4
		MOVEQ V7, #3 // Setting bits A and E to 1; starting timer
		LDREQ V1, =TIMER_MEMORY
		STREQ V7, [V1, #8] // storing config bits in control register
		POP {A1, A2, V1, V7, LR}
		
		PUSH {A1, A2, V1, V7, LR}
		AND A2, A1, #2 // Testing only for STOP
		CMP A2, #2
		MOVEQ V7, #0 // Setting bit E to 0; stoping timer
		LDREQ V1, =TIMER_MEMORY
		STREQ V7, [V1, #8] // storing config bits in control register
		POP {A1, A2, V1, V7, LR}
		
		BL PB_clear_edgecp_ASM
		POP {A1, A2, V1, V2, V7, LR}
		
		

		BL ARM_TIM_read_INT_ASM
		CMP A1, #1 // checking F-bit to know whether the timer period has expired (reached 0)
		ADDEQ V1, #1
		PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
		MOV A1, #1 // one-hot encoding of HEX0
		MOV A2, V1
		BL HEX_write_ASM
		POP {A1, A2, V1, V2, V3, V4, V5, V6}		
		BLEQ ARM_TIM_clear_INT_ASM
		
		CMP V1, #10 // HEX1 will be updated when HEX0 reaches 9
		ADDEQ V2, #1
		MOVEQ V1, #0
		PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
		MOV A1, #2 // one-hot encoding of HEX1
		MOV A2, V2
		BL HEX_write_ASM
		POP {A1, A2, V1, V2, V3, V4, V5, V6}
		
		
		CMP V2, #10 // HEX2 will be updated when HEX1 reaches 9
		ADDEQ V3, #1
		MOVEQ V2, #0
		PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
		MOV A1, #4 // one-hot encoding of HEX3
		MOV A2, V3
		BL HEX_write_ASM
		POP {A1, A2, V1, V2, V3, V4, V5, V6}
		
		CMP V3, #10 // HEX3 will be updated when HEX2 reaches 9
		ADDEQ V4, #1
		MOVEQ V3, #0
		PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
		MOV A1, #8 // one-hot encoding of HEX4
		MOV A2, V4
		BL HEX_write_ASM
		POP {A1, A2, V1, V2, V3, V4, V5, V6}
		
		CMP V4, #6 // HEX4 will be updated when HEX3 reaches 5
		ADDEQ V5, #1
		MOVEQ V4, #0
		PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
		MOV A1, #16 // one-hot encoding of HEX5
		MOV A2, V5
		BL HEX_write_ASM
		POP {A1, A2, V1, V2, V3, V4, V5, V6}
		
		CMP V5, #10 // HEX5 will be updated when HEX4 reaches 9
		ADDEQ V6, #1
		MOVEQ V5, #0
		PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
		MOV A1, #32 // one-hot encoding of HEX6
		MOV A2, V6
		BL HEX_write_ASM
		POP {A1, A2, V1, V2, V3, V4, V5, V6}
		
		CMP V6, #10 // HEX6 will be updated when HEX4 reaches 9
		MOVEQ V6, #0
		PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
		MOV A1, #32 // one-hot encoding of HEX6
		MOV A2, V6
		BL HEX_write_ASM
		POP {A1, A2, V1, V2, V3, V4, V5, V6}
		
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
	
.text // Pushbutton subroutines
/*
The subroutine returns the indices of the pressed pushbuttons 
(the keys from the pushbuttons Data register). 
*/
read_PB_data_ASM:
	PUSH {V1}
	LDR V1, =PB_DATA_MEMORY
	LDR A1, [V1]// passes back I/O push buttons data in register R0 
	POP {V1}
	BX LR
	
/*
The subroutine returns the indices of the pushbuttons that have 
been pressed and then released (the edge bits form the pushbuttons 
Edgecapture register).  
*/
read_PB_edgecp_ASM: 
	PUSH {V1}
	LDR V1, =PB_EDGECAPTURE_MEMORY
	LDR A1, [V1] // get the push buttons edge capture register contents
	AND A1, A1, #15 // only considering the first 4 bits since only 4 push buttons
	POP {V1}
	BX LR
	

/*
The subroutine clears the pushbuttons Edgecapture register. 
The edgecapture register can be cleared by reading it first and then
writing what was just read back into it.
*/
PB_clear_edgecp_ASM: 
	PUSH {V1, V2}
	LDR V1, =PB_EDGECAPTURE_MEMORY // get the push buttons edge capture register contents
	LDR V2, [V1]
	STR V2, [V1]
	POP {V1, V2}
	BX LR
		
