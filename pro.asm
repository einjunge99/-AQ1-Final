
   
    
.model small,STDCALL
;----------------------------------------------------
;-----------------SEGMENTO DE PILA-------------------
;----------------------------------------------------
.stack 100h
;----------------------------------------------------
;-----------------SEGMENTO DE DATO------------------
;----------------------------------------------------
.data

;----------------------CADENAS A MOSTRAR-------------------------
displayTitulo    db      0ah,0dh,'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',
                        0ah,0dh,'FACULTAD DE INGENIERIA',
                        0ah,0dh,'CIENCIAS Y SISTEMAS',
                        0ah,0dh,'ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES',
                        0ah,0dh,'NOMBRE: JULIAN ISAAC MALDONADO LOPEZ',
                        0ah,0dh,'CARNET: 201806839',
                        0ah,0dh,'A','$'

displayUser      db      0ah,0dh,'1) Iniciar juego',
                        0ah,0dh,'2) Cargar juego',
                        0ah,0dh,'3) Salir','$'
                        
displayAdmin     db     0ah,0dh,'1) Top 10 puntos',
                        0ah,0dh,'2) Top 10 tiempo',
                        0ah,0dh,'3) Salir','$'

displayOrden     db     0ah,0dh,'Seleccione ordenamiento:',
                        0ah,0dh,'1) Bubblesort',
                        0ah,0dh,'2) Quicksort',
                        0ah,0dh,'3) Shellsort','$'

displayDireccion db     0ah,0dh,'Indique la direccion a ordenar:',
                        0ah,0dh,'1) Ascendente',
                        0ah,0dh,'2) Descendente','$'

displayLogin     db     0ah,0dh,'LOGIN',
                        0ah,0dh,
                        0ah,0dh,'1) Ingresar',
                        0ah,0dh,'2) Registrar',
                        0ah,0dh,'3) Salir','$'

displayRegistrar db     0ah,0dh,'REGISTRAR',
                        0ah,0dh,'$'

displayVelocidad db     0ah,0dh,'Seleccione velocidad entre el rango (0-9)','$'
displayTopPuntos db     '    Top 10 de puntos',0ah,0dh,0ah,0dh,'$'
displayTopTiempo db     '    Top 10 de tiempo',0ah,0dh,0ah,0dh,'$'
displaySalida    db     'Toma awa, cuidate tkm :3','$'

           

salto            db      0ah,0dh,'$'

msgOrdenamiento  db      'ORDENAMIENTO:'
msgPuntos        db      'TOP 10 PUNTOS'
msgTiempos       db      'TOP 10 TIEMPOS'
msgTiempo        db      'TIEMPO:'
msgVelocidad     db      'VELOCIDAD:'
msgBubble        db      'BUBBLESORT'
msgQuick         db      'QUICKSORT'
msgShell         db      'SHELLSORT'
msgUser          db      'User: ','$'
msgPass          db      'Password: ','$'
msgExito         db      'Usuario registrado exitosamente!','$'
ing              db      0ah,0dh,'Ingrese el nombre del archivo:','$'

msg1             db      0ah,0dh,'Niveles registrados:',0ah,0dh,'$'
msg2             db      0ah,0dh,'Tiempos de niveles:',0ah,0dh,'$'
msg3             db      0ah,0dh,'Tiempos de obstaculos:',0ah,0dh,'$'
msg4             db      0ah,0dh,'Tiempos de premios:',0ah,0dh,'$'
msg5             db      0ah,0dh,'Puntos de obstaculos:',0ah,0dh,'$'
msg6             db      0ah,0dh,'Puntos de premios:',0ah,0dh,'$' 




;-------------------ERRORES-----------------------------
error1      db 'Error al cargar el archivo','$'
error2      db 'Error al cerrar el archivo','$'
error3      db 'Error al leer el archivo','$'
error4      db 'Error al crear el archivo','$'
error5      db 'Error al escribir el archivo','$'
error6      db 'Comando invalido','$'

error7      db  0ah,0dh,'Caracter no valido','$'
error8      db  0ah,0dh,'Datos incorrectos','$'
error9      db  0ah,0dh,'Usuario ya registrado ','$'
error10     db  0ah,0dh,'Password no numerica ','$'
error11     db  0ah,0dh,'Formato incorrecto ','$'
error12     db  0ah,0dh,'Limite erroneo ','$'
error13     db  0ah,0dh,'Se necesitan cuatro caracteres!','$'

errorDebbug db 'Error','$'


;-----------------------VARIABLES DINAMICAS-------------------------
actualOrden         db      0
actualVelocidad     db      0
actualDireccion     dw      0
actualEncabezado    dw      0
actualTop           dw      0

minutos             dw      0
segundos            dw      0
milisegundos        dw      0

msgActualTiempo     db      "00:00"

elementos           dw      10
auxElementos        dw      0
mayor               dw      0
tamanioEscritura    dw      0   

primTop             dw      0
secTop              dw      0

tempPass            db      14 dup('$'),'$'
tempUser            db      14 dup('$'),'$'

