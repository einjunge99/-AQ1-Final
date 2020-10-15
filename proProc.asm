
getDelay PROC USES cx
inicio:

	xor ax, ax
	xor cx, cx
	mov cx, 100

	mov al, actualVelocidad
	mul cl

	mov cx, 1200
	sub cx, ax
	mov ax, cx
        
fin:
ret

getDelay ENDP


setDelay PROC USES si di tiempo : WORD
inicio:

	xor di, di
	xor si, si
	mov si, tiempo

C0:
	dec si
	jz fin
	mov di, tiempo
C1:
	dec di
	jnz C1
	jmp C0

fin:
	ret
setDelay ENDP



buzzer PROC valor : WORD, duracion : WORD
inicio:

	cmp valor, 20
	jle rojo	
	cmp valor, 40
	jle azul
	cmp valor, 60
	jle amarillo
	cmp valor, 80
	jle verde
	cmp valor, 99
	jle blanco

rojo:
	sonido 100, duracion
	jmp fin
azul:
	sonido 300, duracion
	jmp fin
amarillo:
	sonido 500, duracion
	jmp fin
verde:
	sonido 700, duracion
	jmp fin
blanco:
	sonido 900, duracion
	jmp fin

fin:
    ret

buzzer ENDP


;-------------este parser es utilizado para las graficas
parseStringNumero PROC uses si di ax cx dx bx numero: WORD, cadena: ptr BYTE, tamanio : WORD

inicio:
        
	mov ax,numero
	mov cx,10
	mov bx,cadena         
	mov si,0
	mov di,0

	test ax,ax
	jns parse
	
	mov byte ptr[bx+0], '-'
	inc di
	mov cx,-1 
	mul cx
	mov cx,10

parse:

	mov dx,0            
	div cx              
	add dx,'0'         
	
	inc si
	push dx

	cmp ax,0            
	je escribir          
	jmp parse

escribir:

	pop dx
	mov byte ptr[bx+di], dl
	
	inc di
	dec si

	cmp si, 0
	je fin
	jmp escribir

fin:
	ret

parseStringNumero ENDP



setCursor PROC USES ax bx dx cx, columna : BYTE, fila : BYTE

inicio:

	xor ax, ax
	xor bx, bx
	xor dx, dx
    
posicion:

	mov ah, 2
	mov bh, 0
	mov dh, fila
	mov dl, columna
	int 10h

fin:
	ret
setCursor ENDP



correrCursor PROC uses ax bx cx dx, iteaciones : WORD

inicio:

	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx

	mov cx,iteaciones

ciclo:

	push cx
	mov  ah,3
	mov  bh,0
	int  10h
	inc  dl
	mov  ah,2
	int  10h
	pop  cx
	loop ciclo

fin:
ret
correrCursor ENDP


mostrarCadena PROC uses si ax bx cx cadena : ptr BYTE, tamanio : WORD,  columna : BYTE, fila : BYTE, color : BYTE

inicio:

	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor si, si

	mov cx, tamanio
	mov si, cadena

	INVOKE setCursor,columna,fila

ciclo:

	push cx
	mov  ah,9
	mov  al,[si]
	mov  bh,0
	mov  bl,color
	mov  cx,1
	int  10h
	INVOKE correrCursor,1
	inc  si
	pop  cx
	Loop ciclo

fin:
ret
mostrarCadena ENDP

;-----------------------------------
;-------ACA ME QUEDE!
;----------------------------------

getTamanio PROC USES bx cx si cadena : PTR BYTE

inicio:

	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor si, si

	mov bx, cadena

ciclo:
        
	mov cl, BYTE PTR[bx + si]
	cmp cl, 00h
	je fin
	inc al
	inc si
	jmp ciclo

fin:
	ret 
getTamanio ENDP

mostrarNumero PROC USES ax numero : WORD, columna : BYTE, fila : BYTE, color : BYTE
LOCAL tamanio : WORD

inicio:

	xor ax, ax

	mov auxCadena[0],0
	mov auxCadena[1],0
	INVOKE parseStringNumero, numero, offset auxCadena, SIZEOF auxCadena

	cmp auxCadena[1],'0'
	jl agregar
	jmp mostrar

agregar:
	mov al, auxCadena[0]
	mov auxCadena[0], '0'
	mov auxCadena[1], al

mostrar:

	INVOKE mostrarCadena, ADDR auxCadena, 2, columna, fila, color

fin:
	ret
mostrarNumero ENDP

calcularDelay PROC uses cx

iniciar:

	xor ax,ax
	xor cx,cx
	mov cx,100

testVelocidad:

	mov al, actualVelocidad
	mul cl

	mov cx, 1200
	sub cx, ax
	mov ax, cx
        
fin:
	ret
