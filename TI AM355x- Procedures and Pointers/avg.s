@This program calculates the rounded average of 16 8 bit
@binary temperatures. It utilizes the Fahrenheit_Temps array by
@looping through it and adding each value within the array with
@the next value in the array until the loop is complete.
@The progam then takes the rounded average and places it in
@an array of size 1.
@Uses R1-R5
@Rebeka Henry February 12 2020

.text
.global _start
_start:
.Equ NUM, 16
				LDR R1, = Fahrenheit_Temps 	@Load pointer to Fahrenheit_Temps array
				LDR R2, = Average			@Load Pointer to Average array
				MOV R3, #NUM				@Initialize the counter

NEXT:			LDRB R4, [R1], #1			@Get byte from temperature array and increment the pointer
				ADDS R5, R5, R4				@Add each value from the array after each loop and put in in temp R5
				SUBS R3, R3, #1				@Decrement the element counter and set the flags
				BNE	 NEXT					@continue until all 16 elements are done

				MOVS R5, R5, LSR #4			@Divide by 16, 2^n -> 2^4 = 16
				ADC  R5, R5, #0				@Add contents of carry flag to sum in R5 for rounding if CY = 1
				STRB R5, [R2], #1			@Put the result into the average array of one byte

				NOP

.data
Fahrenheit_Temps: .byte 0x8C, 0x0, 0x32, 0x3C, 0x46, 0x50, 0x7D, 0x16, 0x2E, 0x3A, 0x55, 0x84, 0x64, 0x6E, 0x65, 0x2
Average:		  .byte 0x0

.END
