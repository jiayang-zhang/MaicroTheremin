#include <xc.inc>

global	pitch_interrupt_start, pwm_compare_start, compare_int
    
extrn	volume_count
    
psect	udata_acs
volume_dummy:	ds  1
    
    
psect	interrupt_code, class = CODE
 

pitch_interrupt_start:
	
	movlw	00000100B	    ; set CCP7
	movwf	CCP7CON, A 
	bcf	PIE4, 4, A	    ; disable CCP7 capture interrupt
	bcf	PIR4, 4, A	    ; clear ccp7 interrupt flag
	bsf	IPR4, 4, A	    ; set interrupt as high priority

	bcf	C7TSEL1		    ; match CCP7 to TMR1
	bcf	C7TSEL0		    ; match CCP7 to TMR1

        bsf	TRISE, 5, A	    ; set PORTE's RE5 as input
	
	; setup t1con timer1 configuration and start clock 
	
	;bit 76 = clock source
	;bit 54 = prescaler
	;bit 3 = oscillator module enable
	;bit 2 = symch to external clock
	;bit 1 = 16bit or 8 bit operation clock
	;bit 0 = on/off timer
	bcf	T1CON, 0, A	    ; disable timer
	clrf	TMR1H
	clrf	TMR1L
    	movlw	01010111B	    ; enable timer 
	movwf	T1CON, A
	
	
	bsf	PIE4, 4, A	    ; enable CCP7 capture interrupt
	bsf	GIE		    ; enable global interrupt
	bsf	PEIE		    ; enable peripheral interrupt 
	return

	
compare_int:
	btfss	CCP4IF		; check that this is ccp timer 4 interrupt
	retfie	f		; if not then return
	bcf	CCP4IF	        ; clear the CCP4IF flag
	
	bsf	PORTC,	4
	bcf	PORTC,	4
	movff	PORTD, volume_dummy, A
	
	movlw	0x0
	cpfseq	PORTD, A
	clrf	PORTD, A
	movlw	0x0
	cpfsgt	volume_dummy, A
	movff	volume_count, PORTD, A
	
	retfie	f


	
pwm_compare_start:
    
;	movlw	00110001B
;	movwf	T3CON
;	
;	bsf	C4TSEL1	    ;set ccp4 to timer3
;	bcf	C4TSEL0	    ;set ccp4 to timer3
;
;	movlw	000000010B
;	movwf	CCPTMRS1
;	movlw	00001011B		
;	movwf	CCP4CON         	
;	movlw	0xff
;	movwf	CCPR4L
;	movlw	0x00
;	movwf	CCPR4H
;	
;	bsf	CCP4IE	
;	bsf	GIE
;	bsf	PEIE
	
	movlw	00110001B
	movwf	T1CON
	
	bcf	C4TSEL1
	//movlw	000000001B
	//movwf	CCPTMRS1
	movlw	00001011B		
	movwf	CCP4CON         	
	movlw	0xe0
	movwf	CCPR4L
	movlw	0x08
	movwf	CCPR4H
	
	bsf	CCP4IE	
	bsf	GIE
	bsf	PEIE
	
	return
	
end
