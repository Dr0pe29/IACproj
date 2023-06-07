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

COMANDOS		            EQU	6000H	            ; endereço de base dos comandos do MediaCenter
DEFINE_LINHA                EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA               EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL                EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO                 EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 	            EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO     EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
SELECIONA_SOM               EQU COMANDOS + 48H      ; endereço do comando para selecionar um som
REPRODUZ_SOM                EQU COMANDOS + 5AH      ; endereço do comando para reproduzir o som selecionado

ENERGIA_MAX                 EQU 1100H
ALTURA_ASTEROIDE            EQU 4          ; a altura é 5 mas para chegar ao ultimo pixel apenas se soma 4
LARGURA_ASTEROIDE           EQU 4          ; a largura é 5 mas para chegar ao ultimo pixel apenas se soma 4
LINHA_MAX                   EQU 31         ; ultima linha do ecra  

VERMELHO        EQU 0FF00H      ; cor do pixel vermelho
VERDE           EQU 0F0F0H      ; cor do pixel verde
AZUL            EQU 0F00FH      ; cor do pixel azul
AMARELO		    EQU 0FFF0H	    ; cor do pixel amarelo
ROSA            EQU 0FF09H      ; cor do pixel rosa
CINZA           EQU 0F064H      ; cor do pixel cinza
CIANO           EQU 0F0CFH      ; cor do pixel azul ciano


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

DEF_ASTEROIDE_NAO_MINERAVEL:    ; tabela que define o asteroide nao mineravel
	WORD		5, 5        ; largura e altura do asteroide
	WORD		VERMELHO, 0, VERMELHO, 0, VERMELHO
    WORD		0, VERMELHO, 0, VERMELHO, 0
    WORD		VERMELHO, 0, VERMELHO, 0, VERMELHO
    WORD		0, VERMELHO, 0, VERMELHO, 0
    WORD		VERMELHO, 0, VERMELHO, 0, VERMELHO

DEF_SONDA:					; tabela que define a sonda
	WORD		1, 1        ; largura e altura da sonda
	WORD	    AMARELO

DEF_PAINEL_INSTRUMENTOS:    ; tabela que define o painel de instrumentos
    WORD        15, 5       ; largura e altura do painel de instrumentos
    WORD        0, 0, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, 0, 0
    WORD        0, VERMELHO, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, VERMELHO, 0
    WORD        VERMELHO, CINZA, CINZA, CIANO, CINZA, CINZA, CINZA, AMARELO, ROSA, AMARELO, ROSA, AMARELO, CINZA, CINZA, VERMELHO
    WORD        VERMELHO, CINZA, CIANO, CINZA, CIANO, CINZA, CINZA, ROSA, AMARELO, ROSA, AMARELO, ROSA, CINZA, CINZA, VERMELHO
    WORD        VERMELHO, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, CINZA, VERMELHO
    
DEF_LUZES_1:                ; tabela que define o primeiro sprite das luzes
    WORD        5, 2        ; largura e altura das luzes
    WORD        AMARELO, ROSA, AMARELO, ROSA, AMARELO
    WORD        ROSA, AMARELO, ROSA, AMARELO, ROSA

DEF_LUZES_2:                ; tabela que define o segundo sprite das luzes
    WORD        5, 2        ; largura e altura das luzes
    WORD        ROSA, AMARELO, ROSA, AMARELO, ROSA
    WORD        AMARELO, ROSA, AMARELO, ROSA, AMARELO

VALOR_DISPLAY:              ; valor no display
    WORD 100                  

SPAWN_ASTEROIDE:
    WORD 0, 1
    WORD 30, -1
    WORD 30, 0
    WORD 30, 1
    WORD 59, -1

SPAWN_SONDA:
    WORD 26, -1
    WORD 32, 0
    WORD 38, 1

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
SP_init_prog_princ:

STACK 100H
SP_init_teclado:

STACK 100H
SP_init_energia:

STACK 100H
SP_init_asteroide:

STACK 100H
SP_init_nave:

STACK 100H          
SP_init_sonda:   

tecla_carregada:
    LOCK 0              ; LOCK para o teclado comunicar aos restantes processos que tecla detetou

relogio_asteroide:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo boneco que a interrupção ocorreu
    
relogio_sonda:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo sonda que a interrupção ocorreu

relogio_energia:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo energia que a interrupção ocorreu

relogio_nave:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo nave que a interrupção ocorreu

colisao:                ; indica se ha colisao entre asteroide e sonda
    WORD 0

; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0
    WORD rot_int_1      			; rotina de atendimento da interrupção 1
    WORD rot_int_2          ; rotina de atendimento da interrupção 2
    WORD rot_int_3			; rotina de atendimento da interrupção 3


