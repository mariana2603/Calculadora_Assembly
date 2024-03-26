
.MODEL SMALL
.STACK 100H
.DATA
        MSG0 DB 'BEM VINDO(A) A CALCULADORA $'
        MSG1 DB 10,13,'1 - ADICAO $'
        MSG2 DB 10,13,'2 - SUBTRACAO $'
        MSG3 DB 10,13,'3 - MULTIPLICACAO $'
        MSG4 DB 10,13,'4 - DIVISAO $'
        MSGS DB 10,13,'5 - SAIDA $'
        MSG5 DB 10,13,'SUA ESCOLHA: $'
        MSG6 DB 10,13,10,13,'NUMERO 1:$'
        MSG7 DB 10,13,'NUMERO 2:$'
        MSG9 DB 10,13,'QUANTAS VEZES OCORRERA A MULTIPLICACAO POR 2: $'
        MSG91 DB 10,13,'QUANTAS VEZES OCORRERA A DIVISAO POR 2: $'
        MSG8 DB 10,13,10,13,'RESULTADO:$' 
        MSG DB 10,13,10,13,'               OBRIGADA $'

;DW = 16 bits        
        NUM1 DW 0       
        NUM2 DW 0       
        RESULT DW 0     
.CODE
MAIN PROC
        MOV AX,@DATA    ;inicializar DS com o endereco base do segmento de dados
        MOV DS,AX
        
        LEA DX,MSG0     ;colocar endereco de msg em DX
        MOV AH,9        ;mostra o string que esta em msg
        INT 21H         

INICIO:
;ler string do.data
        LEA DX,MSG1     
        MOV AH,9        
        INT 21H
        
        LEA DX,MSG2     
        MOV AH,9        
        INT 21H
        
        LEA DX,MSG3    
        MOV AH,9        
        INT 21H
        
        LEA DX,MSG4     
        MOV AH,9      
        INT 21H 
        
        LEA DX,MSGS     
        MOV AH,9        
        INT 21H 
        
        LEA DX,MSG5     
        MOV AH,9        
        INT 21H
;escolha da operacao desejada        
        MOV AH,1        ;fun??o DOS para entrada pelo teclado
        INT 21H
        AND AL, 0FH     ;retira 30h do ASCII
;compara numero(correspondente com a operacao) escolhido e pula pra tal operacao       
        CMP AL,1        ;compara o AL (escolha) com o numero 1
        JE  UM          ;pula para "UM"
        
        CMP AL,2        
        JE  DOIS        
         
        CMP AL,3        
        JE TRES        
        
        CMP AL,4       
        JE QUATRO      
        
        CMP AL,5        
        JE CINCO        
        JMP INICIO      ;pula novamente para o inicio (loop)
UM: JMP ADI            
DOIS:JMP SUBT         
TRES: JMP MULT        
QUATRO: JMP DIVI        ;pula para "DIVI"
CINCO:  JMP SAIDA       ;pula para "SAIDA"
   
ADI:  
        MOV RESULT, 0   ;iguala result a 0
        MOV NUM1, 0     ;iguala num1 a 0
        MOV NUM2, 0     ;iguala num2 a 0
       
        LEA DX,MSG6     
        MOV AH,9        
        INT 21H 
        
        MOV CX, 3       ;limite de digito
        MOV BL, 10
NUMERO1AD:

    ;l? o numero multplica ele por 10 e soma com o proximo digito


        MOV AH,1        ;fun??o DOS para entrada pelo teclado
        INT 21H         ;interrup??es do DOS
        CMP AL, 0DH     ;compara AL com ENTER(=)
        JE ADI2         ;pula para "ADI2"
        AND AL, 0FH     ;retira 30h do ASCII
        XOR AH, AH      ;AH = 0
        ADD NUM1, AX    ;
        MOV AX, NUM1    ;
        MUL BL          ;
        MOV NUM1, AX    ;move num1 para AX
        LOOP NUMERO1AD

ADI2:

    ; apos todas as multiplica??es por 10, eh feito a divisao para o numero ter seu valor correto


        MOV AX, NUM1    ;move AX para num1
        DIV BL          ;divisao apos o termino da leitura 
        MOV NUM1, AX

        LEA DX,MSG7     
        MOV AH,09H     
        INT 21H 

        MOV CX, 3       ;limite de digitos
NUMERO2AD:        
    ;l? o numero multplica ele por 10 e soma com o proximo digito

        MOV AH,1        
        INT 21H         
        CMP AL, 0DH    
        JE RESULTADOAD  ;pula para "RESULTADOAD"
        AND AL, 0FH     
        ADD NUM2, AX
        MOV AX,NUM2
        MUL BL
        MOV NUM2, AX
        LOOP NUMERO2AD
