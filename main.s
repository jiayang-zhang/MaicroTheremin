#include <xc.inc>

extrn	delay_x4us, delay_x1us, delay_x1ms	; from delay module
extrn	signal_setup, convert_half_full, tone_toggle   ; from signal module  
extrn	transducer_setup, trans_get, pitch_count, volume_count ;from transducer
extrn	pwm_compare_start, compare_int	; from interrupt module
extrn	lcd_setup   ; from lcd config module

    
    
psect	udata_acs
interrupt_count:    ds  1

    
psect	code, abs

rst:
	org	0x0		    ;reset code starts here at address 0x0
	goto	setup

		; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
	; set port as output	    ; output=0 input=1
	call	signal_setup
	call	transducer_setup
	call	lcd_setup
	

	bsf	TRISE, 5, A	    ; set PORTE's RE5 as input
	call	pwm_compare_start   
	
	goto	start	
	
start:
	call	trans_get
	call	tone_toggle

	call	convert_half_full
		    
    	movlw	100
	call	delay_x1ms

	
	bra	start
	return
	


interrupt:	
	   org	0x0008	; high vector, no low vector

	   goto	compare_int
	   
	
;;;;; deprecated capture peripheral test for ultrasound transducers
	   
;interrupt:
;	org	0x08
;	btfss	PIR4, 4			; check if ccp7 capture interrupt
;	retfie				; return if not ccp7 interrupt
;	movff	TMR1H, pitch_count, A	; store captured clock into variable
;	movlw	0xff
;	movwf	PORTF, A		; store captured clock into variable
;	
;	incf	interrupt_count
;	movff	interrupt_count, PORTF, A	; store captured clock into variable
;
;	bcf	PIR4, 4			; clear the interrupt flag
;	retfie
	
    end	rst