.8086
.model small
.stack 100h


.data
	colores db 1
	puntajeReg db 0
	time_aux1 db 0
	score db "Score: "
	puntajeAscii db "000",0dh,0ah,24h
	game_over db " ___ ___ _____ ___    ___ _ _ ___ ___ ",0ah,0dh
			  db "| . | .'|     | -_|  | . | | | -_|  _|",0ah,0dh
			  db "|_  |__,|_|_|_|___|  |___|\_/|___|_|  ",0ah,0dh
			  db "|___|                                 ",0ah,0dh,24h                              
                                     
	menu_exit db "Presiona 'r' para reiniciar",0DH,0AH
			  db "   Presiona 's' para salir",24h
	vidas db "***",0dh,0ah,24h
	ball_x dw 0A0h 					;posicion en x (columna)
	ball_y dw 50h 					;posicion en y (fila)
	ball_size dw 04h 				;tamaño en pixeles de la bola (4 pixeles en altura y ancho)
	time_aux db 0 					;guardamos una variable auxiliar para el tiempo, nos va a servir como flag para saber si pasa el tiempo
	tries db 0                      ;guardamos los intentos, si es igual a 3, finaliza el juego

	ball_velocity_x dw 08h 			;velocidad inicial de la bola en eje X
	ball_velocity_y dw 04h 			;velocidad inicial de la bola en eje Y

	window_width dw 140h 			;(320) ancho de la pantalla en hexa
	window_height dw 0C8h			;(200) alto de la pantalla en hexa
	window_bounds dw 3 				;variable para chequear colisiones

	ball_original_x dw 0A0h         ;posicion inicial de la pelota
	ball_original_y dw 032h

	paddle_x dw 0bh 				;columna inicial del paddle
	paddle_y dw 0b4h 				;fila inicial del paddle

	padle_width dw 1Fh 				;ancho de 15 pixeles
	padle_height dw 05h 			;alto de 5 pixeles


	cartel db "  ___  ______  _____   ___  ",0dh,0ah
 		   db " / _ \ | ___ \/  __ \ / _ \ ",0dh,0ah
           db "/ /_\ \| |_/ /| /  \// /_\ \",0dh,0ah
           db "|  _  ||    / | |    |  _  |",0dh,0ah
           db "| | | || |\ \ | \__/\| | | |",0dh,0ah
           db "\_| |_/\_| \_| \____/\_| |_/",0dh,0ah
           db "							   ",0dh,0ah		 
		   db "             ******---------",0dh,0ah
		   db " 	 ______ _     _____  _    _ ",0dh,0ah
		   db "	                                ",0dh,0ah
		   db "	 | |_  | |   | | | || |  | |",0dh,0ah
		   db "	 |  _| | |   | | | || |/\| |",0dh,0ah
		   db "                             ",0dh,0ah
		   db "	 \_|   \_____/\___/  \/  \/ ",0dh,0ah
		   db "							   ",0dh,0ah
		   db " ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»",0dh,0ah
		   db " º      Presione 'A' para iniciar    º",0dh,0ah
		   db " º         'ESC' para salir          º",0dh,0ah
		   db " ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼",0dh,0ah,24h

	cartel2 db "                           ",0dh,0ah
 		   db "                            ",0dh,0ah
           db " / /_\ \| |_/ /| /  \// /_\ \",0dh,0ah
           db "                            ",0dh,0ah
           db " | | | || |\ \ | \__/\| | | |",0dh,0ah
           db "                            ",0dh,0ah
           db "							   ",0dh,0ah		 
		   db "   ---------*****               ",0dh,0ah
		   db " 	  ______ _     _____  _    _",0dh,0ah
		   db "	 |  ___| |   |  _  || |  | |",0dh,0ah
		   db "	                            ",0dh,0ah
		   db "	                            ",0dh,0ah
		   db "                             ",0dh,0ah
		   db "	 | |   | |___\ \_/ /\  /\  /",0dh,0ah
		   db "							   ",0dh,0ah,24h
		  

.code
extrn regToAscii:proc
main proc
	mov ax, @data
	mov ds, ax

	call clear_screen
