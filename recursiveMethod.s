; define constants
W_Capacity 	EQU 50        ; const W_Capacity = 50
SIZE 		EQU 4         ; const SIZE = 4

		AREA recursiveMethod, CODE, READONLY ; Defines a code area called recursiveMethod, marked as read-only
		ENTRY ; entry point of the program
		THUMB ; indicates that the code will execute in thumb mode
		ALIGN ; aligns the memory 
__main 	FUNCTION ; beginning of the main function
		EXPORT __main ; exports main function
		
		LDR r1, =profit ;store start address of profit array in r1
		LDR r2, =weight ;store start address of weight array in r2
		LDR r5, =W_Capacity ;save capacity value in r5 to give as parameter in knapSack function
		LDR r6, =SIZE ;save size value in r6 to give as parameter in knapSack function 
		BL knapSack ;branch to knapSack function and save pc to link register
		
while    ;while(1)
		B while ; infinite while loop
	
		ENDFUNC  ; end of main function
		
max		PROC ;r3= a, r4=b
		CMP r4, r3 ;compare a(r3) and b(r4)
		BLE retA ;if b is less or equal, jump retA
		MOV r0, r4 ;save b in r0 
		BX lr ;return to where process was called
retA
		MOV r0, r3 ;save a in r0
		BX lr ;return to where process was called
		ENDP ; end of max function
			
knapSack  PROC; r5=W , r6=n
		PUSH {lr} ;Save return address
		PUSH {r3,r4,r5,r6, r7} ;push register values into stack
	
		CMP r5, #0  ;(W==0) 
		BEQ return_0 ; return 0 
		CMP r6, #0  ;(n==0)
		BEQ return_0 ; return 0
		
		SUBS r6, #1 ; n = n-1
		MOV r7, r6 ; r7 = n-1
		LSLS r7, #2 ; r7 = (n-1)*4
		LDR r7, [r2, r7] ; r7 = weight[n-1]
		CMP r7, r5 ;compare weight[n-1] and w
		BLE else ; if weight[n-1] <= w, jump to else
		BL knapSack ;knapSack(w, n-1)
		B return ; jump return

else ; label for else
		BL knapSack ; knapSack(W, n-1)
		MOV r3 , r0 ;save return value of knapSack in r3 to give as a parameter to max (a)
		SUBS r5, r7 ; W = W - weight[n-1]
		BL knapSack ;knapSack(W -weight[n-1] , n-1)
		
		MOV r7, r6 ; r7 = n-1
		LSLS r7, #2 ; r7 = (n-1)*4
		LDR r7, [r1, r7] ; r7 = profit[n-1]
 		ADD r7, r0 ; r7 = profit[n-1] + knapSack()
		MOV r4, r7 ;store the sum value in r4 to give as a parameter in max function (b)
		BL max ; max(knapSack(W, n-1), profit[n-1] + knapSack(W - weight[n-1], n-1)) 
		B return ; jump return
		
		
return_0 ; label for return 0 
		MOVS r0, #0 ;return 0, write 0 in r0
return ; label for returning 
		pop {r3,r4,r5,r6,r7} ;pop pushed values
		pop {pc} ; return where the knapSack label was called
		ENDP ; end of knapSack
					

profit 		DCD 60, 100, 120   ; profit array
weight 		DCD 10, 20, 30     ; weight array
			END ; end of all