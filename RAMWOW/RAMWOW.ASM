.model tiny
.code
org 100h

Start:			push 0				;segment 0
			pop es				
			cli				;stop interruptions
			mov bx, 09*4h
			mov ax, es:[bx]
			mov cs:old_off, ax		;save old offset
			mov es:[bx], offset Proga	;smeschenie - gde code
			
			mov ax, es:[bx+2]		;save old segment
			mov cs:old_seg, ax
			mov ax, cs
			mov es:[bx+2], ax		;segment = segment code
			sti
			
			mov ax, 3100h			;func to exit and save
			mov dx, offset EndProg		;size of prog
			shr dx, 4
			inc dx
			int 21h

esc_code equ 01h
shift_code equ 2ah
backspace_code equ 0eh

hot_key_flag db 0

old_seg dw 0
old_off dw 0
position dw 0
shift db 0
old_symbol dw 0
mas_symb_low 	db 0,0,'1','2','3','4','5','6','7','8','9','0','-','='
		db 0,0,'q','w','e','r','t','y','u','i','o','p','[',']'
		db 0,0,'a','s','d','f','g','h','j','k','l',';',"'", '`'
		db 0,'\','z','x','c','v','b','n','m',',','.','/',0,0,0,' '

mas_symb_up   	db 0,0,'!','@','#','$','%','^','&','*','(',')','_','+'
		db 0,0,'Q','W','E','R','T','Y','U','I','O','P','{','}'
		db 0,0,'A','S','D','F','G','H','J','K','L',':','"','~'
		db 0,'|','Z','X','C','V','B','N','M','<','>','?',0,0,0,' '


Proga			proc				;main function
			push ax bx es
		
			in al, 60h			;read symbol

			test al, 80h			;button is
			jnz .long_jump_Correct_end	;unpressed

			cmp al, esc_code		
			jne .shift_pressed
							;work after press Esc
.int_recovery:		push 0				;and rebuild 9h
			pop es
			cli
			mov bx, 09*4h
			mov ax, cs:old_off		;come back, orig_9h
			mov es:[bx], ax
			mov ax, cs:old_seg
			mov es:[bx+2], ax
			sti
			jmp .long_jump_Correct_end

.shift_pressed:		cmp al, shift_code
			jne .bs_pressed
			mov cs:shift, 1h		;make shift flag True
			jmp .long_jump_Correct_end

.bs_pressed:		cmp al, backspace_code		;backspace_checking
			jne .read
			cmp cs:position, 0h
			je .long_jump_Correct_end

			sub cs:position, 2h
			mov bx, cs:position

			push 0b800h
			pop es
			mov ax, cs:old_symbol
			mov es:[bx], ax
			jmp .long_jump_Correct_end

.long_jump_Correct_end:	jmp Correct_end	
	
.read:			push 0b800h
			pop es	
			mov bl, al
			xor bh, bh

			cmp cs:mas_symb_low[bx], 0h
			je Correct_end

			cmp cs:shift, 1h
			je .upper
			mov al, cs:mas_symb_low[bx]
			jmp .print

.upper:			mov al, cs:mas_symb_up[bx]

.print:			mov ah, 0ceh			;print symbol
			mov bx, cs:position
			push si
			mov si, es:[bx]
			mov cs:old_symbol, si
			pop si
			mov es:[bx], ax				

			mov cs:shift, 0h

			add cs:position, 2
			cmp cs:position, 80*25*2	;when screen ended, 
			jne Correct_end			;write from start
			mov cs:position, 0h
			xor bx, bx

			jmp Correct_end	

Correct_end:		in al, 61h			
			or al, 80h  			;Work with
			out 61h, al			;61h and 20h to end
			and al, not 80h			;working correctly
			out 61h, al
			mov al, 20h
			out 20h, al
			pop es bx ax
			iret
			endp

EndProg:
end			Start																	