;REFACTORIZAR ESTO--------------------
check_time1:
	mov ah,2Ch 				;obtenemos la HORA DEL SISTEMA, usada para crear ilusion de movimiento
	int 21h

	cmp dl, time_aux1 		;comparamos los milisegundos contra mi variable aux
	je check_time1 			;si son iguales, chequeamos nuevamente
	mov time_aux1,dl 		;updateamos nuestra variable tiempo auxuliar con los milisegundos del momento

	mov ax,@data
	mov es,ax

	mov ah,13h
	mov al,00h
	mov bh,00
	mov bl,05h
	mov cx,584
	mov dh,0
	mov dl,0
	lea bp,cartel
	int 10h

	mov cx,60000
aca:
	
	int 45h					;Interrupción residente en memoria para esperar un determinado tiempo

	loop aca

	mov ah,13h
	mov al,00h
	mov bh,00
	mov bl,03h
	mov cx,400
	mov dh,0
	mov dl,0
	lea bp,cartel2
	int 10h

;ACA COMPARO LETRAS
	in AL,60h	
	cmp AL,1Eh 	;esto es A
	je inicio
	cmp AL,01h 	;esto es ESC
	je salir3

	jmp check_time1 		;volvemos a saltar a chequear tiempo, nuestro loop de ilusion de movimiento

salir3:
	call clear_screen
	mov ah,0
    mov al,03h
    int 10h
    mov ax,4c00h
    int 21h

inicio:
;FIN REFACTORIZAR ESTO----------------
lea di,colores
check_time:
	cmp tries, 3           ;comparamos los intentos con 3, si es igual mostramos el menu de game over
	je show_game_over_menu

	mov ah,2Ch 				;obtenemos la HORA DEL SISTEMA, usada para crear ilusion de movimiento
	int 21h

	cmp dl, time_aux 		;comparamos los milisegundos contra mi variable aux
	je check_time 			;si son iguales, chequeamos nuevamente
	mov time_aux,dl 		;updateamos nuestra variable tiempo auxuliar con los milisegundos del momento

    call clear_screen
	call move_ball
	call draw_ball 			;llamamos a la funcion encargada de dibujar el pixel en pantalla
	
	call move_paddle
	call draw_paddle 		;llamamos a la funcion encargada de dibujar el paddle

	lea bx,puntajeReg
	lea si,puntajeAscii
	call regToAscii

	call draw_ui 			;dibuja toda la interfaz del usuario

	jmp check_time 			;volvemos a saltar a chequear tiempo, nuestro loop de ilusion de movimiento

	show_game_over_menu:
		call draw_game_over_menu
		call main

	ret

fin:
	mov ah,0
   	mov al,03h
    int 10h

    mov ax,4c00h
   	int 21h
main endp
;fin main process-------------------------------------------------------------------


draw_ui proc

	mov ah,02h ;seteo posicion de cursor
	mov bh,00h ;seteo numero de pagina
	mov dh,03h ;seteo fila
	mov dl,04h ;seteo columna
	int 10h

	mov ah,09h
	lea dx, score
	int 21h

	;Imprimimos las vidas con un "*" por cada una, se compara tries con cada numero para imprimir la cantidad correspondiente

	mov ah,02h ;seteo posicion de cursor
	mov bh,00h ;seteo numero de pagina
	mov dh,03h ;seteo fila
	mov dl,6fh ;seteo columna
	int 10h

	cmp tries, 0
	je vida3

	cmp tries, 1
	je vida2

	cmp tries, 2
	je vida1

	vida3:
		mov bx, 2
		mov cx, 3
		jmp imprime1

	vida2:
		mov bx, 1
		mov cx, 2
		jmp imprime1

	vida1:
		mov bx, 0
		mov cx, 1
		jmp imprime1
	
	imprime1:
		mov dl, vidas[bx]
		mov ah, 2
		int 21h
		dec bx
		loop imprime1

	ret
draw_ui endp

move_paddle proc
	in AL,60h
	cmp AL,20h 	;esto es D
	je move_right
	cmp AL,1Eh 	;esto es A
	je move_left
	cmp AL,01h 	;esto es ESC
	je salir
	ret
	move_right:
		cmp paddle_x,11Ch
		jge pared2
	moveR:
		add paddle_x, 07h
		ret
	move_left:
		cmp paddle_x,07h
		jbe pared1
		sub paddle_x, 07h
		ret
	pared1:
		ret
	pared2:
		ret

	salir:
		call clear_screen
		mov ah,0
	    mov al,03h
	    int 10h
	    mov ax,4c00h
	    int 21h
