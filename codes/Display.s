;***************************************************************
; Screen (SSI0, PA6-PA2)
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
;GPIO Registers
GPIO_PORTA_DATA			EQU	0x400043FC	; Port A Data
GPIO_PORTA_IM      		EQU 0x40004010	; Interrupt Mask
GPIO_PORTA_DIR   		EQU 0x40004400	; Port Direction
GPIO_PORTA_AFSEL 		EQU 0x40004420	; Alt Function enable
GPIO_PORTA_DEN   		EQU 0x4000451C	; Digital Enable
GPIO_PORTA_AMSEL 		EQU 0x40004528	; Analog enable
GPIO_PORTA_PCTL  		EQU 0x4000452C	; Alternate Functions
;SSI Registers
SSI0_CR0				EQU	0x40008000
SSI0_CR1				EQU	0x40008004
SSI0_DR					EQU	0x40008008
SSI0_SR					EQU	0x4000800C
SSI0_CPSR				EQU	0x40008010
SSI0_CC					EQU	0x40008FC8	
	
;System Registers
SYSCTL_RCGCGPIO  		EQU 0x400FE608	; GPIO Gate Control
SYSCTL_RCGCSSI			EQU	0x400FE61C	; SSI Gate Control
		
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA    	routines, READONLY, CODE
				THUMB

