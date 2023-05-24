; *********************************************************************
; * IST-UL
; * Modulo:    projeto.asm
; * Descrição: Exemplifica o acesso a um teclado.
; *            Lê uma linha do teclado, verificando se há alguma tecla
; *            premida nessa linha.
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
DISPLAYS        EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN         EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL         EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA           EQU 8       ; linha a testar (4ª linha, 1000b)
MASCARA_0F      EQU 0FH     ; para isolar os 4 bits de menor peso

COMANDOS		EQU	6000H	; endereço de base dos comandos do MediaCenter
DEFINE_LINHA    EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 	EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

VERMELHO        EQU 0FF00H      ; cor do pixel vermelho
VERDE           EQU 0F0F0H      ; cor do pixel verde
AZUL            EQU 0F00FH      ; cor do pixel azul
; #######################################################################
;  ZONA DE DADOS 
; #######################################################################
	PLACE		0100H				

DEF_ASTEROIDE_MINERAVEL:    ; tabela que define o asteroide mineravel
	WORD		5, 5
	WORD		0, VERDE, VERDE, VERDE, 0
    WORD		VERDE, VERDE, VERDE, VERDE, VERDE
    WORD		VERDE, VERDE, VERDE, VERDE, VERDE
    WORD		VERDE, VERDE, VERDE, VERDE, VERDE
    WORD		0, VERDE, VERDE, VERDE, 0

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
    MOV  R5, MASCARA_0F   	; para isolar os 4 bits de menor peso

; corpo principal do programa

ciclo:
	MOV  R1, 0 
	MOV [R4], R1      		; escreve linha e coluna a zero nos displays
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
	MOV [R4], R6     		; escreve linha e coluna nos displays
    
ha_tecla:              		; neste ciclo espera-se até NENHUMA tecla estar premida
	MOVB [R2], R1      		; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      		; ler do periférico de entrada (colunas)
	AND  R0, R5        		; elimina bits para além dos bits 0-3
	CMP  R0, 0        		; há tecla premida?
	JNZ  ha_tecla      		; se ainda houver uma tecla premida, espera até não haver
	JMP  ciclo  			; repete ciclo
    
; #######################################################################
;  ROTINA - conversao
; #######################################################################    
    
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

dados_asteroide:          	
	MOV	R0, DEF_ASTEROIDE_MINERAVEL	; endereço da tabela que define o asteroide
    MOV R1, 0                       ; linha do canto superior esquerdo
    MOV R2, 0                       ; coluna do canto superior esquerdo
    CALL desenha_boneco
	 
; #######################################################################
;  ROTINA - desenha_boneco
; #######################################################################    

desenha_boneco:       		; desenha o boneco a partir da tabela
    ; R0 - endereço
    ; R1 - linha
    ; R2 - coluna

desenha_boneco_init:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R6, R2              ; guarda a primeira coluna do boneco
    MOV	R3, [R0]			; obtém a largura do boneco
	ADD	R0, 2			    
    MOV R4, [R0]            ; obtém a altura do boneco
    ADD R0, 2

desenha_boneco_linha:
	MOV	R5, [R0]			; obtém a cor do próximo pixel do boneco
	MOV [DEFINE_LINHA], R1	; seleciona a linha
	MOV [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV [DEFINE_PIXEL], R5	; altera a cor do pixel na linha e coluna selecionadas
	ADD R0, 2			    ; endereço da cor do próximo pixel 
    INC R2                  ; próxima coluna
    CMP R2, R3			    ; vê se chegou ao final da linha
    JN desenha_boneco_linha; continua até percorrer toda a largura do objeto
    MOV R2, R6              ; restora o valor da coluna
    INC R1                  ; passa para a próxima linha
    CMP R1, R4              ; vê se chegou ao final do boneco
    JN desenha_boneco_linha

desenha_boneco_ret:
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

