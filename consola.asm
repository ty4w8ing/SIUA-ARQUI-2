; Proyecto de arquitectura de computadores
; Integrantes : Gustavo Gonzalez y Andres Campos

;;;;;;poner comentarios;
; Esto es para hacer el codigo mas legible

sys_exit equ 1
sys_read equ 3
sys_write equ 4
sys_open equ 5
sys_close equ 6
sys_link equ 9
sys_unlink equ 10
sys_rename equ 38
stdin equ 0
stdout equ 1

;seccion de datos no inicializados
section .bss 	
	comandoLen equ 100; buffer que recibe el comando de usuario
	comando resb comandoLen
	
	forzarLen equ 32;
	forzar resb forzarLen;
	
	comando2Len equ 15000
	comando2 resb comando2Len
	 
	archivoLen equ 100	;buffer que recibe el nombre del archivo 
	archivo resb archivoLen
	archivoLen2 equ 15000	;buffer que recibe el archivo 
	archivo2 resb archivoLen2
	archivoLen3 equ 15000	;buffer que recibe el archivo anexo
	archivo3 resb archivoLen3
	
	cantidadDiferenciasLen equ 2
	cantidadDiferencias resb cantidadDiferenciasLen
	
	buflen equ 25
	buffer resb buflen
		
;seccion de datos inicializados
section .data

msj: db "james@aguacate.console>>>  " ;mensaje de cabecera en consola
len: equ $-msj

msjExitoso: db "Copiado exitoso",10 ;mensaje de cabecera en consola
lenex: equ $-msjExitoso

msjExitosoB: db "Borrado exitoso",10 ;mensaje de cabecera en consola
lenexB: equ $-msjExitosoB

msjFallido: db "Copiado Fallido",10 ;mensaje de cabecera en consola
lenfail: equ $-msjFallido

msjFallidoB: db "Borrado Fallido",10 ;mensaje de cabecera en consola
lenfailB: equ $-msjFallidoB

msjError: db "No se reconoce el comando",10 ;mensaje de error en caso de que no se reconozca
errorLen: equ $-msjError					;un comando

msjError2: db "No se pudo abrir el archivo",10 ;mensaje de error en caso de que no abra
errorLen2: equ $-msjError2					;un archivo

msjError3: db "Digite 2 variables para este comando",10;mensaje de error en caso de que solo de una variable (2 requeridas)
errorLen3: equ $-msjError3

handicap: db "Desea ejecutar este comando?(Y/N)",10
handicapLen: equ $-handicap

;comandos para comprar
salir: db "salir";texto para usar de comparación para el comando salir
mostrar: db "mostrar";texto para usar de comparación para el comando mostrar
copiar: db "copiar"
borrar: db "borrar"
comparar: db "comparar"
renombrar: db "renombrar";texto para usar de comparación para el comando renombrar
ayuda: db "--ayuda";texto para usar de comparación para el comando --ayuda

forzado: db "--forzado";texto para usar de comparación para el comando --forzado
Y: db "Y"
N: db "N"

msjCompara: db "Diferencias en las siguientes lineas: "
msjComparaLen: equ $-msjCompara

msjNiuna: db "ninguna linea, son iguales",10
msjNiunaLen: equ $-msjNiuna

; comando para abrir ayuda
ayudamostrar: db "mostrar.ayuda.txt",0
ayudarenombrar: db "renombrar.ayuda.txt",0
ayudacopiar: db "copiar.ayuda.txt",0
ayudaborrar: db "borrar.ayuda.txt",0
ayudacomparar: db "comparar.ayuda.txt",0

enter: db 10
enterLen: equ $-enter

espacio: db 32
espacioLen: equ $-espacio
   
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
		   
