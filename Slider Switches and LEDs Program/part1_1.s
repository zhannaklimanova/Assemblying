.data
.equ LED_MEMORY, 0xFF200000 // LED data registers in memory
.equ SW_MEMORY, 0xFF200040 // Switches data registers in memory

.text
.global _start
_start:
	loop:
		BL read_slider_switches_ASM
		BL write_LEDs_ASM
		B loop

/*
Reads the state of the slider switches (On/Off state) into the R0 register.
*/
read_slider_switches_ASM:
	PUSH {V1}
	LDR V1, =SW_MEMORY // reads value from memory location
	LDR A1, [V1] // passes back I/O register data in register R0
	POP {V1}
	BX LR

/*
Writes the state of the LEDs (On/Off state) in R0 to the LEDs memory location.
*/	
write_LEDs_ASM:
	PUSH {V1}
	LDR V1, =LED_MEMORY // reads value from memory location
	STR A1, [V1] // stores R0 data into I/O register 
	POP {V1}
	BX LR
	
.end 
