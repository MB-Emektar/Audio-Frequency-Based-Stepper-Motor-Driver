;***************************************************************
; Systick Interrupt Subroutine
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
; ADC Registers
ADC0_RIS 			EQU 	0x40038004 		; Interrupt status
ADC0_ISC			EQU		0X4003800C		; Interrupt status and clear register
ADC0_PSSI 			EQU 	0x40038028 		; Initiate sample
ADC0_SSFIFO3 		EQU 	0x400380A8 		; Channel 3 results ADC0_PC EQU 0x40038FC4 ; Sample rate
	
; NVIC Registers
NVIC_ST_CTRL 		EQU 	0xE000E010
NVIC_ST_RELOAD 		EQU 	0xE000E014
NVIC_ST_CURRENT 	EQU 	0xE000E018
SHP_SYSPRI3 		EQU 	0xE000ED20

; 0x7D0 = 2000 -> 2000*250 ns = 500000ns -> 2kHz        
RELOAD_VALUE 		EQU 	0x000007D0			
data_addr			EQU		0x20000400			; 256 sample stored starting from this address	
number_addr			EQU		0x20000350			; the number of elements in the array is also stored

;*********************************************************
;LABEL 			DIRECTIVE 	VALUE 		COMMENT
				AREA    	routines, CODE,READONLY
				
				EXTERN		Freq_Detect
				EXTERN		arm_cfft_q15			; Reference external subroutine
				EXTERN		arm_cfft_sR_q15_len256	; Reference constant table
				
				EXPORT 		ISR
;***************************************************************				
ISR 			PROC		
			PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}
				LDR	R1,=ADC0_PSSI
				LDR	R0,[R1]
				ORR	R0,R0,#0x08 		; set bit 3 for SS3
				STR	R0,[R1]
			; check if the bit 3 of ADC0_RIS set for sample complete
				LDR	R1,=ADC0_RIS
cont  			LDR	R0,[R1]
				ANDS R0,R0,#8
				BEQ cont
			; if the program continues, that means new value has arrived
				LDR	R1,=ADC0_SSFIFO3
				LDR R0,[R1]
				MOV	R1,#0x60F			; subtract the offset
				SUB	R0,R0,R1	
				MOV	R5,#0xFFFF
				LSL R5,R5,#16	
				BIC	R0,R5	
				
save_data		LDR	R1,=number_addr  	; Save data in array of 256 elements
				LDR R2,[R1]				
				MOV	R3,#256
				CMP	R2,R3   	
				MOVGE R2,#0			
				MOV	R3,#0
				CMP	R2,R3   	
				MOVLT R2,#0	
				MOV	R5,R2
				MOV	R4,#4
				MUL	R5,R4
				LDR	R1,=data_addr 		; The number of stored data
				ADD	R1,R5
				STR	R0,[R1]
				ADD	R2,#1	
				
				LDR	R1,=number_addr
				STR R2,[R1]	
				MOV	R3,#254
				CMP	R2,R3 
				BGE	calculate			;if 256 sample collected, then calculate fft and frequency

quit			LDR R1,=ADC0_ISC ; Clear to get new data later
				LDR R0,[R1]
				ORR R0,#0X08  
				STR R0,[R1]
			POP  {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}
 				BX LR 	
				
calculate		LDR	R0,=arm_cfft_sR_q15_len256
				LDR	R1,=data_addr
				MOV	R2,#0
				MOV	R3,#1
				BL	arm_cfft_q15		;calculate ffts of samples
				BL	Freq_Detect			;detect the frequency of samples
				
				LDR	R1,=number_addr
				MOV	R2,#0
				STR R2,[R1]
				B 	quit
				ENDP
				ALIGN
				END
					