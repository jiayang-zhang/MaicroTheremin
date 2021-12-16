#include <xc.inc>

global delay_x4us, delay_x1us, delay_x1ms
    
psect	udata_acs
delay_cnt_low:	ds  1
delay_cnt_high:	ds  1
delay_cnt_ms:	ds  1	
    
psect	delay_code, class = CODE

 
 ; ===================== x4us delay function ==================================

delay_x1ms:		    ; delay given in ms in W
	movwf	delay_cnt_ms, A
lcdlp2:	movlw	250	    ; 1 ms delay
	call	delay_x4us	
	decfsz	delay_cnt_ms, A
	bra	lcdlp2
	return
 
 
; ===================== x4us delay function ==================================
delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	delay_cnt_low, A	; now need to multiply by 16
	swapf   delay_cnt_low, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	delay_cnt_low, W, A ; move low nibble to W
	movwf	delay_cnt_high, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	delay_cnt_low, F, A ; keep high nibble in LCD_cnt_l
	call	delay_basic
	return
	
; ===================== x1us delay function ==================================	
	
delay_x1us:		    ; delay given in chunks of 1 microsecond in W
	movwf	delay_cnt_low, A
lp2:		
	nop
	nop
	nop
	nop
	nop
	
	nop
	nop
	nop
	nop
	nop
	
	nop
	nop
	nop
	
	decf 	delay_cnt_low, F, A ; no carry when 0x00 -> 0xff
	bc 	lp2		; carry, then loop again
	return
	
	
; ===================== call delay ==================================	
delay_basic:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lp1:	decf 	delay_cnt_low, F, A	; no carry when 0x00 -> 0xff
	subwfb 	delay_cnt_high, F, A	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return			; carry reset so return
	
	
	
end