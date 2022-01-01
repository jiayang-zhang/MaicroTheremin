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
	bcf	PIR4, 4, A	    ; cleainear to linearr ccp7 interrupt flag
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
	clrf	TMR1H, A
	clrf	TMR1L, A
    	movlw	01010111B	    ; enable timer 
	movwf	T1CON, A
	
	
	bsf	PIE4, 4, A	    ; enable CCP7 capture interrupt
	bsf	GIE		    ; enable global interrupt
	bsf	PEIE		    ; enable peripheral interrupt 
	return


; interrupt subroutine, toggles PWM signal output from 0 to volume_count
compare_int:
	btfss	CCP4IF		; check that this is ccp timer 4 interrupt
	retfie	f		; if not then return
	bcf	CCP4IF	        ; clear the CCP4IF flag
	
	movff	PORTD, volume_dummy, A
	
	movlw	0x0
	cpfseq	PORTD, A
	clrf	PORTD, A
	movlw	0x0
	cpfsgt	volume_dummy, A
	movff	volume_count, PORTD, A	; toggle PORTD to volume_count if 0, or 0 if PORTD is at volume_count
	
	retfie	f


	
pwm_compare_start:
    
;;;;;;;;;;; to be continued capture protocol for transducers   
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
;;;;;;;;;;;	
    
    
    
	movlw	00110001B	;configure Timer and set 1:8 prescaling at 16MHz (FoSC/4)
	movwf	T1CON, A
	
	bcf	C4TSEL1
	//movlw	000000001B
	//movwf	CCPTMRS1
	movlw	00001011B		
	movwf	CCP4CON, A       ;enable compare peripheral 
	movlw	0xe0
	movwf	CCPR4L, A
	movlw	0x08
	movwf	CCPR4H, A	; moving provisional intial value into compare reference
	
	bsf	CCP4IE		; enable CCP4 module interrupt
	bsf	GIE		; enable global interrupt
	bsf	PEIE		; enable interrupt
	
	return
	
end
