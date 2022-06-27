.8086
.model small
.stack 100h
.data

.code
public imprimir
public ingreso
public asciiToReg
public regToAscii
public ascii2hexa
public regToBin
public cuenta_cosas
;public cuenta_vocales 

imprimir proc
;FUNCION IMPRESION DE TEXTO
;REQUISITO: ENVIAR PREVIAMENTE EL OFFSET EN DX A LA PILA DEL CARTEL A IMPRIMIR

	;------
	;  BP
	;------
	;  IP
	;------
	; OFFSET CARTEL (DX
	;_______

	push bp ;guardo bp en el stack
	mov bp, sp ; le doy a bp el valor de sp
	mov ah,9
	mov dx, ss:[bp+4] ;accedo al parametro 4bytes atras
	int 21h
	pop bp
	ret 2
imprimir endp
;-------------------------------------------------------------------
ingreso proc
;FUNCION INGRESO/CARGA DE TEXTO
;REQUISITO: COLOCAR PREVIAMENTE EL OFFSET EN BX DE LA VARIABLE A LLENAR
;COMPARA CONTRA ENTER Y 255 CARACTERES
	push ax
carga:
	cmp bx,255
	je finCarga
	mov ah,1
	int 21h
	cmp al, 0dh
	je finCarga
	mov [bx],al
	inc bx
	jmp carga

finCarga:	
	pop ax
	ret
ingreso endp
;-------------------------------------------------------------------
asciiToReg proc
;REQUISITO:COLOCAR EN BX EL OFFSET AL ASCII A CONVERTIR    variable1 db "123" [bx]
		  ;COLOCAR EN DI EL OFFSET A DATAMUL (100,10,1)    datamul db 100,10,1
		  ;COLOCAR EN SI EL OFFSET AL REGISTRO ACUMULADOR  reg db 0--->123
	push ax
	push dx

	mov cx,3 ;seteando en 3 la cantidad de veces que entra al loop
arriba:
	;cmp bx, 3
	;je termine
	xor ax,ax ;plancha ax ah:0000 al:0000
	xor dx,dx ;plancha dx dh:0000 dl:0000
	mov dl,[di] ;aca tengo el 100, ahora tengo el 10
	mov al,[bx] ;aca tengo el "1" ----tendria 31h, ahora tengo el "2"
	sub al, 30h ;obtengo en AL 1, ahora tengo el 2
	mul dl ;hace 100 x 1 , ahora hago 10 x 2 
	add [si],al ;guardo en si (registro acumulador) mi 100, ahora sumo al 100-->20=tengo 120 --->123
	inc bx 
	inc di
	loop arriba

termine:
	pop cx
	pop ax
	ret
asciiToReg endp
;------------------------------------------------------------------
regToAscii proc
;REQUISITO: COLOCAR EN BX EL OFFSET A LA VARIABLE REGISTRO  ----> mov bx, offset regacumulador ---->123
		   ;COLOCAR EN SI EL OFFSET A LA VARIABLE QUE CONTENDRA EL ASCII ---> mov si, offset asciiconvertido "1 2 3"
	push ax
	push cx
	push dx

	mov cx,3 ;porque loopeo 3 veces
	xor ax,ax ;plancho ax ah:0000 al:0000, es lo mismo que mov ax,0
	mov al,[bx] ;muevo a Al lo que contiene la direccion de bx---> 123
aConvertir:
	xor dx,dx ;plancho dx
	mov dl,10;muevo a dl 10
	div dl;agarra lo que tengo en AL y lo divide por 10
	add ah,30h ;nos deja en AH el resto de la division, en este caso 3, le sumo 30h para convertirlo a "3", hago lo mismo y tengo un "2"
	mov [si+2],ah ;ese "3" lo guardo en la ultima posicion de asciiconvertido, ahora muevo a [si+1] y guardo un "2"
	xor ah,ah ;vuelvo a planchar 
	dec si
	loop aConvertir
pop dx
pop cx
pop ax
ret
regToAscii endp
;-----------------------------------------------------------
ascii2hexa proc
;REQUISITO: COLOCAR EN BX EL OFFSET A LA VARIABLE QUE CONTIENE EL ASCII A CONVERTIR
		   ;COLOCAR EN SI EL OFFSET A LA VARIABLE QUE ALOJARA EL HEXA EN ASCII
	push ax
	push cx

	xor ax,ax ;plancho ah y al
	mov cl,16 ;preparo cl para dividir
	mov al,[bx] ;coloco en al el valor que tiene bx
	div cl
	add al,30h
	mov [si],al

	mov al,ah
	cmp al,9
	jbe deUna
	add al,55
	mov [si+1],al
	jmp final


deUna:
	add al,30h
	inc si
	mov [si],al	

final:
	pop cx
	pop ax
	ret

ascii2hexa endp
;---------------------------------------------------
regToBin proc
;REQUISITO: PONER EN AL EL REGISTRO A CONVERTIR
			;MOVER A BX EL INDICE 7 (DW)
			; PONER EN SI EL OFFSET AL ASCII DE 8 DIGITOS "00000000"
	push cx	
	xor cx,cx
	
aca:
	xor ah,ah ;plancho ah
	mov cl,2 ;muevo el 2 para hacer la division
	div cl ;divido, me deja en AH el resto y en AL el cociente
	add ah,30h ;al resto le sumo 30h para obtener un "1" o "0"
	mov [si+bx],ah ;muevo el ascii a la ultima posicion de mi asciinario "_ _ _ _ _ _ _ 1"
	dec bx
	cmp al,1 ;comparo el cociente con 1 para saber si termine de dividir o no
	ja aca ;salto arriba si no termine
	add al,30h ;si termine le sumo al cociente 30h y obtengo 
	mov [si+bx],al

	pop cx	
	ret
regToBin endp

;------------------------------------------------------
cuenta_cosas proc
;REQUISITO: PONER EN BX EL OFFSET DE LA VARIABLE A RECORRER
			;MOVER A CL EL ASCII A BUSCAR
			;PONER EN SI EL OFFSET DEL REGISTRO ACUMULADOR
	push cx
	busco:
		cmp byte ptr[bx],24h
		je termine2
		cmp byte ptr[bx],cl ;en cl poner lo que busco
		je encontre
		inc bx
		jmp busco


	encontre:
		add byte ptr[si],1
		inc bx
		jmp busco

	termine2:
		pop cx
		ret

cuenta_cosas endp	
;--------------------------------------------------------
;REQUISITOS: MOVER A BX EL OFFSET DEL BINARIO EN ASCII
			;MOVER A DI EL OFFSET DEL VECTOR DE BASES (128,64,32,16,8,4,2,1)
			;MOVER A SI EL OFFSET DEL REGISTRO ACUMULADOR
binToAscii proc
	push ax
	push dx
	mov cx,8
aca3:
	mov al,[bx] ;muevo a AL el primer ascii binario a multiplicar
	sub al,30h ;le resto 30h al "1" o "0"
	mov dl, [di] ;muevo a DL el primer 128 para hacer la multiplicacion
	mul dl
	add [si],al
	inc bx
	inc di
	loop aca

	pop dx
	pop ax
	ret

binToAscii endp
;-----------------------------------------------
;REQUISITOS: MOVER A BX EL OFFSET DE LA VARIABLE TEXTO A RECORRER
			;MOVER A SI EL OFFSET DEL REGISTRO ACUMULADOR
len proc
	
up:
	cmp byte ptr[bx],24h
	je finish
	add byte ptr[si],1
	inc bx
	jmp up
finish:	
	ret
len endp
;-----------------------------------------------
; cuenta_vocales proc
; ;REQUISITO: PONER EN BX EL OFFSET DE LA VARIABLE A RECORRER
; 			;MOVER A DI EL OFFSET DEL VECTOR DE VOCALES
; 			;PONER EN SI EL OFFSET DEL REGISTRO ACUMULADOR
; 	push cx ;salvo en la pila el valor que traia CX
; 	push dx;salvo en la pila el valor que traia DX

; 	mov dx,[di]
; 	busco:
; 		mov ch, 10
; 		cmp byte ptr[bx],24h
; 		je termine2
; 		busco3:
; 		mov cl, byte ptr [di] ;MOVEMOS EL CONTENIDO DE NUESTRO VECTOR DE VOCALES A CL
; 		cmp byte ptr[bx],cl ;en cl poner lo que busco
; 		je encontre
; 		inc di
; 		loop busco3
; 		inc bx
; 		mov [di],dx
; 		jmp busco

; 	encontre:
; 		add byte ptr[si],1
; 		inc bx
; 		mov [di],dx
; 		jmp busco

; 	termine2:
; 		pop dx
; 		pop cx
; 		ret
; cuenta_vocales endp

end

