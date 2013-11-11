; Proyecto de arquitectura de computadores
; Integrantes : Gustavo Gonzalez y Andres Campos

;;;;;;poner comentarios;
; Esto es para hacer el codigo mas legible

sys_exit        equ     1
sys_read        equ     3
sys_write       equ     4
sys_open		equ		5
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

msj: db "james@aguacate.console>>>  "
len: equ $-msj

msjError: db "No se reconoce el comando",10
errorLen: equ $-msjError

salir: db "salir"
salirLen: equ $-salir

mostrar: db "mostrar"
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
	
	
	;mov ecx, 0
	;dec eax
	
;cicloAux:

;	mov	dl, byte [comando + ecx]
;	inc	ecx		
;	cmp	ecx, eax		
;	jne	cicloAux
;	inc ecx
;	mov byte [comando + ecx], 0

	mov ecx, 0;muevo al ecx un cero que me servira de contador de digitos
	;dec eax; en el eax queda la cantidad de digitos leidos, incluido el ENTER, 
		   ; asi que decremento en uno para quitar el ENTER y que me quede solo la cantidad de caracteres leidos
		   
;ciclo principal de la funcion	
cicloMostrar:
	mov eax, 7
	mov	dl, byte [comando + ecx]
	cmp	dl, byte [mostrar + ecx]
	jne cicloSalir
	inc		ecx		
	cmp		ecx, eax
	je Show
	jmp     cicloMostrar
	
Show:
	mov		ebx, archivoPin
	mov		ecx, 0		
	mov		eax,sys_open
	int		80h		
	push eax
	call Muestra
	pop ebx
	call Cerrar
	jmp _start
	
cicloSalir:
	mov eax, 5
	mov	dl, byte [comando + ecx]
	cmp	dl, byte [salir + ecx]
	jne mensajeError
	inc		ecx		
	cmp		ecx, eax
	je 		Fin
	jmp     cicloSalir
	

mensajeError:
	mov edx, errorLen    
	mov ecx, msjError
	call DisplayText
	
	jmp _start
	
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
    
Muestra:
	;mov		ebx, archivoPin
	;mov		ecx, 0		
	;mov		eax,sys_open
	;int		80h		
	

	test	eax, eax
	js	mensajeError

; Leo el pin del archivo
	mov		ebx, eax
	mov		ecx, archivo
	mov		edx, archivoLen
	mov		eax, sys_read				
	int 	80h		
	
	mov edx, archivoLen
	mov ecx, archivo 
	call DisplayText	
	ret
	
Cerrar:
	mov eax, 6
	int 80h
	ret
