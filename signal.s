#include <xc.inc>

global	signal_setup, pwm_c4, microtone
extrn	delay_x4us, delay_x1us, sensor_clock01, sensor_clock02


psect	data
half_period_h:	ds  1
half_period_l:	ds  1
    
psect	sig_code, class = CODE

signal_setup:
	movlw	0x0
	movwf	TRISD, A
	return

pwm_c4:	
	; =================== note  =================
	; C4
	; 250  delay_x4us
	; 228  delay_x4us
	
	; C6
	; 250  delay_x4us
	; 228  delay_x4us 
	
	movlw	0x01
	movwf	PORTD, A
	
;	movlw	250		    ; time period 250us for C4
;	call	delay_x4us
;	movlw	228  
;	call	delay_x4us
	movlw	10
	call	delay_x1us

	
	movlw	0x0
	movwf	PORTD, A
	
;	movlw	250		    ; time period 250us for C4
;	call	delay_x4us
;	movlw	228	    
;	call	delay_x4us
	movlw	10
	call	delay_x1us

	
	bra pwm_c4
	return
	
microtone:
	clrf	PRODH
	clrf	PRODL
	
	movlw	6
	mulwf	sensor_clock01 ; PRODH: PRODL
	
	movlw	0xDE 
	addwf	PRODL, A
	; add carry bit to PRODH
	
	movlw	0x01
	addwfc	PRODH, A
	
	movff	PRODL, 0x07, A
	movff	PRODH, 0x06, A
	
	return 
	
end
	
	
	
	
	