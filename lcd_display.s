#include <xc.inc>

extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Instruction, LCD_Send_Byte_D, LCD_Write_Hex
extrn	full_period_h, full_period_l
extrn	dec_output_h, dec_output_l
global	lcd_setup, display_microtone, display_pentatone, display_cmajor, display_period
    

psect udata_acs		; reserve data space in access ram
counter: ds 1		; reserve one byte for a counter variable
delay_count:ds 1 	; reserve one byte for counter in the delay routine

psect udata_bank4 	; reserve data anywhere in RAM (here at 0x400)
myArray: ds 0x80 	; reserve 128 bytes for message data

    
    
psect data
; ******* myTable, data in programme memory, and its length *****
 
the_period_is:
	db 'P','e','r','i','o','d',':', ' ', 0x0a
	; message, plus carriage return
	myTable_0 EQU 10 	; length of data
	align 2 
 
microtone_table:
	db 'M','i','c','r','o','t','o','n','e','!', 0x0a
	; message, plus carriage return
	myTable_l EQU 11 	; length of data
	align 2

pentatone_table:
	db 'P','e','n','t','a','t','o','n','e','!', 0x0a
	; message, plus carriage return
	myTable_l EQU 11 	; length of data
	align 2

cmajor_table:
	db 'Y','o','!','C','m','a','j','o','r','!', 0x0a
	; message, plus carriage return
	myTable_l EQU 11 	; length of data
	align 2


psect lcd_display_code, class=CODE
lcd_setup:
	setup: 
	bcf	CFGS 	; point to Flash program memory
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup 	; setup UART
	return
	

display_period:
	call	clear		
    
	lfsr	0, myArray 	; Load FSR0 with address in RAM
	movlw	low highword(the_period_is) ; address of data in PM
	movwf	TBLPTRU, A 	; load upper bits to TBLPTRU
	movlw	high(the_period_is) 	; address of data in PM
	movwf	TBLPTRH, A 	; load high byte to TBLPTRH
	movlw	low(the_period_is) 	; address of data in PM
	movwf	TBLPTRL, A 	; load low byte to TBLPTRL
	movlw	myTable_0	; bytes to read
	movwf	counter, A 	; our counter register
	call	first_row
	call	runner
	
	movf	dec_output_h, W, A
	call	LCD_Write_Hex
	movf	dec_output_l, W, A
	call	LCD_Write_Hex
	
	return	
	
	
display_microtone:
    
	lfsr	0, myArray 	; Load FSR0 with address in RAM
	movlw	low highword(microtone_table) ; address of data in PM
	movwf	TBLPTRU, A 	; load upper bits to TBLPTRU
	movlw	high(microtone_table) 	; address of data in PM
	movwf	TBLPTRH, A 	; load high byte to TBLPTRH
	movlw	low(microtone_table) 	; address of data in PM
	movwf	TBLPTRL, A 	; load low byte to TBLPTRL
	movlw	myTable_l 	; bytes to read
	movwf	counter, A 	; our counter register
	call	second_row	
	call	runner
	
	return

display_pentatone:
	
	lfsr	0, myArray 	; Load FSR0 with address in RAM
	movlw	low highword(pentatone_table) ; address of data in PM
	movwf	TBLPTRU, A 	; load upper bits to TBLPTRU
	movlw	high(pentatone_table) 	; address of data in PM
	movwf	TBLPTRH, A 	; load high byte to TBLPTRH
	movlw	low(pentatone_table) 	; address of data in PM
	movwf	TBLPTRL, A 	; load low byte to TBLPTRL
	movlw	myTable_l 	; bytes to read
	movwf	counter, A 	; our counter register
	call	second_row	
	call	runner
	return
	
display_cmajor:
    
	lfsr	0, myArray 	; Load FSR0 with address in RAM
	movlw	low highword(cmajor_table) ; address of data in PM
	movwf	TBLPTRU, A 	; load upper bits to TBLPTRU
	movlw	high(cmajor_table) 	; address of data in PM
	movwf	TBLPTRH, A 	; load high byte to TBLPTRH
	movlw	low(cmajor_table) 	; address of data in PM
	movwf	TBLPTRL, A 	; load low byte to TBLPTRL
	movlw	myTable_l 	; bytes to read
	movwf	counter, A 	; our counter register
	call	second_row	
	call	runner
	return
	
runner: 
	tblrd*+ 		; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0
	decfsz	counter, A 	; count down to zero
	bra	runner 		; keep going until finished

	movlw	myTable_l 	; output message to LCD
	addlw	0xff 		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message

	return			; goto current line in code
	

; lcd send instruction subroutines
first_row:	
	movlw	00000000B
	call	LCD_Write_Instruction
	return
second_row:
	movlw	11000000B
	call	LCD_Write_Instruction
	return

clear:
	movlw	00000001B
	call	LCD_Write_Instruction
	return
	
end
	

