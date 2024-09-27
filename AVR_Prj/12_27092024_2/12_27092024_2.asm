/* 	
 	��������� ������ � �������� �1 � ������ ������������� ���
	�� ������� ���������� �������� ������������ ���������
	������� ��� ���������� �������� �������� �����������

*/

.include "m16def.inc"		
.def temp 	= r16		; ��������������� ����������
.def Delay	= r17 		; ���������� ��������
.def Delay2	= r19 		; ���������� �������� 2
.def flag   = r18 		; ���� �����������
.def temp0 	= r20		; ��������������� ����������

.org 0x00

RESET:
	jmp MAIN			;������ ���������� �� ������

.org	0x0100
MAIN:
	ldi 	temp,low(RAMEND)
	out 	SPL,temp		
	ldi 	temp,high(RAMEND)	;������������� �����
	out 	SPH,temp

	clr 	temp
	clr		temp0
	clr		flag
;������������� ������
	ldi 	temp,(1<<DDD4)|(1<<DDD5)
	out 	DDRD,temp		;4 � 5 ������� ����� D �� ����� 
	clr 	temp
	out 	DDRB,temp		;��� ������� ����� B �� ����
	ser 	temp
	out 	PORTB,temp		;�������� ������������� ���������

	clr 	temp			; ���������
	out 	OCR1AL,temp		; ���������
	out 	OCR1BL,temp		; ���������
	out 	TCNT1L,temp		; �������
	out 	TCNT1H,temp		; � ��������

;=============== ��������� ������� ========================
;����� � -������ ������, ����� � -���������;
;PWM Phase Correct, 8-bit
	ldi 	temp,(1<<COM1A1)|(1<<COM1B1)|(1<<COM1B0)|(1<<WGM10)
	out 	TCCR1A,temp		
;��������� ������������ � ������ �������
;CS12..10 = 001 : fck ��� �������
;|(1<<WGM12);(������� ��� ������� ���) 
	ldi 	temp,(1<<CS10)		
	out 	TCCR1B,temp		; 

;======== �������� ���� ===================================	
WAIT_0:					
;������� � ���������� ��������� �������: LD4 ��������, LD5 �������� 
	sbic	PINB,PINB0	; �������� ������� ������ SW0
	rjmp	WAIT_1			
		ser 	temp		;������ ��������� "0"� �������� ���������
		out 	OCR1AL,temp		
		out 	OCR1BL,temp		

;*** ����� ����������� �������� LD5 ���� LD4
WAIT_1:
	sbic PINB,PINB1		;���� �� ������ ������ SW1
	rjmp	WAIT_2			;- ������� � ��������� ��������,
		clr 	temp		;����� ��������� 
		out 	OCR1AL,temp 	; ������������ ����������
		ldi		temp, 8
		out 	OCR1BL,temp	; 8/256

;*** ����� ����������� �������� LD4 ���� LD5
WAIT_2:
	sbic	PINB,PINB2		;���� �� ������ ������ SW2
	rjmp	WAIT_3			;- ������� � ��������� ��������,
		ldi 	temp, 248
		out 	OCR1AL,temp 	; ������������ ����������
		ser 	temp		;����� ���������
		out 	OCR1BL,temp	; 248/256

WAIT_3:
;***������� � ���������� ��������� �������: LD4 ��������, LD5 �������� 
	sbic PINB,PINB3		;���� �� ������ ������ SW3
	rjmp WAIT_4			;- ������� � ��������� ��������, 
		clr 	temp			;����� ���������
		out 	OCR1AL,temp	; ������������ ����������
		out 	OCR1BL,temp	; 256/256

;====	�������������� �������� ����������� � ����������� ��� ������� ������ SW4
WAIT_4:	
	sbic	PINB,PINB4		;�������� ������� ������ SW4:
	rjmp WAIT_0			;���� �� ������ - � ������ 
					;��������� �����, ����� 
;----	�������� �����������
		tst	flag
;���� �� 0 - ���������� ��������� ���������
		brne	L0		
; ����� ���������� ���������
		subi	temp0,-5
; ���� �������� �������� 
		cpi	temp0,0x00
		brne	L1
; - ��������� �����������
		com	flag
		rjmp	L1
L0:		; ���������� ���������
		subi	temp0,5
; ���� ����� �������� 
		cpi	temp0,0xFF
		brne	L1
; - ��������� �����������
		com	flag
;----	������ ��������� � �������� ���������,
L1:
		out	OCR1AL,temp0	
		out	OCR1BL,temp0		
;====	��������� ������ 4
; ��������� ��������
		ldi Delay, 0x00
		ldi	Delay2,0x00
DLY:
			dec	Delay
			brne	DLY
			dec	Delay2
			brne	DLY
; � ������� �� ��������� ��������
	rjmp	WAIT_4

