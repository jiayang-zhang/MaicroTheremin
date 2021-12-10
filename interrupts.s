#include <xc.inc>

    

    
itrans_start:
    
    
    
        bsf	TRISE, CCP8, A ; configure CCP1 pin for input
	
	bcf	PIE1, CCP1IE,A ; disable CCP1 capture interrupt
	movlw	0x81 ; enable Timer1, prescaler set to 1,
	movwf	T1CON,A ; 16-bit, y use instruction cycle clock
	movlw	0x05 ; set CCP1 to capture on every rising edge
	movwf	CCP1CON,A ; "
	bcf	PIR1,CCP1IF,A
    
    
    
    
	; setup ccp6con capture interrupt configuration
	movlw	B'00000100'
	movwf	CCP8CON, A
	bsf	IPR4, 3, A
	bsf	PIE4, 3, A
	
	; setup t1con timer1 configuration and start clock
	
	movlw	B'00110011'
	movwf	T1CON, A
	
	
	
	
	bsf	GIE
	bsf	PEIE
	return

