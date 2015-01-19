
_equalizer:

;PWMAudioC.c,18 :: 		short equalizer(char c)
;PWMAudioC.c,20 :: 		if (c >= 223)
	MOVLW      223
	SUBWF      FARG_equalizer_c+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_equalizer0
;PWMAudioC.c,22 :: 		return 0b11111111;
	MOVLW      255
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer0:
;PWMAudioC.c,23 :: 		else if(c >= 191)
	MOVLW      191
	SUBWF      FARG_equalizer_c+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_equalizer2
;PWMAudioC.c,25 :: 		return 0b11111110;
	MOVLW      254
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer2:
;PWMAudioC.c,26 :: 		else if(c >= 159)
	MOVLW      159
	SUBWF      FARG_equalizer_c+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_equalizer4
;PWMAudioC.c,28 :: 		return 0b11111100;
	MOVLW      252
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer4:
;PWMAudioC.c,29 :: 		else if(c >= 127)
	MOVLW      127
	SUBWF      FARG_equalizer_c+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_equalizer6
;PWMAudioC.c,31 :: 		return 0b11111000;
	MOVLW      248
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer6:
;PWMAudioC.c,32 :: 		else if(c >= 95)
	MOVLW      95
	SUBWF      FARG_equalizer_c+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_equalizer8
;PWMAudioC.c,34 :: 		return 0b11110000;
	MOVLW      240
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer8:
;PWMAudioC.c,35 :: 		else if(c >= 63)
	MOVLW      63
	SUBWF      FARG_equalizer_c+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_equalizer10
;PWMAudioC.c,37 :: 		return 0b11100000;
	MOVLW      224
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer10:
;PWMAudioC.c,38 :: 		else if(c>= 31)
	MOVLW      31
	SUBWF      FARG_equalizer_c+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_equalizer12
;PWMAudioC.c,40 :: 		return 0b11000000;
	MOVLW      192
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer12:
;PWMAudioC.c,41 :: 		else if(c > 0)
	MOVF       FARG_equalizer_c+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_equalizer14
;PWMAudioC.c,43 :: 		return 0b10000000;
	MOVLW      128
	MOVWF      R0+0
	GOTO       L_end_equalizer
L_equalizer14:
;PWMAudioC.c,45 :: 		return 0;
	CLRF       R0+0
;PWMAudioC.c,46 :: 		}
L_end_equalizer:
	RETURN
; end of _equalizer

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;PWMAudioC.c,48 :: 		void interrupt()
;PWMAudioC.c,50 :: 		if (TMR0IF_bit)
	BTFSS      TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
	GOTO       L_interrupt16
;PWMAudioC.c,52 :: 		cnt++;
	INCF       _cnt+0, 1
	BTFSC      STATUS+0, 2
	INCF       _cnt+1, 1
;PWMAudioC.c,53 :: 		if (cnt >= 60)
	MOVLW      128
	XORWF      _cnt+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt38
	MOVLW      60
	SUBWF      _cnt+0, 0
L__interrupt38:
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt17
;PWMAudioC.c,55 :: 		PORTD = equalizer(chr);
	MOVF       _chr+0, 0
	MOVWF      FARG_equalizer_c+0
	CALL       _equalizer+0
	MOVF       R0+0, 0
	MOVWF      PORTD+0
;PWMAudioC.c,56 :: 		cnt = 0;
	CLRF       _cnt+0
	CLRF       _cnt+1
;PWMAudioC.c,57 :: 		}
L_interrupt17:
;PWMAudioC.c,58 :: 		TMR0IF_bit = 0;
	BCF        TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
;PWMAudioC.c,59 :: 		TMR0 = 155;
	MOVLW      155
	MOVWF      TMR0+0
;PWMAudioC.c,60 :: 		}
L_interrupt16:
;PWMAudioC.c,61 :: 		}
L_end_interrupt:
L__interrupt37:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;PWMAudioC.c,63 :: 		void main()
;PWMAudioC.c,65 :: 		ANSEL = 0;
	CLRF       ANSEL+0
;PWMAudioC.c,66 :: 		ANSELH = 0;
	CLRF       ANSELH+0
;PWMAudioC.c,67 :: 		C1ON_bit = 0;
	BCF        C1ON_bit+0, BitPos(C1ON_bit+0)
;PWMAudioC.c,68 :: 		C2ON_bit = 0;
	BCF        C2ON_bit+0, BitPos(C2ON_bit+0)
;PWMAudioC.c,69 :: 		PORTC = 0;                          // set PORTC to 0
	CLRF       PORTC+0
;PWMAudioC.c,70 :: 		TRISC = 0;
	CLRF       TRISC+0
;PWMAudioC.c,71 :: 		PWM2_Init(500000);
	BCF        T2CON+0, 0
	BCF        T2CON+0, 1
	MOVLW      9
	MOVWF      PR2+0
	CALL       _PWM2_Init+0
;PWMAudioC.c,72 :: 		PWM2_Start();
	CALL       _PWM2_Start+0
