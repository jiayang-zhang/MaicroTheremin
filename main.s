#include <xc.inc>
 
;extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Instruction, LCD_Send_Byte_D
extrn	delay_x4us, delay_x1us
extrn	signal_setup, microtone, pentatone, volume_update, pwm
extrn	transducer_setup, trans_get, pitch_count, volume_count
    
    
psect	code, abs

rst:	org	0x0
	bra	setup
	
main:
	org	0x0
	goto	setup

	org	0x100		    ; Main code starts here at address 0x100

		; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
	; set port as output	    ; output=0 input=1
	call	signal_setup
	call	transducer_setup
	
	movlw	0x00
	movwf	TRISF, A
	bsf	TRISE, 5, A	    ; set PORTE's RE5 as input

	goto	start	
	
start:
	clrf	PORTF
	call	trans_get
	
	movlw	200
	call	delay_x4us
	movlw	200
	call	delay_x4us
	movlw	200
	call	delay_x4us
	movlw	200
	call	delay_x4us
;	call	microtone
;	call	pentatone
;	call	volume_update
;;;	movff	pitch_count, PORTB, A
;	call	pwm	; waveform of choice

    
 
	bra	start
	return
	
	
;lcd_position:
;	; write to DDRAM --> set which each pixel block
;	;(CGRAM --> each pixel within a block)
;	
;	; movlw	11000000B	; position address instruction	; hex = 40
;	movlw	11000001B	; hex = 41
;	call	LCD_Write_Instruction
;	return 
;	

interrupt:
	org	0x08
	btfss	PIR4, 4 ; check if ccp7 capture interrupt
	retfie ; return if not ccp7 interrupt
	movff	TMR1H, pitch_count, A ; store captured clock into variable
	movlw	0xff
	movwf	PORTF, A ; store captured clock into variable
	bcf	PIR4, 4 ; clear the interrupt flag
	retfie
	
    end