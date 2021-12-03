#include <xc.inc>

global	signal_setup, pwm, microtone
extrn	delay_x4us, delay_x1us, sensor_clock01, sensor_clock02
    
psect	sig_code, class = CODE

signal_setup:
	movlw	0x0
	movwf	TRISD, A
	return

pwm:	
	; =================== note  =================
	; C4
	; 250  delay_x4us
	; 228  delay_x4us
	
	; C6
	; 250  delay_x4us
	; 228  delay_x4us 
	
	movlw	0x01
	movwf	PORTD, A
	
	movlw	250		    ; time period 250us for C4
	call	delay_x4us
	movlw	228  
	call	delay_x4us
;	movlw	20	    
;	call	delay_x1us
	
	movlw	0x0
	movwf	PORTD, A
	
	movlw	250		    ; time period 250us for C4
	call	delay_x4us
	movlw	228	    
	call	delay_x4us
;	movlw	20   
;	call	delay_x1us
	
	bra	pwm
	return
	
microtone:
	movlw	11
	mulwf	sensor_clock01
	
;	nop
	
	return 
;	

	
end
	
	
	
	
	