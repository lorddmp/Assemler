.model tiny
.code
org 100h

Start:			
			push 0
			pop es
			cli
			mov bx, 09h*4
			mov es:[bx], offset New09
			mov ax, cs
			mov es:[bx+2], ax
			sti
			mov ax, 3100h
			mov dx, offset EndOfProgram
			shr dx, 4
			inc dx
			int 21h
;--------------------------------------------------------------------------------
New09		proc
			push ax bx es

			push 0b800h
			pop es

			mov bx, (5*80+40)*2
			mov ah, 4eh

			in al, 60h
			mov es:[bx], ax			

			in al, 61h
			or al, 80h
			out 61h, al
			and al, not 80h
			out 61h, al
			
			mov al, 20h
			out 20h, al
			pop es bx ax
			iret
			endp
EndOfProgram:
end			Start