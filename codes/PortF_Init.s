;***************************************************************
; Switches and LEDs Initialization
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
; Nested Vector Interrupt Controller registers
NVIC_EN0			EQU 	0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI7			EQU 	0xE000E41C ; IRQ 28 to 31 Priority Register
	
; GPIO Registers
GPIO_PORTF_DATA 	EQU 	0x400253FC ;
GPIO_PORTF_DIR 		EQU 	0x40025400 ; Port Direction
GPIO_PORTF_AFSEL 	EQU 	0x40025420 ; Alt Function enable
GPIO_PORTF_DEN 		EQU 	0x4002551C ; Digital Enable
GPIO_PORTF_AMSEL 	EQU 	0x40025528 ; Analog enable
GPIO_PORTF_PCTL 	EQU 	0x4002552C ; Alternate Functions
GPIO_PORTF_LOCK 	EQU 	0x40025520 ; Unlock
GPIO_PORTF_CR 		EQU 	0x40025524 ; Commit
GPIO_PORTF_MIS		EQU 	0x40025418 ; Masked Interrupt Status 
GPIO_PORTF_ICR		EQU 	0x4002541C ; Interrupt Clear 
GPIO_PORTF_IS		EQU 	0x40025404 ; Interrupt Sense Register 
GPIO_PORTF_IBE		EQU 	0x40025408 ; Interrupt Both Edges 
GPIO_PORTF_IEV		EQU 	0x4002540C ; Interrupt Event Register 
GPIO_PORTF_IM		EQU 	0x40025410 ; Interrupt Mask Register 
GPIO_PORTF_PUR		EQU 	0x40025510 ; Pull-up Register

; System Registers
SYSCTL_RCGCGPIO 	EQU 	0x400FE608 ; GPIO Gate Control

dir_addr			EQU		0x20000100	; direction_address
	
;***************************************************************	
;LABEL			DIRECTIVE	VALUE				COMMENT		
				AREA 		routines, CODE, READONLY
				THUMB
					
				EXPORT 		PortF_Init
				EXPORT		Switch_Handler
					
;***************************************************************
PortF_Init 		PROC
			; Activate Port F clock
				LDR R1,=SYSCTL_RCGCGPIO 
				LDR R0,[R1]
				ORR R0,R0,#0x20 
				STR R0,[R1]
			; Wait for stailization
				NOP 
				NOP
				NOP
			; Unlock register	
				LDR R1,=GPIO_PORTF_LOCK ; Unlock switches
				LDR	R0,=0x4C4F434B
				STR	R0,[R1]
				LDR	R1,=GPIO_PORTF_CR
				MOV	R0,#0x11
				STR	R0,[R1]
			; Set direction register	
				LDR R1,=GPIO_PORTF_DIR 
				LDR R0,[R1]
				BIC R0,R0,#0x11 ; set INPUTS
				ORR R0,R0,#0x0E ; set OUTPUTS
				STR R0,[R1]
			; Regular port function		
				LDR R1,=GPIO_PORTF_AFSEL ;
				LDR R0,[R1]
				BIC R0,R0,#0x1F
				STR R0,[R1]
			; Analog funciton
				LDR R1,=GPIO_PORTF_AMSEL ; disable analog
				MOV R0,#0
				STR R0,[R1]
			; Enable digital port	
				LDR R1,=GPIO_PORTF_DEN ; enable port digital
				LDR R0,[R1]
				ORR R0,R0,#0x1F
				STR R0,[R1]
			; Pull up register	
				LDR R1, =GPIO_PORTF_PUR
				MOV R0, #0x10 ;pull ups on pins 0 and 4 of PORT F
				STR R0, [R1]
				; Configure interrupt priorities
	; GPIO PORTF is interrupt #30.
	; Interrupts 28-31 are handled by NVIC register PRI7.
	; Interrupt 30 is controlled by bits 23:21 of PRI7.
	; set NVIC interrupt 30 to priority 3
				LDR R1,=NVIC_PRI7
				LDR R2,[R1]
				AND R2,R2,#0x00FF0000 ; clear interrupt 30 priority
				ORR R2,R2,#0x00600000 ; set interrupt 30 priority to 3
				STR R2,[R1]
				
	; NVIC has to be enabled
	; Interrupts 0-31 are handled by NVIC register EN0
	; Interrupt 30 is controlled by bit 30
	; enable interrupt 30 in NVIC

				LDR R1,=NVIC_EN0
				MOV R2,#0x40000000 ; set bit 30 to enable interrupt 30
				LDR R0,[R1]
				ORR R0,R2
				STR R0,[R1]
				
				LDR R1,=GPIO_PORTF_IM ;mask the interrupts during setup
				LDR R0,[R1]
				BIC R0,R0, #0xFF
				STR R0,[R1]
				
				LDR R1,=GPIO_PORTF_IS ;set the corresponding input pins as edge or level detection
				LDR R0,[R1]
				BIC R0,R0, #0xFF
				STR R0,[R1]
					
				LDR R1,=GPIO_PORTF_IBE ; Let IEV handle rather than the IBE
				LDR R0,[R1]
				BIC R0,R0, #0xFF
				STR R0,[R1]
				
				LDR R1,=GPIO_PORTF_IEV ;set the corresponding input pins as "rising edge" or "high level" detection
				LDR R0,[R1]
				BIC R0,R0, #0x11
				ORR R0,#0x00 
				STR R0,[R1]
				
				LDR R1,=GPIO_PORTF_ICR ;clear flags
				MOV R0,#0xFF
				STR R0,[R1]
				
				LDR R1,=GPIO_PORTF_IM ;set the corresponding input pin to allow interrupt
				LDR R0,[R1]
				BIC R0,R0, #0xFF
				ORR R0,#0x11
				STR R0,[R1]
					
			BX LR ; return

;*****************************************************************
Switch_Handler	PROC
				PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}
	
				LDR R1,=GPIO_PORTF_DATA
				LDR	R0,[R1]
				
				BIC	R0,#0xFFFFFFEE
				MOV	R3,#0x10			
				CMP	R0,R3
				BEQ	cw				
				
				LDR R1,=dir_addr	; SW2 is pressed -> ccw
				MOV	R2,#1
				STR R2,[R1]
				B	quit		
				
cw				LDR R1,=dir_addr	; SW1 is pressed -> cw
				MOV	R2,#0
				STR R2,[R1]
				
				
quit			LDR R1,=GPIO_PORTF_ICR	;clear interrupt flag
				MOV R0,#0x11
				STR R0,[R1]
					
				POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}		
				BX LR
				ENDP
			ALIGN
		END
					