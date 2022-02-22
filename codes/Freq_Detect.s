;***************************************************************
; Frequency Detection
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
mag_threshold		EQU		0x6000			; Set as default
new_freq			EQU		0x20000358		; location of the new calculated frequency
sampling_freq		EQU		2000			; 2kHz sampling frequency so 1khz max detectable frequency
	
new_curr_freq			EQU		0x20000200		; location of the new calculated frequency
new_curr_mag			EQU		0x20000204		; location of the new calculated frequency	
	
low_freq_thres 		EQU		425	 			;hz
high_freq_thres		EQU		675  			;hz
	
RELOAD_VALUE 		EQU 	0x000009C4		;2500 (min reotation speed for motor (a value for timer))
number_addr			EQU		0x20000350	
data_addr			EQU		0x20000400

GPIO_PORTF_DATA 	EQU 	0x400253FC		; No mask
	
;*********************************************************
;LABEL 			DIRECTIVE 	VALUE 		COMMENT
				AREA    	routines, CODE,READONLY
					

				EXTERN		arm_cfft_q15			; Reference external subroutine
				EXTERN		arm_cfft_sR_q15_len256	; Reference constant table	
				EXTERN		display	
				EXTERN		Timer0A_Init	
					
				EXPORT 		Freq_Detect
					
;***************************************************************
Freq_Detect		PROC
				PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}
				MOV	R10,#1
				MOV	R6,#0
				
				MOV	R9,#mag_threshold	
				LDR	R0,=data_addr
				ADD	R0,#4
				
LOOP			LDRH R1,[R0],#2		;REAL PART
				LDRH R2,[R0],#2		;IMG PART
				SMULBB R3,R1,R1			
				SMULBB R4,R2,R2					; visit all the array elements 
				ADD	R5,R4,R3					 
				CMP	R5,R6
				MOVGT R11,R10	
				MOVGT R6,R5
jump			ADD	R10,#1						; save the biggest ones index and 
				CMP	R10,#127					; the magnitude in R11 and R6 respectively
				BNE	LOOP
				
				MOV	R7,R11
				MOV	R8,R6
				
				LDR	R9,=sampling_freq
				MUL	R7,R9
				MOV	R9,#256
				UDIV R7,R9						; Calculate the frerquency with index found above
				
				MOV	R2,#0x500
				UDIV R8,R2						; This number is calculated as the max amplitude mic can get
				
				LDR R2,=new_curr_freq
				STR	R7,[R2]
				LDR R2,=new_curr_mag			; Store current frequency and current amplitude
				STR	R8,[R2]						; So that the Timer 3A can read them from memory and prints.
				
				
				;BL  current_display
				;compare if not jump to end
				MOV	R9,#mag_threshold
				CMP	R6,R9						; COMPARE WITH MAGNITUDE THRESHOLD
				BLT no_led						; if it is less than threshold, NO led will be on. Quit
													
				LDR	R9,=sampling_freq
				MUL	R11,R9
				MOV	R9,#256
				UDIV R11,R9						; Calculate the frerquency with index found above
				LDR	R0,=new_freq
				STR	R11,[R0]
				
				MOV	R5,R11
				SUB	R5,#100
				MOV	R9,#23
				MUL	R5,R9						; RELOAD TIMER WITH NEW FREQUENCY (adjust rotation speed)
				ADD	R5,#RELOAD_VALUE
				MOV	R9,#25000
				SUB	R5,R9,R5
				BL	Timer0A_Init
				
				MOV	R2,#0x500
				UDIV R6,R2						; This number is calculated as the max amplitude mic can get
				MOV	R5,#mag_threshold
				UDIV R5,R2	
				MOV	R2,#low_freq_thres 
				MOV	R3,#high_freq_thres
				MOV	R4,R11
				BL	display						; Display the signal's frequency and amplitude that rotates the motor
				
				LDR R1,=GPIO_PORTF_DATA
				BIC	R2,#0xE						
				
				MOV	R3,#low_freq_thres 
				CMP	R11,R3						; compare the frequency with thresholds and turn on the related LED
				BLT	red_led
				
				MOV	R3,#high_freq_thres
				CMP	R11,R3
				BGT	blue_led
				ORR	R2,#0x8
				STR R2,[R1]
				B	terminate
				
red_led			ORR	R2,#0x2
				STR R2,[R1]
				B	terminate
				
blue_led		ORR	R2,#0x4
				STR R2,[R1]
				B	terminate
				
no_led			LDR R1,=GPIO_PORTF_DATA
				BIC	R2,#0xE
				STR R2,[R1]
					

terminate		POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}	
				BX LR
				ENDP
				ALIGN
				END
						