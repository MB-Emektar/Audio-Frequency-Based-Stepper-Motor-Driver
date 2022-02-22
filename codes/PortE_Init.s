;***************************************************************
; Microphone Module Initialization
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
;GPIO Registers
GPIO_PORTE_DIR_R	EQU		0X40024400
GPIO_PORTE_AFSEL_R	EQU		0X40024420
GPIO_PORTE_DEN_R	EQU		0X4002451C
GPIO_PORTE_AMSEL_R	EQU		0X40024528
GPIO_PORTE_PDR		EQU		0X40024514 
SYSCTL_RCGC2_R		EQU		0X400FE608
GPIO_PORTE_IS		EQU		0X40024404
GPIO_PORTE_IBE		EQU		0X40024408
GPIO_PORTE_IEV		EQU		0X4002440C
GPIO_PORTE_IM		EQU		0X40024410
GPIO_PORTE_ICR		EQU		0X4002441C
GPIO_PORTE_RIS		EQU		0X40024414
RCGCADC 			EQU 	0x400FE638 ; ADC clock register
	
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA routines,CODE,READONLY,ALIGN=2
				THUMB
				EXPORT		PortE_Init
								
;***************************************************************	
PortE_Init	PROC
		
			; Activate ADC clock
				LDR R1,=RCGCADC 
				LDR R0,[R1]
				ORR R0,R0, #0x01 	; set bit 0 to enable ADC0 clock
				STR R0,[R1]
			; Wait for stailization
				NOP
				NOP
				NOP
			; Activate Port E clock
				LDR	R1,=SYSCTL_RCGC2_R
				LDR	R0,[R1]
				ORR	R0,R0,#0X10	;only port E	
				STR	R0,[R1]
				NOP
				NOP
				NOP
			; Set direction register
				LDR	R1,=GPIO_PORTE_DIR_R
				LDR	R0,[R1]
				BIC	R0,R0,#0X08			;Input
				STR	R0,[R1]
			; Regular port function
				LDR	R1,=GPIO_PORTE_AFSEL_R
				LDR	R0,[R1]
				ORR	R0,R0,#0X08			;Alternate
				STR	R0,[R1]
			; Disable digital port
				LDR	R1,=GPIO_PORTE_DEN_R
				LDR	R0,[R1]
				BIC	R0,R0,#0X08
				STR	R0,[R1]
			; Enable analog port
				LDR	R1,=GPIO_PORTE_AMSEL_R
				LDR	R0,[R1]
				ORR	R0,R0,#0X08
				STR	R0,[R1]	
				
				BX 		LR
				ENDP
			ALIGN
		END