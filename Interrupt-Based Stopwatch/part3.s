.equ PB_INTERRUPTMASK_MEMORY, 0xFF200058 // Push buttons interrupt mask register in memory
.equ LED_MEMORY, 0xFF200000 // LED data registers in memory
.equ HEX0_3_MEMORY, 0xFF200020 // Seven-segment data register in memory
.equ HEX4_5_MEMORY, 0xFF200030 // Seven-segment data register in memory
.equ PB_DATA_MEMORY, 0xFF200050 // Push button data register in memory
.equ PB_EDGECAPTURE_MEMORY, 0xFF20005C // Push buttons edgecapture register in memory
.equ TIMER_MEMORY, 0xFFFEC600 // Cortex-A9 private timer registers in memory

PB_int_flag: .word 0x0
tim_int_flag: .word 0x0

.section .vectors, "ax" // Initializes exception vector table. 
B _start
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0 // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

.text // program
.global _start
_start:

.text
.global _start // Configures interrupt routine.

_start:
    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV        R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR        CPSR_c, R1           // change to IRQ mode
    LDR        SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV        R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR        CPSR, R1             // change to supervisor mode
    LDR        SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL     CONFIG_GIC           // configure the ARM GIC
    // To DO: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
    // to enable interrupt for ARM A9 private timer, use ARM_TIM_config_ASM subroutine

	
	
    LDR        R0, =0xFF200050      // pushbutton KEY base address
    MOV        R1, #0xF             // set interrupt mask bits
    STR        R1, [R0, #0x8]       // interrupt mask register (base + 8)
	
	LDR A1, =#2000000 // Initial count value of 1 second
	MOV A2, #6 // bit I = 1 sets turns on timer interrupts; E = 1 starts timer; bit A = 1 loops timer
	BL ARM_TIM_config_ASM
    // enable IRQ interrupts in the processor
    MOV        R0, #0b01010011      // IRQ unmasked, MODE = SVC
    MSR        CPSR_c, R0

	
IDLE:
	// Initializing all HEX display registers
	MOV V1, #0
	MOV V2, #0
	MOV V3, #0
	MOV V4, #0
	MOV V5, #0
	MOV V6, #0
	// Setting up input arguments for HEX displays 
//	MOV A1, #1 // using only HEX0
	MOV A2, #0 // the values displays from 0-15
	
		loop:
			// Testing pushbuttons		
			PUSH {A1, A2, V1, V2, V7, LR}
			//BL read_PB_edgecp_ASM // returns value into A1
			LDR A1, PB_int_flag // reading pushbutton flag which will have edge cap value
			MOV V7, A1 // useful for RESET
			
			PUSH {A1, A2, V1, V7}
			AND A2, V7, #1 // Testing only for RESET
			CMP A2, #1
			MOVEQ A1, #63
			MOVEQ A2, #0 // Putting all HEX values to 0
			BLEQ HEX_write_ASM
			BLEQ PB_clear_edgecp_ASM
			POPEQ {A1, A2, V1, V7}
			POPEQ {A1, A2, V1, V2, V7, LR}
			BEQ IDLE
			PUSHEQ {A1, A2, A3, A4, V1, V2, V3, V4, V5, V6, LR} // can delete
			POPEQ {A1, A2, A3, A4, V1, V2, V3, V4, V5, V6, LR} // can delete
			POP {A1, A2, V1, V7}
			

			PUSH {A1, A2, V1, V7, LR}
			AND A2, A1, #4 // Testing only for START
			CMP A2, #4
			MOVEQ V7, #7 // Setting bit E to 1; starting timer (bit A was already set)
			LDREQ V1, =TIMER_MEMORY
			STREQ V7, [V1, #8] // storing config bit E in timer control register
			POP {A1, A2, V1, V7, LR}

			PUSH {A1, A2, V1, V7, LR}
			AND A2, A1, #2 // Testing only for STOP
			CMP A2, #2
			MOVEQ V7, #6 // Setting bit E to 0; stoping timer
			LDREQ V1, =TIMER_MEMORY
			STREQ V7, [V1, #8] // storing config bits in control register
			POP {A1, A2, V1, V7, LR}

			//BL PB_clear_edgecp_ASM // Can be removed, not needed for interrupts
			POP {A1, A2, V1, V2, V7, LR}


			LDR A1, tim_int_flag
			CMP A1, #1 // checking F-bit stored in tim_int_flag to know whether the timer period has reached 0
			ADDEQ V1, #1
			PUSH {A1, A2, V1, V2, V3, V4, V5, V6}
			MOV A1, #1 // one-hot encoding of HEX0
			MOV A2, V1
			BL HEX_write_ASM
			POP {A1, A2, V1, V2, V3, V4, V5, V6}		
			MOV A3, #0
			LDR A1, =tim_int_flag
			STR A3, [A1] // clearing the tim_int_flag

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
	
.text // Exception service routines	
/*--- Undefined instructions ---------------------------------------- */
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ------------------------------------------- */
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads -------------------------------------------- */
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch ------------------------------------- */
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ----------------------------------------------------------- */
SERVICE_IRQ:
    PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR

/* To Do: Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED
   See the assembly example provided in the De1-SoC Computer_Manual on page 46 */
Pushbutton_check:   
    CMP R5, #73 // pushbutton check
	Bne Timer_check 
	BLeq KEY_ISR
	B EXIT_IRQ
Timer_check:
	CMP R5, #29 // timer check
	BNE UNEXPECTED
	BLEQ ARM_TIM_ISR
	B EXIT_IRQ
UNEXPECTED:
    BNE UNEXPECTED      // if not recognized, stop here
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ----------------------------------------------------------- */
SERVICE_FIQ:
    B SERVICE_FIQ
	
.text // Configure generic interrupt controller (GIC)
CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
    MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT

	MOV R0, #29           // KEY port (Interrupt ID = 29)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
	
/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}

.text // Using interrupt service routines (ISR) which checks which key was pressed
KEY_ISR:
    LDR R0, =0xFF200050    // base address of pushbutton KEY port
    LDR R1, [R0, #0xC]     // read edge capture register
    MOV R2, #0xF
	LDR R3, =PB_int_flag
	STR R1, [R3] // writing contents of pushbutton into PB_int_flag 
    STR R2, [R0, #0xC]     // clear the interrupt
	BX LR


.text // Using interrupt service routines (ISR) which checks if timer was enabled
ARM_TIM_ISR:
 	LDR R0, =TIMER_MEMORY
	LDR R2, =tim_int_flag
	MOV R3, #1
	STR R3, [R2] // setting tim_int_flag to 1
	STR R3, [R0, #12] // clearing F bit
	BX LR
	

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
