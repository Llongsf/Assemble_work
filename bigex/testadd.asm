assume cs:code,ds:data
data segment
    a db 0,0
data ends
code segment
start:
    mov ax,0
    push ax
    popf
    mov ax,0fff0h
    add ax,0010h
    pushf
    pop ax
    and al,11000101b
    and ah,00001000b

    mov ax,4c00h
    int 21h
code ends
end start