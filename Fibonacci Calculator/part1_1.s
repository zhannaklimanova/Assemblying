.global _start

/*
What to note about this calculator is it does not calculate values above
n >= 47. In order to store values 47 and above, the simulator would need to 
be 64 bit.
*/
_start:

	// Variable initialization
	MOV R0, #0 // f[0] = 0 -> f[i-2]
	MOV R1, #1 // f[1] = 1 -> f[i-1]
	MOV R2, #0 // f[i] = RESULT
	MOV R3, #2 // i = 2
	MOV R4, #10 // n 

	B base_case_1
	
base_case_1:
	CMP R4, #0 
	BGT base_case_2
	
	B STOP
	
	
base_case_2:
	CMP R4, #1
	BGT Fib
	
	MOV R2, #1
	B STOP
	
// Iterative algorithm of the Fibonacci number generator 
Fib:
	CMP R3, R4 
	BGT STOP
	
	ADD R2, R1, R0 // f[i] = f[i-1] + f[i-2]
	MOV R0, R1
	MOV R1, R2	
	ADD R3, R3, #1 // i++
	B Fib

	
STOP:
	B STOP