auxArreglo          dw      30 dup(0)
auxCadena           db      31 dup(00h)
cont                dw      0

ruta                db      'usuarios.txt',0
rutaReporte         db      'reporte.rep',0
rutaNombres         db      'nombres.txt',0
handlerRuta         dw      ?
informacion         db      71 dup('$'),'$'
pruebaContenido     db      15 dup('$'),'$'

anchoBarra          dw      0
diferenciaBarra     dw      0
diferenciaNumero    db      0

datosUsuarios       db      450 dup('$'),'$'
datosPuntaje        dw      30 dup(0),0
datosTiempo         dw      30 dup(0),0   
datosNivel          dw      30 dup(0),0
datosNombre         db      300 dup('$'),'$'   
datosReporte        db      500 dup('$'),'$'

nombreNivel         db      300 dup('$')
tiempoNivel         db      300 dup('$')
tiempoObstaculos    db      300 dup('$')
tiempoPremio        db      300 dup('$')
puntosObstaculos    db      300 dup('$')
puntosPremios       db      300 dup('$')
colorNivel          db      300 dup('$')

entradaJuego        db      1000 dup('$'),'$'
rutaJuego           db      50 dup(0)
indiceNivel         dw      0

;----------------------------ETIQUETAS-------------------------------


;----------------------------------------------------
;-----------------SEGMENTO DE CODIGO-----------------
;----------------------------------------------------
.code 

include proMacro.asm
include proProc.asm

main proc

    mov ax, @data
    mov ds, ax
    setEntrada

;-------------------------------------PANTALLA DE LOGIN----------------------------------

    LOGIN:
        print displayLogin
        getChar
        cmp al,'1'
        je ingresar
        cmp al,'2'
        je registrar
        cmp al,'3'
        je Salir
        jmp LOGIN

    ingresar:
        print salto
        print msgUser
        getTexto tempUser
        print msgPass
        getTexto tempPass
        analizarDatos
        cmp cx,1
        je ADMIN
        cmp cx,2
        je USER
        print error8
        getChar
        jmp LOGIN
    
    registrar:
        print salto
        ingresarDatos
        jmp LOGIN

;----------------------------------------PANTALLA USUARIO----------------------------------

    USER:
        print displayTitulo
        print displayUser
        getChar
        cmp al,'2'
        je carga
        cmp al,'3'
        je LOGIN
        jmp USER

    carga:
        print ing
        print salto
        getTexto rutaJuego
        abrirArchivo rutaJuego,handlerRuta
        leerArchivo handlerRuta,entradaJuego,SIZEOF entradaJuego  
        cargaJuego entradaJuego
        
        print msg1
        printNiveles nombreNivel
        
        print msg2
        printNumeros tiempoNivel

        print msg3
        printNiveles tiempoObstaculos
        
        print msg4
        printNumeros tiempoPremio

        print msg5
        printNiveles puntosObstaculos
        
        print msg6
        printNumeros puntosPremios

        jmp USER

        
;----------------------------------------PANTALLA ADMIN------------------------------------    
    ADMIN:
        colocarCeros auxArreglo,SIZEOF auxArreglo

        xor ax,ax
        print displayTitulo
        print displayAdmin


        getChar
        cmp al,'1'
        je topPuntos
        cmp al,'2'
        je topTiempos
        cmp al,'3'
        je LOGIN
        jmp ADMIN

    topPuntos:
        setEntrada

        setNumericos datosUsuarios
        setStrings datosUsuarios

        copiarArreglo datosPuntaje,auxArreglo
        
        setTopPuntos auxArreglo
        setReporte auxArreglo,displayTopPuntos

        copiarArreglo datosPuntaje,auxArreglo
        
        print salto
        print datosReporte
        getChar

        mov actualTop,0
        jmp ordenamiento
        
    topTiempos:
        setEntrada

        setNumericos datosUsuarios
        setStrings datosUsuarios

        copiarArreglo datosTiempo,auxArreglo
        
        setTopTiempo auxArreglo
        setReporte auxArreglo,displayTopTiempo

        copiarArreglo datosTiempo,auxArreglo

        print salto
        print datosReporte
        getChar

        mov actualTop,1
        jmp ordenamiento

    ordenamiento:
        mov actualEncabezado,0
        INVOKE mostrarPantalla, ADDR auxArreglo
        getChar
        cmp al,' '
        jne ordenamiento
        modoTexto
        mov actualEncabezado,1

        elegirOrdenamiento
        elegirVelocidad
        elegirDireccion


        INVOKE mostrarPantalla, ADDR auxArreglo
    
    leerCaracter:
        getChar
        cmp al,' '
        je ordenar
        cmp al,1bh      ;------------ASCCI de ESC
        je regresarMenu
        jmp leerCaracter

    ordenar:
        mov segundos,0
        mov milisegundos,0
        mov minutos,0

        decidirOrdenamiento
        getChar

    regresarMenu:
        modoTexto
        jmp ADMIN

    Salir:
        print salto
        print displaySalida
        mov ah,4ch
        xor al,al
        int 21h
main endp

end main

