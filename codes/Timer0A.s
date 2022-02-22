;***************************************************************
; Timer0A for Step Motor
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
GPIO_PORTB_DATA 	EQU	 	0x400053FC 
GPIO_PORTB_DATA_IN	EQU 	0x4000503C 
GPIO_PORTB_DATA_OUT EQU 	0x400053C0 
	
; Nested Vector Interrupt Controller registers
NVIC_EN0_INT19 		EQU 	0x00080000 ; Interrupt 19 enable
NVIC_EN0 			EQU 	0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI4 			EQU 	0xE000E410 ; IRQ 16 to 19 Priority Register

; 16/32 Timer Registers
TIMER0_CFG 			EQU 	0x40030000
TIMER0_TAMR 		EQU 	0x40030004
TIMER0_CTL 			EQU 	0x4003000C
TIMER0_IMR 			EQU 	0x40030018
TIMER0_RIS 			EQU	 	0x4003001C ; Timer Interrupt Status
TIMER0_ICR 			EQU 	0x40030024 ; Timer Interrupt Clear
TIMER0_TAILR 		EQU 	0x40030028 ; Timer interval
TIMER0_TAPR 		EQU 	0x40030038
TIMER0_TAR 			EQU 	0x40030048 ; Timer register
SYSCTL_RCGCTIMER 	EQU 	0x400FE604 ; GPTM Gate Control
	
RELOAD_VALUE 		EQU 	0x000007D0		;starts from 2k
	
; direction_address
dir_addr		EQU		0x20000100	
;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA 		routines, CODE, READONLY
				THUMB
					
				EXTERN		DELAY100
				EXPORT 		Timer0A_Init
				EXPORT 		My_Timer0A_Handler
;*****************************************************************
Timer0A_Init	PROC
				LDR	R1,=SYSCTL_RCGCTIMER ; Start Timer0
				LDR	R2,[R1]
				ORR	R2,R2,#0x01
				STR	R2,[R1]
				
				NOP ; allow clock to settle
				NOP
				NOP
				
				LDR R1,=TIMER0_CTL ; disable timer during setup 
				BIC R2,R2,#0x01
				STR R2,[R1]
				
				LDR R1,=TIMER0_CFG ; set 16 bit mode
				MOV R2,#0x04
				STR R2,[R1]
				
				LDR R1,=TIMER0_TAMR
				MOV R2,#0x02 ; set to periodic, count down 
				STR	R2,[R1]
				
				LDR R1,=TIMER0_TAILR ; initialize match clocks
				MOV R2,R5
				STR R2,[R1]
				
				LDR R1,=TIMER0_TAPR
				MOV R2,#0x15 ; divide clock by 16 to
				STR R2,[R1] ; get 1us clocks
				
				LDR R1,=TIMER0_IMR ; enable timeout interrupt
				MOV R2,#0x01
				STR R2,[R1]

				LDR R1,=NVIC_PRI4
				LDR R2,[R1]
				AND R2,R2,#0x00FFFFFF ; clear interrupt19 priority
				ORR R2,R2,#0x40000000 ; set interrupt 19 priority to 2
				STR R2,[R1]

				LDR R1,=NVIC_EN0
				MOVT R2,#0x08 ; set bit 19 to enable interrupt 19
				STR R2,[R1]
			; Enable timer
				LDR R1,=TIMER0_CTL
				LDR R2,[R1]
				ORR R2,R2 , #0x03 ; set bit 0 to enable
				STR R2,[R1] ; and bit 1 to stall on debug
				BX LR 

;*****************************************************************
My_Timer0A_Handler 	PROC
				PUSH{R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}

				LDR R1,=dir_addr
				LDR	R0,[R1]
				CMP R0,#0			
				BEQ clockwise		
				BNE	counter_cw		
								
					
clockwise		LDR R1,=GPIO_PORTB_DATA_OUT
				LDR R9,[R1]			
				CMP R9,#0x80		
				BNE jump_c
				MOV R9,#0x10	
					
jump_c			BEQ immediate_cw_s  
				LSL R9,#1	
					
immediate_cw_s	STR R9,[R1]
				B	quit				
					
counter_cw			
				LDR R1,=GPIO_PORTB_DATA_OUT
				LDR R9,[R1]			
				CMP R9,#0x10		
				BNE jump_ccw
				MOV R9,#0x80		
jump_ccw		BEQ immediate_ccw_s
					
				LSR R9,#1			
immediate_ccw_s	STR R9,[R1]
				
quit			LDR R1,=TIMER0_ICR
				LDR	R0,[R1]
				ORR R0,#0x1
				STR R0,[R1]
					
				POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}			

			BX LR 
			ENDP
			END