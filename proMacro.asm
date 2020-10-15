;----------------------------------------------------------------------------------------
;------------------------------------------ARCHIVOS--------------------------------------
;----------------------------------------------------------------------------------------


abrirArchivo MACRO buffer,handler
LOCAL inicio,error,fin

inicio:
    mov ah,3dh
    mov al,00h
    lea dx,buffer
    int 21h
    jc error
    mov handler,ax
    jmp fin

error:
    print error1
    getChar
    ;jmp Menu
fin:

endm 

cerrarArchivo MACRO handler 
LOCAL inicio,error, fin

inicio:
    mov ah, 3eh
    mov bx,handler
    int 21h
    jc  error
    jmp fin
error:
    print error2
    getChar
    ;jmp Menu
fin:

endm

leerArchivo MACRO handler,buffer,numBytes
LOCAL inicio,error, fin

inicio:    
    mov ah,3fh
    mov bx,handler
    mov cx,numBytes
    lea dx,buffer
    int 21h
    jc error
    jmp fin
error:
    print error3
    getChar
    ;jmp Menu
fin:

endm

crearArchivo MACRO buffer,handler
LOCAL inicio,error,fin

inicio:        
    mov ah,3ch
    mov cx,00h
    lea dx,buffer
    int 21h
    jc error
    mov handler,ax
    jmp fin

error:
    print error4
fin:

endm

escribirArchivo MACRO handler,buffer,numBytes
LOCAL inicio,error,fin

inicio:
    mov ah,40h
    mov bx,handler
    mov cx ,numBytes
    lea dx,buffer
    int 21h
    jc error
    jmp fin
error:
    print error5
fin:

endm

sobrantesArchivo MACRO buffer,numBytes     
LOCAL inicio,ciclo1,ciclo2,fin

inicio:
    xor si,si
    xor cx,cx
    mov cx,numBytes
ciclo1:
    cmp buffer[si],24h    
    je fin
    inc si
    loop ciclo1
    jmp fin
fin:
    mov tamanioEscritura,si
endm


;----------------------------------------------------------------------------------------
;-----------------------------------------VARIOS-----------------------------------------
;----------------------------------------------------------------------------------------

sonido MACRO hz,delaym
LOCAL inicio,fin

inicio:

    push ax
    push cx

    xor ax, ax
    xor cx, cx

    mov al, 86h
    out 43h, al
    mov ax, (1193180 / hz)
    out 42h, al
    mov al, ah
    out 42h, al 
    in  al, 61h
    or  al, 00000011b
    out 61h, al
    
    INVOKE setDelay, delaym

    in al, 61h
    and al, 11111100b
    out 61h, al
fin:
    pop cx
    pop ax

endm

;-------------------------------------------------------------------------------
;-------------------------------------VISUALES----------------------------------
;-------------------------------------------------------------------------------

modoTexto macro
    mov ax, 0003h
    int 10h
endm

print MACRO cadena

    push ax
    push dx

    mov ah, 09h
    mov dx, OFFSET cadena
    int 21h

    pop dx
    pop ax

ENDM


;-----------------------------------PARSERS-------------------------------------;


parseNumeroString MACRO arreglo
LOCAL inicio,fin
    xor ax,ax
    xor bx,bx
inicio:    
    mov al,arreglo[si]
    sub al,30h
    mov bl,10
    mul bx
    inc si
    xor bx,bx
    mov bl,arreglo[si]
    sub bl,30h
    add ax,bx
fin:    
endm

;----------------------------------------------------------------------------------------
;----------------------------CAPTURA Y ANALISIS DE DATOS---------------------------------
;----------------------------------------------------------------------------------------

getChar MACRO

    mov ah,01h
    int 21h

ENDM

getTexto macro buffer
LOCAL concat,fin
  
     xor si,si

concat:
    getChar
    cmp al,0dh
    je fin
    mov buffer[si],al
    inc si
    jmp concat
fin:
    mov al,'$'
    mov buffer[si],al
endm

colocarCeros MACRO buffer,tamanio
LOCAL ciclo,fin
xor si,si
mov cx,tamanio
ciclo:
    mov buffer[si],0
    inc si
    loop ciclo
fin:
endm

colocarDolar MACRO buffer,tamanio
LOCAL ciclo,fin
push si
xor si,si
mov cx,tamanio
ciclo:
    mov buffer[si],24h
    inc si
    loop ciclo
fin:
pop si
endm

