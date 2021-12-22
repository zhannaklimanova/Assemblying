// Fibonacci algorithm
/*
Where A1 is the argument n (register R0), 
V1 is a variable (register R4), 
V2 is a variable (register R5).
*/
.global _start
_start:
   MOV A1, #5 // input argument n
   
   // Base case when n = 0
   CMP A1, #0 // fib(0) = 0
   BLE base_case_0
   // Base case when n = 1
   CMP A1, #1 // fib(1) = 1
   BLE base_case_1
	
   // Base case when n = 2
   CMP A1, #3 // if (n < 3); base case
   BLT return_1 // return 1 
   BL F // case n > 3
   B STOP // the last 

F:
   PUSH {LR, V1, V2} // before calling the subroutine, LR and other registers need to be saved on stack
   MOV V1, A1 // temporarily store value of R0 in R1; preserves parent node
   CMP A1, #2 // testing for base case when F(n=2)=1 or F(n=1) = 1
   MOV A1, #1 // in case base case is reached 1 is already in place to be tallied up
   BLE backtracking
   SUBS A1, V1, #2 // F(n-2); going down n-2 branch
   
   BL F
   MOV V2, A1 
   SUBS A1, V1, #1 // F(n-1); going down the n-1 branch
   
   BL F
   ADD A1, A1, V2  // adding up all the ones encountered
    
backtracking: // reached base case so now recursive backtracking 
   POP {LR, V1, V2}
   BX LR 
   
return_1:
   MOV A1, #1 // return 1
   B STOP
   
base_case_0: 
	MOV A1, #0 // return 0
	B STOP
	
base_case_1:
	MOV A1, #1 // return 1
	B STOP 
   
STOP:
   B STOP