PLACE 0 ; o código começa na posição 0

inicializacoes:
    MOV SP, SP_init_prog_princ
    MOV BTE, tab                        ; inicializa BTE (registo de Base da Tabela de Exceções)

    MOV  [APAGA_AVISO], R1	            ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	            ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV	  R1, 0			                ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    MOV  R4, DISPLAYS                   ; endereço do periférico dos displays
    MOV  R1, 0100H                      ; Valor correspondente a 100 decimal no display
    MOV  [R4], R1                       ; Altera o valor no display

    EI0		
    EI1			                ; permite interrupções 0
    EI2                                 ; permite interrupções 2
    EI3                                 ; permite interrupções 3
	EI					                ; permite interrupções (geral)

    ; criacao dos processos
    CALL teclado
    CALL energia
    CALL asteroide
    CALL nave
    CALL sonda
    

comando:
; R6 - c xgrx

comando_inicio: 

; redireciona para a ação correspondente ao input

    MOV  R6, [tecla_carregada] ; bloqueia neste LOCK até uma tecla ser carregada
    MOV  R1, 0CH
    CMP  R6, R1
    JZ   comando_comeca_jogo        ; input = C -> Começa jogo
    JMP  comando_inicio                

comando_comeca_jogo:
    MOV   R1, 0                         ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1  ; seleciona o cenário de fundo
    MOV  R4, DISPLAYS                   ; endereço do periférico dos displays
    MOV  R1, 64H                        ; Valor correspondente a 100 decimal (energia máxima)
    MOV  [VALOR_DISPLAY], R1            ; Altera o valor na memória
    MOV  R1, 0100H                      ; Valor correspondente a 100 decimal no display
    MOV  [R4], R1                       ; Altera o valor no display
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

teclado:

teclado_inicio:		

; inicializações do teclado

    MOV  R2, TEC_LIN   		    ; endereço do periférico das linhas
    MOV  R3, TEC_COL   		    ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  		    ; endereço do periférico dos displays
    MOV  R5, MASCARA_0F   	    ; para isolar os 4 bits de menor peso

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

; **********************************************************************
; Processo
;
; ENERGIA - Processo que decrementa a energia no display, com
;        temporização marcada pela interrupção 0
;
; **********************************************************************

PROCESS SP_init_energia ; indicação de que a rotina que se segue é um processo,
                        ; com indicação do valor para inicializar o SP

                        ;R1 - número
                        ;R2 - fator
                        ;R3 - valor 10
                        ;R4 - dígito
                        ;R5 - resultado

energia:

    MOV R0, [relogio_energia] ; lê o LOCK e bloqueia até a interrupção escrever nele

    MOV R1, [VALOR_DISPLAY] ; Obtém valor atual da energia
    MOV R2, 3               ; Valor de decremento da energia (3%)
    SUB R1, R2              ; Decremento da energia
    MOV [VALOR_DISPLAY], R1 ; Atualiza valor da energia em memória
    MOV R2, 1000            ; Fator para converter um número de 3 dígitos
    MOV R3, 10              ; Valor para obter diferentes potências de 10
    MOV R5, 0               ; Inicialização a 0

converte_energia:
    MOD R1, R2              ; número: o valor a converter nesta iteração
                            ; fator: uma potência de 10 (para obter os dígitos)

    DIV R2, R3              ; prepara o próximo fator de divisão
    CMP R2, 0               ; se fator = 0, termina
    JZ altera_energia
    MOV R4, R1              ; Preserva o número
    DIV R4, R2              ; Obtém um dígito do valor decimal (0 a 9)
    SHL R5, 4               ; desloca, para dar espaço ao novo dígito
    OR R5, R4               ; vai compondo o resultado
    JMP converte_energia

altera_energia:
    MOV  R4, DISPLAYS           ; endereço do periférico dos displays
    MOV  [R4], R5              ; Altera o valor no display
    JMP energia

; **********************************************************************
; Processo
;
; ASTEROIDE - Processo que executa as ações relativas ao asteroide, como o seu
; movimento e a rotina de colisão com a nave
;
; **********************************************************************

PROCESS SP_init_asteroide  ; indicação de que a rotina que se segue é um processo,
                            ; com indicação do valor para inicializar o SP

asteroide:

asteroide_parametros:
    MOV R5, [TEC_COL]
    SHR R5, 4
    MOV R6, R5
    MOV R8, 5
    MOD R5, R8
    MOV R8, 4
    MOD R6, R8
    JZ asteroide_mineravel

asteroide_nao_mineravel:
    MOV	R0, DEF_ASTEROIDE_NAO_MINERAVEL	; endereço da tabela que define o asteroide nao mineravel
    JMP asteroide_spawn

