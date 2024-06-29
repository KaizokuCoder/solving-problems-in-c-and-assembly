; problema 3 - soma de uma pa :p

ORG     100h

; imprime a variavel msg1
LEA     DX, msg1
MOV     AH, 9
INT     21h

; ler inteiro do usuario e passar para variavel first  
CALL    SCAN_NUM
MOV     first, CX

; pular linha
PUTC    0Dh
PUTC    0Ah

; imprime a variavel msg2
LEA     DX, msg2
MOV     AH, 9
INT     21h  

; ler inteiro do usuario e passar para variavel last
CALL    SCAN_NUM
MOV     last, CX   

; pular linha
PUTC    0Dh
PUTC    0Ah   

; imprime a variavel msg3
LEA     DX, msg3
MOV     AH, 9
INT     21h  

; ler inteiro do usuario e passar para variavel last
CALL    scan_num
MOV     num, CX   

; pular linha
PUTC    0Dh
PUTC    0Ah

; cria uma pilha para os parametros e chama a funcao

MOV     AX, first
MOV     BX, last
MOV     CX, num
CALL    soma_pa     ; o resultado fica em AX 

; imprimir o resultado 
PUSH    AX          ; save AX
LEA     DX, msg4
MOV     AH, 9
INT     21h  
POP     AX          ; restore AX
CALL    print_num   ; print AX

PUTC    0Dh         ; \n no final do output
PUTC    0Ah

RET

; Iniciando variaveis 
msg1    DB "Digite o primeiro digito da PA: $"
msg2    DB "Digite o ultimo digito da PA: $"
msg3    DB "Digite o numero de termos da PA: $"
msg4    DB "A soma da pa eh: $"

first   DW ?
last    DW ?
num     DW ?
                       
;;;;;;;;;;;;;;;;;;;;;;                       
;;; my function :D ;;;
;;;;;;;;;;;;;;;;;;;;;;

; esse procedimento calcula a soma de uma P.A.
; retorna o resultado em AX (usando BX, CX e DX)
SOMA_PA         PROC 
        ; AX = first
        ; BX = last
        ; CX = num
         
        MOV     DX, 0
            
        ADD     AX, BX ; AX = AX + BX       

        IMUL    CX     ; (DX AX) = AX * CX
                                                  
        MOV     BX, 2                                                 
        IDIV    BX     ; AX = (DX AX) / BX  

        RET
SOMA_PA         ENDP
              

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; these functions are copied from emu8086.inc ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; esse macro imprime o caractere do registrador AL e avanca
; a posicao atual do cursor:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h
        POP     AX
ENDM

; esse processo pega o numero multi-digito com SINAL do teclado,
; e guarda o resultado no registrador CX:
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

; esse procedimento imprime o numero em AX,
; usando PRINT_NUM_UNS para numeros com sinal:
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

; esse procedimento imprime numeros sem sinal
; guardados no registrador AX (não apenas com 1 dígito)
; permite valores de 0 a 65535 (FFFF)
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