; ASCII table 
ASCII		DCB		0x00, 0x00, 0x00, 0x00, 0x00 ; 20
			DCB		0x00, 0x00, 0x5f, 0x00, 0x00 ; 21 !
			DCB		0x00, 0x07, 0x00, 0x07, 0x00 ; 22 "
			DCB		0x14, 0x7f, 0x14, 0x7f, 0x14 ; 23 #
			DCB		0x24, 0x2a, 0x7f, 0x2a, 0x12 ; 24 $
			DCB		0x23, 0x13, 0x08, 0x64, 0x62 ; 25 %
			DCB		0x36, 0x49, 0x55, 0x22, 0x50 ; 26 &
			DCB		0x00, 0x05, 0x03, 0x00, 0x00 ; 27 '
			DCB		0x00, 0x1c, 0x22, 0x41, 0x00 ; 28 (
			DCB		0x00, 0x41, 0x22, 0x1c, 0x00 ; 29 )
			DCB		0x14, 0x08, 0x3e, 0x08, 0x14 ; 2a *
			DCB		0x08, 0x08, 0x3e, 0x08, 0x08 ; 2b +
			DCB		0x00, 0x50, 0x30, 0x00, 0x00 ; 2c ,
			DCB		0x08, 0x08, 0x08, 0x08, 0x08 ; 2d -
			DCB		0x00, 0x60, 0x60, 0x00, 0x00 ; 2e .
			DCB		0x20, 0x10, 0x08, 0x04, 0x02 ; 2f /
			DCB		0x3e, 0x51, 0x49, 0x45, 0x3e ; 30 0
			DCB		0x00, 0x42, 0x7f, 0x40, 0x00 ; 31 1
			DCB		0x42, 0x61, 0x51, 0x49, 0x46 ; 32 2
			DCB		0x21, 0x41, 0x45, 0x4b, 0x31 ; 33 3
			DCB		0x18, 0x14, 0x12, 0x7f, 0x10 ; 34 4
			DCB		0x27, 0x45, 0x45, 0x45, 0x39 ; 35 5
			DCB		0x3c, 0x4a, 0x49, 0x49, 0x30 ; 36 6
			DCB		0x01, 0x71, 0x09, 0x05, 0x03 ; 37 7
			DCB		0x36, 0x49, 0x49, 0x49, 0x36 ; 38 8
			DCB		0x06, 0x49, 0x49, 0x29, 0x1e ; 39 9
			DCB		0x00, 0x36, 0x36, 0x00, 0x00 ; 3a :
			DCB		0x00, 0x56, 0x36, 0x00, 0x00 ; 3b ;
			DCB		0x08, 0x14, 0x22, 0x41, 0x00 ; 3c <
			DCB		0x14, 0x14, 0x14, 0x14, 0x14 ; 3d =
			DCB		0x00, 0x41, 0x22, 0x14, 0x08 ; 3e >
			DCB		0x02, 0x01, 0x51, 0x09, 0x06 ; 3f ?
			DCB		0x32, 0x49, 0x79, 0x41, 0x3e ; 40 @
			DCB		0x7e, 0x11, 0x11, 0x11, 0x7e ; 41 A
			DCB		0x7f, 0x49, 0x49, 0x49, 0x36 ; 42 B
			DCB		0x3e, 0x41, 0x41, 0x41, 0x22 ; 43 C
			DCB		0x7f, 0x41, 0x41, 0x22, 0x1c ; 44 D
			DCB		0x7f, 0x49, 0x49, 0x49, 0x41 ; 45 E
			DCB		0x7f, 0x09, 0x09, 0x09, 0x01 ; 46 F
			DCB		0x3e, 0x41, 0x49, 0x49, 0x7a ; 47 G
			DCB		0x7f, 0x08, 0x08, 0x08, 0x7f ; 48 H
			DCB		0x00, 0x41, 0x7f, 0x41, 0x00 ; 49 I
			DCB		0x20, 0x40, 0x41, 0x3f, 0x01 ; 4a J
			DCB		0x7f, 0x08, 0x14, 0x22, 0x41 ; 4b K
			DCB		0x7f, 0x40, 0x40, 0x40, 0x40 ; 4c L
			DCB		0x7f, 0x02, 0x0c, 0x02, 0x7f ; 4d M
			DCB		0x7f, 0x04, 0x08, 0x10, 0x7f ; 4e N
			DCB		0x3e, 0x41, 0x41, 0x41, 0x3e ; 4f O
			DCB		0x7f, 0x09, 0x09, 0x09, 0x06 ; 50 P
			DCB		0x3e, 0x41, 0x51, 0x21, 0x5e ; 51 Q
			DCB		0x7f, 0x09, 0x19, 0x29, 0x46 ; 52 R
			DCB		0x46, 0x49, 0x49, 0x49, 0x31 ; 53 S
			DCB		0x01, 0x01, 0x7f, 0x01, 0x01 ; 54 T
			DCB		0x3f, 0x40, 0x40, 0x40, 0x3f ; 55 U
			DCB		0x1f, 0x20, 0x40, 0x20, 0x1f ; 56 V
			DCB		0x3f, 0x40, 0x38, 0x40, 0x3f ; 57 W
			DCB		0x63, 0x14, 0x08, 0x14, 0x63 ; 58 X
			DCB		0x07, 0x08, 0x70, 0x08, 0x07 ; 59 Y
			DCB		0x61, 0x51, 0x49, 0x45, 0x43 ; 5a Z
			DCB		0x00, 0x7f, 0x41, 0x41, 0x00 ; 5b [
			DCB		0x02, 0x04, 0x08, 0x10, 0x20 ; 5c '\'
			DCB		0x00, 0x41, 0x41, 0x7f, 0x00 ; 5d ]
			DCB		0x04, 0x02, 0x01, 0x02, 0x04 ; 5e ^
			DCB		0x40, 0x40, 0x40, 0x40, 0x40 ; 5f _
			DCB		0x00, 0x01, 0x02, 0x04, 0x00 ; 60 `
			DCB		0x20, 0x54, 0x54, 0x54, 0x78 ; 61 a
			DCB		0x7f, 0x48, 0x44, 0x44, 0x38 ; 62 b
			DCB		0x38, 0x44, 0x44, 0x44, 0x20 ; 63 c
			DCB		0x38, 0x44, 0x44, 0x48, 0x7f ; 64 d
			DCB		0x38, 0x54, 0x54, 0x54, 0x18 ; 65 e
			DCB		0x08, 0x7e, 0x09, 0x01, 0x02 ; 66 f
			DCB		0x0c, 0x52, 0x52, 0x52, 0x3e ; 67 g
			DCB		0x7f, 0x08, 0x04, 0x04, 0x78 ; 68 h
			DCB		0x00, 0x44, 0x7d, 0x40, 0x00 ; 69 i
			DCB		0x20, 0x40, 0x44, 0x3d, 0x00 ; 6a j
			DCB		0x7f, 0x10, 0x28, 0x44, 0x00 ; 6b k
			DCB		0x00, 0x41, 0x7f, 0x40, 0x00 ; 6c l
			DCB		0x7c, 0x04, 0x18, 0x04, 0x78 ; 6d m
			DCB		0x7c, 0x08, 0x04, 0x04, 0x78 ; 6e n
			DCB		0x38, 0x44, 0x44, 0x44, 0x38 ; 6f o
			DCB		0x7c, 0x14, 0x14, 0x14, 0x08 ; 70 p
			DCB		0x08, 0x14, 0x14, 0x18, 0x7c ; 71 q
			DCB		0x7c, 0x08, 0x04, 0x04, 0x08 ; 72 r
			DCB		0x48, 0x54, 0x54, 0x54, 0x20 ; 73 s
			DCB		0x04, 0x3f, 0x44, 0x40, 0x20 ; 74 t
			DCB		0x3c, 0x40, 0x40, 0x20, 0x7c ; 75 u
			DCB		0x1c, 0x20, 0x40, 0x20, 0x1c ; 76 v
			DCB		0x3c, 0x40, 0x30, 0x40, 0x3c ; 77 w
			DCB		0x44, 0x28, 0x10, 0x28, 0x44 ; 78 x
			DCB		0x0c, 0x50, 0x50, 0x50, 0x3c ; 79 y
			DCB		0x44, 0x64, 0x54, 0x4c, 0x44 ; 7a z
			DCB		0x00, 0x08, 0x36, 0x41, 0x00 ; 7b {
			DCB		0x00, 0x00, 0x7f, 0x00, 0x00 ; 7c |
			DCB		0x00, 0x41, 0x36, 0x08, 0x00 ; 7d }
			DCB		0x10, 0x08, 0x08, 0x10, 0x08 ; 7e ~
			
;***************************************************************
c_freq_msg	DCB		"C. Freq:    Hz",0x04
			SPACE	1		; for padding				
c_mag_msg	DCB		"C. Mag:       ",0x04
			SPACE	1		; for padding
				
freq_msg	DCB		"Freq:       Hz",0x04
			SPACE	1		; for padding				
mag_msg		DCB		"Mag:          ",0x04
			SPACE	1		; for padding

f_t_msg		DCB		"F.Ts:   -   Hz",0x04
			SPACE	1		; for padding
mag_t_msg	DCB		"Mag.T:       ",0x04
			SPACE	1		; for padding				
	
;***************************************************************
		AREA   routines, CODE, READONLY
        THUMB

		EXPORT		clear_screen
		EXPORT		send_bit
		EXTERN		DELAY100
			
		EXPORT		display	
		EXPORT		current_display
;*****************************************************************
current_display
			PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}
			; Current frequency is passed with R7
			; Current magnitude is passed with R8
		; first row
				MOV R0,#0		;X 
				MOV R1,#0		;Y 
				BL set_coords
				LDR R5,=c_freq_msg
				BL print_str_nokia
				
			; coordinates of current frequency
				MOV R0,#50		;X 
				MOV R1,#0		;Y 
				BL set_coords
			; print frequency 
				MOV	R5,R7
				BL print_number
				
		; second row
				MOV R0,#0		;X
				MOV R1,#1		;Y
				BL set_coords
				LDR R5,=c_mag_msg
				BL print_str_nokia

			; coordinates of current magnitude
				MOV R0,#50		;X 
				MOV R1,#1		;Y
				BL set_coords
			; print  magnitude 
				MOV	R5,R8
				BL print_number
			POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R11,R12,LR}	
				BX LR
				
;*****************************************************************
display
			PUSH{R0-R5,LR}
			; Below frequency threshold  is passed with R2
			; Above frequency threshold  is passed with R3
			; Frequency is passed with R4
			; Magnitude threshold  is passed with R5
			; Magnitude is passed with R6


			PUSH{R5}
				
			; clear screen
				;BL clear_screen		
				
		; third row
				MOV R0,#0		;X 
				MOV R1,#2		;Y 
				BL set_coords
				LDR R5,=freq_msg
				BL print_str_nokia
				
			; coordinates of frequency
				MOV R0,#40		;X 
				MOV R1,#2		;Y 
				BL set_coords
			; print frequency passed to R5 by popping
				MOV	R5,R4
				BL print_number
				
		; fourth row
				MOV R0,#0		;X
				MOV R1,#3		;Y
				BL set_coords
				LDR R5,=mag_msg
				BL print_str_nokia

			; coordinates of magnitude
				MOV R0,#40		;X 
				MOV R1,#3		;Y
				BL set_coords
			; print  magnitude passed to R5 by popping
				MOV	R5,R6
				BL print_number
				
		; fifth row
				MOV R0,#0		;X
				MOV R1,#4		;Y
				BL set_coords
				LDR R5,=f_t_msg
				BL print_str_nokia
				
			; coordinates of higher frequency threshold
				MOV R0,#53		;X
				MOV R1,#4		;Y
				BL set_coords
			; print higher frequency threshold
				MOV	R5,R3
				BL print_number
			; coordinates of lower frequency threshold
				MOV R0,#30		;X
				MOV R1,#4		;Y
				BL set_coords
			; print lower frequency threshold
				MOV	R5,R2
				BL print_number
				
		; sixth row
				MOV R0,#0		;X
				MOV R1,#5		;Y
				BL set_coords
				LDR R5,=mag_t_msg
				BL print_str_nokia
				
			; set coordinates for magnitude threshold
				MOV R0,#40		;X
				MOV R1,#5		;Y
				BL set_coords
				;print  magnitude threshold passed to R5 by popping
			POP{R5}
				BL print_number
				
			POP{R0-R5,LR}
				BX LR
			
;*****************************************************************
print_number
				PUSH{R0-R5,LR}
				
				;3 digit number is passed via R5.
				;If R5 is greater than 999, load R5 with 999.
				MOV R0,#999
				CMP R5,R0
				MOVHI R5,#999	
				
				MOV R0,R5
				MOV R2,#100
				UDIV R1,R0,R2
				ADD R5,R1,#0X30
				BL print_char			; first digit
				
				MUL R1,R1,R2
				SUB R0,R0,R1
				MOV R2,#10
				UDIV R1,R0,R2
				ADD R5,R1,#0X30
				BL print_char			; second digit
				
				MUL R1,R1,R2
				SUB R0,R0,R1
				ADD R5,R0,#0X30
				BL print_char			; third digit
				
				POP{R0-R5,LR}
				BX LR
		
;*****************************************************************
; output ASCII character to LCD screen - ASCII hex value passed via R5
print_char
				PUSH{R0-R4,LR}
				LDR	R1,=GPIO_PORTA_DATA		; PA6 is high for Data
				LDR	R0,[R1]
				ORR	R0,#0x40
				STR	R0,[R1]
				
				LDR	R1,=ASCII				; load address of ASCII table and calculate offset of char
				SUB	R2,R5,#0x20		
				MOV	R3,#0x05
				MUL	R2,R2,R3
				ADD	R1,R1,R2
				PUSH{R5}					; save state of R5, 5 bytes in every char, one column between chars
				MOV	R0,#0x05				
				MOV	R2,#0x00				
send_char_byte
				LDRB R5,[R1],#1				
				BL	send_bit			; send each byte of the char
				SUBS R0,R0,#1
				BNE	 send_char_byte
				MOV	R5,R2
				BL	send_bit			; add space on after the char
wait_char_done		
				LDR	R1,=SSI0_SR				; wait until SSI is done
				LDR	R0,[R1]
				ANDS R0,R0,#0x10
				BNE	wait_char_done
				POP	{R5}
				POP	{R0-R4,LR}
				BX LR
;*****************************************************************
	; clear screen
clear_screen
				PUSH{R0-R5,LR}
				LDR	R1,=GPIO_PORTA_DATA		; set PA6 low for Command
				LDR	R0,[R1]
				BIC	R0,#0x40
				STR	R0,[R1]
				MOV	R5,#0x20				; ensure H=0
				BL	send_bit	
				MOV	R5,#0x40				; set Y address to 0
				BL	send_bit
				MOV	R5,#0x80				; set X address to 0
				BL	send_bit	
wait_clear		
				LDR	R1,=SSI0_SR				; wait until SSI is done
				LDR	R0,[R1]
				ANDS R0,R0,#0x10
				BNE	wait_clear	
				LDR	R1,=GPIO_PORTA_DATA		; set PA6 high for Data
				LDR	R0,[R1]
				ORR	R0,#0x40
				STR	R0,[R1]	
				MOV	R0,#504					; 504 bytes in full image
				MOV	R5,#0x00				; load zeros to send
clear_next		
				BL	send_bit
				SUBS R0,#1
				BNE	clear_next	
wait_clear_done		
				LDR	R1,=SSI0_SR				; wait until SSI is done
				LDR	R0,[R1]
				ANDS R0,R0,#0x10
				BNE	wait_clear_done	
				POP	{R0-R5,LR}
				BX LR
		
		LTORG			; assemble current pool immediately
		
;*****************************************************************	
	; SSI Send routine. Bits passed with R5
send_bit
				PUSH{R0,R1}
wait_send	
				LDR	R1,=SSI0_SR				; wait for buffer 
				LDR	R0,[R1]
				ANDS R0,R0,#0x02
				BEQ	wait_send
				LDR	R1,=SSI0_DR
				STRB R5,[R1]
				POP	{R0,R1}
				BX LR
;*****************************************************************


;*****************************************************************
; output ASCII string to LCD screen
; Address of start of message passed via R5
; Ended using character 0x04
print_str_nokia		
				PUSH{R0-R5,LR}
				MOV	R1,R5
next_str_char
				LDRB R5,[R1],#1
				CMP	R5,#0x04			;end of transmission ascii character.
				BEQ	done_str_char
				BL	print_char
				B	next_str_char
done_str_char
				POP	{R0-R5,LR}
				BX LR
;*****************************************************************		
; Set X,Y coordinates of screen	
set_coords	
			; X(0-83) is passed with R0, Y(0-5) is passed with R1, DC is high, so the data can be sent
				PUSH{R0-R5,LR}
				PUSH{R0-R1}
				LDR	R1,=GPIO_PORTA_DATA		; set PA6 low for Command
				LDR	R0,[R1]
				BIC	R0,#0x40
				STR	R0,[R1]
				MOV	R5,#0x20				; H=0
				BL	send_bit	
				POP	{R0-R1}
				MOV	R5,R1					; Y coordinate
				ORR	R5,#0x40
				BL	send_bit
				MOV	R5,R0					; X coordinate
				ORR	R5,#0x80
				BL	send_bit
wait_coords_setting		
				LDR	R1,=SSI0_SR				; wait SSI 
				LDR	R0,[R1]
				ANDS R0,R0,#0x10
				BNE	wait_coords_setting	
				LDR	R1,=GPIO_PORTA_DATA		; set PA6 high for Data
				LDR	R0,[R1]
				ORR	R0,#0x40
				STR	R0,[R1]
				POP	{R0-R5,LR}
				BX LR
;*****************************************************************

		
		END
		ALIGN
	ENDP