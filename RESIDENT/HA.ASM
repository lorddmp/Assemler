.model tiny
.code
org 100h

Start:			push ax bx cx dx
			xor ax, ax
			mov cx, 0ffffh

.prikol:		inc ax
			loop .prikol			

			pop dx cx bx ax
			
			mov ax, 4c00h
			int 21h
end			Start