asteroide_mineravel:
    MOV	R0, DEF_ASTEROIDE_MINERAVEL	; endereço da tabela que define o asteroide

asteroide_spawn:
    MUL R5, R8                       ; cada endereço da tabela tem 2 WORDS (4 bytes)
    MOV R9, SPAWN_ASTEROIDE
    MOV R2, [R9 + R5]               ; coluna de spawn do asteroide
    ADD R5, 2                       ; o incremento do asteroide encontra-se na segunda WORD do endereço
    MOV R7, [R9 + R5]               ; incremento
    MOV R1, 0                       ; linha de spawn do asteroide

asteroide_ciclo:
    CALL desenha_boneco             ; desenha o asteroide
    MOV	R3, [relogio_asteroide]	    ; lê o LOCK e bloqueia até a interrupção escrever nele
						            ; Quando bloqueia, passa o controlo para outro processo
						            ; Como não há valor a transmitir, o registo pode ser um qualquer
asteroide_movimento:
    CALL apaga_boneco               ; Rotina para apagar o boneco
    ADD  R1, 1                      ; Incremento da linha
    ADD  R2, R7                     ; incremento da coluna
    MOV  [LINHA_ASTEROIDE], R1      ; Atualização da posição do asteróide na memória
    MOV  [COLUNA_ASTEROIDE], R2
    CALL testa_limites_A
    MOV  R5, 0
    CMP  R8, R5
    JZ   asteroide_parametros
    INC  R5
    CMP  R8, R5
    JZ   asteroide_fim_jogo
    INC  R5
    CMP  R8, R5
    JZ   asteroide_colisao
    JMP  asteroide_ciclo            ; este processo é um ciclo infinito. Não é bloqueante devido ao LOCK
    
asteroide_colisao:
    MOV R8, 1
    MOV [colisao], R8
    JMP asteroide_parametros
    
asteroide_fim_jogo:
    JMP asteroide_fim_jogo

; **********************************************************************
; Processo
;
; NAVE - Processo que executa as ações relativas ao painel de instrumentos,
; isto é, a animação das luzes
;
; **********************************************************************

PROCESS SP_init_nave  ; indicação de que a rotina que se segue é um processo,
                            ; com indicação do valor para inicializar o SP
nave:            
    MOV R0, DEF_PAINEL_INSTRUMENTOS ; endereço da tabela que define o painel
    MOV R1, 27                      ; linha da posição do painel
    MOV R2, 25                      ; coluna da posição do painel
    CALL desenha_boneco             ; desenha o painel
    MOV R4, 1                       ; este registo representa o sprite em que as luzes se encontram no instante

nave_ciclo:
    MOV	R3, [relogio_nave]	        ; lê o LOCK e bloqueia até a interrupção escrever nele
						            ; Quando bloqueia, passa o controlo para outro processo
						            ; Como não há valor a transmitir, o registo pode ser um qualquer
    CMP R4, 1
    JZ nave_sprite_2

nave_sprite_1:
    MOV R0, DEF_LUZES_1             ; endereço da tabela que define o primeiro sprite das luzes
    MOV R1, 29                      ; linha da posição do painel
    MOV R2, 32                      ; coluna da posição do painel
    CALL desenha_boneco
    INC R4
    JMP nave_ciclo

nave_sprite_2:
    MOV R0, DEF_LUZES_2             ; endereço da tabela que define o segundo sprite das luzes
    MOV R1, 29                      ; linha da posição do painel
    MOV R2, 32                      ; coluna da posição do painel
    CALL desenha_boneco
    SUB R4, 1
    JMP nave_ciclo

; ********************************************************************************
; Processo
;
; SONDA - Processo que desenha as sondas e as move na direcao correta consoante 
;         a tecla premida com temporizacao marcada pela interrupcao 0
;
; ********************************************************************************]

PROCESS SP_init_sonda  ; indicação de que a rotina que se segue é um processo,
                        ; com indicação do valor para inicializar o SP

sonda:   
    MOV	R0, DEF_SONDA			    ; endereço da tabela que define a sonda
    MOV R4, 14                      ; linha da posição máxima

sonda_input:
    MOV R1, -1
    MOV [LINHA_SONDA], R1
    MOV [COLUNA_SONDA], R1 
    MOV R5, [tecla_carregada]       ; bloqueia neste LOCK até uma tecla ser carregada
    MOV R8, 2
    CMP R5, R8
    JGT sonda_input

