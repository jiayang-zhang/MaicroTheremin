#include <xc.inc>

global	MUL16x16
global	ARG1H, ARG1L, ARG2H, ARG2L
global	RES3, RES2, RES1, RES0

psect	udata_acs
ARG1H:	ds  1    ; kH 
ARG1L:	ds  1	 ; kL
	
ARG2H:	ds  1	 ; voltage H
ARG2L:	ds  1	 ; voltage L

RES3:	ds  1	; final output 3
RES2:	ds  1	; final output 2
RES1:	ds  1	; final output 1
RES0:	ds  1	; final output 0
    
    
    
psect	maths_code, class = CODE

MUL16x16:
	; multiplication
	; X = ARG2H: ARG2L
	; Y = ARG1H: ARG1L
	; Output = X*Y = RES3 RES2 RES1 RES0
	
	MOVF	ARG1L, W
	MULWF	ARG2L	; ARG1L * ARG2L->
			; PRODH:PRODL
	MOVFF	PRODH, RES1 ;
	MOVFF	PRODL, RES0 ;
    ;
	MOVF	ARG1H, W
	MULWF	 ARG2H ; ARG1H * ARG2H->
		    ; PRODH:PRODL
	MOVFF	PRODH, RES3 ;
	MOVFF	PRODL, RES2 ;
    ;
	MOVF	ARG1L, W
	MULWF	ARG2H ; ARG1L * ARG2H->
		    ; PRODH:PRODL
	MOVF	PRODL, W ;
	ADDWF	RES1, F ; Add cross
	MOVF	PRODH, W ; products
	ADDWFC	RES2, F ;
	CLRF	WREG ;
	ADDWFC	RES3, F ;
    ;
	MOVF	ARG1H, W ;
	MULWF	ARG2L ; ARG1H * ARG2L->
		    ; PRODH:PRODL
	MOVF	PRODL, W ;
	ADDWF	RES1, F ; Add cross
	MOVF	PRODH, W ; products
	ADDWFC	RES2, F ;
	CLRF	WREG ;
	ADDWFC	RES3, F ;
	
	return 
	
end