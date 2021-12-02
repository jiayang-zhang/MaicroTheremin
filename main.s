#include <xc.inc>
 
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Instruction, LCD_Send_Byte_D
extrn	delay_x4us, delay_x1us
extrn	signal_setup
;  ======================== note =========================
; PORTE for sensor01 I/O
; PORTH for sensor02 I/O
; PORTF for sensor01 reading 
; PORTJ for sensor02 reading
    
psect	udata_acs

sensor_clock01:	ds  1
sensor_clock02:	ds  1
    
psect	code, abs
main:
	org 0x0
	goto	setup

	org 0x100		    ; Main code starts here at address 0x100

		; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	signal_setup
	
;	; set port as output	    ; output=0 input=1
	movlw	0x0
	movwf	TRISF, A	    ; output
	movlw	0x0
	movwf	TRISJ, A	    ; output

	
;	call	LCD_Setup 	; setup LCD
	goto	start	
	
start:
	; set port as output	    ; output=0 input=1
	movlw	0x00		    ; high - 4us
	movwf	TRISE, A
	movlw	0x00
	movwf	TRISH, A
	
	; output 1 - to sensor
	movlw	0x01		    
	movwf	PORTE, A
	movlw	0x01
	movwf	PORTH, A	
	movlw	1		    ; output signal - 4us
	call	delay_x4us
	
	; output 0 - to sensor
	movlw	0x00		    ; for delay and reading the input
	movwf	PORTE, A
	movlw	0x00
	movwf	PORTH, A

	; set port as input - read position
	movlw	0x01
	movwf	TRISE, A
	movlw	0x01
	movwf	TRISH, A
	
	
	; start the countdown
	call	count_loop_init_1
	call	count_loop_init_2

	; call LCD
;	call	lcd_position
;	movf	sensor_clock, w, A	; output message to LCD
;;	movlw	0x01
;	call	LCD_Send_Byte_D
	
	
	
	; timegap before next postion measurement
	movlw	250		    
	call	delay_x4us	    ; no output signal - 4us
	
	
	; repeat position reading
;	bra	start
	
	
; ===================== countdown function ==================================
count_loop_init_1:
    	movlw	0			    ; 8-bits: count from 0 to 255
	movwf	sensor_clock01, A
count_loop_1:
	movff	sensor_clock01, PORTF, A	    ; check update frequency
	incf	sensor_clock01, A		    ; increment clock
	
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
	movff	sensor_clock02, PORTJ, A	    ; check update frequency
	incf	sensor_clock02, A		    ; increment clock
	
	movlw	6			    
	call	delay_x4us
	
	movlw	0
	cpfseq	PORTH, A		    
	bra	count_loop_2
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