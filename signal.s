#include <xc.inc>

global	signal_setup, convert_half_full, tone_toggle
global	full_period_h, full_period_l
    
extrn	delay_x4us, delay_x1us, pitch_count, volume_count
extrn	HexDec_Convert_Precise, HexDec_Convert_Rough
extrn	lcd_setup, display_microtone, display_pentatone, display_cmajor, display_period


psect	udata_acs
half_period_h:	    ds  1
half_period_l:	    ds  1
full_period_h:	    ds	1  
full_period_l:	    ds	1   
dummy_256:	    ds  1
counter_ref_high:   ds  1
counter_ref_low:    ds  1
dummy_cr_high:	    ds	1   
dummy_cr_low:	    ds	1
    
octave_count:	    ds	1
    
    
    
psect data
cmajorTable:	
    	db	0x01, 0xDE
	db	0x01, 0xFA
	db	0x02, 0x38
	db	0x02, 0x7E
	db	0x02, 0xCC
	db	0x02, 0xF6
	db	0x03, 0x53
	db	0x03, 0xBC
	db	0x03, 0xF4
	db	0x04, 0x70
	db	0x04, 0xFC
	db	0x05, 0x98
	db	0x05, 0xED
	db	0x06, 0xA7
	db	0x07, 0x77
	db	0x07, 0x77
	align	2
	
amajorTable:	
    	db	0x01, 0xDE
	db	0x01, 0xFA
	db	0x02, 0x38
	db	0x02, 0x7E
	db	0x02, 0xCC
	db	0x02, 0xF6
	db	0x03, 0x53
	db	0x03, 0xBC
	db	0x03, 0xF4
	db	0x04, 0x70
	db	0x04, 0xFC
	db	0x05, 0x98
	db	0x05, 0xED
	db	0x06, 0xA7
	db	0x07, 0x77
	db	0x07, 0x77
	align	2
	
    
psect	sig_code, class = CODE

signal_setup:
	movlw	0x0
	movwf	TRISD, A
	movlw	0x00
	movwf	counter_ref_high, A
	movlw	0x00
	movwf	counter_ref_low, A
	
	movlw	0x0
	movwf	TRISB, A
	
	movlw	00000011B    ; for tone toggle  ; pin01 of PORTC
	movwf	TRISC
	
	movlw	255
	movwf	pitch_count
	movwf	volume_count
	
	return

	
tone_toggle:
;	call	HexDec_Convert_Precise
;	call	display_period
	
	btfss	PORTC, 0, A	; skip if 1
	call	microtone	; low , call penta
	btfss	PORTC, 0, A
	call	display_microtone
	btfss	PORTC, 0, A
	return
	
	btfss	PORTC, 1, A
	call	cmajor
	btfss	PORTC, 1, A
	call	display_cmajor
	btfss	PORTC, 1, A
	return
	
	call	pentatone
	call	display_pentatone

	return

microtone:	
	movlw	6
	mulwf	pitch_count ; PRODH: PRODL
	
	movlw	0xDE 
	addwf	PRODL, A
	; add carry bit to PRODH
	
	movlw	0x01
	addwfc	PRODH, A
	
	movff	PRODH, half_period_h, A
	movff	PRODL, half_period_l, A
	
	
	return 

	
cmajorTable_read:
 	movlw	low highword(cmajorTable)	; address of data in PM
	movwf	TBLPTRU, A			; load upper bits to TBLPTRU
	movlw	high(cmajorTable)		; address of data in PM
	movwf	TBLPTRH, A			; load high byte to TBLPTRH
	movlw	low(cmajorTable)		; address of data in PM
	movwf	TBLPTRL, A			; load low byte to TBLPTRL
	return

cmajor:
	call	cmajorTable_read
	
	swapf	pitch_count, f, A
	movlw	0x0f
	andwf	pitch_count, A
	
	; Multiply by two and add to TBLPTR
	rlncf	pitch_count, W, A
	addwf	TBLPTRL, F
	movlw	0x0
	addwfc	TBLPTRH, F
	addwfc	TBLPTRU, F
	
	; Write the new frequency into CCP compare registers
	tblrd*+
	movff	TABLAT, half_period_h
	tblrd*
	movff	TABLAT, half_period_l
	
	return
		
	
pentatone:
	; compare number counts 
	movlw	0x07		    ; set C4
	movwf	half_period_h, A
	movlw	0x77
	movwf	half_period_l, A
	
	movlw	233		    ; C4   if   pitch_count = 256 to 235
	cpfslt	pitch_count 
	return
	
	
	movlw	0x06		    ; set D4
	movwf	half_period_h, A
	movlw	0xA7
	movwf	half_period_l, A
	
	movlw	210		    ; D4   if   pitch_count = 235 to 214
	cpfslt	pitch_count 
	return
	
	
	movlw	0x05		    ; set E4
	movwf	half_period_h, A
	movlw	0xED
	movwf	half_period_l, A
	
	movlw	187		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x04		    ; set G4
	movwf	half_period_h, A
	movlw	0xFC
	movwf	half_period_l, A
	
	movlw	164		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x04		    ; set A4
	movwf	half_period_h, A
	movlw	0x70
	movwf	half_period_l, A
	
	movlw	141		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x03		    ; set C5
	movwf	half_period_h, A
	movlw	0xBC
	movwf	half_period_l, A
	
	movlw	118		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x03		    ; set D5
	movwf	half_period_h, A
	movlw	0x53
	movwf	half_period_l, A
	
	movlw	95		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x02		    ; set E5
	movwf	half_period_h, A
	movlw	0xF6
	movwf	half_period_l, A
	
	movlw	72		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x02		    ; set G5
	movwf	half_period_h, A
	movlw	0x7E
	movwf	half_period_l, A
	
	movlw	49		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x02		    ; set A5
	movwf	half_period_h, A
	movlw	0x38
	movwf	half_period_l, A
	
	movlw	26		    
	cpfslt	pitch_count 
	return
	
	
	movlw	0x01		    ; set C6
	movwf	half_period_h, A
	movlw	0xDE
	movwf	half_period_l, A
	

	return	

	
convert_half_full:
    
	movff	half_period_h, full_period_h, A
	movff	half_period_l, full_period_l, A
	
	bcf	3, 0
	rlcf	full_period_l, A
	rlncf	full_period_h, A
	movlw	0x0
	addwfc	full_period_h, A	
	
	movff	full_period_l, CCPR4L, A
	movff	full_period_h, CCPR4H, A
	
	return
	
end
	
	
	
	
	