sonda_spawn:
    MOV R8, 4
    MUL R5, R8                       ; cada endereço da tabela tem 2 WORDS (4 bytes)
    MOV R9, SPAWN_SONDA
    MOV R2, [R9 + R5]               ; coluna de spawn da sonda
    ADD R5, 2                       ; o incremento da sonda encontra-se na segunda WORD do endereço
    MOV R6, [R9 + R5]               ; incremento
    MOV R1, 26                      ; linha de spawn da sonda

sonda_ciclo:
    CALL desenha_boneco             ; desenha a sonda na sua posição atual
    MOV  R3, [relogio_sonda]        ; lê o LOCK e bloqueia até a interrupção escrever nele
                                    ; Quando bloqueia, passa o controlo para outro processo
                                    ; Como não há valor a transmitir, o registo pode ser um qualquer

sonda_movimento:
    CALL apaga_boneco           ; apaga a sonda da sua posição corrente
    SUB  R1, 1                  ; para desenhar sonda na linha seguinte
    ADD  R2, R6                 ; para desenhar a sonda na próxima coluna
    CMP  R1, R4                 ; verifica máximo movimentos
    JZ   sonda_input
    MOV  [LINHA_SONDA], R1      ; Atualização da posição da sonda na memória
    MOV  [COLUNA_SONDA], R2
    MOV  R8, [colisao]
    MOV  R3, 1
    CMP  R8, R3
    JZ   sonda_destruida
    JMP  sonda_ciclo            ; esta "rotina" nunca retorna porque nunca termina
                                ; Se se quisesse terminar o processo, era deixar o processo chegar a um RET

sonda_destruida:
    MOV  R8, 0
    MOV  [colisao], R8
    JMP  sonda_input

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

; #######################################################################
; TESTA_LIMITES_A -   verifica se o asteroide embate com alguma coisa ou sai 
;               do mapa 
;
; Argumentos:   
;               R1 - linha do pixel posicao do asteroide
;               R2 - coluna do pixel posicao do asteroide
; #######################################################################

testa_limites_A:

testa_limites_A_inicio:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    MOV  R3, R1
    MOV  R4, R2

testa_limites_A_ecra:
    MOV R0, LINHA_MAX
    CMP R1, R0
    JLE testa_limites_A_nave

testa_limites_A_respawn:
    MOV R8, 0
    JMP testa_limites_A_ret

testa_limites_A_nave:
    ADD R1, ALTURA_ASTEROIDE
    MOV R0, 27
    CMP R1, R0
    JLT testa_limites_A_sonda
    MOV R0, 39
    CMP R2, R0
    JGT testa_limites_A_sonda
    MOV R0, 25
    ADD R2, LARGURA_ASTEROIDE
    CMP R2, R0
    JLT testa_limites_A_sonda

testa_limites_A_fim_jogo:
    MOV R8, 1
    JMP testa_limites_A_ret

testa_limites_A_sonda:
    MOV R1, R3
    MOV R2, R4
    MOV R0, [LINHA_SONDA]
    CMP R1, R0
    JGT testa_limites_A_ret
    ADD R1, ALTURA_ASTEROIDE
    CMP R1, R0
    JLT testa_limites_A_ret
    MOV R0, [COLUNA_SONDA]
    CMP R2, R0
    JGT testa_limites_A_ret
    ADD R2, LARGURA_ASTEROIDE
    CMP R2, R0
    JLT testa_limites_A_ret

testa_limites_A_colisao:
    MOV R8, 2

testa_limites_A_ret:
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; ***********************************************************************
; * INTERRUPÇÕES
; ***********************************************************************   

; **********************************************************************
; ROT_INT_0 - 	Rotina de atendimento da interrupção 0
;			Faz simplesmente uma escrita no LOCK que o processo asteroide lê
; **********************************************************************

rot_int_0:
	MOV	[relogio_asteroide], R0	; desbloqueia processo boneco (qualquer registo serve) 
	RFE

; **********************************************************************
; ROT_INT_1 - 	Rotina de atendimento da interrupção 1
;			Faz simplesmente uma escrita no LOCK que o processo asteroide lê
; **********************************************************************

rot_int_1:
	MOV	[relogio_sonda], R0	; desbloqueia processo sonda (qualquer registo serve) 
	RFE

; **********************************************************************
; ROT_INT_2 -   Rotina de atendimento da interrupção 2
;           Faz simplesmente uma escrita no LOCK que o processo energia lê
; **********************************************************************

rot_int_2:
    MOV [relogio_energia], R0  ; desbloqueia processo energia 
    RFE

; **********************************************************************
; ROT_INT_3 - 	Rotina de atendimento da interrupção 3
;			Faz simplesmente uma escrita no LOCK que o processo nave lê
; **********************************************************************

rot_int_3:
	MOV  [relogio_nave], R0	; desbloqueia processo nave (qualquer registo serve) 
	RFE