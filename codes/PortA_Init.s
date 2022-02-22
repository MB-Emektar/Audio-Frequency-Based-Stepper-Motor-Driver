;***************************************************************
; LCD Screen Initialization
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
;GPIO Registers
GPIO_PORTA_DATA		EQU		0x400043FC	; Port A Data
GPIO_PORTA_IM      	EQU 	0x40004010	; Interrupt Mask
GPIO_PORTA_DIR   	EQU 	0x40004400	; Port Direction
GPIO_PORTA_AFSEL 	EQU 	0x40004420	; Alt Function enable
GPIO_PORTA_DEN   	EQU 	0x4000451C	; Digital Enable
GPIO_PORTA_AMSEL 	EQU 	0x40004528	; Analog enable
GPIO_PORTA_PCTL  	EQU 	0x4000452C	; Alternate Functions
	
;SSI Registers
SSI0_CR0			EQU		0x40008000
SSI0_CR1			EQU		0x40008004
SSI0_DR				EQU		0x40008008
SSI0_SR				EQU		0x4000800C
SSI0_CPSR			EQU		0x40008010
SSI0_CC				EQU		0x40008FC8	
	
;System Registers
SYSCTL_RCGCGPIO  	EQU 	0x400FE608	; GPIO Gate Control
SYSCTL_RCGCSSI		EQU		0x400FE61C	; SSI Gate Control

;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
		AREA   routines, CODE, READONLY
        THUMB
			
		EXTERN 	clear_screen
		EXTERN 	send_bit
		EXTERN 	DELAY100
			
		EXPORT	PortA_Init

;***************************************************************
PortA_Init	PROC
	
				PUSH{LR}
			; Activate Port A clock
				LDR R1, =SYSCTL_RCGCGPIO
				LDR R0, [R1]                   
				ORR R0, #0x01				
				STR R0, [R1]                   
			; Wait for stailization
				NOP								
				NOP
				NOP
			; Set direction register		
				LDR	R1,=GPIO_PORTA_DIR		; make PA2 PA3 PA5 PA6 PA7 output
				MOV R0, #0xEC			
				STR	R0,[R1]
			; Alternate port function		
				LDR	R1,=GPIO_PORTA_AFSEL	
				MOV R0, #0x3C				; enable for PA2 PA3 PA4 PA5
				STR	R0,[R1]
			; Enable digital port
				LDR	R1,=GPIO_PORTA_DEN		
				MOV R0, #0xFC				; enable digital I/O at PA2 PA3 PA5 PA6 PA7 
				STR	R0,[R1]			
			; Alternate funciton selection
				LDR	R1,=GPIO_PORTA_PCTL 	
				LDR R0, =0x00222200			; configure PA2 PA3 PA5 as SSI
				STR	R0,[R1]
			; Analog funciton
				LDR	R1,=GPIO_PORTA_AMSEL	; disable
				LDR	R0, [R1]
				BIC R0, #0xFC				
				STR	R0,[R1]
				
			;Setup SSI	
				LDR R1,=SYSCTL_RCGCSSI		; start SSI clock
				LDR R0,[R1]                   
				ORR R0, #0x01				
				STR R0,[R1]                
			; Wait for stailization
				PUSH {LR}
				BL DELAY100
				POP {LR}
				
				LDR	R1,=SSI0_CR1			
				MOV	R0, #0x00				; disable SSI during setup 
				STR	R0,[R1]
				
			; Baud = 2MHz,PIOSC = 16MHz,CPSDVSR = 4,SCR = 1, BR = SysClk/(CPSDVSR * (1 + SCR))
			
				LDR	R1,=SSI0_CC				; PIOSC (16MHz)		
				MOV	R0,#0x05				; bits 3:0 of the SSICC = 0x5 
				STR	R0,[R1]
				LDR	R1,=SSI0_CR0			; SCR bits = 0x01
				LDR	R0,[R1]
				ORR	R0, #0x0100				;
				STR	R0,[R1]
				LDR	R1,=SSI0_CPSR			; CPSDVSR (prescale) = 0x04
				MOV R0, #0x04				;
				STR	R0,[R1]
				LDR	R1,=SSI0_CR0			; clear SPH,SPO
				LDR	R0,[R1]					; choose Freescale frame format
				BIC	R0, #0x3F				; clear bits 5:4 	
				ORR	R0, #0x07				; choose 8-bit data
				STR	R0,[R1]
				LDR	R1,=SSI0_CR1			; enable SSI
				LDR	R0,[R1]
				ORR R0, #0x02			
				STR	R0,[R1]
			
			; Reset LCD memory, ensure reset is low
				LDR	R1,=GPIO_PORTA_DATA	
				LDR	R0, [R1]
				BIC R0, #0x80				; clear reset(PA7) 	
				STR	R0,[R1]

				MOV	R0,#10
delReset		
				SUBS R0,R0,#1
				BNE	delReset
				
				LDR	R1,=GPIO_PORTA_DATA		
				ORR R0, #0x80				; PA7 reset
				STR	R0,[R1]					
				
			; Setup LCD
				LDR	R1,=GPIO_PORTA_DATA		; PA6 low for Command
				LDR	R0,[R1]
				BIC R0, #0x40				
				STR	R0,[R1]
				
			; extended instruction set (H=1), horizontal addressing (V=0), chip active (PD=0)
				MOV	R5,#0x21
				BL	send_bit	
			;set contrast
				MOV	R5,#0xB8
				BL	send_bit
			;set temp coefficient
				MOV	R5,#0x04
				BL	send_bit
			;set bias 1:48: try 0x13 or 0x14
				MOV	R5,#0x14
				BL	send_bit
			;change H=0
				MOV	R5,#0x20
				BL	send_bit
			;set control mode to normal
				MOV	R5,#0x0C
				BL	send_bit
			; clear screen, screen memory is undefined after startup
				BL	clear_screen
		
wait_CMD		
				LDR	R1,=SSI0_SR				; wait for SSI
				LDR	R0,[R1]
				ANDS R0,R0,#0x10
				BNE	wait_CMD
				
				POP{LR}
				BX LR
						
;*****************************************************************		

