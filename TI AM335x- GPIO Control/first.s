@This program turns on and off LED3, LED2, LED1, and LED0
@that are connnected to the GPIO1`module. It
@Controls the pins that represent the LEDs and turns on
@LED3 (GPIO1_24) and LED1 (GPIO1_22), waits (approximately)
@one second, turns them off, and then turns on LED2 (GPIO1_23)
@and LED0 (GPIO1_21), waits (approximately) one second
@turns them off and the sequence continues forever.
@Rebeka Henry February 26, 2020
.text
.global _start

_start: 				LDR R0, = #0x02 			@Enable clocks for GPIO1 modules
						LDR R1, = 0x44E000AC 		@Address of CM_PER_GPIO1_CLKCTRL Register
						STR R0, [R1] 				@Write #02 to register

						LDR R0, = #0x4804C000 		@Load base address of GPIO1: 0x4804C000
						
						MOV R10, #0x00200000 		@Loop delay constant
						
						@clear data out for all LEDS- set them as low
						MOV R4, #0x01E0000  		@GPIO2_21-24 as off with GPIO1_CLEARDATAOUT register
						ADD R5, R0, #0x190 			@Make the GPIO1_CLEARDATAOUT register address
						STR R4, [R5] 				@Write to GPIO1_CLEARDATAOUT register to init as low
						
						@Program GPIO1_21-24 as outputs
		
						ADD R1, R0, #0x134 			@Make the GPIO1_OE register address
						LDR R6, [R1] 				@READ GPIO1_OE register
						MOV R8, #0xFE1FFFFF 		@Word to Enable GPIO1_21-24 as output
						AND R6, R8, R6 				@MODIFY by AND the configured GPIO1 with pin 21-24 mask
						STR R6, [R1] 				@WRITE to GPIO1 Output enable register
			
						
						

TOP:
		@Set GPIO1_24 (LED3) and GPIO1_22 to high
		
		MOV R3, #0x01400000 						@GPIO2_24 as on with GPIO1_SETDATAOUT register
		ADD R5, R0, #0x194 							@Make the GPIO1_SETDATAOUT register address
		STR R3, [R5] 								@Write to GPIO1_SETDATAOUT register to init as high
		
		@Wait 1 second- CALL LOOP
		B LOOP1
		
		
LOOP1:	NOP
		SUBS R10, #1 								@Loop to branch to
		BNE LOOP1
		B LED2LED0

LED2LED0:
		
		@Clear GPIO1_24 (LED3) and GPIO1_22 (LED1)-> Turn Off
		
		MOV R2, #0x01400000 						@GPIO1_24 and 22 as off with GPIO1_CLEARDATAOUT register
		ADD R7, R0, #0x190 							@Make the GPIO1_CLEARDATAOUT register address
		STR R2, [R7] 								@Write to GPIO1_CLEARDATAOUT register to init as low
		
		@Set GPIO1_23 (LED2) and GPIO1_21 as high
		
		MOV R3, #0x00A00000 						@GPIO1_23 as on with GPIO1_SETDATAOUT register
		ADD R5, R0, #0x194 							@Make the GPIO1_SETDATAOUT register address
		STR R3, [R5] 								@Write to GPIO1_SETDATAOUT register to init as high
		
		MOV R10, #0x00200000 						@Reload loop delay constant
		
		@Wait 1 second- CALL LOOP
		B LOOP2
		
		

LOOP2:	NOP
		SUBS R10, #1 								@Loop to branch to
		BNE LOOP2
		B RETURNTOP

RETURNTOP:		
			
		@Clear GPIO1_23 (LED2) and GPIO1_21 (LED0)-> Turn Off
		
		MOV R2, #0x00A00000 						@GPIO1_23 as off with GPIO1_CLEARDATAOUT register
		ADD R7, R0, #0x190 							@Make the GPIO1_CLEARDATAOUT register address
		STR R2, [R7] 								@Write to GPIO1_CLEARDATAOUT register to init as low
		
		@Execute first instruction again so branch here to top
		B TOP

.end

