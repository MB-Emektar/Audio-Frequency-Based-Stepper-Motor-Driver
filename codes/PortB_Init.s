;***************************************************************
; Step Motor Initialization
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
;GPIO Registers
GPIO_PORTB_DIR 		EQU 	0x40005400
GPIO_PORTB_AFSEL 	EQU 	0x40005420
GPIO_PORTB_DEN 		EQU 	0x4000551C
GPIO_PORTB_PUR 		EQU 	0x40005510 
SYSCTL_RCGCGPIO 	EQU 	0x400FE608
GPIO_PORTB_DATA_OUT EQU 	0x400053C0 ; B4-B7 output pins
IOB 				EQU 	0xF0
PUB 				EQU 	0x0F 	
	
;***************************************************************	
;LABEL		DIRECTIVE		VALUE		COMMENT
			AREA			routines, CODE, READONLY
			THUMB
			EXPORT		PortB_Init
				
;***************************************************************				
PortB_Init	PROC
	
			; Activate Port B clock
				LDR R1,=SYSCTL_RCGCGPIO
				LDR R0,[R1]
				ORR R0,R0, #0x02
				STR R0,[R1]
			; Wait for stailization
				NOP
				NOP
				NOP 
			; Set direction register
				LDR R1,=GPIO_PORTB_DIR
				LDR R0,[R1]
				BIC R0,#0xFF
				ORR R0,#IOB
				STR R0,[R1]
			; Regular port function			
				LDR R1,=GPIO_PORTB_AFSEL
				LDR R0,[R1]
				BIC R0,#0xFF
				STR R0,[R1]
			; Enable digital port			
				LDR R1,=GPIO_PORTB_DEN
				LDR R0,[R1]
				ORR R0,#0xFF
				STR R0,[R1] 
			; Pull up register			
				LDR R1,=GPIO_PORTB_PUR ;setting input and output pins' pull up 
				MOV R0,#PUB			  
				STR R0,[R1]
						
				LDR R1,=GPIO_PORTB_DATA_OUT ;initialize with out1
				LDR R0,[R1]
				MOV R0,#0x10
				STR R0,[R1]
				BX LR ; return	
				ENDP
				ALIGN
				END