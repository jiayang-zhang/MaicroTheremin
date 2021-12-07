#include <xc.inc>


global	transducer_setup, trans_get
global	sensor_clock01, sensor_clock02

    
extrn	delay_x4us, delay_x1us

psect	udata_acs
sensor_clock01:	ds  1
sensor_clock02:	ds  1
    
    
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
	movwf	TRISH, A	    ; output
	return

	
trans_capture_pitch:
	
	movlw	b'00000100'
	movwf	CCP1CON		    ;Capture Mode, every falling edge on RC2
	movlw	b'00110100'
	movwf	T1CON		    ;Capture Mode, every falling edge on RC2
	bsf	STATUS,RP0	    ;Bank 1
	bsf	TRISC,2		    ;Make RC2 input
	clrf	TRISB		    ;Make PORTB output
;	bcf	STATUS,RP0	    ;Bank 0
;	bsf	T1CON,TMR1ON
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
	movwf	sensor_clock01, A
count_loop_1:
	movff	sensor_clock01, PORTF, A	    ; check update frequency
	decf	sensor_clock01, A		    ; increment clock
	
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