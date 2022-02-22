;*********************************************************
GPIO_PORTB_DATA 	EQU 0x400053FC 
GPIO_PORTB_DATA_IN	EQU 0x4000503C 
GPIO_PORTB_DATA_OUT EQU 0x400053C0 

number_addr			EQU		0x20000350	
data_addr			EQU		0x20000400
dir_addr			EQU		0x20000100		
RELOAD_VALUE 		EQU 	0x000009C4	;2500	
	
	
new_freq			EQU		0x20000358		; location of the new calculated frequency
new_curr_freq		EQU		0x20000200		; location of the new calculated frequency
new_curr_mag		EQU		0x20000204		; location of the new calculated frequency	
	
	
	
;LABEL 			DIRECTIVE 	VALUE 		COMMENT
				AREA main , CODE, READONLY
				THUMB	
						
				EXTERN		PortE_Init		; Mic GPIO Initialization
				EXTERN		ADC0_Init		; Mic ADC Initialization
				EXTERN 		InitSysTick		; SysTick
					
				EXTERN		PortA_Init		; Display Initialization
				EXTERN		display
							
				EXTERN 		PortB_Init 		; Step motor GPIO Initialization
				EXTERN		Timer0A_Init	; Step motor GPTM Initialization
					
				EXTERN 		PortF_Init 		; Switches and LEDs Initialization	
				EXTERN  	Timer3A_Init	
				EXTERN		DELAY100		
					
				EXPORT 		__main
					
;***************************************************************
__main 			PROC
				
				LDR	R1,	=number_addr 
				MOV	R2,#0
				STR R2,[R1]				; THE NUMBER OF STORED DATA  (0x20000350)
				BL	PortF_Init		
				
				LDR R1,=dir_addr		; Step Motor
				MOV	R2,#0
				STR	R2,[R1]
				BL	PortB_Init		
				LDR	R5,=RELOAD_VALUE	; Default rotation speed before any signal arrives
				BL   Timer0A_Init	
				
				BL	PortE_Init			; Mic
				BL	ADC0_Init		
				BL	InitSysTick		
				CPSIE I 	
				
				BL	PortA_Init 			; Display
				BL 	Timer3A_Init	
			
				
				
loop			B	loop	
				ENDP