calcularDelay ENDP


incrementoTiempo PROC uses ax entrada

inicio:

	xor ax,ax

incremento:

	mov ax,entrada
	add milisegundos,ax
    
	cmp milisegundos,1000
	jb fin
	
	add segundos,1
	mov milisegundos,0

	cmp segundos,60
	jb fin
	
	add minutos,1
	mov segundos,0
	mov milisegundos,0

fin:
	ret
incrementoTiempo ENDP



modoVideo PROC uses ax

inicio:

	mov ah, 00h
	mov al, 18
	int 10h
    
fin:
	ret
modoVideo ENDP


parseStringTiempo PROC

inicio:

	mov msgActualTiempo[0],"0"
	mov msgActualTiempo[1],"0"
	mov msgActualTiempo[3],"0"
	mov msgActualTiempo[4],"0"

testMinutos:

	cmp minutos,10
	jb M01
	jmp M02

;----------------M01,M02...Minutos
M01:

	INVOKE parseStringNumero, minutos, offset msgActualTiempo[1], 1
	jmp testSegundos
    
M02:

	INVOKE parseStringNumero, minutos, offset msgActualTiempo[0], 2
	jmp testSegundos

testSegundos:

	cmp segundos, 10
	jb S01
	jmp S02
;----------------S01,S02...Segundos
S01:

	INVOKE parseStringNumero, segundos, offset msgActualTiempo[4], 1
	jmp fin

S02:

	INVOKE parseStringNumero, segundos, offset msgActualTiempo[3], 2
	jmp fin

fin:
ret

parseStringTiempo ENDP

mostrarBarra PROC USES ax bx cx dx, x : WORD, y : WORD, ancho : WORD, altura : WORD, color : BYTE
LOCAL x0 : WORD

inicio:

	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx

	mov ax, x
	mov x0, ax
	
	mov dx, y
	mov cx, altura

;-----------------------C01,C02...Ciclo
S1:

	push cx
	mov  cx, ancho

S2:
            
	push cx
	mov  ah, 0Ch
	mov  al, color
	mov  bh, 0
	mov  cx, x
	mov  dx, y
	int  10h
	inc  x
	pop  cx
	loop S2

	pop cx
	dec y

	mov ax, x0
	mov x, ax
	Loop S1

fin:
	ret

mostrarBarra ENDP


setEncabezado PROC uses ax

inicio:

	xor ax, ax

	cmp actualEncabezado,1
	je encabezadoOrden

encabezadoTop:
	cmp actualTop,1
	je T1
;--------------T0,T1..Estado de titulo, puntos y tiempos respectivamente	
T0:
	INVOKE mostrarCadena, ADDR msgPuntos, SIZEOF msgPuntos, 2, 1, 15
	jmp margenes
T1:
	INVOKE mostrarCadena, ADDR msgTiempos, SIZEOF msgTiempos, 2, 1, 15
	jmp margenes

encabezadoOrden:

        INVOKE mostrarCadena, ADDR msgOrdenamiento, SIZEOF msgOrdenamiento, 2, 1, 15
     
        cmp actualOrden,1
        je S0
        cmp actualOrden,2
        je S1
        cmp actualOrden,3
        je S2
;--------------S0,S1,S2..Estado de mensaje ordenamiento, bubblesort, quicksort y shellsort respectivamente
S0:

        INVOKE mostrarCadena, ADDR msgBubble, SIZEOF msgBubble, 16, 1, 15
        jmp continuar
    
S1:

        INVOKE mostrarCadena, ADDR msgQuick, SIZEOF msgQuick, 16, 1,15
        jmp continuar
    
S2:

        INVOKE mostrarCadena, ADDR msgShell, SIZEOF msgShell, 16, 1, 15
        jmp continuar
    
continuar:
        
        INVOKE parseStringTiempo
        INVOKE mostrarCadena, ADDR msgTiempo, SIZEOF msgTiempo, 37, 1, 15
        INVOKE mostrarCadena, ADDR msgActualTiempo, SIZEOF msgActualTiempo, 45, 1, 15

        INVOKE mostrarCadena, ADDR msgVelocidad, SIZEOF msgVelocidad, 64, 1, 15
        INVOKE mostrarNumero, actualVelocidad, 76, 1, 15

margenes:

        INVOKE mostrarBarra, 10, 45, 620, 4, 15
        INVOKE mostrarBarra, 10, 400, 4, 355, 15
        INVOKE mostrarBarra, 626, 400, 4, 355, 15
        INVOKE mostrarBarra, 10, 400, 620, 4, 15

fin:
ret

setEncabezado ENDP

;-----------------------aca estoy......................
getColor PROC rango : WORD