move_paddle endp

draw_paddle proc
	mov cx, paddle_x 	 ;le damos una columna inicial(x)
	mov dx, paddle_y 	 ;le damos una fila inicial (Y)	

draw_paddle_proc:
	mov ah,0Ch 			 ;seteamos configuracion para impresion de pixel
	mov al,04h 			 ;elegimos color rojo para el pixel
	mov bh,00h 			 ;seteamos el numero de pagina, nuestro caso 0	
	int 10h

	inc cx 				 ;incrementamos en 1 cx
	mov ax,cx
	sub ax,paddle_x
	cmp ax,padle_width	 ;cx - paddle_x > padle_width (si se cumple vamos a la proxima fila, sino a la siguiente columna)
	jng draw_paddle_proc

	mov cx,paddle_x 	 ;cx vuelve al valor inicial de columna
	inc dx 				 ;avanzamos una fila

    mov ax,dx 			
    sub ax,paddle_y
    cmp ax, padle_height ;dx - ball_y > ball_size (si se cumple salimos de la funcion, sino seguimos a al siguiente fila)
    jng draw_paddle_proc

	ret
draw_paddle endp

reset_ball_position proc
	mov ax,ball_original_x
	mov ball_x,ax

	mov ax, ball_original_y
	mov ball_y,ax

    call sonido2
    inc tries
	ret
reset_ball_position endp

move_ball proc
	
	mov ax, ball_velocity_x ;movemos la bola horizontalmente
    add ball_x,ax

    mov ax, window_bounds
    cmp ball_x, ax			;cuando ball_x < 0 + window_bounds (hay colision)
    jl neg_velocity_x
    
    mov ax, window_width
    sub ax, ball_size
    sub ax,window_bounds
    cmp ball_x,ax
    jg neg_velocity_x

    mov ax,ball_velocity_y
    add ball_y,ax 			;movemos la bola verticalmente

    mov ax, window_bounds
    cmp ball_y,ax			;ball_y < 0 + window_bounds (hay colision)
    jl neg_velocity_y		;ball_y > window_height (hay colision)

    mov ax,window_height
    sub ax,ball_size
    sub ax,window_bounds
    cmp ball_y,ax
    jg reset_ball_position 	;ball_y > window_height - ball_size - window_bounds (hay colision)
    
   
    ;REBOTE EN PADDLE:
    ;ball_x + ball_size > paddle_x && ball_x < paddle_x + paddle_width
	;&& ball_y + ball_size > paddle_y && ball_y < paddle_y + paddle_height

	mov ax, ball_x
	add ax, ball_size   ;sumo los cuadros de la bola y el paddle
	cmp ax, paddle_x    ;la suma tiene que ser menor a la medida del paddle
    jae check1
    jmp check_no
    check1:
	    mov ax, paddle_x
	    add ax, padle_width
	    cmp ball_x, ax 
	    jl check2
	    jmp check_no
    check2:
	    mov ax, ball_y
	    add ax, ball_size
        cmp ax, paddle_y
        jae check3
        jmp check_no
    check3:
        mov ax, paddle_y
        add ax, padle_height
        cmp ball_y, ax
        jl rebota
        jmp check_no
        
    check_no:
        ret

    neg_velocity_x:
    	neg ball_velocity_x
    	call sonido1

    	inc byte ptr[di]
    	cmp byte ptr[di],9
    	je resta
    	ret
    resta:
    	sub byte ptr[di],7	
    	ret

    neg_velocity_y:    	
    	neg ball_velocity_y
    	call sonido1
   
    	inc byte ptr[di]
    	cmp byte ptr[di],9
    	je resta2
    	ret
    resta2:
    	sub byte ptr[di],7	
    	ret

    rebota:
    	neg ball_velocity_y
    	call sonido1
    	inc puntajeReg

    	inc byte ptr[di]
    	cmp byte ptr[di],9
    	je resta2
    	ret
move_ball endp

clear_screen proc
	mov ah,00h 				;seteamos modo video
	mov al,13h 				;seteamos 320x200 256 colores
	int 10h 				;ejecutamos
	
    mov ah,0Bh 				;seteamos configuracion para el background
	mov bh,00h
	mov bl,00h 				;elegimos color negro de fondo
	int 10h 				;ejecutamos

	ret
