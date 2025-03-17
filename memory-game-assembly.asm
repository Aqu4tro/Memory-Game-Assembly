# Feito por: Andr� Lucas e Jonathas Levi

.data
SIZE         : .word 4 # A constante "SIZE" representa o tamanho de um dos lados do tabuleiro quadrado; Ex.: SIZE = 2 represente um tabuleiro 2x2
pairs        : .word 8 # A vari�vel "pairs" guarda a quantidade de pares restantes a serem desvendados no tabuleiro, sendo decrescida a cada par encontrado
# Ela tamb�m controla a quantidade de loopings que acontecer�o durante a execu��o, j� que assim que chegar a 0, o jogo termina
board        : .word 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8 # O vetor "board" � uma representa��o linear do tabuleiro do jogo, usado para acessar os elementos ao longo do programa
revealed     : .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # O vetor "revealed" funciona para determinar se um n�mero deve ou n�o ser revelado durante a impress�o do tabuleiro
space        : .asciiz " "
cl           : .asciiz "\n"
hidden       : .asciiz "*"
l1_msg       : .asciiz "Digite a linha do primeiro n�mero: "
c1_msg       : .asciiz "Digite a coluna do primeiro n�mero: "
l2_msg       : .asciiz "Digite a linha do segundo n�mero: "
c2_msg       : .asciiz "Digite a coluna do segundo n�mero: "
invalid_msg  : .asciiz "Entrada inv�lida! Por favor, insira valores entre 0 e 3"
guessed_msg  : .asciiz "N�mero j� revelado! Por favor, uma posi��o que esteja oculta"
end_game_msg : .asciiz "O jogo terminou!"

.text # Declara os registradores n�o tempor�rios
la $s0, SIZE # Aloca o tamanho do tabuleiro em $s0
lw $s0, 0($s0)
la $s1, board # Aloca o endere�o do tabuleiro em $s1
la $s2, revealed # Aloca o endere�o dos revelados em $s2
la $s3, pairs # Aloca o n�mero de pares em $s3
lw $s3, ($s3)

jal print_header # Imprime o cabe�alho inicial do jogo
jal print_board # Imprime o tabuleiro inicial do jogo com todos os n�meros ocultos

game_loop: # Inicia o looping do jogo
	beqz $s3, end_game # Caso o n�mero de pares restantes seja 0, o jogo termina
	jal read_number_1 # L� o primeiro n�mero escolhido
	jal print_header
	jal print_board # Imprime o tabuleiro do jogo com o primeiro n�mero sendo revelado
	jal read_number_2 # L� o segundo n�mero escolhido
	jal print_header
	jal print_board # Imprime o tabuleiro do jogo com o segundo n�mero sendo revelado
	jal verify_numbers # Verifica a igualdade de ambos os n�meros
	j game_loop # Reinicia o looping

end_game: # Fim do jogo
	la $a0, end_game_msg # Imprime a mensagem de fim do jogo
	li $v0, 4
	syscall
	li $v0, 10 # Finaliza o programa
	syscall

print_header: # Declara a fun��o para imprimir o cabe�alho
	la $a0, cl
	li $v0, 4
	syscall
	la $a0, space
	li $v0, 4
	syscall
	syscall
	li $t0, 0 # Declara i = 0
begin_for_i_h: # Inicia o looping de colunas com i para o cabe�alho
	beq $t0, $s0, end_for_i_h # Caso i seja igual a "SIZE", encerra o looping ao pular para a branch "end_for_i_h"
	la $a0, space
	li $v0, 4
	syscall
	move $a0, $t0 # Copia i para $a0, para que assim cada coluna possa ser impressa e numerada de 0 a "SIZE"
	li $v0, 1
	syscall
	addi $t0, $t0, 1 # i++
	j begin_for_i_h # Reinicia o looping de colunas com i