correrComa MACRO buffer
LOCAL inicio,fin,ciclo
ciclo:
    cmp buffer[di],','
    je fin
    inc di
    jmp ciclo
fin:
inc di
endm

correrSiguiente MACRO buffer
LOCAL fin,ciclo,siguiente,finCadena

ciclo:  
    xor ax,ax
    mov al,buffer[di]
    cmp al,0dh
    je siguiente
    cmp al,24h
    je finCadena
    inc di
    jmp ciclo

finCadena:
    STC         
    jmp fin
siguiente:
    CLC
    jmp fin
fin:

endm

cargaJuego macro entrada
LOCAL inicio, fin, ciclo,separador,S0,S1,S2,S3,S4,S5,S6
mov indiceNivel,0
xor si,si
xor di,di
dec si
dec si

inicio:
print pruebaContenido
inc si
S0:
    inc si
    mov al,entrada[si]
    cmp al,24h
    je fin
    cmp al,';'
    je S1
    jmp S0

S1:
    inc si
    mov al,entrada[si]
    cmp al,';'
    je separador
    push di
    mov di,indiceNivel
    mov nombreNivel[di],al
    inc indiceNivel
    pop di
    jmp S1

separador:
    push di
    mov di,indiceNivel
    mov nombreNivel[di],','
    inc indiceNivel
    pop di
S2:
    inc si

    mov al,entrada[si]
    mov ah,entrada[si+1]

    mov tiempoNivel[di],al
    mov tiempoNivel[di+1],ah

    
    mov al,entrada[si+3]
    mov ah,entrada[si+4]
    mov tiempoObstaculos[di],al
    mov tiempoObstaculos[di+1],ah
        

    mov al,entrada[si+6]
    mov ah,entrada[si+7]
    mov tiempoPremio[di],al
    mov tiempoPremio[di+1],ah

    mov al,entrada[si+9]
    mov ah,entrada[si+10]
    mov puntosObstaculos[di],al
    mov puntosObstaculos[di+1],ah

    mov al,entrada[si+12]
    mov ah,entrada[si+13]
    mov puntosPremios[di],al
    mov puntosPremios[di+1],ah

    add si,14
    add di,2

S3:
    inc si
    mov al,entrada[si]
    cmp al,0dh
    je inicio
    jmp S3

fin:

endm

           ;datosUsuario,tempUser/tempPass
cadenaIgual MACRO actual,comprobar
LOCAL inicio,ciclo,fin,filtro,error,correcto,continuar,correr
xor si,si
xor ax,ax
ciclo:
    mov al,comprobar[si]
    cmp al,24h
    je filtro
    cmp actual[di],','
    je error
    cmp al,actual[di]
    jne error
    inc si
    inc di

    jmp ciclo

filtro:
    cmp actual[di],','
    je correcto
    jmp error

;----------------------CF=1, correcto; CF=0, incorrecto
correcto:
    STC         
    jmp fin

error:
    CLC
    jmp fin

fin:
endm

validarUsuario MACRO
LOCAL ciclo,correcto,error,fin
xor di,di
ciclo:
    cadenaIgual datosUsuarios,tempUser
    jc correr                            
    jmp correcto

correr:
    correrSiguiente datosUsuarios
    jc error
    inc di
    ;inc di
    jmp ciclo

correcto:
    STC         
    jmp fin

error:
    CLC
    jmp fin

fin:

endm


validarPassword MACRO
LOCAL ciclo,correcto,error,fin
xor di,di
ciclo:
    cmp tempPass[di],24h
    je correcto
    cmp tempPass[di],30h
    jle error
    cmp tempPass[di],39h
    jg error
    inc di
    jmp ciclo

correcto:
    STC         
    jmp fin

error:
    CLC
    jmp fin

fin:
endm

correrIndice MACRO buffer
LOCAL ciclo,fin
xor di,di
ciclo:
    cmp buffer[di],24h
    je fin
    cmp buffer[di],0
    je fin
    inc di
    jmp ciclo
fin:
endm

concatenar MACRO original,incluir
LOCAL ciclo,fin
xor si,si
ciclo:
    cmp incluir[si],24h
    je fin
    mov al,incluir[si]
    mov original[di],al
    inc si
    inc di
    jmp ciclo
fin:
endm

tamanioValido MACRO entrada
LOCAL ciclo,fin,comprobar,correcto,error
xor si,si
ciclo:
    cmp entrada[si],24h
    je comprobar
    inc si
    jmp ciclo
