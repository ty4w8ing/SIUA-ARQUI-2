; Proyecto de arquitectura de computadores
; Integrantes : Gustavo Gonzalez y Andres Campos

;;;;;;poner comentarios;
; Esto es para hacer el codigo mas legible

sys_exit        equ     1
sys_read        equ     3
sys_write       equ     4
sys_open		equ		5
sys_close		equ 	6
stdin           equ     0
stdout          equ     1

;seccion de datos no inicializados
section .bss 	
	comandoLen		equ		100; buffer que recibe el comando de usuario
	comando		resb	comandoLen
	 
	archivoLen equ 2000	;buffer que recibe el archivo a abrirse
	archivo resb archivoLen
		
;seccion de datos inicializados
section .data

msj: db "james@aguacate.console>>>  " ;mensaje de cabecera en consola
len: equ $-msj

msjError: db "No se reconoce el comando",10 ;mensaje de error en caso de que no se reconozca
errorLen: equ $-msjError					;un comando

msjError2: db "No se pudo abrir el archivo",10 ;mensaje de error en caso de que no abra
errorLen2: equ $-msjError2					;un archivo

salir: db "salir";texto para usar de comparación para el comando salir
salirLen: equ $-salir

mostrar: db "mostrar";texto para usar de comparación para el comando mostrar
mostrarLen: equ $-mostrar

archivoPin:	db "a.txt",0

null: db 0
;seccion de codigo
section .text
; inicio del codigo del programa
	global _start
	
_start:
	nop; mantiene feliz al gbd
	
	;imprimo el tag para pa consola que vamos a utilizar
	mov edx, len; muevo al edx el largo del mensaje
	mov ecx, msj; muevo al ecx el puntero del mensaje
	call DisplayText; llamo a la subrutina de escribir texto
	
	;leo del usuario el comando que se va a ejecutar
	mov edx, comandoLen;muevo al edx el largo del mensaje
	mov ecx, comando; muevo al ecx el puntero del mensaje
	call ReadText; llamo a la subrutina de leer de usuario
	dec eax;decremento el eax que trae la cantidad de digitos leidos mas el ENTER
	;push eax; salvo esa cantidad de dígitos en la pila
	mov ecx, 0;muevo al ecx un cero que me servira de contador de digitos
		   
;ciclo principal de la funcion	
cicloMostrar:
	mov eax, 7;cantidad de digitos maxima de salir
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [mostrar + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne cicloSalir; si no son iguales pase al otro comando
	inc		ecx		; si son iguales, incremento el ecx para pasar al otro digito
	cmp		ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je Show; si son iguales valla a mostrar el archivo
	jmp     cicloMostrar; si no siga el ciclo
;muestra el archivo leido
Show:
	inc ecx ;incremeto el eax para seguir leyendo el comando
	mov	dl, byte [comando + ecx]; muevo al dl el digito+ecx del archivo
	cmp dl, 10; lo comparo con enter, para verificar que termino de escribir
	je .sub2; brinco si es igual
	mov byte[archivo+ecx], dl; si no lo meto en un buffer
	jmp Show; y vuelvo al ciclo
	
.sub2:
	inc ecx; incremento el ecx
	mov byte[archivo+ecx], 0; y meto en el buffer un null
	
	;%%%%%%%%%%%      PRUEBA PARA VER QUE TIENE EL BUFFER %%%%%%%%%%%
	mov edx, archivoLen
	mov ecx, archivo
	call DisplayText
	;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	;mov ebx, archivoPin ; ACA SI LO ABRE
	
	mov	ebx, archivo ; muevo al ebx el pintero del archivo (nombre.txt)
	mov	ecx, 0	; cero para las FLAGS
	mov	eax,sys_open; llamada al sistema
	int	80h		
	push eax;salvo en la pila este FD
	call Muestra; llamo a la subrutina de mostrar
	pop ebx	; saco de la pila ese FD
	call Cerrar ; llamo a cerrar el archivo para que no quede abierto
	jmp _start; iniacia nuevamente el programa (parecido a un while true)
	
;ciclo que revisa lo digitado por el usuario y si este digita salir, se sale del programa
cicloSalir:
	mov eax, 5;cantidad de digitos maxima de salir
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [salir + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne mensajeError; si no son iguales salgo al mensaje de error
	inc		ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp		ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je 		Fin; si son iguales brinque a salir
	jmp     cicloSalir; no son iguales siga el ciclo
	
; etiqueta de inciao para imprimir el mensaje de error
mensajeError:
	mov edx, errorLen; muevo al edx el len del tamaño del mensaje de error
	mov ecx, msjError; muevo al ecx el puntero del mensaje
	call DisplayText; llamo a la subrutina de mostrar en pantalla
	
	jmp _start ; si se imprime mensaje de error, inicie nuevamente el programa (parecido a un while true)
	
mensajeError2:
	mov edx, errorLen2; muevo al edx el len del tamaño del mensaje de error
	mov ecx, msjError2; muevo al ecx el puntero del mensaje
	call DisplayText; llamo a la subrutina de mostrar en pantalla
	
	jmp _start ; si se imprime mensaje de error, inicie nuevamente el programa (parecido a un while true)
;fin del programa
; paso al eax 1 y ebx 0 y me salgo con la llamada al sistema
Fin:
	mov eax, sys_exit
	mov ebx, 0
	int 80h
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
;rutinas intermedias...

; desplega algo en la salida estándar. debe "setearse" lo siguiente:
; ecx: el puntero al mensaje a desplegar
; edx: el largo del mensaje a desplegar
; modifica los registros eax y ebx.
DisplayText:
    mov     eax, sys_write
    mov     ebx, stdout
    int     80H 
    ret

; lee algo de la entrada estándar.debe "setearse" lo siguiente:
; ecx: el puntero al buffer donde se almacenará
; edx: el largo del mensaje a leer
ReadText:
    mov     ebx, stdin
    mov     eax, sys_read
    int     80H
    ret
 
;subrutina que muestra el contenido interno de un archivo 
Muestra:
	test	eax, eax ; primero nos aseguramos que abrio bien
	js	mensajeError2; no es asi? imprime mensaje de errorLen
	; si se abre bien
	mov		ebx, eax; paso al ebx el FD
	mov		ecx, archivo; paso el puntero del buffer con el archivo
	mov		edx, archivoLen; y su len correspondiente
	mov		eax, sys_read; y llamo a read de dicho archivo
	int 	80h		
	;Una vez leido lo imprimo en consola por medio del DisplayText
	mov edx, archivoLen
	mov ecx, archivo 
	call DisplayText	
	ret

;Subrutina que cierrra un archivo abierto
Cerrar:
	mov eax, sys_close; solamente se llama a la llamada del sistema sys_close
	int 80h
	ret
