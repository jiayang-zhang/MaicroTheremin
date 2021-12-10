#include <xc.inc>
 
;extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Instruction, LCD_Send_Byte_D
extrn	delay_x4us, delay_x1us
extrn	signal_setup, microtone, pentatone, volume_update, pwm
extrn	transducer_setup, trans_get, sensor_clock01, sensor_clock02
    
    
psect	code, abs
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
	
	goto	start	
	
start:
	call	trans_get
	
	;call	trans_capture_pitch
	;btfss	PIR1, CCP1IF
	;call	microtone ;update freq if capture flag triggered
	
	
	call	microtone
;	call	pentatone
	call	volume_update
;;;	movff	sensor_clock01, PORTB, A
	call	pwm	; waveform of choice

    
 
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

    end