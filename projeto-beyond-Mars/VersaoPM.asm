; *********************************************************************
; * IST-UL
; * Modulo:    projeto.asm
; * Grupo: 24
; * Pedro Macedo 107301
; * João Caçador 106439
; * João Alves 106439
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************

DISPLAYS         EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN          EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL          EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA            EQU 8       ; linha a testar (4ª linha, 1000b)
MASCARA_0F       EQU 0FH     ; para isolar os 4 bits de menor peso

COMANDOS		EQU	6000H	            ; endereço de base dos comandos do MediaCenter
DEFINE_LINHA    EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 	EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
SELECIONA_SOM  EQU COMANDOS + 48H       ; endereço do comando para selecionar um som
REPRODUZ_SOM EQU COMANDOS + 5AH         ; endereço do comando para reproduzir o som selecionado


VERMELHO        EQU 0FF00H      ; cor do pixel vermelho
VERDE           EQU 0F0F0H      ; cor do pixel verde
AZUL            EQU 0F00FH      ; cor do pixel azul
AMARELO		    EQU 0FFF0H	    ; cor do pixel amarelo


; #######################################################################
;  ZONA DE DADOS 
; #######################################################################

	PLACE		3000H				

DEF_ASTEROIDE_MINERAVEL:    ; tabela que define o asteroide mineravel
	WORD		5, 5        ; largura e altura do asteroide
	WORD		0, VERDE, VERDE, VERDE, 0
    WORD		VERDE, VERDE, VERDE, VERDE, VERDE
    WORD		VERDE, VERDE, VERDE, VERDE, VERDE
    WORD		VERDE, VERDE, VERDE, VERDE, VERDE
    WORD		0, VERDE, VERDE, VERDE, 0

DEF_SONDA:					; tabela que define a sonda
	WORD		1, 1        ; largura e altura da sonda
	WORD	    AMARELO

DEF_PAINEL_INSTRUMENTOS:    ; tabela que define o painel de instrumentos
    WORD        15, 5       ; largura e altura do painel de instrumentos
    WORD        0, 0, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, 0, 0
    WORD        0, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, 0
    WORD        VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO
    WORD        VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO
    WORD        VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO
    
VALOR_DISPLAY:              ; valor no display
    WORD 0                  

LINHA_ASTEROIDE:
    WORD 0                  ; valor da linha do pixel-posição do asteroide

COLUNA_ASTEROIDE:           ; valor da coluna do pixel-posição do asteroide
    WORD 0    

LINHA_SONDA:                ; valor da linha do pixel-posição da sonda
    WORD 26

COLUNA_SONDA:               ; valor da linha do pixel-posição da sonda
    WORD 32 

; **********************************************************************
; * Código
; **********************************************************************

PLACE 1000H

; inicialização da stack

STACK 100H
SP_init:

STACK 100H
SP_init_teclado:

tecla_carregada:
    LOCK 0              ; LOCK para o teclado comunicar aos restantes processos que tecla detetou

PLACE 0 ; o código começa na posição 0

inicializacoes:
    MOV SP, SP_init
    MOV  [APAGA_AVISO], R1	            ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	            ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV	  R1, 0			                ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo

    CALL teclado_inicio

desenha_asteroide:          	
	MOV	R0, DEF_ASTEROIDE_MINERAVEL	; endereço da tabela que define o asteroide
    MOV R1, [LINHA_ASTEROIDE]       ; linha da posição do asteroide
    MOV R2, [COLUNA_ASTEROIDE]      ; coluna da posição do asteroide
    CALL desenha_boneco             ; desenha o asteroide

dsenha_sonda:          	
	MOV	R0, DEF_SONDA			    ; endereço da tabela que define a sonda
    MOV R1, [LINHA_SONDA]           ; linha da posição da sonda
    MOV R2, [COLUNA_SONDA]          ; coluna da posição da sonda
    CALL desenha_boneco             ; desenha a sonda

desenha_painel:            
    MOV R0, DEF_PAINEL_INSTRUMENTOS ; endereço da tabela que define o painel
    MOV R1, 27                      ; linha da posição do painel
    MOV R2, 25                      ; coluna da posição do painel
    CALL desenha_boneco             ; desenha o painel

; #######################################################################
; COMANDO - executa a ação correspondente ao input
;                 
;
; Argumentos:   
;             R6 - input
; #######################################################################   


comando:
; R6 - input

comando_inicio: 

