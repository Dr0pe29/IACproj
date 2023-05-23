; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descrição: Exemplifica o acesso a um teclado.
; *            Lê uma linha do teclado, verificando se há alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos periféricos de 8 bits
; *       através da instrução MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATENÇÃO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto não altera o valor de 16 bits e permite distinguir números de identificadores
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA      EQU 8       ; linha a testar (4ª linha, 1000b)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; **********************************************************************
; * Código
; **********************************************************************

PLACE 1000H

STACK 100H
SP_init:

PLACE      0

MOV SP, SP_init

inicio:		

; inicializações

    MOV  R2, TEC_LIN   		; endereço do periférico das linhas
    MOV  R3, TEC_COL   		; endereço do periférico das colunas
    MOV  R4, DISPLAYS  		; endereço do periférico dos displays
    MOV  R5, MASCARA   		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; corpo principal do programa

ciclo:
	MOV  R1, 0 
	MOVB [R4], R1      		; escreve linha e coluna a zero nos displays
	MOV R1, LINHA     		; o ciclo começa na linha 4 (1000b)

espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	MOVB [R2], R1      		; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      		; ler do periférico de entrada (colunas)
	AND  R0, R5        		; elimina bits para além dos bits 0-3
	JNZ  tecla_premida 		; se uma tecla foi premida, avança
	SHR  R1, 1        		; 
	JNZ espera_tecla   		; se nenhuma tecla premida, repete para a próxima linha
	MOV R1, LINHA      		; depois de percorrer a última linha restora o valor de R1 a 8 (1000b)
	JMP espera_tecla   		; repete o ciclo

tecla_premida:	       		; vai mostrar a linha e a coluna da tecla
	CALL conversao
	MOVB [R4], R6     		; escreve linha e coluna nos displays
    
ha_tecla:              		; neste ciclo espera-se até NENHUMA tecla estar premida
	MOVB [R2], R1      		; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      		; ler do periférico de entrada (colunas)
	AND  R0, R5        		; elimina bits para além dos bits 0-3
	CMP  R0, 0        		; há tecla premida?
	JNZ  ha_tecla      		; se ainda houver uma tecla premida, espera até não haver
	JMP  ciclo  			; repete ciclo
    
    
    
conversao:			; converte a linha e a coluna da tecla para um digito hexadecimal

; R1 - linha
; R0 - coluna
; R6 - resultado

conversao_inicio:
	PUSH R0
	PUSH R1
	PUSH R3
	MOV R6, 0
	MOV R3, 0
	
conversao_linha:
	SHR R1, 1
	INC R6
	CMP R1, 0
	JNZ conversao_linha
	SUB R6, 1
	
conversao_coluna:
	SHR R0, 1
	INC R3
	CMP R0, 0
	JNZ conversao_coluna
	SUB R3, 1
	
conversao_soma:
	MOV R1, 4
	MUL R6, R1
	ADD R6, R3
	
conversao_ret:
	POP R3
	POP R1
	POP R0
	RET