end_for_i_h: # Fim do looping de linhas com i para o cabe�alho
	la $a0, cl # Quebra a linha para poder distanciar o cabe�alho do tabuleiro
	li $v0, 4
	syscall
	jr $ra # Retorna para o looping do jogo

print_board: # Declara a fun��o para imprimir o tabuleiro
	li $t0, 0 # Declara i = 0
begin_for_i_b: # Inicia o looping de linhas com i para o tabuleiro
	beq $t0, $s0, end_for_i_b # Caso i seja igual a "SIZE", encerra o looping ao pular para a branch "end_for_i_b"
	li $t1, 0 # Declara j = 0
	la $a0, space
	li $v0, 4
	syscall
	move $a0, $t0 # Copia i para $a0, para que assim cada linha possa ser impressa e numerada de 0 a "SIZE"
	li $v0, 1
	syscall
begin_for_j_b: # Inicia o looping de colunas com j para o tabuleiro
	beq $t1, $s0, end_for_j_b # Caso j seja igual a SIZE, encerra o looping ao pular para a branch "end_for_j_b"
	la $a0, space
	li $v0, 4
	syscall
	sll $a1, $t0, 4 # $a1 = 16 * i
	sll $a2, $t1, 2 # $a2 = 4 * j
	addi $sp, $sp, -4 # Libera espa�o no registrador stack para que a fun��o "print_number" possa ser executada internamtne � "print_board" sem problemas
	sw $ra, ($sp)
	jal print_number # Chama a fun��o "print_number" internamente que avalia qual valor deve ser impresso
	lw $ra, ($sp)
	addi $sp, $sp, 4
	addi $t1, $t1, 1 # j++
	j begin_for_j_b # Reinicia o looping de colunas com j
end_for_j_b: # Fim do looping de colunas com j para o tabuleiro
	la $a0, cl # Quebra a linha para imprimir os valores da pr�xima abaixo
	li $v0, 4
	syscall
	addi $t0, $t0, 1 # i++
	j begin_for_i_b # Reinicia o looping de linhas com i
end_for_i_b: # Fim do looping de linhas com i para o tabuleiro
	la $a0, cl
	li $v0, 4
	syscall
	jr $ra # Retorna para o looping do jogo

print_number: # Declara a fun��o para imprimir ou n�o o valor no tabuleiro
	# Em regra, o npumero 0, no vetor "revealed", representa um n�mero que deve ser ocultado
	# J� o n�mero 1 reprsenta um que deve ser impresso at� o fim do jogo por j� ter sido acertado e 2, um n�mero que tamb�m deve ser impresso, mas apenas no itera��o atual do looping
	add $t2, $a1, $a2 # As multiplica��es de $a1 por 16 e $a2 por 4 s�o necess�rias para localizar o elemento nos vetores "board" e "revelead"
	add $t3, $t2, $s1 # Soma o endere�o de "board" � $t2 para acessar, individualmente, o valor do elemento e imprimi-lo caso necess�rio
	add $t4, $t2, $s2 # Soma o endere�o de "revelead" � $t2 para acessar, individualmente, a situa��o de revela��o do elemento e decidir se ele deve ser impresso
	lw $t4, ($t4) # Aloca, em $t4, o valor do n�mero atual no vetor "revealed" para que seja decidido se ele deve ser impresso ou n�o
	bnez $t4, not_0 # Caso o correspondente de revela��o do elemento seja diferente de 0, pula para a branch "not_0"
	la $a0, hidden # Imprimi "*" na tela, caractere respons�vel por representar que o n�mero est� oculto
	li $v0, 4
	syscall
	jr $ra # Retorna para a fun��o "print_board"
not_0: # Label que indica o que deve ser feito caso o elemento possua o n�mero 1 ou 2 como indicativo de revela��o no vetor "revealed"
	lw $a0, ($t3) # Imprime o n�mero
	li $v0, 1
	syscall
	jr $ra # Retorna para a fun��o "print_board"

