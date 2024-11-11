; define constants
W_Capacity 	EQU 50        ; const W_Capacity = 50
SIZE 		EQU 4         ; const SIZE = 4

; allocate space for dp array
			AREA dpArr, DATA, READWRITE ; Defines a read-write area for dp array
			ALIGN ; aligns the memory
			 
dp_array	SPACE W_Capacity * 4 ; dp_array has W_Capacity number of elements, each having size 4 bytes
dp_end


		AREA iterativeMethod, CODE, READONLY ; Defines a code area called iterativeMethod, marked as read-only
		ENTRY ; entry point of the program
		THUMB ; indicates that the code will execute in thumb mode
		ALIGN ; aligns the memory
__main 	FUNCTION ; beginning the main function			
		EXPORT __main ; exports main function				 
		
		LDR r1, =W_Capacity ;load content of the label W_Capacity in r1
		LDR r2, =SIZE ;load content of the label SIZE in r2
		BL knapSack ; Branch to knapSack label and save pc in lr

while   ; while(1)
	    B while 		; infinite while loop
		ENDFUNC ; end of main function
		
max		PROC ; r1 = a, r2=b
		CMP r1, r2 ; a > b ?
		BGT retA ; if a > b, branch to label retA
		MOV r0, r2 ; if b>= a , move r2 into r0 (r0 is the return register)
		MOV pc, lr ; return r0 as b 
retA	
		MOV r0, r1 ; if b < a , move r1 into r0 (r0 is the return register)
		MOV pc, lr ; return r0 as a
		ENDP ; end of max function

knapSack 	PROC ; r1=W, r2=n
			PUSH {lr} ; push link register value into stack 
			PUSH {r3, r4, r5, r6, r7} ; push registers into stack
		
			MOVS r3, #0 ; r3 = 0 -> will be used to track i
			ADDS r2, #1 ; r2 = n + 1
			
for_i	; r3 = i
			MOV r4, r1 ; at each for loop, reset w to W_capacity
			ADDS r3, #1 ; r3 = i + 1
		    CMP r3, r2  ; i < n + 1 ?
			BGE ret_dpW  ; if i >= n + 1, branch to ret_dpW
			B for_w ; if i < n + 1, continue with for_w
			
for_w_min1  SUBS r4, #1 ; decrement w
for_w   ; r4 = w
			CMP r4, #0 ; w >= 0 ?
			BLT for_i  ; if w < 0, jump to for_i
			
			; inside of for_w
			LDR r5, =weight ; load start address of weight array in r5 
			MOV r6, r3 ; move content of the r3 (i) to r6
			SUBS r6, #1 ; r6 = i - 1
			LSLS r6, #2 ; r6 = 4*(i - 1) -> addr of i-1
			LDR r5, [r5, r6] ; r5 = weight[i - 1]
			CMP r5, r4  ; weight[i-1] <= w ?
			BGT for_w_min1 ; if weight[i-1] > w, continue with decrementing w without entering the if condition
			; inside of if
			MOV r7, r4 ; r7 = w 
			SUBS r7, r5 ; r7 = w - weight[i - 1]
			LDR r5, =profit ; load start address of profit array in r5
			LDR r5, [r5, r6] ; r5 = profit[i - 1] 
			LDR r6, =dp_array ; load start address of dp_array in r6
			LSLS r7, #2 ; 4*(w - weight[i - 1]) addr of w - weight[i - 1]
			LDR r7, [r6, r7] ; r7 = dp[ w - weight[i - 1]]
			ADDS r7, r5 ; r7 = dp[ w - weight[i - 1]] + profit[i - 1]
			
			PUSH {r2} ; push r2 into stack to use n + 1 value later
			MOVS r2, r7 ; b parameter of max
			
			MOVS r7, r4 ; r7 = w
			LSLS r7, #2 ; r7 = 4*w -> addr of w
			PUSH {r1} ; push r1 into stack to use W value later
			LDR r1, [r6, r7] ; r1 = dp[w]
			BL max ; max(dp[w], dp[ w - weight[i - 1]] + profit[i - 1])
			POP {r1} ; r1 = W
			POP {r2} ; r2 = n + 1
			
			MOVS r7, r4  ;r7 = w
			LSLS r7, #2 ; r7 = w*4 -> addr of w 
			STR r0, [r6, r7] ; dp[w] = max(dp[w], dp[ w - weight[i - 1]] + profit[i - 1])
			B for_w_min1 ; after if condition, continue with decrementing w value 
			
			
ret_dpW		; label for return dp[W]
			LDR r3, =dp_array ; load start address of dp array in r3
			LSLS r1, #2 ; r1 = 4 * w -> addr of w
			LDR r0, [r3, r1]  ; value variable from main func
			LDR r1, =profit ;starting addr of profit array
			LDR r2, =weight ;starting addr of weight array
			
			POP {r3, r4, r5, r6, r7}	; pop pushed registers
			LDR r3, =dp_array ;starting addr of dp array
			POP  {pc} ; return to the line where knapSack was called
			ENDP ; end of knapSack


; array declarations
profit 		DCD 60,100,120 ; defines the array for profit values
profit_end ; label for end of profit data

weight 		DCD 10,20,30 ; defines the array for weight values
weight_end ; label for end of weight data
	

			END ; end of all