; experiment1.asm
; Created: 05/11/2024 11:11:39
; Author : ArthurLBDS

/*  

Repeat exercise 1 using Timer 1 in CTC mode, utilizing the COMPARE_MATCH interrupt, 
to generate a pulse with a frequency of 100 Hz on pin PC0.
Configure the timer to generate a COMPARE_MATCH interrupt every 1 ms. Inside the interrupt,
use a counter to count the number of interrupt occurrences and control pin PC0 to generate a pulse with a frequency of 100 Hz.
Instructions: Increment the counter by 1 each time the interrupt occurs. If the counter reaches 5, toggle PC0 and reset the counter to 0.


 */
.ORG 0x0  ; Location for reset
	JMP INIT
.ORG 0x26 ; Location for Timer1 compare match interrupt
	JMP T1_OVERFLOW_INTERRUPT  ; jump to ISR for Timer1 ov.

; Main program for initialization


// Experiment 2a)
/* 
INIT: 
	LDI R20, HIGH(RAMEND)
	OUT SPH, R20
	LDI R20, LOW(RAMEND)
	OUT SPL, R20   ; Initialize stack
	LDI R20, 1
	OUT DDRC, R20  ; PORTC as output
	LDI R20, 0x3F
	STS OCR1AL, R20
	LDI R20, 0x9C
	STS OCR1AH, R20
	LDI R20, 0
	STS  TCCR1A, R20  ; CTC mode
	LDI R20, (1<<WGM12)|(1<<CS10)
	STS TCCR1B, R20  ; Prescaler of 1


	LDI R20, (1<<OCIE1A)
	STS TIMSK1, R20   ; enable Timer1 compare match interrupt
	SEI               ; set Interrupt

MAIN:
	JMP MAIN

T1_OVERFLOW_INTERRUPT:
	IN R16, PORTC    ; Read PORTc
	LDI R17, 1
	EOR R16, R17     ; Toggle PC0
	OUT PORTC, R16
	LDI R20, 0x3F
	STS OCR1AL, R20
	LDI R20, 0x9C
	STS OCR1AH, R20
	RETI
*/

// Experiment 2b)

INIT: 
	LDI R20, HIGH(RAMEND)
	OUT SPH, R20
	LDI R20, LOW(RAMEND)
	OUT SPL, R20   ; Initialize stack
	LDI R20, 1
	OUT DDRC, R20  ; PORTC as output
	LDI R20, 0x3F
	STS OCR1AL, R20
	LDI R20, 0x1F
	STS OCR1AH, R20
	LDI R20, 0
	STS  TCCR1A, R20  
	LDI R20, (1<<WGM12)|(1<<CS10)
	STS TCCR1B, R20  ; No prescaler, CTC mode


	LDI R20, (1<<OCIE1A)
	STS TIMSK1, R20   ; enable Timer1 compare match interrupt
	SEI               ; set Interrupt

	LDI R21, 0
	LDI R22, 5
MAIN:
	JMP MAIN

T1_OVERFLOW_INTERRUPT:
	IN R16, SREG     ; Save value of SREG
	PUSH R16

	INC R21
	CPSE R21, R22
	JMP NOT_REACHED

	LDI R21, 0
	IN R18, PORTC    ; Read PORTc
	LDI R17, 1
	EOR R18, R17     ; Toggle PC0
	OUT PORTC, R18
	LDI R20, 0x3F
	STS OCR1AL, R20
	LDI R20, 0x1F
	STS OCR1AH, R20
	POP R16
	OUT SREG, R16
	RETI

NOT_REACHED:
	LDI R20, 0x3F
	STS OCR1AL, R20
	LDI R20, 0x1F
	STS OCR1AH, R20
	POP R16
	OUT SREG, R16
	RETI
