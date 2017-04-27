; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

LV EQU 0    ;local variable for LCD_OutDec, used for link register
	
C1 EQU 0    ;first character
C2 EQU 4    ;second character
C3 EQU 8    ;third character
C4 EQU 12   ;fourth character

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	  SUB SP, #8          ; allocation for local variables
	  STR LR, [SP, #LV]
	  CMP R0, #10         ;checks if the character is less than 10, if so ends
	  BLO OEND
	  MOV R2, #10         ;make r2 number 10
	  UDIV R3, R0, R2     ;r3=r0/r2, or r3=input/10
	  MUL R1, R3, R2      ;r1=r3*r2, or r1=(input/10)*10
	  SUB R1, R0, R1      ;r1=remainder
	  PUSH {R1, R11}      ;pushes remainder to stack
	  MOVS R0, R3         ;r0=input/10
	  BL LCD_OutDec
	  POP {R0, R11}       
OEND  ADD R0, R0, #0x30
      BL ST7735_OutChar   ;outputs remainder to LCD
	  LDR LR, [SP, #LV]
	  ADD SP, #8
      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
	  PUSH {R4, LR}
	  SUB SP, #16			; Allocation for local variables
	  MOV R4, #10000        ;check if r0 is 10000, if so output *.***
	  CMP R0, R4
	  BHS STAR
	                      ;first character
	  MOV R2, #10         ;make r2 number 10
	  UDIV R3, R0, R2     ;r3=r0/r2, or r3=input/10
	  MUL R1, R3, R2      ;r1=r3*r2, or r1=(input/10)*10
	  SUB R1, R0, R1      ;r1=remainder
	  ADD R1, #0x30
	  STR R1, [SP, #C1]
	  MOVS R0, R3         ;r0=input/10
	                      ;second character
	  UDIV R3, R0, R2     ;r3=r0/r2, or r3=input/10
	  MUL R1, R3, R2      ;r1=r3*r2, or r1=(input/10)*10
	  SUB R1, R0, R1      ;r1=remainder
	  ADD R1, #0x30
	  STR R1, [SP, #C2]
	  MOVS R0, R3         ;r0=input/10
	                      ;third character
	  UDIV R3, R0, R2     ;r3=r0/r2, or r3=input/10
	  MUL R1, R3, R2      ;r1=r3*r2, or r1=(input/10)*10
	  SUB R1, R0, R1      ;r1=remainder
	  ADD R1, #0x30
	  STR R1, [SP, #C3]
	  MOVS R0, R3         ;r0=input/10
	                      ;fourth character
	  UDIV R3, R0, R2     ;r3=r0/r2, or r3=input/10
	  MUL R1, R3, R2      ;r1=r3*r2, or r1=(input/10)*10
	  SUB R1, R0, R1      ;r1=remainder
	  ADD R1, #0x30
	  STR R1, [SP, #C4]
	  
	  B OUT
STAR	
	  MOV R0, #0x2A       ;puts stars in all the characters
	  STR R0, [SP, #C1]
	  STR R0, [SP, #C2]
	  STR R0, [SP, #C3]
	  STR R0, [SP, #C4]
	
OUT	 LDR R0, [SP, #C4]
     BL ST7735_OutChar
	 MOV R0, #0x2E       ;puts a decimal before the next three characters
	 BL ST7735_OutChar
	 LDR R0, [SP, #C3]
     BL ST7735_OutChar
	 LDR R0, [SP, #C2]
     BL ST7735_OutChar
	 LDR R0, [SP, #C1]
	 BL ST7735_OutChar
	 ADD SP, #16
	 POP {R4, PC}
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