comprobar:
    cmp si,4
    je correcto
    jmp error
correcto:
    STC
    jmp fin
error:
    CLC
    jmp fin
fin:
endm


ingresarDatos MACRO 
LOCAL inicio,fin,error,setUser,errorUser,setPassword,errorPass
xor si,si
setUser:
    print msgUser
    getTexto tempUser
    tamanioValido tempUser
    jnc errorUser
    validarUsuario
    jc setPassword
    print error9
    getChar
    jmp setUser
errorUser:
    print error13
    getChar
    jmp setUser

setPassword:
    print msgPass
    getTexto tempPass
    tamanioValido tempPass
    jnc errorPass
    validarPassword
    jc fin
    print error10
    getChar
    jmp setPassword
errorPass:
    print error13
    getChar
    jmp setPassword


fin:
    print salto
    print msgExito
    print salto

;----------se escribe en el arreglo local y en el archivo los cambios realizados
    correrIndice datosUsuarios
    mov datosUsuarios[di],0dh
    inc di
    concatenar datosUsuarios,tempUser
    mov datosUsuarios[di],','
    inc di
    concatenar datosUsuarios,tempPass

    mov datosUsuarios[di],','
    mov datosUsuarios[di+1],'0'
    mov datosUsuarios[di+2],'0'
    mov datosUsuarios[di+3],','
    mov datosUsuarios[di+4],'0'
    mov datosUsuarios[di+5],'0'
    mov datosUsuarios[di+6],','
    mov datosUsuarios[di+7],'0'
    mov datosUsuarios[di+8],'0'

    crearArchivo ruta,handlerRuta
    sobrantesArchivo datosUsuarios,SIZEOF datosUsuarios
    escribirArchivo handlerRuta,datosUsuarios,tamanioEscritura
    cerrarArchivo handlerRuta
    endm

analizarDatos MACRO
;--------------------DONDE  CX=0,error, CX=1,admin, CX=2,user
LOCAL cicloAdmin,fin,otros,error,correr,mover

xor si,si
xor di,di
mov cx,1
cicloAdmin:
    cadenaIgual datosUsuarios,tempUser
    jnc mover
    correrComa datosUsuarios
    cadenaIgual datosUsuarios,tempPass
    jnc error
    jmp fin

mover:
    mov cx,2
    jmp correr
cicloUsuarios:
    cadenaIgual datosUsuarios,tempUser
    jnc correr                            
    correrComa datosUsuarios
    cadenaIgual datosUsuarios,tempPass
    jnc correr
    jmp fin

correr:
    correrSiguiente datosUsuarios
    jc error
    inc di
    ;inc di
    jmp cicloUsuarios 

error:
    mov cx,0
    jmp fin

fin:

endm


;---------------------------------------------------AQUI ME QUEDE
;------convertir los numeros de estas cosas a su valor numerico
;------intercambiar los nombres, dejando el mismo espacio entre todos aunque el nombre no llegue a los 7 caracteres
;------el reporte de top


setMayor macro entrada,A1,A2,A3
LOCAL inicio,S0,S1,S2,fin
inicio:
    mov ax,elementos
    sal ax,1
    mov primTop,ax
    sub ax,2
    mov secTop,ax
    xor di,di
S0:
    mov si,di
    add si,2
S1:
    mov ax,entrada[di]
    mov bx,entrada[si]
    cmp ax,bx
    jg S2
    mov entrada[di],bx
    mov entrada[si],ax

;----------------inicio intercambio secundario----------

;--Intercambio variable(Puntos/tiempo)
    mov ax,A1[di]
    mov bx,A1[si]
    mov A1[di],bx
    mov A1[si],ax

;--Intercambio nivel
    mov ax,A2[di]
    mov bx,A2[si]
    mov A2[di],bx
    mov A2[si],ax


;--Intercambio nombre
    push di
    push si

    sal si,1
    sal di,1

    mov al,A3[di]
    mov ah,A3[si]
    mov A3[di],ah
    mov A3[si],al

    mov al,A3[di+1]
    mov ah,A3[si+1]
    mov A3[di+1],ah
    mov A3[si+1],al

    mov al,A3[di+2]
    mov ah,A3[si+2]
    mov A3[di+2],ah
    mov A3[si+2],al

    mov al,A3[di+3]
    mov ah,A3[si+3]
    mov A3[di+3],ah
    mov A3[si+3],al


    pop si
    pop di

;-----------------fin intercambio secundario------------