;PWMAudioC.c,73 :: 		PWM2_Set_Duty(255);
	MOVLW      255
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;PWMAudioC.c,75 :: 		UART1_Init(115200);
	MOVLW      10
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;PWMAudioC.c,76 :: 		Delay_ms(100);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_main18:
	DECFSZ     R13+0, 1
	GOTO       L_main18
	DECFSZ     R12+0, 1
	GOTO       L_main18
	DECFSZ     R11+0, 1
	GOTO       L_main18
	NOP
	NOP
;PWMAudioC.c,77 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;PWMAudioC.c,78 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;PWMAudioC.c,79 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;PWMAudioC.c,82 :: 		for (position = 0; position < 33; position++)
	CLRF       _position+0
L_main19:
	MOVLW      33
	SUBWF      _position+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main20
;PWMAudioC.c,84 :: 		text[position] = ' ';
	MOVF       _position+0, 0
	ADDLW      _text+0
	MOVWF      FSR
	MOVLW      32
	MOVWF      INDF+0
;PWMAudioC.c,82 :: 		for (position = 0; position < 33; position++)
	INCF       _position+0, 1
;PWMAudioC.c,85 :: 		}
	GOTO       L_main19
L_main20:
;PWMAudioC.c,87 :: 		TRISD = 0;
	CLRF       TRISD+0
;PWMAudioC.c,88 :: 		PORTD = 255;
	MOVLW      255
	MOVWF      PORTD+0
;PWMAudioC.c,89 :: 		cnt = 0;
	CLRF       _cnt+0
	CLRF       _cnt+1
;PWMAudioC.c,90 :: 		chr = 0;
	CLRF       _chr+0
;PWMAudioC.c,91 :: 		position = 0;
	CLRF       _position+0
;PWMAudioC.c,92 :: 		row = 1;
	MOVLW      1
	MOVWF      _row+0
;PWMAudioC.c,93 :: 		col = 1;
	MOVLW      1
	MOVWF      _col+0
;PWMAudioC.c,94 :: 		OPTION_REG = 0x84;
	MOVLW      132
	MOVWF      OPTION_REG+0
;PWMAudioC.c,95 :: 		TMR0 = 155;
	MOVLW      155
	MOVWF      TMR0+0
;PWMAudioC.c,96 :: 		INTCON = 0xA0;
	MOVLW      160
	MOVWF      INTCON+0
;PWMAudioC.c,99 :: 		while (1)
L_main22:
;PWMAudioC.c,101 :: 		if (UART1_Data_Ready())
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main24
;PWMAudioC.c,103 :: 		chr = UART1_Read();
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _chr+0
;PWMAudioC.c,105 :: 		if (chr == 1)
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main25
;PWMAudioC.c,107 :: 		break;
	GOTO       L_main23
;PWMAudioC.c,108 :: 		}
L_main25:
;PWMAudioC.c,111 :: 		if (position<33)
	MOVLW      33
	SUBWF      _position+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main27
;PWMAudioC.c,113 :: 		text[position] = chr;
	MOVF       _position+0, 0
	ADDLW      _text+0
	MOVWF      FSR
	MOVF       _chr+0, 0
	MOVWF      INDF+0
;PWMAudioC.c,114 :: 		}
L_main27:
;PWMAudioC.c,115 :: 		position++;
	INCF       _position+0, 1
;PWMAudioC.c,117 :: 		}
L_main24:
;PWMAudioC.c,118 :: 		}
	GOTO       L_main22
L_main23:
;PWMAudioC.c,121 :: 		chr = 0;
	CLRF       _chr+0
;PWMAudioC.c,122 :: 		for (position=0; position<33; position++)
	CLRF       _position+0
L_main28:
	MOVLW      33
	SUBWF      _position+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main29
;PWMAudioC.c,124 :: 		Lcd_Chr(row, col, text[position]);
	MOVF       _row+0, 0
	MOVWF      FARG_Lcd_Chr_row+0
	MOVF       _col+0, 0
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _position+0, 0
	ADDLW      _text+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;PWMAudioC.c,125 :: 		col++;
	INCF       _col+0, 1
;PWMAudioC.c,126 :: 		if (position == 15)
	MOVF       _position+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_main31
;PWMAudioC.c,128 :: 		col = 1;
	MOVLW      1
	MOVWF      _col+0
;PWMAudioC.c,129 :: 		row = 2;
	MOVLW      2
	MOVWF      _row+0
;PWMAudioC.c,130 :: 		}
L_main31:
;PWMAudioC.c,122 :: 		for (position=0; position<33; position++)
	INCF       _position+0, 1
;PWMAudioC.c,131 :: 		}
	GOTO       L_main28
L_main29:
;PWMAudioC.c,134 :: 		while (1)
L_main32:
;PWMAudioC.c,136 :: 		if (UART1_Data_Ready())
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main34
;PWMAudioC.c,138 :: 		chr = UART1_Read();
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _chr+0
;PWMAudioC.c,139 :: 		PWM2_Set_Duty(chr);
	MOVF       R0+0, 0
	MOVWF      FARG_PWM2_Set_Duty_new_duty+0
	CALL       _PWM2_Set_Duty+0
;PWMAudioC.c,140 :: 		}
L_main34:
;PWMAudioC.c,141 :: 		}
	GOTO       L_main32
;PWMAudioC.c,142 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
