; experiment1.asm
; Created: 05/11/2024 11:11:39
; Author : ArthurLBDS

/*  

Programming to generate a 1 kHz frequency signal on pin PC0 using Timer 1 overflow interrupt.
When Timer 1 overflows, the interrupt routine will toggle the PC0 pin and reset the counter register value.

We want a timer of 500us to have a 1kHz squarewave -> Number of cycles = 500us / (64/8 000 000) = 63
We load TCNT0 with 255 - 63 = 192

 */
.ORG 0x0  ; Location for reset
	JMP INIT
.ORG 0x30 ; Location for Timer1 overflow
	JMP T1_OVERFLOW_INTERRUPT  ; jump to ISR for Timer1 ov.

; Main program for initialization

INIT: 
	LDI R20, HIGH(RAMEND)
	OUT SPH, R20
	LDI R20, LOW(RAMEND)
	OUT SPL, R20   ; Initialize stack
	LDI R20, 1
	OUT DDRC, R20  ; PORTC as output
	LDI R20, 0x40
	STS TCNT1L, R20
	LDI R20, 0xF0    ; Load TCNT as 65 555 - 63 = 0xFFC0
	STS TCNT1H, R20 
	LDI R20, 0
	STS  TCCR1A, R20  ; Normal mode
	LDI R20, 1
	STS TCCR1B, R20  ; Prescaler of 64


	LDI R20, (1<<TOIE1)
	STS TIMSK1, R20   ; enable Timer1 Overflow
	SEI               ; set Interrupt

MAIN:
	JMP MAIN

T1_OVERFLOW_INTERRUPT:
	IN R16, PORTC    ; Read PORTc
	LDI R17, 1
	EOR R16, R17     ; Toggle PC0
	OUT PORTC, R16
	LDI R20, 0x40
	STS TCNT1L, R20
	LDI R20, 0xF0
	STS TCNT1H, R20 
	RETI