read_number_1: # Declara a fun��o para ler o primeiro n�mero escolhido pelo usu�rio
looping_l1: # Inicia o looping respons�vel por requisitar a linha do primeiro n�mero ao usu�rio at� que seja v�lida
	la $a0, l1_msg # Imprime a mensagem requisitando o �ndice da linha do primeiro n�mero
	li $v0, 4
	syscall
	li $v0, 5 # L� o input
	syscall
	li $t3, -1 # Passa o valor -1 para $t3, que servir� como o limiar para tratamento de valores negativos
	ble $v0, $t3, invalid_l1
	bge $v0, $s0, invalid_l1
	move $s4, $v0 # Copia o �ndice da linha do primeiro n�mero para $s4
looping_c1: # Inicia o looping respons�vel por requisitar a coluna do primeiro n�mero ao usu�rio at� que seja v�lida
	la $a0, c1_msg # Imprime a mensagem requisitando o �ndice da coluna do primeiro n�mero
	li $v0, 4
	syscall
	li $v0, 5 # L� o input
	syscall
	li $t3, -1 # Passa o valor -1 para $t3, que servir� como o limiar para tratamento de valores negativos
	ble $v0, $t3, invalid_c1
	bge $v0, $s0, invalid_c1
	move $s5, $v0 # Copia o �ndice da coluna do primeiro n�mero para $s5
	sll $t3, $s4, 4
	sll $t4, $s5, 2
	add $t5, $t3, $t4
	add $t6, $t5, $s2
	lw $t3, ($t6)
	beq $t3, 1, guessed_1 # Caso o n�mero j� tenha sido acertado, pula para a branch "guessed_1"
	li $t7, 2
	sw $t7, ($t6) # # Salva o valor 2 na posi��o correspondente do n�mero com linha e coluna inseridas no vetor "revealed"
	jr $ra # Retorna para o looping do jogo
invalid_l1: # Label que indica as instru��es a serem tomadas assim que um valor inv�lido for inseriido
	li $v0, 4
	la $a0, invalid_msg # Imprime a mensagem que informa a invalidade das entradas
	syscall
	la $a0, cl
	syscall
	j looping_l1 # Retorna para "looping_l1" para requisitar a entrada e realizar as verifica��es novamente
invalid_c1: # Label que indica as instru��es a serem tomadas assim que um valor inv�lido for inseriido
	li $v0, 4
	la $a0, invalid_msg # Imprime a mensagem que informa a invalidade das entradas
	syscall
	la $a0, cl
	syscall
	j looping_c1 # Retorna para "looping_c1" para requisitar a entrada e realizar as verifica��es novamente
guessed_1: # Label que indica as instru��es a serem tomadas quando o primeiro n�mero escolhido j� foi acertdado
	li $v0, 4
	la $a0, guessed_msg # Imprime a mensagem que informa que o n�mero escolhido n�o est� oculto
	syscall
	la $a0, cl
	syscall
	j looping_l1 # Retorna para a branch "looping_l1" para a reinserida do primeiro n�mero e suas verifica��es

read_number_2: # Declara a fun��o para ler o segundo n�mero escolhido pelo usu�rio
looping_l2: # Inicia o looping respons�vel por requisitar a linha do segundo n�mero ao usu�rio at� que seja v�lida
	la $a0, l2_msg # Imprime a mensagem requisitando o �ndice da linha do segundo n�mero
	li $v0, 4
	syscall
	li $v0, 5 # L� o input
	syscall
	move $s6, $v0 # Copia o �ndice da linha do segundo n�mero para $s6
	li $t3, -1 # Passa o valor -1 para $t3, que servir� como o limiar para tratamento de valores negativos
	ble $v0, $t3, invalid_l2
	bge $v0, $s0, invalid_l2