cicloMostrar:
	mov eax, 7;cantidad de digitos maxima de mostrar
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [mostrar + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne cicloRenombrar; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je Show; si son iguales valla a mostrar el archivo
	jmp cicloMostrar; si no siga el ciclo
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
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
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

cicloRenombrar:
	mov ecx, 0; contador en cero
	.rsub:
	mov eax, 9; cantidad de digitos de renombrar
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [renombrar + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne cicloCopiar; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je Rename; si son iguales valla a mostrar el archivo
	jmp .rsub; si no siga el ciclo
	  
Rename:
	mov eax, 7;   
	mov ecx, 10;muevo al ecx un 10 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0
.ayuda:
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [ayuda + ebx]; comparo con lo mismo pero en el texto de comparacion
	jne .sub_; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	inc ebx
	cmp	ebx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je mensajeAyudaMostrar; si son iguales valla mostrar mensaje de ayuda
	jmp .ayuda; si no siga el ciclo
	
.sub_:
	mov ecx, 10; muevo al ecx un 10 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0; muevo un 0 al ebx que sirve de contador
.sub:	
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 20h;comparo a ver si ya termine con espacio
	je .sub2;si hay un espacio pase a analizar y abrir
	cmp al, 0h;me fijo a ver si es null el bit
	je mensajeError3;si lo es hay un error al digitar ya que solo digito un nombre y no dos
	mov byte[archivo+ebx], al;si no es null, mueva el byte al buffer del nombre del archivo
	inc ecx;incremento los contadores
	inc ebx
	jmp .sub;regreso al ciclo
.sub2:

	mov byte[archivo+ecx],0h; paso un null
	xor ebx, ebx
	inc ecx;paso del espacio al siguiente digito
.sub3:
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 0h;comparo a ver si ya termine con un espacio
	je .sub4;si es null pase a analizar y abrir
	cmp al, 20h
	je .sub6
	mov byte[archivo2+ebx], al;si no es null, mueva el byte al buffer del nombre del archivo
	inc ecx;incremento los contadores
	inc ebx
	jmp .sub3;regreso al ciclo

;#Forzado
.sub4:
	mov byte[archivo2+ecx],0h; paso un null
.sub5:
	call Handicap;Se llama al handicap subrutina encargada de preguntar si esta seguro del comando
	mov eax, sys_rename;muevo la llamada 38 de rename
	mov ebx, archivo ; muevo al ebx el primer parametro: nombre viejo
	mov ecx, archivo2; muevo al ecx el segundo parametro: nombre nuevo
	int 80h
	cmp eax, 0
	je  .copiadoExitoso
	mov edx, lenfail
	mov ecx, msjFallido
	call DisplayText
	jmp Limpiar

;#Sin Forzado
.sub6:
	mov byte[archivo2+ecx],0h; paso un null
.sub7:	
	mov eax, sys_rename;muevo la llamada 38 de rename
	mov ebx, archivo ; muevo al ebx el primer parametro: nombre viejo
	mov ecx, archivo2; muevo al ecx el segundo parametro: nombre nuevo
	int 80h
	cmp eax, 0
	je  .copiadoExitoso
	mov edx, lenfail
	mov ecx, msjFallido
	call DisplayText
	jmp Limpiar
	
.copiadoExitoso:
	mov edx, lenex
	mov ecx, msjExitoso
	call DisplayText
	jmp Limpiar
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cicloCopiar:
	mov ecx, 0; contador en cero
	.rsub:
	mov eax, 6; cantidad de digitos de renombrar
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [copiar + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne cicloBorrar; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je Copy; si son iguales valla a mostrar el archivo
	jmp .rsub; si no siga el ciclo
	  
Copy:
	mov eax, 7;   
	mov ecx, 7;muevo al ecx un 10 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0
.ayuda:
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [ayuda + ebx]; comparo con lo mismo pero en el texto de comparacion
	jne .sub_; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	inc ebx
	cmp	ebx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je mensajeAyudaCopy; si son iguales valla mostrar mensaje de ayuda
	jmp .ayuda; si no siga el ciclo
.sub_:
	mov ecx, 7; muevo al ecx un 10 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0; muevo un 0 al ebx que sirve de contador
.sub:	
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 20h;comparo a ver si ya termine con espacio
	je .sub2;si hay un espacio pase a analizar y abrir
	cmp al, 0h;me fijo a ver si es null el bit
	je mensajeError3;si lo es hay un error al digitar ya que solo digito un nombre y no dos
	mov byte[archivo+ebx], al;si no es null, mueva el byte al buffer del nombre del archivo
	inc ecx;incremento los contadores
	inc ebx
	jmp .sub;regreso al ciclo
.sub2:
	mov byte[archivo+ecx],0h; paso un null
	xor ebx, ebx
	inc ecx;paso del espacio al siguiente digito
.sub3:
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 0h;comparo a ver si ya termine con un espacio
	je .sub4;si es null pase a analizar y abrir
	mov byte[archivo2+ebx], al;si no es null, mueva el byte al buffer del nombre del archivo
	inc ecx;incremento los contadores
	inc ebx
	jmp .sub3;regreso al ciclo	
.sub4:
	mov byte[archivo2+ecx],0h; paso un null
.sub5:	
	mov eax, sys_link;muevo la llamada 38 de rename
	mov ebx, archivo ; muevo al ebx el primer parametro: nombre viejo
	mov ecx, archivo2; muevo al ecx el segundo parametro: nombre nuevo
	int 80h
	cmp eax, 0
	je  .copiadoExitoso
	mov edx, lenfail
	mov ecx, msjFallido
	call DisplayText
	jmp Limpiar
	
.copiadoExitoso:
	mov edx, lenex
	mov ecx, msjExitoso
	call DisplayText
	jmp Limpiar
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cicloBorrar:
	mov eax, 6;cantidad de digitos maxima de mostrar
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [borrar + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne cicloComparar; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je Erase; si son iguales valla a mostrar el archivo
	jmp cicloBorrar; si no siga el ciclo
;muestra el archivo leido
Erase:
	mov ecx, 7; muevo al ecx un 8 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0; muevo un 0 al ebx que sirve de contador
.sub:	
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 0h;comparo a ver si ya termine con null
	je .sub2;si es null pase a analizar y abrir
	cmp al, 20h
	je .sub5
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
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je mensajeAyudaErase; si son iguales valla mostrar mensaje de ayuda
	jmp .sub3; si no siga el ciclo
	
;#Con Forzado	
.sub4:	
	call Handicap
	mov eax, sys_unlink
	mov ebx, archivo
	int 80h
	cmp eax, 0
	je  .BorradoExitoso
	mov edx, lenfailB
	mov ecx, msjFallidoB
	call DisplayText
	jmp Limpiar
	
.sub5:
	mov eax, 7;cantidad de digitos maxima de --ayuda
	mov ecx, 0; contador en cero

;# Sin forzado
.sub6:
	mov	dl, byte [archivo + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [ayuda + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne .sub7; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je mensajeAyudaErase; si son iguales valla mostrar mensaje de ayuda
	jmp .sub6; si no siga el ciclo
	
.sub7:	
	mov eax, sys_unlink
	mov ebx, archivo
	int 80h
	cmp eax, 0
	je  .BorradoExitoso
	mov edx, lenfailB
	mov ecx, msjFallidoB
	call DisplayText
	jmp Limpiar
	
.BorradoExitoso:
	mov edx, lenexB
	mov ecx, msjExitosoB
	call DisplayText
	jmp Limpiar

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cicloComparar:
	mov ecx, 0; contador en cero
	.rsub:
	mov eax, 8; cantidad de digitos de renombrar
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [comparar + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne cicloSalir; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je Equals; si son iguales valla a mostrar el archivo
	jmp .rsub; si no siga el ciclo
	  
Equals:
	mov eax, 7;   
	mov ecx, 9;muevo al ecx un 10 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0
.ayuda:
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [ayuda + ebx]; comparo con lo mismo pero en el texto de comparacion
	jne .sub_; si no son iguales pase al otro comando
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	inc ebx
	cmp	ebx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je mensajeAyudaCompare; si son iguales valla mostrar mensaje de ayuda
	jmp .ayuda; si no siga el ciclo
.sub_:
	mov ecx, 9; muevo al ecx un 10 que sirve de puntero a la siguiente texto, en este caso el nombre del archivo
	mov ebx, 0; muevo un 0 al ebx que sirve de contador
.sub:	
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 20h;comparo a ver si ya termine con espacio
	je .sub2;si hay un espacio pase a analizar y abrir
	cmp al, 0h;me fijo a ver si es null el bit
	je mensajeError3;si lo es hay un error al digitar ya que solo digito un nombre y no dos
	mov byte[archivo+ebx], al;si no es null, mueva el byte al buffer del nombre del archivo
	inc ecx;incremento los contadores
	inc ebx
	jmp .sub;regreso al ciclo
.sub2:
	mov byte[archivo+ecx],0h; paso un null
	xor ebx, ebx
	inc ecx;paso del espacio al siguiente digito
.sub3:
	mov al, byte[comando+ecx];muevo al al el byte actual del comando
	cmp al, 0h;comparo a ver si ya termine con un espacio
	je .sub4;si es null pase a analizar y abrir
	mov byte[archivo2+ebx], al;si no es null, mueva el byte al buffer del nombre del archivo
	inc ecx;incremento los contadores
	inc ebx
	jmp .sub3;regreso al ciclo	
.sub4:
	mov byte[archivo2+ecx],0h; paso un null
.sub5:	
;PRIMER ARCHIVO
	mov eax, sys_open
	mov ebx, archivo
	mov ecx, 2
	int 80h
	push eax
	test eax, eax ; primero nos aseguramos que abrio bien
	js	mensajeError2; no es asi? imprime mensaje de errorLen
	mov	ebx, eax; paso al ebx el FD
	mov	ecx, comando2; paso el puntero del buffer con el archivo
	mov	edx, comando2Len; y su len correspondiente
	mov	eax, sys_read; y llamo a read de dicho archivo
	int 80h		
	pop ebx
	call Cerrar
;SEGUNDO ARCHIVO
	mov eax, sys_open
	mov ebx, archivo2
	mov ecx, 2
	int 80h
	push eax
	test eax, eax ; primero nos aseguramos que abrio bien
	js	mensajeError2; no es asi? imprime mensaje de errorLen
	mov	ebx, eax; paso al ebx el FD
	mov	ecx, archivo3; paso el puntero del buffer con el archivo
	mov	edx, archivoLen3; y su len correspondiente
	mov	eax, sys_read; y llamo a read de dicho archivo
	int 80h		
	pop ebx
	call Cerrar
	;imprimo a continuación la frase de comparar
	mov edx, msjComparaLen
	mov ecx, msjCompara
	call DisplayText


	xor ecx, ecx;contador en cero
	xor edx, edx;contador en cero
	mov ebx, 1;contador en uno... Simulando la linea actual del texto
CicloComparador:
	mov al, byte[comando2+ecx] ;muevo al al el byte a comparar en el primer archivo
	cmp al, byte[archivo3+edx] ;comparo AL con el byte a comparar en el segundo archivo
	jne .avanzarLinea; si no son iguales hay que avanzar a la siguiente linea
	inc ecx; si son iguales imcremento los contadores para avanzar al siguente bit
	inc edx
	cmp al, 0h;si el bit que analizamos y sabemos q es igual en ambos archivos es null
	je fin;brinco a fin
	cmp al, 10 ;si el bit que analizamos y sabemos q es igual en ambos archivos es cambio de linea
	je .avanzarLineaP;brinco a avanzar linea (bien)
	jmp CicloComparador
.avanzarLineaP:
	inc bl	;aca incremento el numero de linea
	jmp CicloComparador; y sigo analizando
.avanzarLinea:
	push eax;salvo cada registro para no perderlo
	push ecx
	push edx
	push ebx
	
	;Aca imprimo la linea actual del archivo. Solo entro aca si hay diferencias en algun archivo
	mov eax, ebx;paso al eax el numero de linea actual
	lea esi,[cantidadDiferencias];utilizo el esi para guardar el address del buffer
	call int_to_string;llamo a la funcion que pasa de enteros a string
	;imprimo el string de la linea actual
	mov [cantidadDiferencias], eax
	mov edx, cantidadDiferenciasLen
	mov ecx, eax
	call DisplayText
	;imprimo un espacio en blanco (para no confundir 1 y 2 con 12)
	mov edx, espacioLen
	mov ecx, espacio
	call DisplayText
	;retorno a cada registro los valores que tenian salvados previamente
	pop ebx
	pop edx
	pop ecx
	pop eax
.sub1: ;subrutina que avanza el contador del primer archivo a la siguiente linea
	cmp al, 0h;comparo el bit actual con null
	je fin; si es igual salga
	cmp al, 10;comparo cel bit actual con cambio de linea
	je .sub2;si es igual ya avanzamos al final y pasamos al otro archivo
	inc ecx;si no son iguales incremento el ecx
	mov al, byte[comando2+ecx];muevo al al el siguiente bit
	jmp .sub1;vovemos a comparar
.sub2:
	cmp byte[archivo3+edx], 0h;comparo el bit actual con null
	je fin; si es igual salga
	cmp byte[archivo3+edx], 10;comparo cel bit actual con cambio de linea
	je CicloComparador;si es igual ya avanzamos al final y pasamos a analizar la siguiente linea
	inc edx;paso al bit siguiente
	jmp .sub2; volvemos a comparar
fin:
	pop ebx;limpiar pila para q no de problemas
	cmp byte[cantidadDiferencias], 0h;comparo a ver si se utilizo el buffer de diferencias con null
	je .niuna; es es igual a null es porque no se uso, por consiguiente los archivos son iguales
	mov edx, enterLen;imprimo un enter por estetica
	mov ecx, enter
	call DisplayText
	jmp Limpiar
.niuna:
	;imprimo que son iguales
	mov edx, msjNiunaLen
	mov ecx, msjNiuna
	call DisplayText
	jmp Limpiar;brincamos a limpiar los buffers
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;ciclo que revisa lo digitado por el usuario y si este digita salir, se sale del programa
cicloSalir:
	mov eax, 5;cantidad de digitos maxima de salir
	mov	dl, byte [comando + ecx]; si es igual muevo al dl el byte numero ecx(contador) de lo digitado 
	cmp	dl, byte [salir + ecx]; comparo con lo mismo pero en el texto de comparacion
	jne mensajeError; si no son iguales salgo al mensaje de error
	inc	ecx	; si son iguales, incremento el ecx para pasar al otro digito
	cmp	ecx, eax; comparo el contador con la cantidad de digitos maxima a comparar
	je Fin; si son iguales brinque a salir
	jmp cicloSalir; no son iguales siga el ciclo
	
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
	
mensajeError3:
	mov edx, errorLen3; muevo al edx el len del tamaño del mensaje de error
	mov ecx, msjError3; muevo al ecx el puntero del mensaje
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
	je .archivo4 ; si no es null, es porque tiene basura.Inicie nuevamente el programa (parecido a un while true) si esta limpio
	mov byte[archivo3+ecx], dl;muevo un null al buffer
	inc ecx;incremento el contador
	jmp .sub2;siga el ciclo
;limpiar archivo4
.archivo4: 
	xor ecx, ecx; limpio el ecx para usarlo como contador
	.sub3:
	mov al, byte[archivo3+ecx]; muevo del bufer al al el byte actual
	cmp al, dl;comparo con null
	je .archivo5 ; si no es null, es porque tiene basura.Inicie nuevamente el programa (parecido a un while true) si esta limpio
	mov byte[archivo3+ecx], dl;muevo un null al buffer
	inc ecx;incremento el contador
	jmp .sub3;siga el ciclo
;limpiar archivo5
.archivo5: 
	xor ecx, ecx; limpio el ecx para usarlo como contador
	.sub4:
	mov al, byte[cantidadDiferencias+ecx]; muevo del bufer al al el byte actual
	cmp al, dl;comparo con null
	je _start ; si no es null, es porque tiene basura.Inicie nuevamente el programa (parecido a un while true) si esta limpio
	mov byte[cantidadDiferencias+ecx], dl;muevo un null al buffer
	inc ecx;incremento el contador
	jmp .sub4;siga el ciclo

	
;fin del programa
; paso al eax 1 y ebx 0 y me salgo con la llamada al sistema
Fin:
	mov eax, sys_exit
	mov ebx, 0
	int 80h
;funcion que imprime el mensaje de ayuda para comando ayuda
mensajeAyudaMostrar:
	mov eax, ayudamostrar; saco al eax el nombre del archivo
	mov ebx, eax; lo paso al ebx
	mov	ecx, 0; read mode
	mov	eax,sys_open; llamada al sistema
	int	80h		
	push eax;salvo en la pila este FD
	call Muestra; llamo a la subrutina de mostrar
	pop ebx	; saco de la pila ese FD
	call Cerrar ; llamo a cerrar el archivo para que no quede abierto
	jmp Limpiar; brinco a limpiar los buffers; iniacia nuevamente el programa (parecido a un while true)

mensajeAyudaRename:
	mov eax, ayudarenombrar; saco al eax el nombre del archivo
	mov ebx, eax; lo paso al ebx
	mov	ecx, 0; read mode
	mov	eax,sys_open; llamada al sistema
	int	80h		
	push eax;salvo en la pila este FD
	call Muestra; llamo a la subrutina de mostrar
	pop ebx	; saco de la pila ese FD
	call Cerrar ; llamo a cerrar el archivo para que no quede abierto
	jmp Limpiar; brinco a limpiar los buffers; iniacia nuevamente el programa (parecido a un while true)
	
mensajeAyudaCopy:
	mov eax, ayudacopiar; saco al eax el nombre del archivo
	mov ebx, eax; lo paso al ebx
	mov	ecx, 0; read mode
	mov	eax,sys_open; llamada al sistema
	int	80h		
	push eax;salvo en la pila este FD
	call Muestra; llamo a la subrutina de mostrar
	pop ebx	; saco de la pila ese FD
	call Cerrar ; llamo a cerrar el archivo para que no quede abierto
	jmp Limpiar; brinco a limpiar los buffers; iniacia nuevamente el programa (parecido a un while true)

mensajeAyudaErase:
	mov eax, ayudaborrar; saco al eax el nombre del archivo
	mov ebx, eax; lo paso al ebx
	mov	ecx, 0; read mode
	mov	eax,sys_open; llamada al sistema
	int	80h		
	push eax;salvo en la pila este FD
	call Muestra; llamo a la subrutina de mostrar
	pop ebx	; saco de la pila ese FD
	call Cerrar ; llamo a cerrar el archivo para que no quede abierto
	jmp Limpiar; brinco a limpiar los buffers; iniacia nuevamente el programa (parecido a un while true)
	
mensajeAyudaCompare:
	mov eax, ayudacomparar; saco al eax el nombre del archivo
	mov ebx, eax; lo paso al ebx
	mov	ecx, 0; read mode
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
    mov ebx, stdin
    mov eax, sys_read
    int 80H
    ret
 
;subrutina que muestra el contenido interno de un archivo 
Muestra:
	test eax, eax ; primero nos aseguramos que abrio bien
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

;http://stackoverflow.com/questions/19309749/nasm-assembly-convert-input-to-integer
int_to_string:
	push esi
	add esi,9
	mov byte [esi],0
	mov ebx,10         
.next_digit:
	xor edx,edx         ; Clear edx prior to dividing edx:eax by ebx
	div ebx             ; eax /= 10
	add dl,'0'          ; Convert the remainder to ASCII 
	dec esi             ; store characters in reverse order
	mov [esi],dl
	test eax,eax            
	jnz .next_digit     ; Repeat until eax==0
	mov eax,esi
	pop esi
	ret

;subrutina que me pregunta si quiero hacer una accion
Handicap:
	mov edx,handicapLen
	mov ecx,handicap
	call DisplayText
	;leo de usuario
	mov edx,forzarLen
	mov ecx,forzar
	call ReadText
	
	mov al, byte[forzar]
	cmp al, byte[Y];comparo lo que dice el usuaro (y/n)
	je .sal; si es igual a Y salgo
	mov al, byte[forzar]
	cmp al, byte[N];comparo lo que dice el usuaro (y/n)
	je Limpiar; si es igual a N no realizo la accion y voy a limpiar
	jmp Handicap;ciclo que me indica q el usuario no puso Y o N
.sal:
	ret
	


