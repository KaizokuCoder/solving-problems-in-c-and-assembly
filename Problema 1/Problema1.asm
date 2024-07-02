;; PRATICA 2 - DEMONSTRACAO DE ESCRITA DE NUMERO

ORG 100h

; imprime a mensagem do operador    
LEA DX, msg1
MOV AH, 9
INT 21h

; pega o input do usuario e pula uma linha
CALL scan_num
PUTC 0Dh
PUTC 0Ah

; verifica se o operador eh valido
CMP CX, 5
JAE erro
CMP CX, 1
JB erro

; coloca o numero de input na variavel op
MOV w.op, CX

; imprime a mensagem do primeiro numero
LEA DX, msg2
MOV AH, 9
INT 21h

; pega o input do usuario e pula uma linha
CALL scan_num
PUTC 0Dh
PUTC 0Ah

; coloca o numero de input na variavel num1
MOV num1, CX          

; imprime a mensagem do segundo numero
LEA DX, msg3
MOV AH, 9
INT 21h

; pega o input do usuario e pula uma linha
CALL scan_num
PUTC 0Dh
PUTC 0Ah

; coloca o numero de input na variavel num2
MOV num2, CX


; verifica se eh soma
CMP op, 1
JE soma
                     
; verifica se eh subtracao                     
CMP op, 2
JE subt

; verifica se eh multiplicacao
CMP op, 3
JE multip

; verifica se eh divisao
CMP op, 4
JE divid

soma:

    ; imprime a mensagem de soma
    PUTR '+'
    
    ; faz a soma e imprime o resultado
    MOV AX, num1
    ADD AX, num2
    
    ; checa se overflow
    JO overflow
    
    CALL print_num
    
    JMP stop


subt:

    ; imprime a mensagem de subtracao
    PUTR '-'
    
    ; faz a subtracao e imprime o resultado
    MOV AX, num1
    SUB AX, num2
    
    ; checa se overflow
    JO overflow
    
    CALL print_num
    
    JMP stop
     
     
multip:
    
    ; imprime a mensagem de multiplicacao
    PUTR '*'
    
    ; faz a multiplicacao e imprime o resultado
    MOV AX, num1
    IMUL b.num2
    
    ; checa se overflow
    JO overflow
     
    CALL print_num
    
    JMP stop
     
     
divid:

    ; divisao com resto negativo da erro
    
    ; imprime a mensagem de divisao
    PUTR '/'
    
    ; Checa se divisor eh 0
    CMP num2, 0
    JE divid_por_0
    
    ; faz a divisao e imprime o resultado
    MOV AX, num1
    IDIV b.num2
    
    ; checa se overflow
    JO overflow
    
    MOV b.num1, AL
    MOV b.num2, AH
    
    ; imprime o resultado
    MOV AX, num1
    CALL print_num
            
    ; imprime a mensagem de resto
    LEA DX, resto
    MOV AH, 9
    INT 21h
    
    ; pega o resto e imprime
    CMP num2, 127
    JS print_resto
    
    ; se for negativo
    MOV AH, 255
    
    print_resto:
    MOV AL, b.num2
    CALL print_num 
    JMP stop
     
overflow:
    ; imprime a mensagem de overflow
    LEA DX, msg_overflow
    MOV AH, 9
    INT 21h
    JMP stop
    
divid_por_0:
    ; imprime a mensagem de overflow
    LEA DX, msg_divisor_0
    MOV AH, 9
    INT 21h
    JMP stop

     
erro:
    
    ; imprime a mensagem de erro
    LEA DX, msg_erro
    MOV AH, 9
    INT 21h
    

stop:

RET

; Prints:
msg1 DB "Operador (1 = soma, 2 = subtracao, 3 = multiplicacao, 4 = divisao): $"
msg2 DB "Primeiro numero: $"
msg3 DB "Segundo numero: $"

msg_overflow DB "Overflow $"

msg_divisor_0 DB "ERRO (divisor = 0) $"

resto DB ", de resto $"

msg_erro DB "OPERADOR INVALIDO$"

op DB ?

num1 DW ?
num2 DW ?

; esse macro imprime o resultado da conta
PUTR    MACRO   char
        MOV     AX, num1
        CALL    print_num
        PUTC    ' '
        PUTC    char
        PUTC    ' '
        MOV     AX, num2
        CALL    print_num
        PUTC    ' '
        PUTC    '='
        PUTC    ' '
ENDM        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; these functions are copied from emu8086.inc ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this macro prints a char in AL and advances
; the current cursor position:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

; gets the multi-digit SIGNED number from the keyboard,
; and stores the result in CX register:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP                             

; this procedure prints number in AX,
; used with PRINT_NUM_UNS to print signed numbers:
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; the check SIGN of AX,
        ; make absolute if it's negative:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP

; this procedure prints out an unsigned
; number in AX (not just a single digit)
; allowed values are from 0 to 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX is zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0
        JZ      end_print

        ; avoid printing zeros before number:
        CMP     CX, 0
        JE      calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; print last digit
        ; AH is always ZERO, so it's ignored
        ADD     AL, 30h    ; convert to ASCII code.
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP

ten             DW      10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.
