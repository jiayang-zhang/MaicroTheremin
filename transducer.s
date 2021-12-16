#include <xc.inc>


global	transducer_setup, trans_get
global	pitch_count, volume_count
    
   
extrn	pitch_interrupt_start    
extrn	delay_x4us, delay_x1us

psect	udata_acs
pitch_count:	ds  1
volume_count:	ds  1
pitch_temp:	ds  1	
volume_temp:	ds  1
    
    
psect	trans_code, class = CODE
;  ======================== note =========================
; PORTE for sensor01 I/O
; PORTJ for sensor02 I/O
; PORTF for sensor01 reading 
; PORTH for sensor02 reading

transducer_setup:
    	movlw	0
	movwf	TRISF, A	    ; output
	movlw	0
	movwf	TRISJ, A	    ; output
	movlw	0
	movwf	TRISH, A	    ; output
;	movlw	200
;	movwf	PORTH, A
;	return


trans_get:
;	 set port as output	    ; output=0 input=1
	movlw	0		    ; high - 4us
	movwf	TRISE, A
	movlw	1		    ; output 1 - to sensor    
	movwf	PORTE, A
	movlw	1		    ; output signal - 4us
	call	delay_x4us	
	
	movlw	0		    ; output 0 - to sensor ; for delay and reading the input
	movwf	PORTE, A	
	
	; set port as input - read position
	movlw	1
	movwf	TRISE, A
	movlw	188		    ; output signal - 4us
	call	delay_x4us
	; start the countdown
	call	count_loop_init_1
	movff	pitch_temp, pitch_count, A
	
	movlw	0
	movwf	TRISJ, A
	movlw	1
	movwf	PORTJ, A	
	movlw	1		    ; output signal - 4us
	call	delay_x4us	
	movlw	0
	movwf	PORTJ, A
	movlw	1
	movwf	TRISJ, A
	movlw	188		    ; output signal - 4us
	call	delay_x4us
	call	count_loop_init_2
	movff	volume_temp, volume_count, A

	
	return
	
	
; ===================== countdown function ==================================
count_loop_init_1:
    	movlw	256			    ; 8-bits: count from 0 to 255
	movwf	pitch_temp, A
count_loop_1:
	movff	pitch_temp, PORTF, A	    ; check update frequency
	dcfsnz	pitch_temp, A		    ; increment clock
	return
	
	movlw	2				    ; delay 24us
	call	delay_x4us
	
	btfsc	PORTE, 0,  A		    ; compare PORTE with w, skip if equals
	bra	count_loop_1
	return

	
count_loop_init_2:	
    	movlw	80		    ; 8-bits: count from 0 to 255
	movwf	volume_temp, A
count_loop_2:
	movff	volume_temp, PORTH, A	    ; check update frequency
	dcfsnz	volume_temp, A		    ; increment clock
	return
	
	movlw	2 
	call	delay_x4us
	
	btfsc	PORTJ, 0, A	
	bra	count_loop_2
	
	return
	
end





