/*
Example Applications 9-2 STK500 User Guide
===============================================
Connect PORTD to LEDS and PORTB to SWITCHES.
LEDs will operate differently depending on what switch is pressed.
Tip: Copy the code from this document into AVR Studio.
***** STK500 LEDS and SWITCH demonstration

��� ������������� ��� ������������� ���������� ����� EVBavr05
��������� ����������� ���������� � ��������� ������:
���������� ���������� ������ ������� �� ������ ����� PORTD
*/
;----- ���������� ���� �������� �����������
.include "m16def.inc"

;----- ����������� ���������� � ���������
.def Temp 	=	r16 	; ��������� ���������� 1
.def Temp2	=	r19 	; ��������� ���������� 2
.def Temp3	=	r20 	; ��������� ���������� 3
.def Delay	=	r17 	; �������� �������� 1
.def Delay2	=	r18 	; �������� �������� 2
.def Delay3 =   r21

;----- ������ ���������� �� ������
RESET: 
	jmp	START

;----- ������ ���������� ����
.org	0x100	;

START:
;----- ������������� ������
	ser	Temp			
	out	DDRD,temp 	; ���� D �� �����
	clr	Temp			;
	out	DDRB,Temp		; ���� B �� ����
	ser	Temp
	out	PORTB,Temp	; ��������� "�������������" ����������

	ser Temp3

;----- �������� ������� ������ � ���������
LOOP:	;������ ��������� �����
	
	mov Temp2,Temp
	eor Temp2, Temp3
	out	PORTD,Temp2 	; �������� ���������
		sbis	PINB,0x00 	; ���� ������ ������ 0 
		inc	Temp 		; -> ��������� Temp,
					; �����
		sbis	PINB,0x01 	; ���� ������ ������ 1
		dec	Temp 		; -> ��������� Temp,
					; �����
		sbis	PINB,0x02 	; ���� ������ ������ 2
		ror	Temp 		; -> ����� ������ 
					; �����
		sbis	PINB,0x03 	; ���� ������ ������ 3
		rol	Temp 		; -> ����� �����
					; �����
		sbis	PINB,0x04 	; ���� ������ ������ 4
		com	Temp 		; -> ��������
					; �����
		sbis	PINB,0x05 	; ���� ������ ������ 5
		neg	Temp 		; -> ���������� �� 2
					; �����
		sbis	PINB,0x06 	; ���� ������ ������ 6
		swap	Temp 		; -> ������������ ����������

;---- ��������, ����� ��������� ��������� ����������� ���� �������
		ldi	Delay,0x00	; ����� ���������� ����������� ����� ��������
		ldi	Delay2,0x00	; ����� ���������� �������� ����� ��������
		ldi Delay3,0x00

		sbis	PINB,0x07 	; ���� ������ ������ 7
		ldi	Delay2,0x04
DLY:
		dec	Delay
		brne	DLY
		dec	Delay2
		brne	DLY
		dec Delay2
		brne	DLY


;----  ������� � ������ ������������ �����
	rjmp	LOOP 