inicio:

	xor ax, ax

	cmp rango,20
	jle rojo

	cmp rango,40
	jle azul

	cmp rango,60
	jle amarillo

	cmp rango,80
	jle verde

	cmp rango,99
	jle blanco
;--------------------------valores de colores
;-------12----Rojo
;-------09----Azul
;-------14----Amarillo
;-------10----Verde
;-------15----Blanco
rojo:
	mov al, 12
	jmp fin
azul:
	mov al, 09
	jmp fin
amarillo:
	mov al, 14
	jmp fin
verde:
	mov al, 10
	jmp fin
blanco:
	mov al, 15
	jmp fin

fin:
ret

getColor ENDP


mostrarValores PROC USES ax bx cx dx si di, arreglo : PTR WORD
  
inicio:

	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	xor si, si
	xor di, di
	
	
	mov cx, 20 				;-----------iteraciones a realizar
	
	;---------------Calculo de barras dinamicas en base a los elementos
	mov si, arreglo
	mov anchoBarra,0
	mov diferenciaBarra,0
	

	mov ax,560
	mov bx,elementos
	div bx
	mov diferenciaBarra,ax
	sub ax,5
	mov anchoBarra,ax
	

	mov dx,40
	mov bl,5

ciclo:

	mov ax, [si]
	cmp ax, 0
	ja graficar

	jmp incremento

graficar:

	INVOKE getColor, [si]

	mov di, [si]
	add di, [si]

;---------inicio calculo de altura dinamica-----
	push dx
	push ax
	push bx

	xor dx,dx
	mov ax,di
	mov bx,100
	mul bx
	xor dx,dx
	mov bx,mayor
	div bx
	mov di,ax

	pop bx
	pop ax
	pop dx
;--------fin calculo de altura dinamica--------


	INVOKE mostrarBarra, dx, 330,anchoBarra, di, al
	INVOKE mostrarNumero, [si], bl, 21, 15
	add dx,diferenciaBarra
	add bl,3
	jmp incremento



incremento:

	add si, 2
	dec cx
	cmp cx, 0
	jne ciclo

fin:
	ret

mostrarValores ENDP


mostrarPantalla PROC arreglo : ptr byte

inicio:

	INVOKE modoVideo
	INVOKE setEncabezado
	INVOKE mostrarValores,arreglo

fin:
ret

mostrarPantalla ENDP


;------------------------------------------------------------------------------------------------
;---------------------------------METODOS DE ORDENAMIENTO----------------------------------------
;------------------------------------------------------------------------------------------------


;-------------
;---BUBBLESORT
;-------------

bubbleSort PROC uses si di ax bx cx dx arreglo : word, tamanio : word

inicio:
        
	xor si,si
	xor di,di
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
	
	mov bx,arreglo ;---este movimiento permite acceder al arreglo por medio de [bx]

primCiclo:
        
	xor cx,cx
	xor dx,dx
	xor di,di	   ;----para poder moverse dentro de [bx], se le suma di, con la posibilidad 
				   ;----de una constante adicional

secCiclo:

	push dx

	mov ax,[bx+di+2] 
	mov dx,[bx+di]	 

	cmp actualDireccion,1
	je ascendente 
	cmp actualDireccion,2
	je descendente

descendente:

	cmp ax,dx
	jg intercambio
	jmp testCiclo

ascendente:

	cmp ax,dx
	jl intercambio
	jmp testCiclo

intercambio:

;---intercambio de numeros
	mov [bx + di + 2],dx 
	mov [bx + di],ax

;----------INICIO DE VISUALIZACION--------------

	INVOKE getDelay
	mov dx,ax

	INVOKE incrementoTiempo,dx
	INVOKE mostrarPantalla,bx
	INVOKE buzzer,[bx + di],dx

;----------FIN DE VISUALIZACION----------------

testCiclo:
                
	pop dx
	add di,2
	inc dx
	mov cx,tamanio ;---el valor de tamanio se calcula con anterioridad al ser los usuarios dinámicos
	sub cx,si
	sub cx,1
	cmp dx,cx
	jb secCiclo
			
	inc si
	cmp si,tamanio
	jb primCiclo

fin:
	ret

bubbleSort ENDP

;-------------
;---QUICKSORT, y esteeeeee, es el más loco, la verdad es complejo comentarlo porque es recursivo :c
;-------------
particion PROC uses si di bx cx dx arreglo : PTR word, bottom : word, top : word
LOCAL pivote : word, separador : word

inicio:
        
	xor si,si
	xor di,di
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
	mov bx,arreglo

setPivote:

	mov ax,2
	mul top
	mov si,ax
	mov ax,[bx+si]
	mov pivote,ax

setSeparador:

	mov ax,bottom
	sub ax,1
	mov separador,ax 

setCiclo:

	mov cx,top
	sub cx,1
	mov ax,2
	mul bottom
	mov si,ax

