#include <xc.inc>


global	transducer_setup, trans_get
global	pitch_count, volume_count
    
   
extrn	pitch_interrupt_start    
extrn	delay_x4us, delay_x1us

psect	udata_acs
pitch_count:	ds  1
volume_count:	ds  1
    
    
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
	movlw	200
	movwf	PORTH, A
	return


trans_get:
	; set port as output	    ; output=0 input=1
	movlw	0		    ; high - 4us
	movwf	TRISE, A
	; output 1 - to sensor
	movlw	1		    
	movwf	PORTE, A
	movlw	1		    ; output signal - 4us
	call	delay_x4us	
	; output 0 - to sensor
	movlw	0		    ; for delay and reading the input
	movwf	PORTE, A	
	
;	call	pitch_interrupt_start
	
	; set port as input - read position
	movlw	1
	movwf	TRISE, A
	movlw	188		    ; output signal - 4us
	call	delay_x4us
	; start the countdown
	call	count_loop_init_1
	
	
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

	
	return
	
	
; ===================== countdown function ==================================
count_loop_init_1:
    	movlw	256			    ; 8-bits: count from 0 to 255
	movwf	pitch_count, A
count_loop_1:
	movff	pitch_count, PORTF, A	    ; check update frequency
	dcfsnz	pitch_count, A		    ; increment clock
	return
	
	movlw	2				    ; delay 24us
	call	delay_x4us
;	
	movlw	0
	cpfseq	PORTE, A		    ; compare PORTE with w, skip if equals
	bra	count_loop_1
	return

	
count_loop_init_2:	
    	movlw	256		    ; 8-bits: count from 0 to 255
	movwf	volume_count, A
count_loop_2:
	movff	volume_count, PORTH, A	    ; check update frequency
	dcfsnz	volume_count, A		    ; increment clock
	return
	
	movlw	2		    
	call	delay_x4us
	
	movlw	0
	cpfseq	PORTJ, A	
	bra	count_loop_2
	
	return
	
end