; redireciona para a ação correspondente ao input


    MOV R6, [tecla_carregada] ; bloqueia neste LOCK até uma tecla ser carregada
    CMP  R6, 0
    JZ   comando_aumenta_display    ; input = 0 -> Aumenta o display em 1 unidade
    CMP  R6, 1
    JZ   comando_diminui_display    ; input = 1 -> Diminui o display em 1 unidade
    CMP  R6, 2
    JZ   comando_move_asteroide     ; input = 2 -> Move o asteróide
    CMP  R6, 3
    JZ   comando_move_sonda         ; input = 3 -> Move a sonda
    JMP  comando_inicio               
    
comando_aumenta_display:
    MOV  R4, DISPLAYS           ; endereço do periférico dos displays
    MOV  R1, [VALOR_DISPLAY]    ; Obtém o valor atual do display
    INC  R1                     ; Adiciona 1 a esse valor
    MOV  [VALOR_DISPLAY], R1    ; Altera o valor na memória
    MOV  [R4], R1               ; Altera o valor no display
    JMP  comando_inicio

comando_diminui_display:
    MOV  R4, DISPLAYS           ; endereço do periférico dos displays
    MOV  R1, [VALOR_DISPLAY]    ; Obtém o valor atual do display
    SUB  R1, 1                  ; Subtrai 1 a esse valor
    MOV  [VALOR_DISPLAY], R1    ; Altera o valor na memória
    MOV  [R4], R1               ; Altera o valor no display
    JMP  comando_inicio

comando_move_asteroide:
    MOV R0, DEF_ASTEROIDE_MINERAVEL     ; Obtém o endereço do asteróide
    MOV R1, [LINHA_ASTEROIDE]           ; Obtém a sua posição (linha)
    MOV R2, [COLUNA_ASTEROIDE]          ; Obtém a sua posição (coluna)
    CALL apaga_boneco                   ; Rotina para apagar o boneco
    INC R1                              ; Incremento da sua posição (1 na diagonal)
    INC R2
    MOV [LINHA_ASTEROIDE], R1           ; Atualização da posição do asteróide na memória
    MOV [COLUNA_ASTEROIDE], R2
    CALL desenha_boneco                 ; Rotina para desenhar o boneco
    MOV R0, 0
    MOV [REPRODUZ_SOM], R0              ; Reproduz som
    JMP  comando_inicio
    
comando_move_sonda:
    MOV R0, DEF_SONDA       ; Obtém o endereço da sonda
    MOV R1, [LINHA_SONDA]   ; Obtém a sua posição (linha)
    MOV R2, [COLUNA_SONDA]  ; Obtém a sua posição (coluna)
    CALL apaga_boneco       ; Rotina para apagar o boneco
    SUB R1, 1               ; Sobe a posição 1 linha
    MOV [LINHA_SONDA], R1   ; Atualização da posição da sonda na memória
    MOV [COLUNA_SONDA], R2
    CALL desenha_boneco     ; Rotina para desenhar o boneco
    JMP  comando_inicio



; **********************************************************************
; Processo
;
; TECLADO - Processo que deteta quando se carrega numa tecla
;         do teclado e escreve o valor da tecla num LOCK.
;
; **********************************************************************

PROCESS SP_init_teclado  ; indicação de que a rotina que se segue é um processo,
                        ; com indicação do valor para inicializar o SP
teclado_inicio:		

; inicializações do teclado

    MOV  R2, TEC_LIN   		    ; endereço do periférico das linhas
    MOV  R3, TEC_COL   		    ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  		    ; endereço do periférico dos displays
    MOV  R5, MASCARA_0F   	    ; para isolar os 4 bits de menor peso
    MOV  R1, 0
    MOV  [R4], R1               ; mete os valores 000 nos displays

; corpo principal do programa

teclado_ciclo:
    MOV R6, -1        ; valor que representa nenhuma tecla premida
	MOV R1, LINHA     ; o ciclo começa na linha 4 (1000b)

teclado_espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
    
    YIELD

	MOVB [R2], R1      		        ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      		        ; ler do periférico de entrada (colunas)
	AND  R0, R5        		        ; elimina bits para além dos bits 0-3
	JNZ  teclado_tecla_premida 		; verifica se alguma tecla foi premida
	SHR  R1, 1        		        ; passa para a próxima linha
	JNZ teclado_espera_tecla   		; verifica se a linha anula-se (0000b)
	MOV R1, LINHA      	        	; restora o valor da linha a 8 (1000b)
	JMP teclado_espera_tecla   		; repete o ciclo