RESULTADOAD:
     ; apos todas as multiplica??es por 10, eh feito a divisao para o numero tem seu valor correto

        MOV AX, NUM2
        DIV BL
        MOV NUM2, AX 
        
        MOV AX, NUM1    ;move AX para num1
        MOV BX, NUM2    ;move BX para num2
        ADD AX,BX       ;soma AX e BX
        MOV RESULT, AX  ;move result para AX
        LEA DX,MSG8       
        MOV AH,9         
        INT 21H
    ; verifica se o resultado tem somente um digito
        MOV BL, 10      
        XOR CX, CX      ;CX = 0
        MOV AX, RESULT  ;move AX para result 
        CMP AX, 9       
        JNGE ULTIMOAD   ;pula para"ULTIMOAD"

PRINTAD:
    ; caso o numero tenha mais de um digito, eh feito a divisao por 10 e o resto da divisao eh armazenado na pilha
        MOV AX, RESULT  
        DIV BL  
        MOV DX, AX      
        XOR DH, DH      ;DH = 0
        MOV RESULT, 0   
        MOV RESULT, DX  
        XOR AL, AL      ;AL = 0
        MOV DL, AH      
        PUSH DX         ;coloca o conte?do de DX no topo da pilha
        MOV AX, RESULT
        
        INC CX          ;incrementa o contador
        CMP AX, 9
        JNGE ULTIMOAD   ;pula para "ULTIMO AD"
        JMP PRINTAD     ;pula para "PRINTAD"
ULTIMOAD:
    ; o ultimo digito sendo armazenado na pilha

        MOV AX, RESULT
        PUSH AX         ;coloca o conte?do de AX no topo da pilha
        INC CX          ;incrementa o contador
IMPRIMIAD:
    ; apos os restos da divis?es estiverem na pilha, ocorre o despilhamento 
        POP DX          ;retira elemento do topo da pilha e o coloca em DX
        ADD DL, 30h     
        MOV AH, 02      ;imprime caracter na tela
        INT 21H
        LOOP IMPRIMIAD

        JMP INICIO      ;pula novamente para o inicio (loop)
SUBT:  
        MOV RESULT, 0
        MOV NUM1, 0 
        MOV NUM2, 0

        LEA DX,MSG6  
        MOV AH,9
        INT 21H 
        
        MOV CX, 3
        MOV BL, 10

NUMERO1SU:

        MOV AH,1
        INT 21H
        CMP AL, 0DH
        JE SUB2
        AND AL, 0FH
        XOR AH, AH
        ADD NUM1, AX
        MOV AX, NUM1
        MUL BL
        MOV NUM1, AX
        LOOP NUMERO1SU


SUB2:
        MOV AX, NUM1
        DIV BL
        MOV NUM1, AX

        LEA DX,MSG7    
        MOV AH,9
        INT 21H 

        MOV CX, 3
NUMERO2SUB:        
        MOV AH,1
        INT 21H
        CMP AL, 0DH
        JE RESULTADOSU
        AND AL, 0FH
        XOR AH, AH
        ADD NUM2, AX
        MOV AX, NUM2
        MUL BL
        MOV NUM2, AX
        LOOP NUMERO2SUB

RESULTADOSU:       
        MOV AX, NUM2
        DIV BL
        MOV NUM2, AX 
        MOV AX, NUM1
        MOV BX, NUM2
        
        SUB AX, BX
        MOV RESULT, AX

        LEA DX,MSG8
        MOV AH,9
        INT 21H

        
        MOV BL, 10
        xor cx, cx
        MOV AX, RESULT
        CMP AX, 9
        JNGE ULTIMOSU
        

PRINTSU:
        MOV AX, RESULT
        DIV BL
        MOV DX, AX
        XOR DH, DH
        MOV RESULT, 0
        MOV RESULT, DX
        XOR AL, AL
        MOV DL, AH
        PUSH DX
        MOV AX, RESULT
        
        INC CX

        CMP AX, 9
        JNGE ULTIMOSU
        JMP PRINTSU
        
ULTIMOSU:  
        MOV AX, RESULT
        PUSH AX
        INC CX
IMPRIMISU:
        POP DX
        ADD DL, 30h
        MOV AH, 02
        INT 21H
        LOOP IMPRIMISU
        JMP INICIO


        
    
