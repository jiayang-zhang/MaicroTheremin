#include <xc.inc>
   
psect	udata_acs
delay_cnt_low:	ds  1
delay_cnt_high:	ds  1
    
 
psect	code, abs
main:
	org 0x0
	goto	setup

	org 0x100		    ; Main code starts here at address 0x100

		; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
     	movlw	0x0
	movwf	TRISE, A	    ; Port E all outputs ; set PORTE to 11111100, output=0 input=1
	
	
	movlw	0x01
	movwf	PORTE, A	    ;  high 
	
	movlw	0x0
	
;	goto	start

	
;	
;
;delay_x4us:		    ; delay given in chunks of 4 microsecond in W
;	movwf	delay_cnt_low, A	; now need to multiply by 16
;	swapf   delay_cnt_low, F, A	; swap nibbles
;	movlw	0x0f	    
;	andwf	delay_cnt_low, W, A ; move low nibble to W
;	movwf	delay_cnt_high, A	; then to LCD_cnt_h
;	movlw	0xf0	    
;	andwf	delay_cnt_low, F, A ; keep high nibble in LCD_cnt_l
;	call	delay_basic
;	return
;
;delay_basic:			; delay routine	4 instruction loop == 250ns	    
;	movlw 	0x00		; W=0
;	
;lp1:	decf 	delay_cnt_low, F, A	; no carry when 0x00 -> 0xff
;	subwfb 	delay_cnt_high, F, A	; no carry when 0x00 -> 0xff
;	bc 	lp1		; carry, then loop again
;	return			; carry reset so return
	
end