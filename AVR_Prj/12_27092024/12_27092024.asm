/*
Example Applications 9-2 STK500 User Guide
===============================================
Connect PORTD to LEDS and PORTB to SWITCHES.
LEDs will operate differently depending on what switch is pressed.
Tip: Copy the code from this document into AVR Studio.
***** STK500 LEDS and SWITCH demonstration

Код модифицирован для использования отладочной платы EVBavr05
Индикация сетодиодами происходит в инверсном режиме:
светодиоды включаются низким уровнем на выводе порта PORTD
*/
;----- Подключить файл описания архитектуры
.include "m16def.inc"

;----- Определения переменных в регистрах
.def Temp 	=	r16 	; Временная переменная 1
.def Temp2	=	r19 	; Временная переменная 2
.def Temp3	=	r20 	; Временная переменная 3
.def Delay	=	r17 	; Параметр задержки 1
.def Delay2	=	r18 	; Параметр задержки 2
.def Delay3 =   r21

;----- Вектор прерывания по сбросу
RESET: 
	jmp	START

;----- Начало размещения кода
.org	0x100	;

START:
;----- Инициализация портов
	ser	Temp			
	out	DDRD,temp 	; порт D на вывод
	clr	Temp			;
	out	DDRB,Temp		; порт B на ввод
	ser	Temp
	out	PORTB,Temp	; включение "подтягивающих" резисторов

	ser Temp3

;----- Проверка нажатия кнопок и индикация
LOOP:	;Начало основного цикла
	
	mov Temp2,Temp
	eor Temp2, Temp3
	out	PORTD,Temp2 	; Обновить индикацию
		sbis	PINB,0x00 	; Если нажата кнопка 0 
		inc	Temp 		; -> инкремент Temp,
					; иначе
		sbis	PINB,0x01 	; если нажата кнопка 1
		dec	Temp 		; -> декремент Temp,
					; иначе
		sbis	PINB,0x02 	; если нажата кнопка 2
		ror	Temp 		; -> сдвиг вправо 
					; иначе
		sbis	PINB,0x03 	; если нажата кнопка 3
		rol	Temp 		; -> сдвиг влево
					; иначе
		sbis	PINB,0x04 	; если нажата кнопка 4
		com	Temp 		; -> инверсия
					; иначе
		sbis	PINB,0x05 	; если нажата кнопка 5
		neg	Temp 		; -> дополнение до 2
					; иначе
		sbis	PINB,0x06 	; если нажата кнопка 6
		swap	Temp 		; -> перестановка полубайтов

;---- Задержка, чтобы изменения состояния светодиодов были заметны
		ldi	Delay,0x00	; Число повторений внутреннего цикла задержки
		ldi	Delay2,0x00	; Число повторений внешнего цикла задержки
		ldi Delay3,0x00

		sbis	PINB,0x07 	; если нажата кнопка 7
		ldi	Delay2,0x04
DLY:
		dec	Delay
		brne	DLY
		dec	Delay2
		brne	DLY
		dec Delay2
		brne	DLY


;----  Возврат в начало бесконечного цикла
	rjmp	LOOP 