looping_c2: # Inicia o looping respons�vel por requisitar a coluna do segundo n�mero ao usu�rio at� que seja v�lida
	la $a0, c2_msg # Imprime a mensagem requisitando o �ndice da coluna do segundo n�mero
	li $v0, 4
	syscall
	li $v0, 5 # L� o input
	syscall
	li $t3, -1 # Passa o valor -1 para $t3, que servir� como o limiar para tratamento de valores negativos
	ble $v0, $t3, invalid_c2 # Caso 
	bge $v0, $s0, invalid_c2
	move $s7, $v0 # Copia o �ndice da coluna do segundo n�mero para $s7
	sll $t3, $s6, 4
	sll $t4, $s7, 2
	add $t5, $t3, $t4
	add $t6, $t5, $s2
	lw $t3, ($t6)
	beq $t3, 1, guessed_2 # Caso o n�mero j� tenha sido acertado, pula para a branch "guessed_2"
	beq $t3, 2, guessed_2 # Caso o segundo n�mero seja o mesmo do primeiro, pula para a branch "guessed_2"
	li $t7, 2
	sw $t7, ($t6) # Salva o valor 2 na posi��o correspondente do n�mero com linha e coluna inseridas no vetor "revealed"
	jr $ra # Retorna para o looping do jogo
invalid_l2: # Label que indica as instru��es a serem tomadas assim que um valor inv�lido for inseriido
	li $v0, 4
	la $a0, invalid_msg # Imprime a mensagem que informa a invalidade das entradas
	syscall
	la $a0, cl
	syscall
	j looping_l2 # Retorna para "looping_l2" para requisitar a entrada e realizar as verifica��es novamente
invalid_c2: # Label que indica as instru��es a serem tomadas assim que um valor inv�lido for inseriido
	li $v0, 4
	la $a0, invalid_msg # Imprime a mensagem que informa a invalidade das entradas
	syscall
	la $a0, cl
	syscall
	j looping_c2 # Retorna para "looping_c2" para requisitar a entrada e realizar as verifica��es novamente
guessed_2: # Label que indica as instru��es a serem tomadas quando o segundo n�mero escolhido j� foi escolhido ou � o mesmo do primeiro
	li $v0, 4
	la $a0, guessed_msg # Imprime a mensagem que informa que o n�mero escolhido n�o est� oculto
	syscall
	la $a0, cl
	syscall
	j looping_l2 # Retorna para a branch "looping_l2" para a reinserida do segundo n�mero e suas verifica��es

verify_numbers: # Declara a fun��o para veficar a igualdade entre os n�meros escolhidos
	sll $t0, $s4, 4
	sll $t1, $s5, 2
	add $t2, $t0, $t1
	add $t3, $t2, $s1
	lw $t3, ($t3) # Guarda, em $t3, o primeiro n�mero escolhido pelo usu�rio
	sll $t4, $s6, 4
	sll $t5, $s7, 2
	add $t6, $t4, $t5
	add $t7, $t6, $s1
	lw $t7, ($t7) # Guarda, em $t7, o segundo n�mero escolhido pelo usu�rio
	add $t0, $t2, $s2
	add $t1, $t6, $s2
	bne $t3, $t7, not_equal # Caso os n�meros escolhidos sejam diferentes, pula para a branch "not_equal"
	li $t4, 1
	sw $t4, ($t0) # Salva, em $t1, o valor 1 para representar que o n�mero foi acertado
	sw $t4, ($t1) # Salva, em $t1, o valor 1 para representar que o n�mero foi acertado
	addi $s3, $s3, -1 # Subtrai 1 da quantidade de pares restantes
	jr $ra # Retorna para o looping do jogo
not_equal: # Caso os n�meros sejam diferentes, eles ser�o ocultados
	sw $zero, ($t0) # Aloca o valor 0 na posi��o do primeiro n�mero no vetor "revealed"
	sw $zero, ($t1) # Aloca o valor 0 na posi��o do segundo n�mero no vetor "revealed"
	jr $ra # Retorna para o looping do jogo
