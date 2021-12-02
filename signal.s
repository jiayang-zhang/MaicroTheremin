#include <xc.inc>

global	signal_setup
extrn	delay_x4us, delay_x1us
    
psect	code, abs

signal_setup:
	movlw	0x0
	movwf	TRISD, A
	call	pwm
	return
	

pwm:	
	movlw	0x01
	movwf	PORTD, A
	
	movlw	250		    ; time period 250us for C4
	call	delay_x1us
;	movlw	220	    
;	call	delay_x4us
;	movlw	31	    
;	call	delay_x1us
	
	movlw	0x0
	movwf	PORTD, A
	
	movlw	250		    ; time period 250us for C4
	call	delay_x1us
;	movlw	220	    
;	call	delay_x4us
;	movlw	31	    
;	call	delay_x1us
	
	bra	pwm
	return
	
end
	
	
	
	
	