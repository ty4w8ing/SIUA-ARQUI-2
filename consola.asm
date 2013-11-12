; Proyecto de arquitectura de computadores
; Integrantes : Gustavo Gonzalez y Andres Campos

;;;;;;poner comentarios;
; Esto es para hacer el codigo mas legible

sys_exit equ 1
sys_read equ 3
sys_write equ 4
sys_open equ 5
sys_close equ 6
stdin equ 0
stdout equ 1

;seccion de datos no inicializados
section .bss 	
	comandoLen equ 30; buffer que recibe el comando de usuario
	comando resb comandoLen
	 
	archivoLen equ 30	;buffer que recibe el nombre del archivo 
	archivo resb archivoLen
	archivoLen2 equ 9999	;buffer que recibe el archivo 
	archivo2 resb archivoLen2
	archivoLen3 equ 9999	;buffer que recibe el archivo anexo
	archivo3 resb archivoLen3
	
		
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

ayuda: db "--ayuda";texto para usar de comparación para el comando --ayuda
ayudaLen: equ $-ayuda

ayudacomando: db "comando.ayuda.txt",0; comando para abrir ayuda en mostrar

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
	mov ecx, eax; muevo al ecx la cantidad de digitos leidos
	dec ecx; decremento el ecx
	mov byte[comando+ecx],0h;muevo al ultimo bit un null 
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
	mov ecx, 8; muevo al ecx un 8 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0; muevo un 0 al ebx que sirve de contador
.sub:	
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 0h;comparo a ver si ya termine con null
	je .sub2;si es null pase a analizar y abrir
	mov byte[archivo+ebx], al;si no es null, mueva el byte al buffer del nombre del archivo
	inc ecx;incremento los contadores
	inc ebx
	jmp .sub;regreso al ciclo
	
.sub2:
	mov eax, 7;cantidad de digitos maxima de --ayuda
	mov ecx, 0; contador en cero
.sub3:
	mov	dl, byte [archivo + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [ayuda + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne .sub4; si no son iguales pase al otro comando
	inc	ecx		; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je mensajeAyudaMostrar; si son iguales valla mostrar mensaje de ayuda
	jmp .sub3; si no siga el ciclo
.sub4:	
	mov eax, archivo; saco al eax el nombre del archivo
	mov ebx, eax; lo paso al ebx
	mov	ecx, 0; read  mode
	mov	eax,sys_open; llamada al sistema
	int	80h		
	push eax;salvo en la pila este FD
	call Muestra; llamo a la subrutina de mostrar
	pop ebx	; saco de la pila ese FD
	call Cerrar ; llamo a cerrar el archivo para que no quede abierto
	jmp Limpiar; brinco a limpiar los buffers
	
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
	
	jmp Limpiar; brinco a limpiar los buffers
	
mensajeError2:
	mov edx, errorLen2; muevo al edx el len del tamaño del mensaje de error
	mov ecx, msjError2; muevo al ecx el puntero del mensaje
	call DisplayText; llamo a la subrutina de mostrar en pantalla
		
	jmp Limpiar; brinco a limpiar los buffers
	
	
;Funcion que limpia los buffers para volver a ser usados
Limpiar:
	xor edx, edx ;limpio el edx para usarlo como setter de stats
	xor ecx, ecx; limpio el ecx para usarlo como contador
;limpia comando
.comando:
	mov al, byte[comando+ecx]; muevo del bufer al al el byte actual
	cmp al, dl;comparo con null
	je .archivo; si no es null, es porque tiene basura. Brinque si no tiene basura
	mov byte[comando+ecx], dl;muevo un null al buffer
	inc ecx ;incremento el contador
	jmp .comando;siga el ciclo
;limpiar archivo
.archivo:
	xor ecx, ecx; limpio el ecx para usarlo como contador
	.sub:
	mov al, byte[archivo+ecx]; muevo del bufer al al el byte actual
	cmp al, dl;comparo con null
	je .archivo2; si no es null, es porque tiene basura. Brinque si no tiene basura
	mov byte[archivo+ecx], dl;muevo un null al buffer
	inc ecx;incremento el contador
	jmp .sub;siga el ciclo
;limpiar archivo2
.archivo2:
	xor ecx, ecx; limpio el ecx para usarlo como contador
	.sub1:
	mov al, byte[archivo2+ecx]; muevo del bufer al al el byte actual
	cmp al, dl;comparo con null
	je .archivo3; si no es null, es porque tiene basura. Brinque si no tiene basura
	mov byte[archivo2+ecx], dl;muevo un null al buffer
	inc ecx;incremento el contador
	jmp .sub1;siga el ciclo
;limpiar archivo3
.archivo3: 
	xor ecx, ecx; limpio el ecx para usarlo como contador
	.sub2:
	mov al, byte[archivo3+ecx]; muevo del bufer al al el byte actual
	cmp al, dl;comparo con null
	je _start ; si no es null, es porque tiene basura.Inicie nuevamente el programa (parecido a un while true) si esta limpio
	mov byte[archivo3+ecx], dl;muevo un null al buffer
	inc ecx;incremento el contador
	jmp .sub2;siga el ciclo
	
;fin del programa
; paso al eax 1 y ebx 0 y me salgo con la llamada al sistema
Fin:
	mov eax, sys_exit
	mov ebx, 0
	int 80h
;funcion que imprime el mensaje de ayuda para comando ayuda
mensajeAyudaMostrar:
	mov eax, ayudacomando; saco al eax el nombre del archivo
	mov ebx, eax; lo paso al ebx
	mov	ecx, 0; read and write mode
	mov	eax,sys_open; llamada al sistema
	int	80h		
	push eax;salvo en la pila este FD
	call Muestra; llamo a la subrutina de mostrar
	pop ebx	; saco de la pila ese FD
	call Cerrar ; llamo a cerrar el archivo para que no quede abierto
	jmp Limpiar; brinco a limpiar los buffers; iniacia nuevamente el programa (parecido a un while true)
	
	
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
	mov	ebx, eax; paso al ebx el FD
	mov	ecx, archivo2; paso el puntero del buffer con el archivo
	mov	edx, archivoLen2; y su len correspondiente
	mov	eax, sys_read; y llamo a read de dicho archivo
	int 80h		
	;Una vez leido lo imprimo en consola por medio del DisplayText
	mov edx, archivoLen2
	mov ecx, archivo2
	call DisplayText	
	ret

;Subrutina que cierrra un archivo abierto
Cerrar:
	mov eax, sys_close; solamente se llama a la llamada del sistema sys_close
	int 80h
	ret
