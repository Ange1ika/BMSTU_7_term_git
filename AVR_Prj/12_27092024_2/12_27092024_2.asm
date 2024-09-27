/* 	
 	Программа работы с таймером Т1 в режиме двухканальной ШИМ
	со взаимно инверсными режимами формирования выходного
	сигнала для управления яркостью свечения светодиодов

*/

.include "m16def.inc"		
.def temp 	= r16		; Вспомогательная переменная
.def Delay	= r17 		; Переменная задержки
.def Delay2	= r19 		; Переменная задержки 2
.def flag   = r18 		; Флаг направления
.def temp0 	= r20		; Вспомогательная переменная

.org 0x00

RESET:
	jmp MAIN			;Вектор прерывания по сбросу

.org	0x0100
MAIN:
	ldi 	temp,low(RAMEND)
	out 	SPL,temp		
	ldi 	temp,high(RAMEND)	;Инициализация стека
	out 	SPH,temp

	clr 	temp
	clr		temp0
	clr		flag
;Инициализация портов
	ldi 	temp,(1<<DDD4)|(1<<DDD5)
	out 	DDRD,temp		;4 и 5 разряды порта D на вывод 
	clr 	temp
	out 	DDRB,temp		;Все разряды порта B на ввод
	ser 	temp
	out 	PORTB,temp		;Включить подтягивающие резисторы

	clr 	temp			; Обнуление
	out 	OCR1AL,temp		; регистров
	out 	OCR1BL,temp		; сравнения
	out 	TCNT1L,temp		; таймера
	out 	TCNT1H,temp		; и счетчика

;=============== Настройка таймера ========================
;Канал А -прямая логика, канал В -инверсная;
;PWM Phase Correct, 8-bit
	ldi 	temp,(1<<COM1A1)|(1<<COM1B1)|(1<<COM1B0)|(1<<WGM10)
	out 	TCCR1A,temp		
;Настройка предделителя и режима таймера
;CS12..10 = 001 : fck без деления
;|(1<<WGM12);(вариант для быстрой ШИМ) 
	ldi 	temp,(1<<CS10)		
	out 	TCCR1B,temp		; 

;======== Основной цикл ===================================	
WAIT_0:					
;Перевод в устойчивые состояния выводов: LD4 светится, LD5 выключен 
	sbic	PINB,PINB0	; проверка нажатия кнопки SW0
	rjmp	WAIT_1			
		ser 	temp		;запись константы "0"в регистры сравнения
		out 	OCR1AL,temp		
		out 	OCR1BL,temp		

;*** Режим постоянного свечения LD5 ярче LD4
WAIT_1:
	sbic PINB,PINB1		;если не нажата кнопка SW1
	rjmp	WAIT_2			;- переход к следующей проверке,
		clr 	temp		;иначе установка 
		out 	OCR1AL,temp 	; коэффициента заполнения
		ldi		temp, 8
		out 	OCR1BL,temp	; 8/256

;*** Режим постоянного свечения LD4 ярче LD5
WAIT_2:
	sbic	PINB,PINB2		;если не нажата кнопка SW2
	rjmp	WAIT_3			;- переход к следующей проверке,
		ldi 	temp, 248
		out 	OCR1AL,temp 	; коэффициента заполнения
		ser 	temp		;иначе установка
		out 	OCR1BL,temp	; 248/256

WAIT_3:
;***Перевод в устойчивые состояния выводов: LD4 выключен, LD5 светится 
	sbic PINB,PINB3		;если не нажата кнопка SW3
	rjmp WAIT_4			;- переход к следующей проверке, 
		clr 	temp			;иначе установка
		out 	OCR1AL,temp	; коэффициента заполнения
		out 	OCR1BL,temp	; 256/256

;====	Скачкообразное мерцание светодиодов в противофазе при нажатой кнопке SW4
WAIT_4:	
	sbic	PINB,PINB4		;проверка нажатия кнопки SW4:
	rjmp WAIT_0			;если не нажата - в начало 
					;основного цикла, иначе 
;----	Проверка направления
		tst	flag
;если не 0 - уменьшение константы сравнения
		brne	L0		
; иначе увеличение константы
		subi	temp0,-5
; Если превышен максимум 
		cpi	temp0,0x00
		brne	L1
; - изменение направления
		com	flag
		rjmp	L1
L0:		; Уменьшение константы
		subi	temp0,5
; Если равно минимуму 
		cpi	temp0,0xFF
		brne	L1
; - изменение направления
		com	flag
;----	Запись константы в регистры сравнения,
L1:
		out	OCR1AL,temp0	
		out	OCR1BL,temp0		
;====	Окончание режима 4
; Настройка задержки
		ldi Delay, 0x00
		ldi	Delay2,0x00
DLY:
			dec	Delay
			brne	DLY
			dec	Delay2
			brne	DLY
; и переход на следующую итерацию
	rjmp	WAIT_4

