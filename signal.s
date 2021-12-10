#include <xc.inc>

global	signal_setup, microtone, pentatone, volume_update, pwm
extrn	delay_x4us, delay_x1us, sensor_clock01, sensor_clock02

extrn	MUL16x16, ARG1H, ARG1L, ARG2H, ARG2L, RES3, RES2, RES1, RES0
    

psect	udata_acs
half_period_h:	    ds  1
half_period_l:	    ds  1
dummy_256:	    ds  1
counter_ref_high:   ds  1
counter_ref_low:    ds  1
dummy_cr_high:	    ds	1   
dummy_cr_low:	    ds	1
psect	sig_code, class = CODE

signal_setup:
	movlw	0x0
	movwf	TRISD, A
	movlw	0x01
	movwf	counter_ref_high
	movlw	0x00
	movwf	counter_ref_low
	
	movlw	0x0
	movwf	TRISB, A
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

	
pentatone:
	; compare number counts 
	movlw	0x07		    ; set C4
	movwf	half_period_h, A
	movlw	0x77
	movwf	half_period_l, A
	
	movlw	233		    ; C4   if   sensor_clock01 = 256 to 235
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x06		    ; set D4
	movwf	half_period_h, A
	movlw	0xA7
	movwf	half_period_l, A
	
	movlw	210		    ; D4   if   sensor_clock01 = 235 to 214
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x05		    ; set E4
	movwf	half_period_h, A
	movlw	0xED
	movwf	half_period_l, A
	
	movlw	187		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x04		    ; set G4
	movwf	half_period_h, A
	movlw	0xFC
	movwf	half_period_l, A
	
	movlw	164		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x04		    ; set A4
	movwf	half_period_h, A
	movlw	0x70
	movwf	half_period_l, A
	
	movlw	141		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x03		    ; set C5
	movwf	half_period_h, A
	movlw	0xBC
	movwf	half_period_l, A
	
	movlw	118		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x03		    ; set D5
	movwf	half_period_h, A
	movlw	0x53
	movwf	half_period_l, A
	
	movlw	95		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x02		    ; set E5
	movwf	half_period_h, A
	movlw	0xF6
	movwf	half_period_l, A
	
	movlw	72		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x02		    ; set G5
	movwf	half_period_h, A
	movlw	0x7E
	movwf	half_period_l, A
	
	movlw	49		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x02		    ; set A5
	movwf	half_period_h, A
	movlw	0x38
	movwf	half_period_l, A
	
	movlw	26		    
	cpfslt	sensor_clock01 
	return
	
	
	movlw	0x01		    ; set C6
	movwf	half_period_h, A
	movlw	0xDE
	movwf	half_period_l, A
	

	return

	
volume_update:
	movlw	0xff
	movwf	PORTH, A
;	movff	sensor_clock02, PORTH, A
	return

	
cycle_count:
	movff	half_period_h, ARG1H
	movff	half_period_l, ARG1L
	
	movlw	0x1B
	movwf	ARG2L
	movlw	0x00
	movwf	ARG2H
	
	call	MUL16x16
	
	movff	counter_ref_low, dummy_cr_low
	movff	counter_ref_high, dummy_cr_high
	
	movf	RES1, W, A
	subwf	dummy_cr_low, A
	
	movf	RES2, W, A
	subwfb	dummy_cr_high, A
	
	movff	dummy_cr_high, RES2, A
	movff	dummy_cr_low, RES1, A
	
	movff	dummy_cr_low, PORTB, A
	
	return
	
	
pwm:	
	call	cycle_count
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
	movlw	128
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
	
	
	
	
	