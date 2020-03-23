@This program turns on the LEDs in the strobe pattern developed 
@in part 1 if the button is pressed. The second press turns the LEDs off.
@This sequence continues. It uses GPIO2 module for the button presses 
@and GPIO1 module for the LEDs.
@Rebeka Henry March 10, 2020


.text
.global _start
.global INT_DIRECTOR
_start:
			LDR R13, = STACK1 				@Point to base of STACK for SVC mode
			ADD R13, R13, #0x1000 			@Point to top of STACK
			CPS #0x12 						@Switch to IRQ mode
			LDR R13, = STACK2 				@Point to IRQ stack
			ADD R13, R13, #0x1000 			@Point to to top of STACK
			CPS #0x13 						@Back to SVC Mode

			@Turn on GPIO1 and GPIO2 CLKS
			
			LDR R0, = #0x02 				@Enable clocks for GPIO1 modules
			LDR R1, = 0x44E000AC			@Address of CM_PER_GPIO1_CLKCTRL Register
			STR R0, [R1]					@Write #02 to register
			
			LDR R0, = #0x4804C000 			@Load base address of GPIO1: 0x4804C000
			
			LDR R11, = #0x02 				@Enable clocks for GPIO2 modules
			LDR R2, = 0x44E000B0 			@Address of CM_PER_GPIO2_CLKCTRL Register
			STR R11, [R2] 					@Write #02 to register
			
			LDR R11, = #0x481AC000			@Load base address of GPIO2: 0x481AC000
			
			
			@Clear data out for all LEDS- set them as low
			
			MOV R4, #0x01E0000   			@GPIO1_21-24 as off with GPIO1_CLEARDATAOUT register
			ADD R5, R0, #0x190 				@Make the GPIO1_CLEARDATAOUT register address
			STR R4, [R5] 					@Write to GPIO1_CLEARDATAOUT register to init as low
			
			@Program GPIO1_21-24 as outputs

			ADD R1, R0, #0x134 				@Make the GPIO1_OE register address
			LDR R6, [R1] 					@READ GPIO1_OE register
			MOV R8, #0xFE1FFFFF 			@Word to Enable GPIO1_21-24 as output
			AND R6, R8, R6 					@MODIFY by AND the configured GPIO1 with pin 21-24 mask
			STR R6, [R1] 					@WRITE to GPIO1 Output enable register
			
			@detect falling edge on GPIO2_1 and enable to assert POINTRPEND1
			
			ADD R2, R11, #0x14C 			@R2 = address of GPIO2_FALLINGDETECT register
			MOV R9, #0x00000002			 	@Load value for bit 1
			LDR R3, [R2] 					@Read GPIO2_FALLINGDETECT register
			ORR R3, R3, R9 					@Modify (set bit 1)
			STR R3, [R2] 					@Write back
			ADD R2, R11, #0x34 				@Address of GPIO2_IRQSTATUS_SET_0 register
			STR R9, [R2] 					@Enable GPIO2_1 request on POINTRPEND1
			
			@Initialize INTC
			
			LDR R2, = 0x48200010 			@Address of INTC_MIR_CLEAR1 register (because INT 32)
			MOV R9, #0x02 					@Value to unmask INTC INT 32, GPIOINT2A
			STR R9, [R2] 					@Write to INTC_MIR_CLEAR1 register
			
			LDR R2, = 0x482000A8 			@Address of INTC_MIR_CLEAR1 register (because INT 32)
			MOV R9, #0x01 					@Value to unmask INTC INT 32, GPIOINT2A
			STR R9, [R2] 					@Write to INTC_MIR_CLEAR1 register

			@Make sure processor IRQ enable in CPSR
			
			MRS R3, CPSR 					@Copy CPSR to R3
			BIC R3, #0x80 					@Clear bit 7
			MSR CPSR_c, R3 					@Write back to CPSR
			
			
			@Wait for interrupt

