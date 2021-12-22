.data
.equ LED_MEMORY, 0xFF200000 // LED data registers in memory
.equ HEX0_3_MEMORY, 0xFF200020 // Seven-segment data register in memory
.equ HEX4_5_MEMORY, 0xFF200030 // Seven-segment data register in memory
.equ SW_MEMORY, 0xFF200040 // Switches data registers in memory
.equ PB_DATA_MEMORY, 0xFF200050 // Push button data register in memory
.equ PB_INTERRUPTMASK_MEMORY, 0xFF200058 // Push buttons interrupt mask register in memory
.equ PB_EDGECAPTURE_MEMORY, 0xFF20005C // Push buttons edgecapture register in memory


.text // program
.global _start
_start:
	// Setting up the input arguments
	//MOV A1, #6 // input HEX displays indices (one-hot encoding)
	//MOV A2, #1 //test
	/*
	LDR V7, =HEX0_3_MEMORY// test
	STRB A2, [V7, #0]
	STRB A2, [V7, #1]
	STRB A2, [V7, #2]
	STRB A2, [V7, #13]
	LDR V7, =HEX4_5_MEMORY
	STRB A2, [V7, #0]
	STRB A2, [V7, #1]
	*/
	.text // main loop
	loop:
		//BL HEX_clear_ASM
		//BL HEX_flood_ASM
		//BL HEX_write_ASM
		//BL read_PB_data_ASM
		//BL read_PB_edgecp_ASM
		//BL PB_clear_edgecp_ASM
		//BL enable_PB_INT_ASM
		//BL disable_PB_INT_ASM
		BL read_slider_switches_ASM
		TST A2, #0b1000000000 // testing if switch 9 has been pressed
		BEQ on
		B off
		on:
			PUSH {A1, A2}
			MOV A1, #48 // turning on HEX4-HEX5 
			MOV A2, #8 // turning on HEX4-HEX5 with value 8
			BL HEX_flood_ASM
			POP {A1, A2}
			BL read_slider_switches_ASM
			BL write_LEDs_ASM
			BL read_PB_data_ASM
			BL read_PB_edgecp_ASM
			BL PB_clear_edgecp_ASM		
			BL HEX_write_ASM
			B loop
		off:
			PUSH {A1}
			MOV A1, #63 // turning on HEX4-HEX5 
			BL HEX_clear_ASM
			POP {A1}
		B loop
		
