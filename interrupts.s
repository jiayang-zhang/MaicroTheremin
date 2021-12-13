#include <xc.inc>

global	pitch_interrupt_start    
    
    
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

	
end
