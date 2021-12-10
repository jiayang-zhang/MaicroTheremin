#include <xc.inc>

global	signal_setup, microtone, volume_update, pwm
extrn	delay_x4us, delay_x1us, sensor_clock01, sensor_clock02

extrn	MUL16x16, ARG1H, ARG1L, ARG2H, ARG2L, RES3, RES2, RES1, RES0
    

psect	udata_acs
half_period_h:	ds  1
half_period_l:	ds  1
dummy_256:  ds 1
counter_length:	ds  1
count_256:  ds	1   
 
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
	movlw	6
	mulwf	sensor_clock01 ; PRODH: PRODL
	
	movlw	0xDE 
	addwf	PRODL, A
	; add carry bit to PRODH
	
	movlw	0x01
	addwfc	PRODH, A
	
	movff	PRODH, half_period_h, A
	movff	PRODL, half_period_l, A
	
	
	return 

volume_update:
    
	movff	sensor_clock02, PORTH, A
	return

	
cycle_count:
	movff	half_period_h, ARG1H
	movff	half_period_l, ARG1L
	
	movlw	0x2B
	movwf	ARG2L
	movlw	0x00
	movwf	ARG2H
	
	call	MUL16x16
	movlw	0xAB
	addwf	RES1, A

	movlw	0x01
	addwfc	RES2, A
	
	return
	
	
pwm:	

	movlw	50
	movwf	counter_length, A
	
pwm_loop:
	movlw	0x01		     ; time period for high
	movwf	PORTD, A
	
	call	loop_256
	movf	half_period_l, W, A
	call	delay_x1us
	
	
	movlw	0x00		    ; time period for low
	movwf	PORTD, A
	
	call	loop_256
	movf	half_period_l, W, A
	call	delay_x1us
	

	decfsz	RES1, A		; one beat length
	bra	pwm_loop
	
	movlw	0x00
	cpfseq	RES2
	return
	
	decf	RES2, A
	movlw	256
	movwf	RES1, A
	bra	pwm_loop
	
	return
	
	
	
loop_256:
	movff	half_period_h, dummy_256, A
    
loop_256_inner:
	movlw	64	    
	call	delay_x4us
	
	decfsz	dummy_256, A
	bra	loop_256_inner	
	
	return

	
	
end
	
	
	
	
	