S2:
    add si,2
    cmp si,primTop
    jne S1
    add di,2
    cmp di,secTop
    jne S0

fin:
    mov ax,entrada[0]
    mov mayor,ax
endm


setReporte MACRO entrada,titulo
LOCAL inicio,ciclo,fin,bandera
xor si,si
xor di,di
xor ax,ax

inicio:
    concatenar datosReporte,titulo
    mov si,di
    xor di,di

ciclo:
    xor ax,ax
    push di

    sal di,1
;----------espacios-----------------
    mov datosReporte[si],' '
    mov datosReporte[si+1],' '
;--------------nombre usuario---------
    mov al,datosNombre[di]
    mov datosReporte[si+2],al
    mov al,datosNombre[di+1]
    mov datosReporte[si+3],al
    mov al,datosNombre[di+2]
    mov datosReporte[si+4],al
    mov al,datosNombre[di+3]
    mov datosReporte[si+5],al
;----------espacios-----------------
    mov datosReporte[si+6],' '
    mov datosReporte[si+7],' '
    mov datosReporte[si+8],' '
    mov datosReporte[si+9],' '
    mov datosReporte[si+10],' '
    mov datosReporte[si+11],' '
    mov datosReporte[si+12],' '
    mov datosReporte[si+13],' '

    pop di

;-------------nivel-------------
    xor dx,dx
    mov ax,datosNivel[di]
    mov bl,10
    div bl
    add al,30h
    add ah,30h

    mov datosReporte[si+14],al
    mov datosReporte[si+15],ah

;----------espacios-----------------

    mov datosReporte[si+16],' '
    mov datosReporte[si+17],' '


;-----------parametro-----------
    xor dx,dx
    mov ax,entrada[di]
    mov bl,10
    div bl
    add al,30h
    add ah,30h

    mov datosReporte[si+18],al
    mov datosReporte[si+19],ah

;----------espacios-----------------
    mov datosReporte[si+20],0ah
    mov datosReporte[si+21],0dh

bandera:
    cmp di,18
    je fin
    cmp entrada[di+2],0
    je fin
    add di,2
    add si,21
    jmp ciclo


fin:
    mov datosReporte[si+22],24h
    crearArchivo rutaReporte,handlerRuta
    escribirArchivo handlerRuta,datosReporte,SIZEOF datosReporte
    cerrarArchivo handlerRuta

;--------------concatenar en un mega string todo lo que tengo guardado? y ver que pex con el convertidor de numero a string
;--------------para usarlo al momento de concatenar los numeros
endm


setTopPuntos MACRO arreglo
    setMayor arreglo,datosTiempo,datosNivel,datosNombre
endm

setTopTiempo MACRO arreglo
    setMayor arreglo,datosPuntaje,datosNivel,datosNombre
endm





setStrings MACRO arreglo
LOCAL saltarAdmin,ciclo,setNombre,fin,correr

xor si,si
xor di,di
saltarAdmin:
    cmp arreglo[di],0dh
    je ciclo
    cmp arreglo[di],24h
    je fin
    inc di
    jmp saltarAdmin  
ciclo:
    inc di
setNombre:
    mov al,arreglo[di]
    cmp al,','
    je correr 
    mov datosNombre[si],al
    inc si
    inc di
    jmp setNombre

correr:
    correrSiguiente arreglo
    jc fin
    inc di
    jmp setNombre

fin:
endm


setNumericos MACRO arreglo
LOCAL saltarAdmin,ciclo,comprobar,correrNombre,correrPass,setPuntos,setTiempo,setNivel,fin
xor si,si
xor di,di
dec di
dec di
saltarAdmin:
    cmp arreglo[si],0dh
    je ciclo
    cmp arreglo[si],24h
    je fin
    inc si
    jmp saltarAdmin  
ciclo:
    add di,2
correrNombre:
    inc si
    cmp arreglo[si],','
    jne correrNombre 
correrPass:    
    inc si
    cmp arreglo[si],','
    jne correrPass
    inc si
setNivel:
    parseNumeroString datosUsuarios
    mov datosNivel[di],ax
    add si,2
setPuntos:
    parseNumeroString datosUsuarios
    mov datosPuntaje[di],ax
    add si,2
setTiempo:
    parseNumeroString datosUsuarios
    mov datosTiempo[di],ax
    inc si
comprobar:    
    cmp arreglo[si],0dh
    je ciclo
    cmp arreglo[si],24h
    je fin
  
fin:
   add di,2
