#line 1 "D:/Finki/sm5/ms/dopolnitelan_proekt/Final/MikroC/PWMAudioC.c"
sbit LCD_RS at RB4_bit;
sbit LCD_EN at RB5_bit;
sbit LCD_D4 at RB0_bit;
sbit LCD_D5 at RB1_bit;
sbit LCD_D6 at RB2_bit;
sbit LCD_D7 at RB3_bit;
sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;
sbit LCD_D4_Direction at TRISB0_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;

char chr, position, row, col;
int cnt;
char text[33];

short equalizer(char c)
{
 if (c >= 223)

 return 0b11111111;
 else if(c >= 191)

 return 0b11111110;
 else if(c >= 159)

 return 0b11111100;
 else if(c >= 127)

 return 0b11111000;
 else if(c >= 95)

 return 0b11110000;
 else if(c >= 63)

 return 0b11100000;
 else if(c>= 31)

 return 0b11000000;
 else if(c > 0)

 return 0b10000000;
 else
 return 0;
}

void interrupt()
{
 if (TMR0IF_bit)
 {
 cnt++;
 if (cnt >= 60)
 {
 PORTD = equalizer(chr);
 cnt = 0;
 }
 TMR0IF_bit = 0;
 TMR0 = 155;
 }
}

void main()
{
 ANSEL = 0;
 ANSELH = 0;
 C1ON_bit = 0;
 C2ON_bit = 0;
 PORTC = 0;
 TRISC = 0;
 PWM2_Init(500000);
 PWM2_Start();
 PWM2_Set_Duty(255);

 UART1_Init(115200);
 Delay_ms(100);
 Lcd_Init();
 Lcd_Cmd(_LCD_CURSOR_OFF);
 Lcd_Cmd(_LCD_CLEAR);


 for (position = 0; position < 33; position++)
 {
 text[position] = ' ';
 }

 TRISD = 0;
 PORTD = 255;
 cnt = 0;
 chr = 0;
 position = 0;
 row = 1;
 col = 1;
 OPTION_REG = 0x84;
 TMR0 = 155;
 INTCON = 0xA0;


 while (1)
 {
 if (UART1_Data_Ready())
 {
 chr = UART1_Read();

 if (chr == 1)
 {
 break;
 }
 else
 {
 if (position<33)
 {
 text[position] = chr;
 }
 position++;
 }
 }
 }


 chr = 0;
 for (position=0; position<33; position++)
 {
 Lcd_Chr(row, col, text[position]);
 col++;
 if (position == 15)
 {
 col = 1;
 row = 2;
 }
 }


 while (1)
 {
 if (UART1_Data_Ready())
 {
 chr = UART1_Read();
 PWM2_Set_Duty(chr);
 }
 }
}
