#include <xc.inc>
 
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Instruction, LCD_Send_Byte_D

    
psect	udata_acs
delay_cnt_low:	ds  1
delay_cnt_high:	ds  1
sensor_clock:	ds  1
    
 
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
	movwf	TRISE, A	    ; output=0 input=1
	movlw	0x0
	movwf	TRISF, A	    ; output=0 input=1
	movlw	0x0
	movwf	TRISJ, A
	movlw	0x0
	movwf	TRISH, A
;	call	LCD_Setup 	; setup LCD

	
	goto	start

lcd_position:
	; write to DDRAM --> set which each pixel block
	;(CGRAM --> each pixel within a block)
	
	; movlw	11000000B	; position address instruction	; hex = 40
	movlw	11000001B	; hex = 41
	call	LCD_Write_Instruction
	return 
	
	
	
	
start:
	; set port as output - to sensor
	movlw	0x01		    ; high - 4us
	movwf	PORTE, A
	movwf	PORTF, A	
	movlw	1		    ; wait 4us
	call	delay_x4us
	; reset to zero
	movlw	0x00		    ; low - for delay while reading the input
	movwf	PORTE, A
	movwf	PORTF, A

	; set port as input - to sensor
	movlw	0x01
	movwf	TRISE, A
	movwf	TRISF, A
	
	; start the countdown
	call	count_loop_init_1
	call	count_loop_init_2

	; call LCD
;	call	lcd_position
;	movf	sensor_clock, w, A	; output message to LCD
;;	movlw	0x01
;	call	LCD_Send_Byte_D
	
	; low - delay
	movlw	250		    ; low - wait 1ms
	call	delay_x4us	

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

delay_basic:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
	
lp1:	decf 	delay_cnt_low, F, A	; no carry when 0x00 -> 0xff
	subwfb 	delay_cnt_high, F, A	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return			; carry reset so return
	
	

count_loop_init_1:
	; 8-bits: count from 0 to 255
    	movlw	0
	movwf	sensor_clock, A
   
count_loop_1:
	; check update frequency
	movff	sensor_clock, PORTH, A

	; increment clock
	incf	sensor_clock, A
	
	; delay
	movlw	6		    ; wait 4us
	call	delay_x4us
	
	movlw	0
	; compare porte with w, skip if equals
	cpfseq	PORTE, A
	bra	count_loop_1
	return

count_loop_init_2:
	; 8-bits: count from 0 to 255
    	movlw	0
	movwf	sensor_clock, A
   
count_loop_2:
	; check update frequency
	movff	sensor_clock, PORTJ, A

	; increment clock
	incf	sensor_clock, A
	
	; delay
	movlw	6		    ; wait 4us
	call	delay_x4us
	
	movlw	0
	; compare porte with w, skip if equals
	cpfseq	PORTE, A
	bra	count_loop_2
	return
	
end