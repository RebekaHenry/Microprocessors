@This program loops through the array of Fahrenheit_Temps
@and finds the maximum and minimum values and stores them
@in the Max and Min arrays of one element. It utilizes the
@stack and calls the procedure MINMAX in order to return the
@maximum and minimum values.
@Uses R0-R14
@Rebeka Henry February 16 2020

.text
.global _start
_start:
.Equ NUM, 16


					LDR R13, = STACK 					@stack pointer to the lower end of the stack
					ADD R13, R13, #0x100 				@Point to the top of the stack
					LDR R0, = Fahrenheit_Temps 			@Load pointer to Fahrenheit_Temps Array at R0
					LDR R1, = Min 						@Load pointer to Min array at R1
					LDR R2, = Max 						@Load pointer to Max array at R2
					MOV R3, #NUM 						@Initialize the main counter

					LDRB R6, [R0] 						@Load one byte from the Fahrenheit_temps arrays
					MOV R7, R6 							@Put the first element in R0 into R7 for min temp
					MOV R8, R6 							@Put the first element in R0 into R8 for max temp

					BL  MINMAX 							@Call the procedure MINMAX



MINMAX: 			STMFD R13!, {R6-R8, R14} 			@Save the used registers on the stack

NEXT: 				LDRB R6, [R0], #1 					@get byte from Fahrenheit_Temps and increment the pointer

					CMP R7, R6    						@compare the value in the Temps array with the R7 value
					MOVLT R7, R6 						@copy contents of the array to R7 when the value is less than

					CMP R8, R6     						@compare the value in the Temps array with the R8 value
					MOVGT R8, R6 						@copy contents of the array to R8 when the value is greater than

					SUBS R3, R3, #1 					@Decrement the element counter and set the flags
					BNE NEXT 							@continue until all 16 elements are done

					STRB R7, [R1], #1 					@store the value in R7 to the register that holds min array

					STRB R8, [R2], #1 					@store the value in R8 to the register that holds max array

					LDMFD R13!, {R6-R8,PC} 				@restore registers
					MOV PC, R14							@return to mainline

					NOP



.data
.align 2
Fahrenheit_Temps: .byte 0x5, 0x21, 0x14, 0x1E, 0x28, 0x32, 0x3C, 0x46, 0x50, 0x50, 0x64, 0x78, 0x82, 0x84, 0x78, 0x8C

Min: .byte 0x0
Max: .byte 0x0
.align 2
STACK: .rept 256 										@reserve 256 bytes for the stack and initialize with 0x00
  .byte 0x00
  .endr

.END
