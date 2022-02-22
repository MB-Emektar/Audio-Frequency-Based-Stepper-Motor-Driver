;***************************************************************
; Systick  Initialization 
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
; NVIC Registers
NVIC_ST_CTRL 		EQU 0xE000E010
NVIC_ST_RELOAD 		EQU 0xE000E014
NVIC_ST_CURRENT 	EQU 0xE000E018
SHP_SYSPRI3 		EQU 0xE000ED20
; 0x7D0 = 2000 -> 2000*250 ns = 500000ns -> 2kHz       
RELOAD_VALUE 		EQU 0x000007D0
	
;*********************************************************
;LABEL 			DIRECTIVE VALUE 		COMMENT
				AREA init_isr , CODE, READONLY, ALIGN=2
				THUMB
				EXPORT InitSysTick
					
InitSysTick 	PROC
				LDR R1, =NVIC_ST_CTRL
				MOV R0, #0
				STR R0, [R1]
										
				LDR R1, =NVIC_ST_RELOAD
				LDR R0, =RELOAD_VALUE
				STR R0, [R1]
										
										
				LDR R1, =NVIC_ST_CURRENT
				STR R0, [R1]
										
										
				LDR R1, =SHP_SYSPRI3
				MOV R0, #0x40000000
				STR R0, [R1]
										
				LDR R1, =NVIC_ST_CTRL
				MOV R0, #0x03
				STR R0, [R1]
										
				BX LR
				ENDP
				ALIGN
				END