clear_screen endp

draw_ball proc
	mov cx, ball_x 			;le damos una columna inicial (X)
	mov dx, ball_y 			;le damos una fila inicial (Y)

	draw_ball_horizontal:
		mov ah,0Ch 			;seteamos configuracion para impresion de pixel
		mov al,[di] 		;elegimos color violeta para el pixel
		mov bh,00h 			;seteamos el numero de pagina, nuestro caso 0	
		int 10h

		inc cx 				;incrementamos en 1 cx
		mov ax,cx			;cx - ball_x > ball_size (si se cumple vamos a la proxima fila, sino a la siguiente columna)
		sub ax,ball_x
		cmp ax,ball_size
		jng draw_ball_horizontal

		mov cx,ball_x 		;cx vuelve al valor inicial de columna
		inc dx 				;avanzamos una fila

        mov ax,dx 			;dx - ball_y > ball_size (si se cumple salimos de la funcion, sino seguimos a la siguiente fila)
        sub ax,ball_y
        cmp ax, ball_size
        jng draw_ball_horizontal
	ret
draw_ball endp

draw_game_over_menu proc
	
	call clear_screen

	mov ah,02h ;seteo posicion de cursor
	mov bh,00h ;seteo numero de pagina
	mov dh,02h ;seteo fila
	mov dl,00h ;seteo columna
	int 10h

	mov ah,09h
	lea dx, game_over
	int 21h

	mov ah,02h ;seteo posicion de cursor
	mov bh,00h ;seteo numero de pagina
	mov dh,0Ah ;seteo fila
	mov dl,09h ;seteo columna
	int 10h

	mov ah,09h
	lea dx, score
	int 21h

	mov ah,02h ;seteo posicion de cursor
	mov bh,00h ;seteo numero de pagina
	mov dh,0Ch ;seteo fila
	mov dl,03h ;seteo columna
	int 10h

	mov ah,09h
	lea dx, menu_exit
	int 21h

	again:
		mov ah, 00
		int 16h

		cmp al, 'r'
		je restart

		cmp al, 's'
		je salir4
		jmp again

	restart:
		mov tries, 0
		mov puntajeReg, 0
		ret

	salir4:
		mov ah, 0
		mov al, 03h
		int 10h

		mov ax, 4c00h
		int 21h

draw_game_over_menu endp

sonido1 proc 

    mov al, 182         	;Prepara el altavoz para la
    out 43h, al         	;nota.
    mov ax, 7237 			;Número de frecuencia (en decimal): Mi (E) central
   
    out 42h, al     		;Salida de LB
    mov al, ah      		;Salida de HB
    out 42h, al 
    in  al, 61h         	;Activar nota (obtiene el valor del puerto 61h)
   
    or  al, 00000011b   	;Setea los bytes 1 y 0
    out 61h, al         	;Envía el nuevo valor de los bytes 1 y 0 al puerto
    mov bx, 25          	;Duración de la nota

pause1:
    mov cx, 65535
pause2:
    
    dec cx
    jne pause2
    dec bx
    jne pause1
    in  al, 61h        		;Desactiva la nota (obtiene el valor del puerto 61h)
    
    and al, 11111100b   	;Reestablece los valores de los bytes 1 y 0
    out 61h, al         	;Envía el nuevo valor al puerto

 ret
sonido1 endp

sonido2 proc
     
    mov al, 182      		;Prepara el altavoz para la
    out 43h, al         	;nota.
    mov ax, 6087 			;Número de frecuencia (en decimal): Sol (G) central
  							
    out 42h, al      		;Salida de LB
    mov al, ah         		;Salida de HB
    out 42h, al 			
    in  al, 61h        		;Activar nota (obtiene el valor del puerto 61h)
   
    or  al, 00000011b   	;Setea los bytes 1 y 0
    out 61h, al        		;Envía el nuevo valor de los bytes 1 y 0 al puerto
    mov bx, 25          	;Duración de la nota

pause11:
    mov cx, 65535
pause22:
    dec cx
    jne pause22
    dec bx
    jne pause11
    in al, 61h        		;Desactiva la nota (obtiene el valor del puerto 61h)
    							
    and al, 11111100b   	;Reestablece los valores de los bytes 1 y 0
    out 61h, al         	;Envía el nuevo valor al puerto

    ret
sonido2 endp

end