;---------------asignación de valores a globales y tope a arreglos---------
   mov datosTiempo[di],0
   mov datosPuntaje[di],0
   mov datosNivel[di],0
   xor dx,dx
   mov ax,di
   mov bx,2
   div bx
   mov elementos,ax
   dec ax
   mov auxElementos,ax
   xor di,di
endm


setEntrada MACRO
  abrirArchivo ruta,handlerRuta
  leerArchivo handlerRuta,datosUsuarios,SIZEOF datosUsuarios  
endm


copiarArreglo MACRO original,copia
LOCAL inicio,ciclo,fin

inicio:

    xor ax,ax
    xor si,si
    xor cx,cx

    mov ax,elementos
    mov bx,2
    mul bx
    mov bx,ax
    
ciclo:

    mov ax, original[si]
    mov copia[si], ax

    add si,2

    cmp bx,si
    jne ciclo

fin:

endm


elegirOrdenamiento MACRO
LOCAL inicio,fin,setBubble,setQuick,setShell
    
inicio:
    print displayOrden
    getChar
    cmp al,'1'
    je setBubble
    cmp al,'2'
    je setQuick
    cmp al,'3'
    je setShell
    jmp inicio

setBubble:
    mov actualOrden,1
    jmp fin
setQuick:
    mov actualOrden,2
    jmp fin
setShell:
    mov actualOrden,3
fin:

endm




elegirVelocidad MACRO
LOCAL inicio,fin,setVelocidad
xor ax,ax    
inicio:
    print displayVelocidad
    getChar
    cmp al,'0'
    jl inicio
    cmp al,'9'
    jle setVelocidad
    jmp inicio

setVelocidad:
    sub al,30h
    mov actualVelocidad,al
fin:
endm

elegirDireccion MACRO
LOCAL inicio,fin,setDireccion
xor ax,ax    
inicio:
    print displayDireccion
    getChar
    cmp al,'1'  ;---------ascendente
    jl inicio   
    cmp al,'2'  ;---------descendente
    jle setDireccion
    jmp inicio

setDireccion:
    mov bl,al
    xor ax,ax
    mov al,bl
    sub ax,30h
    mov actualDireccion,ax
fin:
endm

decidirOrdenamiento MACRO
LOCAL inicio,fin,setBubble,setQuick,setShell

inicio:
    cmp actualOrden,1           ;-------------Bubblesort
    je setBubble
    cmp actualOrden,2           ;-------------Quicksort
    je setQuick
    cmp actualOrden,3           ;-------------Shellsort
    je setShell

setBubble:
    INVOKE bubblesort, ADDR auxArreglo, elementos
    INVOKE mostrarPantalla, ADDR auxArreglo
    jmp fin
setQuick:

    mov ax,elementos
    sub ax,1
    mov auxElementos,ax
    
    INVOKE quicksort, ADDR auxArreglo, 0, auxElementos
    INVOKE mostrarPantalla, ADDR auxArreglo

    jmp fin
setShell:
    INVOKE Shellsort, ADDR auxArreglo, elementos
    INVOKE mostrarPantalla, ADDR auxArreglo

    jmp fin

fin:
endm



;-------------------nada mas para debugear.....................XD

printArreglo macro arreglo
LOCAL ciclo,fin
xor si,si
ciclo:
xor ax,ax
mov al,arreglo[si]
cmp al,24h
je fin
mov pruebaContenido[0],al
print pruebaContenido
getChar
inc si
jmp ciclo
fin:
endm

printNumeros macro arreglo
LOCAL ciclo,fin
xor si,si
ciclo:
    xor ax,ax
    mov al,arreglo[si]
    cmp al,24h
    je fin
    mov ah,arreglo[si+1]
    cmp ah,24h
    je fin
    mov pruebaContenido[0],al
    mov pruebaContenido[1],ah
    print pruebaContenido
    getChar
    add si,2
    jmp ciclo
fin:
    colocarDolar pruebaContenido,10
endm



printNiveles macro arreglo
LOCAL ciclo,fin,mostrar
xor si,si
xor di,di
ciclo:
    xor ax,ax
    mov al,arreglo[si]
    cmp al,24h
    je fin
    cmp al,','
    je mostrar
    mov pruebaContenido[di],al
    inc si
    inc di
    jmp ciclo
mostrar:
    print pruebaContenido
    getChar
    inc si
    xor di,di
    colocarDolar pruebaContenido,10
    jmp ciclo
fin:
    colocarDolar pruebaContenido,10
endm