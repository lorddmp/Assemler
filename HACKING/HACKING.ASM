.model tiny
.code
org 100h

Start:              
                    mov dx, offset ask_password
                    mov ah, 9h
                    int 21h

                    xor di, di
                    xor dx, dx

Count_hash:        
                    mov ah, 8h
                    int 21h

                    cmp al, 13
                    je .check

                    mov dl, al
                    add di, dx

                    mov dl, '*'
                    mov ax, 0200h
                    int 21h

                    loop Count_hash

.check:             
                    push 0b800h
                    pop es
                    cmp di, password_hash
                    jne .print_wrong

.print_right:       
                    mov bx, left_high_ang
			        mov es: word ptr [bx], 2fc9h
			        add bx, (right_lable_len*2 + 2)
			        mov es: word ptr [bx], 2fbbh
			        add bx, 140h
			        mov es: word ptr [bx], 2fbch
			        sub bx, (right_lable_len*2 + 2)
			        mov es: word ptr [bx], 2fc8h

                    mov cx, right_lable_len
			        mov bx, left_high_ang
			        add bx, 2h	;take place after high left angle
			
							
Cycle_write:        mov es: word ptr [bx], 2fcdh
			        mov es: word ptr [bx+320], 2fcdh
			        add bx, 2h
			        loop Cycle_write
			
			        mov bx, left_high_ang
			        add bx, 0a0h
                    mov es: word ptr [bx], 2fbah
                    add bx, (right_lable_len*2 + 2)
			        mov es: word ptr [bx], 2fbah

                    mov si, offset right_lable
                    mov cx, right_lable_len
                    mov bx, left_high_ang + 162
                    mov ah, 0afh

.print_right_label: mov al, cs: byte ptr [si]
                    mov es: word ptr [bx], ax
                    inc si
                    add bx, 2h
                    loop .print_right_label

                    jmp .exit_exit

.print_wrong:       
                    mov bx, left_high_ang
			        mov es: word ptr [bx], 4fc9h
			        add bx, (wrong_lable_len*2 + 2)
			        mov es: word ptr [bx], 4fbbh
			        add bx, 140h
			        mov es: word ptr [bx], 4fbch
			        sub bx, (wrong_lable_len*2 + 2)
			        mov es: word ptr [bx], 4fc8h

                    mov cx, wrong_lable_len
                    mov bx, left_high_ang
			        add bx, 2h	;take place after high left angle
			
							
Cycle_wrong:        mov es: word ptr [bx], 4fcdh
			        mov es: word ptr [bx+320], 4fcdh
			        add bx, 2h
			        loop Cycle_wrong

                    mov bx, left_high_ang
			        add bx, 0a0h
                    mov es: word ptr [bx], 4fbah
                    add bx, wrong_lable_len*2
			        mov es: word ptr [bx+2], 4fbah

                    mov si, offset wrong_lable
                    mov cx, wrong_lable_len
                    mov bx, left_high_ang + 162
                    mov ah, 0cfh

.print_wrong_label: mov al, cs: byte ptr [si]
                    mov es: word ptr [bx], ax
                    inc si
                    add bx, 2h
                    loop .print_wrong_label

.exit_exit:         mov ax, 4c00h
                    int 21h

password_hash equ 402
left_high_ang equ (80*12+33)*2

ask_password db "Enter password: $"

right_lable db "Access granted"
right_lable_len equ 0eh

wrong_lable db "Access denied"
wrong_lable_len equ 0dh

end                 Start