ciclo:

	mov ax,[bx+si]
	cmp actualDireccion,1
	je ascendente
	cmp actualDireccion,2
	je descentente

descentente:

	cmp ax, pivote
	jg intercambio
	jmp testCiclo

ascendente:

	cmp ax, pivote
	jl intercambio
	jmp testCiclo

intercambio:

	inc separador
	mov ax,2
	mul separador
	mov di,ax

	mov ax,[bx+di] 
	mov dx,[bx+si]
	
	mov [bx+si],ax
	mov [bx+di],dx

;----------INICIO DE VISUALIZACION--------------

	INVOKE getDelay
	mov dx,ax

	INVOKE incrementoTiempo,dx
	INVOKE mostrarPantalla,arreglo
	INVOKE buzzer,[bx + di],dx

;----------FIN DE VISUALIZACION--------------


testCiclo:

	add si,2
	sub cx,1
	cmp cx,bottom
	jge ciclo

correrPivote:

	inc separador
	mov ax,2
	mul separador
	mov di,ax
	mov ax,2
	mul top
	mov si,ax

	mov ax,[bx+di]
	mov dx,[bx+si]

	mov [bx+si],ax
	mov [bx+di],dx

	mov ax,separador

fin:
ret
particion ENDP


quickSort PROC USES si di ax bx cx arreglo : ptr word, bottom : word, top : word
LOCAL separador : word

inicio:
	xor si, si
	xor di, di
	xor ax, ax
	xor bx, bx
	xor cx, cx 

	mov si, bottom
	mov di, top

	cmp si, di
	jl ordenar

	jmp fin

ordenar:
            
	INVOKE particion, arreglo, bottom, top
	mov separador, ax

	sub separador, 1
	INVOKE quickSort, arreglo, bottom, separador

	add separador, 2
	INVOKE quickSort, arreglo, separador, top

fin:
ret
quickSort ENDP


;-------------
;---SHELLSORT, explicación: https://youtu.be/ddeLSDsYVp8
;-------------
shellSort PROC uses si di ax bx cx dx  arreglo : word, tamanio : word
LOCAL i : word, j : word, k : word 

inicio:
	
	xor si,si
	xor di,di
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx

	mov bx,arreglo

;---Así como se explica en el video, todo radica definir una distancia entre los 'swap'
;---e ir reduciendola de forma gradual. En este caso, se toma como referencia la mitad del
;---tamanio del arreglo.

setC1:	;---etiqueta inicial, simplemente saca la mitad del tamanio, al ser DW lo tomo como el doble

	mov ax, tamanio
	mov dx,2
	div dl
	mov ah,0
	mov i,ax
	cmp i,0
	jg C1
	jmp fin

C1:

setC2:	;---copia i a j

	mov ax,i
	mov j,ax
	mov ax,tamanio
	cmp j,ax
	jl C2   
	jmp testC1
        
C2:

setC3:
	;--asignación a K de su diferencia con j
	mov ax,j
	mov k,ax
	mov ax,i
	sub k,ax

	cmp k,0
	jge C3
	jmp testC2

C3:
	;---conversión del valor de k para asignarle a si el extremo derecho y a di, el limite izquierdo
	mov ax,k
	add ax,i
	mov si,2
	mul si
	mov si,ax
	mov cx,[bx+si]

	mov ax,k
	mov di,2
	mul di
	mov di,ax
	mov dx,[bx+di]

	cmp actualDireccion,1
	je ascendente
				
	cmp actualDireccion,2
	je descentente

descentente:

	cmp cx,dx
	jg intercambio
	jmp testC2

ascendente:

	cmp cx, dx
	jl intercambio
	jmp testC2
			
intercambio:

	mov cx,[bx+di] 
	mov dx,[bx+si]

	mov [bx+si],cx
	mov [bx+di],dx

;----------INICIO DE VISUALIZACION--------------

	INVOKE getDelay
	mov dx,ax

	INVOKE incrementoTiempo,dx
	INVOKE mostrarPantalla,arreglo
	INVOKE buzzer,[bx + di],dx

;----------FIN DE VISUALIZACION--------------


testC3: ;---decremento k, en el caso sea mayor o igual a 0 signifca que llegó al último intercambio

	mov ax,i
	sub k,ax
	cmp k,0
	jge C3

testC2:	;---incremento j, hasta que sea igual o mayor al tamanio real del arreglo

	add j,1
	mov ax,tamanio
	cmp j,ax
	jl C2

testC1: ;---decremento i, hasta que sea menor o igual a 0

	mov ax,i
	mov dx,2
	div dl
	mov ah,0
	mov i,ax

	cmp i, 0
	jg C1

fin:
	ret
shellSort ENDP