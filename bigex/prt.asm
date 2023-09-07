assume cs:code, ds:data, ss:stack

data segment
    StringToPrint db "Hello World!", 13, 10, "$"
    StringForRead db "Please Input Your Name:", "$"
    Input db 0ah, 20 dup("$")
data ends

stack segment
    db 128 dup (0)
stack ends

code segment
start:
    mov ax, data
    mov ds, ax
    
    mov ax, stack
    mov ss, ax
    mov sp, 128

    mov ax, offset StringForRead
    push ax
    mov bp, sp
    call read

    mov ax, offset StringToPrint
    push ax
    mov bp, sp
    call puts

    mov ah,4ch
    int 21h
puts:
    pop si
    pop dx
    push si
    push bp
    mov bp, sp

    mov ah, 09h
    int 21h
    
    mov sp, bp
    pop bp
    ret

read:
    pop si
    pop ax
    push si
    push bp
    mov bp, sp
    push ax
    call puts

    mov ch, 0
    mov di, offset Input + 1
    mov bx, 17
    get:
        mov cx, bx
        jcxz ok
        mov ah, 01h
        int 21h
        mov cl, al
        sub cl, 0dh
        jcxz ok
        mov ds:[di], al
        inc di
        dec bx
        jmp get
    ok:
        show:
            mov al, ","
            mov ds:[di], al
            mov ax, offset INPUT
            push ax
            call puts
    mov sp, bp
    pop bp
    ret

code ends
end start
