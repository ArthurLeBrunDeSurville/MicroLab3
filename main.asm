.include "m324padef.inc" ; Include Atmega324pa definitions
.org 0x0000 ; interrupt vector table
rjmp reset_handler ; reset
.org 0x001A
rjmp timer1_COMP_ISR
reset_handler:
 ; initialize stack pointer
 ldi r16, 1
 OUT DDRC, r16
 ldi r16, high(RAMEND)
 out SPH, r16
 ldi r16, low(RAMEND)
 out SPL, r16
 ldi r16, (1<<PCIE0)
 sts PCICR, r16
 call initTimer1CTC
 call led7seg_portinit
 call Led7seg_buffer_init
 ; enable global interrupts
 sei
main:

jmp main
; Lookup table for 7-segment codes

table_7seg_data:
 .DB 0XC0,0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
 .DB 0XC6,0XA1,0X86,0X8E
; Lookup table for LED control

table_7seg_control:
 .DB 0b00001110,0b00001101, 0b00001011, 0b00000111
 .equ LED7SEGPORT = PORTD
.equ LED7SEGDIR = DDRD
.equ LED7SEGLatchPORT = PORTB
.equ LED7SEGLatchDIR = DDRB
.equ nLE0Pin = 4
.equ nLE1Pin = 5
.dseg
.org SRAM_START ;starting address is 0x100
LED7segValue: .byte 4 ;store the BCD value to display
LED7segIndex: .byte 1
.cseg
.align 2
;init the Led7seg buffer

Led7seg_buffer_init:

 push r20
ldi r20,3 ;LED index start at 3
ldi r31,high(LED7segIndex)
ldi r30,low(LED7segIndex)
st z,r20
ldi r20,1
ldi r31,high(LED7segValue)
ldi r30,low(LED7segValue)
st z+,r20 ;display value is 0-1-2-3
inc r20
st z+,r20
inc r20
st z+,r20
inc r20
st z+,r20
 pop r20
 ret

led7seg_portinit:

push r20
ldi r20, 0b11111111 ; SET led7seg PORT as output
out LED7SEGDIR, r20
in r20, LED7SEGLatchDIR ; read the Latch Port direction register
 ori r20, (1<<nLE0Pin) | (1 << nLE1Pin)
out LED7SEGLatchDIR,r20
pop r20
ret

display_7seg:


 push r16 ; Save the temporary register

 ; Look up the 7-segment code for the value in R18

 ; Note that this assumes a common anode display, where a HIGH output turns OFF the segment

 ; If using a common cathode display, invert the values in the table above

ldi zh,high(table_7seg_data<<1) ;
ldi zl,low(table_7seg_data<<1) ;
clr r16
add r30, r27
adc r31,r16
 lpm r16, z
out LED7SEGPORT,r16
sbi LED7SEGLatchPORT,nLE0Pin
nop
cbi LED7SEGLatchPORT,nLE0Pin
ldi zh,high(table_7seg_control<<1) ;
ldi zl,low(table_7seg_control<<1) ;
clr r16
 add r30, r26
adc r31,r16
lpm r16, z
out LED7SEGPORT,r16
sbi LED7SEGLatchPORT,nLE1Pin
nop
cbi LED7SEGLatchPORT,nLE1Pin
 pop r16 ; Restore the temporary register
 ret ; Return from the function

initTimer1CTC:
 push r16
 ldi r16, high(10000) ; Load the high yte into the temporary register
 sts OCR1AH, r16 ; Set the high byte of the timer 1 compare value
 ldi r16, low(10000) ; Load the low byte into the temporary register
 sts OCR1AL, r16 ; Set the low byte of the timer 1 compare value
 ldi r16, (1 << CS10)| (1<< WGM12) ; Load the value 0b00000101 into the temporary register
 sts TCCR1B, r16 ;
 ldi r16, (1 << OCIE1A); Load the value 0b00000010 into the temporary register
 sts TIMSK1, r16 ; Enable the timer 1 compare A interrupt
 pop r16
 ret

timer1_COMP_ISR:

push r16
push r26
push r27
IN R26, PORTC    ; Read PORTc
LDI R27, 1
EOR R26, R27     ; Toggle PC0
OUT PORTC, R26
ldi r31,high(LED7segIndex)
ldi r30,low(LED7segIndex)
ld r16,z
mov r26,r16
ldi r31,high(LED7segValue)
ldi r30,low(LED7segValue)
add r30,r16
clr r16
adc r31,r16
ld r27,z
call display_7seg
cpi r26,0
brne timer1_COMP_ISR_CONT
ldi r26,4 ;if r16 = 0, reset to 3

timer1_COMP_ISR_CONT:

dec r26 ;else, decrease
ldi r31,high(LED7segIndex)
ldi r30,low(LED7segIndex)
st z,r26
pop r27
pop r26
pop r16
reti