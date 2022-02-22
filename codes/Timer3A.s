;***************************************************************
; Timer3A for Current Display
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
GPIO_PORTF_DATA 	EQU 	0x400253FC 	

; Nested Vector Interrupt Controller registers
NVIC_EN0_INT19 		EQU 	0x00080000 ; Interrupt 19 enable
NVIC_EN1 			EQU 	0xE000E104 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI8 			EQU 	0xE000E420 ; IRQ 16 to 19 Priority Register

; 16/32 Timer Registers
TIMER3_CFG 			EQU 	0x40033000
TIMER3_TAMR 		EQU 	0x40033004
TIMER3_CTL 			EQU 	0x4003300C
TIMER3_IMR 			EQU 	0x40033018
TIMER3_RIS 			EQU	 	0x4003301C ; Timer Interrupt Status
TIMER3_ICR 			EQU 	0x40033024 ; Timer Interrupt Clear
TIMER3_TAILR 		EQU 	0x40033028 ; Timer interval
TIMER3_TAPR 		EQU 	0x40033038
TIMER3_TAR 			EQU 	0x40033048 ; Timer register,
TIMER3_TAMATCHR  	EQU		0x40033030  
SYSCTL_RCGCTIMER 	EQU 	0x400FE604 ; GPTM Gate Control
	
RELOAD_VALUE 		EQU 	0x000007D0		;starts from 2k
	
new_curr_freq		EQU		0x20000200		; location of the new calculated frequency
new_curr_mag		EQU		0x20000204		; location of the new calculated frequency		
; direction_address
dir_addr		EQU		0x20000100	
;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA 		routines, CODE, READONLY
				THUMB
					
				EXTERN		DELAY100
				EXPORT 		Timer3A_Init
				EXPORT 		My_Timer3A_Handler
				EXTERN		current_display
;*****************************************************************
Timer3A_Init	PROC
	
			; Start Timer3	
				LDR	R1,=SYSCTL_RCGCTIMER ; Start Timer3
				LDR	R2,[R1]
				ORR	R2,R2,#0x08
				STR	R2,[R1]
				
			; wait for stabilization
				NOP
				NOP
				NOP
			 ;disable timer
				LDR R1,=TIMER3_CTL
				LDR R0,[R1]
				BIC R0,#0x01
				STR R0,[R1]
			;select16 bit timer
				LDR R1,=TIMER3_CFG
				MOV R0,#0x04 ;16 bit mode
				STR R0,[R1]

				LDR R1,=TIMER3_TAMR
				MOV R0,#0x02 ; set to periodic, count down 
				STR R0,[R1]
  
				LDR R1,=TIMER3_TAILR ; load value, 
				LDR R0,=62500   ;62500 * 256 = 16M, get every one second
				STR R0,[R1];
				
				LDR R1,=TIMER3_TAPR
				MOV R0,#0xff    ;prescaler 256, get 15us count interval 
				STR R0,[R1]
				
				LDR R1,=TIMER3_TAMATCHR
				MOV R0,#0
				STR R0,[R1]

				LDR R1,=TIMER3_IMR ; enable timeout interrupt
				MOV R0,#0x01
				STR R0,[R1]
				  
			;;;;;CONFIG NVIC TIMER3A INTTERYPT 23
				LDR R1,=NVIC_PRI8
				LDR R0,[R1]
				LDR R3,=0x30000000 ;priorty 3
				ORR R0,R3
				STR R0,[R1]
				
				LDR R1,=NVIC_EN1
				LDR R0,[R1]
				LDR R3,=0x00000008 ;3th bit 1
				ORR R0,R3
				STR R0,[R1]
				
			;enable
				LDR R1,=TIMER3_CTL
				LDR R0,[R1]
				ORR R0,#0x001
				STR R0,[R1]
				
				BX	LR
	

;*****************************************************************
My_Timer3A_Handler 	PROC
				PUSH{R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}
				
				LDR R2,=new_curr_freq
				LDR	R7,[R2]
				LDR R2,=new_curr_mag
				LDR	R8,[R2]
				
				BL  current_display
				
				LDR R1,=TIMER3_ICR
				LDR	R0,[R1]
				ORR R0,#0x1
				STR R0,[R1]
				
				POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}			

			BX LR 
			ENDP
			END