LOOP: 		NOP


			LDR R12, = TOMEM
			LDR R10, [R12]
			
			@Turn off all LEDs
			T_ZERO:	 	
	
						MOV R4, #0x01E0000   						@GPIO2_21-24 as off with GPIO1_CLEARDATAOUT register
						ADD R5, R0, #0x190 							@Make the GPIO1_CLEARDATAOUT register address
						STR R4, [R5] 								@Write to GPIO1_CLEARDATAOUT register to init as low
						
			LDR R10, [R12]											@Reload the value from TOMEM again		
			CMP R10, #0x00000001									@If 1, then branch to T_ONE
			BEQ T_ONE
						
			B T_ZERO												@Otherwise, keep doing the off loop
			
								
			
			T_ONE: 		@Strobe the LEDS
						@Set GPIO1_24 (LED3) and GPIO1_22 to high
			
						MOV R3, #0x01400000 						@GPIO2_24 as on with GPIO1_SETDATAOUT register
						ADD R5, R0, #0x194 							@Make the GPIO1_SETDATAOUT register address
						STR R3, [R5] 								@Write to GPIO1_SETDATAOUT register to init as high
						
						MOV R10, #0x00200000						@Load the loop delay constant
						
						@Wait 1 second- CALL LOOP
						B LOOP1
			
		
			LOOP1:		NOP
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
						
					
			
			LOOP2:		NOP
						SUBS R10, #1 								@Loop to branch to
						BNE LOOP2
						B RETURNTOP
			
			RETURNTOP:		
							
						@Clear GPIO1_23 (LED2) and GPIO1_21 (LED0)-> Turn Off
						
						MOV R2, #0x00A00000 						@GPIO1_23 as off with GPIO1_CLEARDATAOUT register
						ADD R7, R0, #0x190 							@Make the GPIO1_CLEARDATAOUT register address
						STR R2, [R7] 								@Write to GPIO1_CLEARDATAOUT register to init as low
						
			LDR R10, [R12]											@Reload the value from TOMEM again		
			CMP R10, #0x00000000									@If 0, then branch to T_ZERO
			BEQ T_ZERO					
						
			B T_ONE													@Otherwise, keep doing the on loop
			
			
									
			B LOOP
			


INT_DIRECTOR: 	STMFD SP!, {R0-R11, LR} 		@Push registers on the stack to be used by the button
				LDR R11, = 0x482000B8 			@Address of INTC_PENDING_IRQ1 register
				LDR R2, [R11] 					@Read INTC_PENDING_IRQ1 register
				TST R2, #0x00000001 			@Test bit 0
				BEQ PASS_ON 					@Not from GPIOINT2A, go back to wait loop, Else
				LDR R11, = 0x481AC02C 			@Load GPIO2_IRQSTATUS_0 register address
				LDR R2, [R11] 					@Read STATUS register
				TST R2, #0x00000002 			@Check if bit 1 = 1
				BNE BUTTON_SVC 					@If bit 1 = 1, then button pushed
				BEQ PASS_ON 					@If bit 1 = 0, then go back to wait loop

PASS_ON:
			LDMFD SP!, {R0-R11, LR} 		@Restore registers
			SUBS PC, LR, #4 				@Pass execution on to wait LOOP for now

BUTTON_SVC:
			MOV R2, #0x00000002 			@Value turns off GPIO2_1 and INTC Interrupt requests
			STR R2, [R11] 					@Write to GPIO2_IRQSTATUS_0 Register
			
			@Turn off NEWIRQ bit in INTC Control, so processor can respond to new IRQ
			
			LDR R11, =0x48200048 			@Address of INTC_CONTROL register
			MOV R2, #01 					@Value to clear bit 0
			STR R2, [R11] 					@Write to INTC_CONTROL Register
			
	
			
			@Load TOMEM from memory
			
			LDR R7, = TOMEM 				@TOMEM address loaded from memory
			
			@If the R7 is either 0 or 1 and it is the equal to R8 or if it is not equal to R8
			
			LDR R5, [R7]					@Load the value from R7 (whether 1 or 0) into R5
			
			CMP R5, #0x00000001				@Compare R5 to 1 and then update R5 accordingly
			
			MOVEQ R5, #0x00000000
			MOVNE R5, #0x00000001
			
			STR R5, [R7]
		
			B R_REGISTER 					@restore registers and return from IRQ

	


R_REGISTER: 

			LDMFD SP !, {R0-R11, LR} 		@Restore registers
			SUBS PC, LR, #4 				@Return from IRQ Interrupt Procedure



.align 2
TOMEM: .word 0x00000000 					@Toggle Memory location that is referenced in BUTTON_SVC
.data
.align 2
STACK1: .rept 1024
.word 0x0000
.endr

STACK2: .rept 1024
.word 0x0000
.endr
.END

