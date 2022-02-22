;***************************************************************
; Delay subroutine (~1ms)
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
POINTONESEC		EQU			30000
;***************************************************************	
;LABEL		DIRECTIVE		VALUE		COMMENT
			AREA			routines, CODE, READONLY
			THUMB
			EXPORT		DELAY100
;***************************************************************				
DELAY100		PROC
				PUSH{R2,LR}
				LDR		R2,=POINTONESEC
loop			SUBS	R2,#1
				BCC 	end_loop
				BCS		loop
					
end_loop		POP{R2,LR}
				BX	LR
			ENDP
		END