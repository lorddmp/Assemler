.model tiny
.code
org 100h

Start:			push 0							;segment 0
				pop es				
				cli								;stop interruptions

				mov bx, 08*4h
				mov ax, es:[bx]
				mov cs:old_off_08, ax				
				mov es:[bx], offset Proga_08
												;save and repare 08h
				mov ax, es:[bx+2]				
				mov cs:old_seg_08, ax
				mov ax, cs
				mov es:[bx+2], ax			

				mov bx, 09*4h
				mov ax, es:[bx]
				mov cs:old_off_09, ax				
				mov es:[bx], offset Proga_09
												;save and repare 09h
				mov ax, es:[bx+2]			
				mov cs:old_seg_09, ax
				mov ax, cs
				mov es:[bx+2], ax				
				sti

				mov ax, 3100h					;func to exit and save
				mov dx, offset EndProg			;size of prog
				shr dx, 4
				inc dx
				int 21h

flag_main db 0
hot_key1_code equ 02h
hot_key2_code equ 03h
left_high_ang equ 63*2
left_low_ang equ (80*14+63)*2
ramka_length equ 14h

hex_mas db '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'
reg_mas db 'A','X','B','X','C','X','D','X','S','I','D','I','B','P','S','P','D','S','E','S','S','S','C','S','I','P'
val_mas dw 100 dup (0)

Proga_09		proc								;main function

				mov cs: word ptr val_mas[0],  ax
				mov cs: word ptr val_mas[2],  bx

				xor ax, ax
				in al, 60h							;read symbol

				cmp al, hot_key1_code
				jne .key2_check

				mov cs:flag_main, 1h
				jmp .ret_9h

.key2_check:	cmp al, hot_key2_code
				jne .exit_as_usual

				mov cs:flag_main, 0h

.ret_9h:		mov ax, cs: word ptr val_mas[0]
				mov bx, cs: word ptr val_mas[2]

				in al, 61h			
				or al, 80h  						;Work with
				out 61h, al							;61h and 20h to end
				and al, not 80h						;working correctly
				out 61h, al
				mov al, 20h
				out 20h, al

				iret

.exit_as_usual:	
				mov ax, cs: word ptr val_mas[0]
				mov bx, cs: word ptr val_mas[2]

				db 0eah								;jmp far
				old_off_09 dw 0
				old_seg_09 dw 0
				endp

Proga_08      	proc

				mov cs: word ptr val_mas[0],  ax
				mov cs: word ptr val_mas[2],  bx
				mov cs: word ptr val_mas[4],  cx
				mov cs: word ptr val_mas[6],  dx
				mov cs: word ptr val_mas[8],  si
				mov cs: word ptr val_mas[10], di
				mov cs: word ptr val_mas[12], bp
				mov cs: word ptr val_mas[14], sp
				mov cs: word ptr val_mas[16], ds
				mov cs: word ptr val_mas[18], es
				mov cs: word ptr val_mas[20], ss
				mov cs: word ptr val_mas[22], cs

				mov bx, sp
				mov ax, ss: word ptr [bx]
				mov cs: word ptr val_mas[24], ax

				cmp cs:flag_main, 1h
				je .make_ramka

				jmp .exit_exit

				endp

.make_ramka:	
				push 0b800h
				pop es

				mov bx, left_high_ang 
				mov es: word ptr [bx], 4ec9h		;set left up angle

				add bx, ramka_length 
				mov es: word ptr [bx], 4ebbh		;set right up angle
	
				mov bx, left_low_ang 
				mov es: word ptr [bx], 4ec8h		;set left low angle

				add bx, ramka_length 
				mov es: word ptr [bx], 4ebch		;set right low angle

				mov cx, 9h

Cycle1:			
				mov bx, cx
				shl bx, 1h
				add bx, left_high_ang
				mov es: word ptr [bx], 4ecdh		;set up horizontal borders
				mov bx, cx
				shl bx, 1h
				add bx, left_low_ang
				mov es: word ptr [bx], 4ecdh		;set low horizontal borders
				loop Cycle1

				mov cx, 0dh

Cycle2:			
				mov bx, cx
				mov ax, 0a0h
				mul bx
				mov bx, ax
				add bx, left_high_ang
				mov es: word ptr [bx], 4ebah		;set left vertical borders
				add bx, ramka_length
				mov es: word ptr [bx], 4ebah		;set  right vertical borders
				loop Cycle2

				mov bx, left_high_ang
				add bx, 0a2h
				mov cx, 0dh							;prepare to next cycle
				xor si, si

.print_regs:		
				mov ah, 4eh
				mov al, cs:reg_mas[si]
				mov es: word ptr [bx], ax	
				mov al, cs:reg_mas[si+1]			;print names of registers
				mov es: word ptr [bx+2], ax
				mov al, ' '
				mov es: word ptr [bx+4], ax
				mov al, '='
				mov es: word ptr [bx+6], ax
				mov al, ' '
				mov es: word ptr [bx+8], ax
				add si, 2h
				add bx, 0a0h
				loop .print_regs

				mov cx, 0dh
				mov bx, left_high_ang
				add bx, 0ach
				xor si, si

.print_vals:	
				mov di, cs: word ptr val_mas[si]

				push cx
				mov cx, 4h

.inner_cycle:	
				rol di, 4h
				mov dx, di
				and di, 0fh
				mov al, cs: byte ptr hex_mas[di]
				mov ah, 4eh
				mov es: word ptr [bx], ax
				add bx, 2h
				mov di, dx

				loop .inner_cycle

				pop cx
				add bx, 98h
				add si, 2h

				loop .print_vals

				jmp Correct_end

Correct_end:		
				mov cx, cs: word ptr val_mas[4]		;bring back registers
				mov dx, cs: word ptr val_mas[6]
				mov si, cs: word ptr val_mas[8]
				mov di, cs: word ptr val_mas[10]
				mov bp, cs: word ptr val_mas[12]
				mov sp, cs: word ptr val_mas[14]
				mov ds, cs: word ptr val_mas[16]
				mov es, cs: word ptr val_mas[18]
				mov ss, cs: word ptr val_mas[20]

.exit_exit:	
				mov ax, cs: word ptr val_mas[0]
				mov bx, cs: word ptr val_mas[2]
				db 0eah
				old_off_08 dw 0
				old_seg_08 dw 0

				endp

EndProg:
end				Start