teclado_tecla_premida:	       		
	CALL conversao                  ; converte a linha e coluna da tecla premida para um só dígito hexadecimal
    MOV [tecla_carregada], R6
    
teclado_ha_tecla:              		; neste ciclo espera-se até NENHUMA tecla estar premida

    YIELD

	MOVB [R2], R1      		        ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      		        ; ler do periférico de entrada (colunas)
	AND  R0, R5        		        ; elimina bits para além dos bits 0-3
	CMP  R0, 0        		        ; há tecla premida?
	JNZ  teclado_ha_tecla      		; se ainda houver uma tecla premida, espera até não haver
	JMP  teclado_ciclo  			; repete ciclo
    
; ***********************************************************************
; * ROTINAS
; ***********************************************************************   

; #######################################################################
; CONVERSAO - converte a linha e a coluna da tecla para um digito 
;             hexadecimal
;
; Argumentos:   
;             R1 - linha
;             R0 - coluna
;             R6 - resultado
; #######################################################################
    
conversao:			

conversao_inicio:
	PUSH R0
	PUSH R1
	PUSH R3
	MOV R6, 0       ; inicializa a linha (decimal) a 0
	MOV R3, 0       ; inicializa a coluna (decimal) a 0
	
conversao_linha:

; a linha em formato decimal obtém-se contando o número de SHR precisos para anular o valor da linha

	SHR R1, 1       
	INC R6           
	CMP R1, 0
	JNZ conversao_linha
	SUB R6, 1
	    
conversao_coluna:

; a linha em formato decimal obtém-se contando o número de SHR precisos para anular o valor da coluna

	SHR R0, 1
	INC R3
	CMP R0, 0
	JNZ conversao_coluna
	SUB R3, 1
	
conversao_soma:

; a tecla permida obtêm-se com a fórmula 4*linha + coluna

	MOV R1, 4
	MUL R6, R1
	ADD R6, R3
	
conversao_ret:
	POP R3
	POP R1
	POP R0
	RET

; #######################################################################
; DESENHA_BONECO - desenha um boneco a partir da sua tabela definida
;                  nos dados
;
; Argumentos:   
;             R0 - endereço
;             R1 - linha
;             R2 - coluna
; ####################################################################### 

desenha_boneco:
    ; R0 - endereço
    ; R1 - linha
    ; R2 - coluna
    ; R3 - contador da largura
    ; R4 - contador da altura
    ; R5 - cor do pixel
    ; R6 - posição inicial

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
    ADD R3, R2              ; adiciona a coluna da posição do boneco à largura
	ADD	R0, 2			    ; próxima posição na tabela (Altura)
    MOV R4, [R0]            ; obtém a altura do boneco
    ADD R4, R1              ; adiciona a linha da posição do boneco à altura
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


; #######################################################################
; APAGA_BONECO - apaga um boneco a partir da sua tabela definida
;                  nos dados
;
; Argumentos:   
;             R0 - endereço
;             R1 - linha
;             R2 - coluna
; #######################################################################    


apaga_boneco:       		; apaga o boneco a partir da tabela
    ; R0 - endereço
    ; R1 - linha
    ; R2 - coluna
    ; R3 - contador da largura
    ; R4 - contador da altura
    ; R5 - pixel transparente
    ; R6 - posição inicial

apaga_boneco_init:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R6, R2              ; guarda a primeira coluna do boneco
    MOV	R3, [R0]			; obtém a largura do boneco
    ADD R3, R2              ; adiciona a coluna da posição do boneco à largura
	ADD	R0, 2			    ; próxima posição na tabela (Altura)
    MOV R4, [R0]            ; obtém a altura do boneco
    ADD R4, R1              ; adiciona a linha da posição do boneco à altura

apaga_boneco_linha:
	MOV	R5, 0			    ; obtém a cor do próximo pixel do boneco
	MOV [DEFINE_LINHA], R1	; seleciona a linha
	MOV [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV [DEFINE_PIXEL], R5	; altera a cor do pixel na linha e coluna selecionadas
    INC R2                  ; próxima coluna
    CMP R2, R3			    ; vê se chegou ao final da linha
    JN apaga_boneco_linha   ; continua até percorrer toda a largura do objeto
    MOV R2, R6              ; restora o valor da coluna
    INC R1                  ; passa para a próxima linha
    CMP R1, R4              ; vê se chegou ao final do boneco
    JN apaga_boneco_linha

apaga_boneco_ret:
    POP R6
    POP R5
    POP R4
    POP R3  
    POP R2
    POP R1
    POP R0
    RET