.text // HEX display subroutines
/*
Turns off all segments of the HEX displays passed in the argument.
It receives the HEX displays indices through the R0 register as an 
argument.
*/
HEX_clear_ASM:
	LDR A3, =HEX0_3_MEMORY // storing the HEX displays register memory location
	MOV A4, #0 // storing 0 in HEX displays registers will clear them
	
	PUSH {V1, V2, V3, V4, V5, V6} // callee-save convention
	AND A1, #63 // only considering the first 6 bits since only 6 HEX displays
	
	// Testing which registers need to be cleared
	AND V1, A1, #0b00000001
	CMP V1, #0
	BGT flooding_HEX0
	B next1
	flooding_HEX0:
		STRB A4, [A3, #0] // clearing HEX0
	
	next1:
	AND V2, A1, #0b00000010
	CMP V2, #0
	BGT flooding_HEX1
	B next2
	flooding_HEX1:
		STRB A4, [A3, #1] // clearing HEX1
		
	next2:
	AND V3, A1, #0b00000100
	CMP V3, #0
	BGT flooding_HEX2
	B next3
	flooding_HEX2:
		STRB A4, [A3, #2] // clearing HEX2
	
	next3:
	AND V4, A1, #0b00001000
	CMP V4, #0
	BGT flooding_HEX3
	B next4
	flooding_HEX3:
		STRB A4, [A3, #3] // clearing HEX3
	
	next4:
	LDR A3, =HEX4_5_MEMORY // storing the HEX displays register memory location
	
	AND V5, A1, #0b00010000
	CMP V5, #0
	BGT flooding_HEX4
	B next5
	flooding_HEX4:
		STRB A4, [A3, #0] // clearing HEX4
	
	next5:
	AND V6, A1, #0b00100000 
	CMP V6, #0
	BGT flooding_HEX5
	B next6
	flooding_HEX5:
		STRB A4, [A3, #1] // clearing HEX5
	
	next6:
	POP {V1, V2, V3, V4, V5, V6} // callee-save convention
	BX LR
	
/*
Turns on all segments of the HEX displays passed in the argument. 
It receives the HEX displays indices through R0 register as an
argument.
*/
HEX_flood_ASM:
	LDR A3, =HEX0_3_MEMORY // storing the HEX displays register memory location
	MOV A4, #0b1111111 // storing 0 in HEX displays registers will clear them
	
	PUSH {V1, V2, V3, V4, V5, V6} // callee-save convention
	AND A1, #63 // only considering the first 6 bits since only 6 HEX displays
	
	// Testing which registers need to be cleared
	AND V1, A1, #0b00000001
	CMP V1, #0
	BGT clearing_HEX0
	B continue1
	clearing_HEX0:
		STRB A4, [A3, #0] // clearing HEX0
	
	continue1:
	AND V2, A1, #0b00000010
	CMP V2, #0
	BGT clearing_HEX1
	B continue2
	clearing_HEX1:
		STRB A4, [A3, #1] // clearing HEX1
		
	continue2:
	AND V3, A1, #0b00000100
	CMP V3, #0
	BGT clearing_HEX2
	B continue3
	clearing_HEX2:
		STRB A4, [A3, #2] // clearing HEX2
	
	continue3:
	AND V4, A1, #0b00001000
	CMP V4, #0
	BGT clearing_HEX3
	B continue4
	clearing_HEX3:
		STRB A4, [A3, #3] // clearing HEX3
	
	continue4:
	LDR A3, =HEX4_5_MEMORY // storing the HEX displays register memory location
	
	AND V5, A1, #0b00010000
	CMP V5, #0
	BGT clearing_HEX4
	B continue5
	clearing_HEX4:
		STRB A4, [A3, #0] // clearing HEX4
	
	continue5:
	AND V6, A1, #0b00100000 
	CMP V6, #0
	BGT clearing_HEX5
	B continue6
	clearing_HEX5:
		STRB A4, [A3, #1] // clearing HEX5
	
	continue6:
	POP {V1, V2, V3, V4, V5, V6} // callee-save convention
	BX LR

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
		
/*
The subroutine receives pushbuttons indices as an argument.
Then, it enables the interrupt function for the corresponding pushbuttons 
by setting the interrupt mask bits to '1'.
*/
enable_PB_INT_ASM:
	PUSH {V1}
	LDR V1, =PB_INTERRUPTMASK_MEMORY // get the push buttons interrupt-mask register contents
	AND A1, A1, #15 // only considering the first 4 bits since only 4 push buttons
	STR A1, [V1] // subroutine receives pushbutton indices as an argument R0 (1, 2, 4, 8)
	POP {V1}
	BX LR
	
/*
The subroutine receives pushbuttons indices as an argument. 
Then, it disables the interrupt function for the corresponding pushbuttons 
by setting the interrupt mask bits to '0'.
*/
disable_PB_INT_ASM:
	PUSH {V1, V2, V3}
	LDR V1, =PB_INTERRUPTMASK_MEMORY // get the push buttons interrupt-mask register contents
	LDR V3, [V1] // what is already in the interrupt-mask register
	MVN V2, A1 // moving the opposite of the push button index bits
	AND V3, V3, V2 // setting the selected interrupt mask bits to 0
	STR V3, [V1] // storing the interrupt mask bits in push button register
	POP {V1, V2, V3}
	BX LR
	
.text // Slider switches subroutine
/*
Reads the state of the slider switches (On/Off state) into the R0 register.
*/
read_slider_switches_ASM:
	PUSH {V1}
	LDR V1, =SW_MEMORY // reads value from memory location
	LDR A2, [V1] // passes back I/O register data in register R0 // really its R1, because that's the value we're reading. But it should be A1.
	POP {V1}
	BX LR

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
