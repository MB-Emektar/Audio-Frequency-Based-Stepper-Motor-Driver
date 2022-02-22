;*********************************************************
GPIO_PORTB_DATA 	EQU 0x400053FC 
GPIO_PORTB_DATA_IN	EQU 0x4000503C 
GPIO_PORTB_DATA_OUT EQU 0x400053C0 
	
;Nested Vector Interrupt Controller registers
NVIC_EN0_INT19 		EQU 	0x00080000 ; Interrupt 19 enable
NVIC_EN0 			EQU 	0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI4 			EQU 	0xE000E410 ; IRQ 16 to 19 Priority Register
	
; 16/32 Timer Registers
TIMER1_CFG			EQU 0x40031000
TIMER1_TAMR			EQU 0x40031004
TIMER1_CTL			EQU 0x4003100C
TIMER1_IMR			EQU 0x40031018
TIMER1_RIS			EQU 0x4003101C ; Timer Interrupt Status
TIMER1_ICR			EQU 0x40031024 ; Timer Interrupt Clear
TIMER1_TAILR		EQU 0x40031028 ; Timer interval
TIMER1_TAPR			EQU 0x40031038
TIMER1_TAR			EQU	0x40031048 ; Timer register
TIMER1_MATCH		EQU	0x40031030 ; Timer match	
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control
	
	
RELOAD_VALUE 		EQU 0x000007D0	
;I will read the exact same output port of the blue LED
;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		main, READONLY, CODE
            THUMB
            EXPORT 		Timer1A_Init
			EXPORT 		My_Timer1A_Handler
				
Timer1A_Init	PROC
			
			LDR    R1, =TIMER3
    
    ;disable timer
    LDR    R2, =TIMER1_CTL
    LDR    R0, [R1,R2]
    BIC    R0, #0x01
    STR    R0, [R1,R2]
    ;select16 bit timer
    LDR    R2, =TIMER1_CFG
    MOV    R0, #0x04 ;16 bit mode
    STR    R0, [R1,R2]

    LDR   R2, =TIMER1_TAMR
    mov   R0, #0x02 ; set to periodic, count down 
    STR   R0, [R1,R2]
    ;
          ;
    LDR   R2, =TIMER1_TAILR ; load value, 
    LDR   R0, =62500   ;62500 * 256 = 16M, get every one second
    STR    R0, [R1,R2];
    
    LDR    R2, =TIMER1_TAPR
    MOV    R0, #0xff    ;prescaler 256, get 15us count interval 
    STR    R0, [R1,R2]
    
    LDR    R2, =TIMER1_TAMATCHR
    MOV    R0, #0
    STR    R0, [R1,R2]

    ;
    LDR    R2, =TIMER1_IMR ; enable timeout interrupt
    MOV   R0, #0x01
    STR     R0, [R1,R2]
      
    ;;;;;CONFIG NVIC TIMER3A INTTERYPT 23
    LDR    R1, =NVIC_BASE
    LDR    R2, =NVIC_PRI8
    LDR    R0, [R1,R2]
    LDR    R3, =0x30000000 ;priorty 3
    ORR    R0,R3
    STR    R0, [R1,R2]
    
    LDR    R2, =NVIC_EN1
    LDR    R0, [R1,R2]
    LDR    R3, =0x00000008 ;3th bit 1
    ORR    R0, R3
    STR    R0, [R1,R2]
	
	LDR    R1,=TIMER3
    ;enable
    LDR    R2, =TIMER_CTL
    LDR    R0, [R1,R2]
    ORR    R0, #0x001
    STR    R0, [R1,R2]
	BX LR 					; return

	ENDP
	END
			
My_Timer1A_Handler	PROC		
					
					BX LR 					; return




			ENDP
			END
