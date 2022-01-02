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

    
psect data
; these scale tables are all 16bit HALF periods, to be converted later
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
    	db	0x01, 0xC2
	db	0x01, 0xFA
	db	0x02, 0x38
	db	0x02, 0x59
	db	0x02, 0xA3
	db	0x02, 0xF6
	db	0x03, 0x53
	db	0x03, 0x85
	db	0x03, 0xF4
	db	0x04, 0x70
	db	0x04, 0xB3
	db	0x05, 0x47
	db	0x05, 0xEC
	db	0x06, 0xA6
	db	0x07, 0x0B
	db	0x07, 0x0B
	align	2
	
    
psect	sig_code, class = CODE

signal_setup:
	movlw	0x0
	movwf	TRISD, A	; prepare PORTD as PWM signal output

	
	movlw	0x0
	movwf	TRISB, A
	
	movlw	00000011B	; for tone toggle, using two inputs for now
	movwf	TRISC, A
	
	;;; just initialising pitch_count and volume_count with max to help 
	;;; with debugging
	movlw	255
	movwf	pitch_count, A
	movwf	volume_count, A
	
	return


;; selection subroutine that chooses tone mapping protocol based on switches
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



; right shift to multiply half period by 2 to accomodate CCP 0.5MHz clock
convert_half_full:
    
	movff	half_period_h, full_period_h, A
	movff	half_period_l, full_period_l, A
	
	bcf	3, 0, A
	rlcf	full_period_l, A
	rlncf	full_period_h, A
	movlw	0x0
	addwfc	full_period_h, A	
	
	movff	full_period_l, CCPR4L, A
	movff	full_period_h, CCPR4H, A
	
	return

	
	
;;; linear scaling of 0-255 pitch count to c4 - c6 half period values
microtone:	
	movlw	6
	mulwf	pitch_count, A ; PRODH: PRODL
	
	movlw	0xDE 
	addwf	PRODL, A
	; add carry bit to PRODH
	
	movlw	0x01
	addwfc	PRODH, A
	
	movff	PRODH, half_period_h, A
	movff	PRODL, half_period_l, A
	
	return 	
	
	

cmajor:
	movlw	low highword(cmajorTable)	; address of data in PM
	movwf	TBLPTRU, A			; load upper bits to TBLPTRU
	movlw	high(cmajorTable)		; address of data in PM
	movwf	TBLPTRH, A			; load high byte to TBLPTRH
	movlw	low(cmajorTable)		; address of data in PM
	movwf	TBLPTRL, A			; load low byte to TBLPTRL
	
	swapf	pitch_count, f, A		; make higher nibble the lower one
	movlw	0x0f				; set mask for lower nibble
	andwf	pitch_count, A			; take lower nibble for counting
						; this is equivalent to dividing by 2**4 = 16
						; so we map 256 integers to 16 bins
	; Multiply by two and add to TBLPTR
	rlncf	pitch_count, W, A
	addwf	TBLPTRL, F, A
	movlw	0x0
	addwfc	TBLPTRH, F, A
	addwfc	TBLPTRU, F, A
	
	; Write the new frequency into CCP compare registers
	tblrd*+
	movff	TABLAT, half_period_h
	tblrd*
	movff	TABLAT, half_period_l
	
	return
		
	
; 'ladder' comparator chain to map period values to pitch_count
pentatone:
	; compare number counts 
	movlw	0x07		    ; set C4
	movwf	half_period_h, A
	movlw	0x77
	movwf	half_period_l, A
	
	movlw	233		    ; C4   if   pitch_count = 256 to 235
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x06		    ; set D4
	movwf	half_period_h, A
	movlw	0xA7
	movwf	half_period_l, A
	
	movlw	210		    ; D4   if   pitch_count = 235 to 214
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x05		    ; set E4
	movwf	half_period_h, A
	movlw	0xED
	movwf	half_period_l, A
	
	movlw	187		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x04		    ; set G4
	movwf	half_period_h, A
	movlw	0xFC
	movwf	half_period_l, A
	
	movlw	164		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x04		    ; set A4
	movwf	half_period_h, A
	movlw	0x70
	movwf	half_period_l, A
	
	movlw	141		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x03		    ; set C5
	movwf	half_period_h, A
	movlw	0xBC
	movwf	half_period_l, A
	
	movlw	118		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x03		    ; set D5
	movwf	half_period_h, A
	movlw	0x53
	movwf	half_period_l, A
	
	movlw	95		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x02		    ; set E5
	movwf	half_period_h, A
	movlw	0xF6
	movwf	half_period_l, A
	
	movlw	72		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x02		    ; set G5
	movwf	half_period_h, A
	movlw	0x7E
	movwf	half_period_l, A
	
	movlw	49		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x02		    ; set A5
	movwf	half_period_h, A
	movlw	0x38
	movwf	half_period_l, A
	
	movlw	26		    
	cpfslt	pitch_count, A 
	return
	
	
	movlw	0x01		    ; set C6
	movwf	half_period_h, A
	movlw	0xDE
	movwf	half_period_l, A
	

	return	
	

end
	
	
	
	
	
