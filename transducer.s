#include <xc.inc>


global	transducer_setup, trans_get
global	sensor_clock01, sensor_clock02

    
extrn	delay_x4us, delay_x1us

psect	data
sensor_clock01:	ds  1
sensor_clock02:	ds  1
    
    
psect	trans_code, class = CODE
;  ======================== note =========================
; PORTE for sensor01 I/O
; PORTJ for sensor02 I/O
; PORTF for sensor01 reading 
; PORTH for sensor02 reading

transducer_setup:
    	movlw	0x0
	movwf	TRISF, A	    ; output
	movlw	0x0
	movwf	TRISH, A	    ; output
    
trans_get:
	; set port as output	    ; output=0 input=1
	movlw	0x00		    ; high - 4us
	movwf	TRISE, A
	movlw	0x00
	movwf	TRISJ, A
	
	; output 1 - to sensor
	movlw	0x01		    
	movwf	PORTE, A
	movlw	0x01
	movwf	PORTJ, A	
	movlw	1		    ; output signal - 4us
	call	delay_x4us
	
	; output 0 - to sensor
	movlw	0x00		    ; for delay and reading the input
	movwf	PORTE, A
	movlw	0x00
	movwf	PORTJ, A

	; set port as input - read position
	movlw	0x01
	movwf	TRISE, A
	movlw	0x01
	movwf	TRISJ, A
	
	
	; start the countdown
	call	count_loop_init_1
	call	count_loop_init_2
	
	
	return
	
	
; ===================== countdown function ==================================
count_loop_init_1:
    	movlw	0			    ; 8-bits: count from 0 to 255
	movwf	sensor_clock01, A
count_loop_1:
	movff	sensor_clock01, PORTF, A	    ; check update frequency
	incf	sensor_clock01, A		    ; increment clock
	
	movlw	6			    ; delay 24us
	call	delay_x4us
	
	movlw	0
	cpfseq	PORTE, A		    ; compare PORTE with w, skip if equals
	bra	count_loop_1
	return

	
count_loop_init_2:	
    	movlw	0			    ; 8-bits: count from 0 to 255
	movwf	sensor_clock02, A
count_loop_2:
	movff	sensor_clock02, PORTH, A	    ; check update frequency
	incf	sensor_clock02, A		    ; increment clock
	
	movlw	6			    
	call	delay_x4us
	
	movlw	0
	cpfseq	PORTJ, A	
	bra	count_loop_2
	
	return
	
end