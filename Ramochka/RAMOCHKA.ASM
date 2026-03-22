ё.model tiny
.code
org 100h

Start:			mov ax, 0b800h
			mov es, ax  
			mov dx, 0h
			mov al, ds: byte ptr [80h]	;get length
			mov ah, 0h
			sub ax, 1h

			mov bx, ax
			sar bx, 1h			;find otstup
			sal bx, 1h
			mov di, 50h
			sub di, bx
			mov bx, di	

			mov si, ax			;it's more comfortable
			add si, 1h
			sal si, 1h
				 
			add bx, 0780h
			mov es: word ptr [bx], 12c9h
			add bx, si
			mov es: word ptr [bx], 12bbh
			add bx, 140h
			mov es: word ptr [bx], 12bch
			sub bx, si
			mov es: word ptr [bx], 12c8h

			mov cx, ax
			sub bx, 140h
			mov di, bx 	;remember adr high_left_angle
			add bx, 2h	;take place after high left angle
			
							
Cycle1:			mov es: word ptr [bx], 12cdh
			mov dx, bx
			add bx, 140h
			mov es: word ptr [bx], 12cdh
			mov bx, dx
			add bx, 2h
			loop Cycle1
		
			mov cx, 1h			
			mov bx, di
			add bx, 0a0h

Cycle2:			mov es: word ptr [bx], 12bah
			mov dx, bx
			add bx, si
			mov es: word ptr [bx], 12bah
			mov bx, dx
			add bx, 0a0h
			loop Cycle2

			mov cx, ax
			mov bx, 82h
			mov si, di
			add si, 0a2h 

Cycle3: 		mov dl, ds:byte ptr [bx]
			mov es: byte ptr [si], dl
			add si, 1h
			mov es: byte ptr [si], 97h
			add si, 1h
			add bx, 1h
			loop Cycle3
	
			mov ax, 4c00h
			int 21h
end			Start		