MULT:   
        MOV RESULT, 0
        MOV NUM1, 0 
        MOV NUM2, 0

        LEA DX,MSG6
        MOV AH,9
        INT 21H
        
        MOV CX, 3
        MOV BL, 10

        
 NUMERO1MU:
        MOV AH,1
        INT 21H
        CMP AL, 0DH
        JE MULT2
        AND AL, 0FH
        XOR AH, AH
        ADD NUM1, AX
        MOV AX, NUM1
        MUL BL
        MOV NUM1, AX
        LOOP NUMERO1MU


MULT2:
        MOV AX, NUM1
        DIV BL
        MOV NUM1, AX

        LEA DX,MSG9
        MOV AH,9
        INT 21H 

        MOV CX, 3
NUMERO2MU:        
        MOV AH,1
        INT 21H
        CMP AL, 0DH
        JE RESULTADOMU
        SUB AL,30H
        ADD NUM2, AX
        MOV AX,NUM2
        MUL BL
        MOV NUM2, AX
        LOOP NUMERO2MU

        
RESULTADOMU:

        MOV AX, NUM2
        DIV BL
        MOV NUM2, AX
        MOV CX, NUM2
        MOV AX, NUM1

        SHL AL,CL
        MOV RESULT, AX

        LEA DX,MSG8
        MOV AH,9
        INT 21H

        MOV BL, 10
        xor cx, cx
        MOV AX, RESULT
        CMP AX, 9
        JNGE ULTIMOMU
        
PRINTMU:
        MOV AX, RESULT
        DIV BL
        MOV DX, AX
        XOR DH, DH
        MOV RESULT, 0
        MOV RESULT, DX
        XOR AL, AL
        MOV DL, AH
        PUSH DX
        MOV AX, RESULT

        INC CX
        CMP AX, 9
        JNGE ULTIMOMU       
        JMP PRINTMU
ULTIMOMU:
        MOV AX, RESULT
        PUSH AX
        INC CX
IMPRIMIMU:
        POP DX
        ADD DL, 30h
        MOV AH, 02
        INT 21H
        LOOP IMPRIMIMU
        
        JMP INICIO
        
DIVI: 
        MOV RESULT, 0
        MOV NUM1, 0 
        MOV NUM2, 0

        LEA DX,MSG6
        MOV AH,9
        INT 21H

        MOV CX, 3
        MOV BL, 10

NUMERO1DI: 

        MOV AH,1
        INT 21H
        CMP AL, 0DH
        JE DIVI2
        AND AL, 0FH
        XOR AH, AH
        ADD NUM1, AX
        MOV AX, NUM1
        MUL BL
        MOV NUM1, AX
        LOOP NUMERO1DI

        
DIVI2: 
        MOV AX, NUM1
        DIV BL
        MOV NUM1, AX

        LEA DX,MSG91
        MOV AH,9
        INT 21H 
        
NUMERO2DI: 
        MOV AH,1
        INT 21H
        CMP AL, 0DH
        JE RESULTADODI
        SUB AL,30H
        ADD NUM2, AX
        MOV AX,NUM2
        MUL BL
        MOV NUM2, AX
        LOOP NUMERO2DI
 RESULTADODI: 
        MOV AX, NUM2
        DIV BL
        MOV NUM2, AX
        MOV CX, NUM2
        MOV AX, NUM1

        SHR AX,CL
        MOV RESULT, AX
       
        LEA DX,MSG8
        MOV AH,9
        INT 21H 
        
        MOV BL, 10
        xor cx, cx
        MOV AX, RESULT
        CMP AX, 9
        JNGE ULTIMODI 
      
PRINTDI:       
        MOV AX, RESULT
        DIV BL
        MOV DX, AX
        XOR DH, DH
        MOV RESULT, 0
        MOV RESULT, DX
        XOR AL, AL
        MOV DL, AH
        PUSH DX
        MOV AX, RESULT
        
        INC CX
        CMP AX, 9
        JNGE ULTIMODI    
        JMP PRINTDI    

ULTIMODI:
        MOV AX, RESULT
        PUSH AX
        INC CX
IMPRIMIDI:
        POP DX
        ADD DL, 30h
        MOV AH, 02
        INT 21H
        LOOP IMPRIMIDI
        
        JMP INICIO

SAIDA:  LEA DX,MSG
        MOV AH,9
        INT 21H  
      
       
EXIT:   MOV AH,4CH  ;move valor 4ch para o registrador AH (encerra programa)
        INT 21H     ;chama a interrup??o 
    
MAIN ENDP   ;encerra fun??o principal
END MAIN    ;finaliza o c?digo do programa