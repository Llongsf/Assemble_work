org 100h

; 数据段
data segment
    LIST DB 13,10
            DB '*~*~*~*~*~*~*~LIST*~*~*~*~*~*~*~*~*~*~*',13,10
            DB '@         1.INPUT                     @',13,10
            DB '@         2.OUTPUT(RANK)              @',13,10
            DB '@         3.FIND(SNO)                 @',13,10
            DB '@         0.QUIT                      @',13,10
            DB '*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*',13,10
    students db 10, 0  ; 学生姓名，最多10个字符，以0结束
    id db 10, 0        ; 学生学号，最多10个字符，以0结束
    hos dw 16 dup(0)   ; 16次作业成绩
    final dw 0         ; 大作业成绩
    total dw 0         ; 总成绩
data ends


; 代码段
code segment
; 提示信息
name_prompt db 'Please enter student name: $'
id_prompt db 'Please enter student id: $'
hos_prompt db 'Please enter student homework scores: $'
final_prompt db 'Please enter student final work score: $'
total_prompt db 'Final score: $'
search_prompt db 'Search by name input 1,search by id input 2: $'

start:
    ; 字符串和数字缓冲区
    buffer db 256 dup(0)

    ;显示表格
    mov ah, 9
    lea dx, LIST
    int 21h
    call input_string
    lea di, students
    call copy_string

    ; 输入学生信息
    mov ah, 9
    lea dx, name_prompt
    int 21h
    call input_string
    lea di, students
    call copy_string
    
    mov ah, 9
    lea dx, id_prompt
    int 21h
    call input_string
    lea di, id
    call copy_string

    ; 输入成绩
    lea si, hos
    mov cx, 16
input_hw:
    push cx
    mov ah, 09h
    lea dx, hos_prompt
    int 21h
    call input_number
    mov [si], ax
    add si, 2
    pop cx
    loop input_hw

    mov ah, 09h
    lea dx, final_prompt
    int 21h
    call input_number
    mov [final], ax
;***************************************

;***************************************
    ; 计算总成绩
    mov ax, 0
    lea si, hos
    mov cx, 16
calc_avg:
    push cx
    add ax, [si]
    add si, 2
    pop cx
    loop calc_avg
    cwd
    idiv cx
    imul ax, 40
    cwd
    idiv cx
    mov bx, ax

    mov ax, [final]
    imul ax, 60
    cwd
    idiv cx
    add ax, bx
    mov [total], ax

    ; 显示总成绩
    mov ah, 09h
    lea dx, total_prompt
    int 21h
    mov ax, [total]
    call print_number

    ; 查询功能
    mov ah, 09h
    lea dx, search_prompt
    int 21h
    call input_string
    lea si, buffer
    cmp byte ptr [si], '1'
    je search_by_name
    jmp search_by_id

search_by_name:
    ; 按姓名查询
    ; ...
    jmp end

search_by_id:
    ; 按学号查询
    ; ...
    jmp end

end:
    ; 退出程序
    mov ah, 4ch
    int 21h

; 输入字符串定义
input_string:
    mov si, buffer
    lodsb
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je done_input_string
    stosb
    jmp input_string
done_input_string:
    stosb
    ret

; 复制字符串定义
copy_string:
    lodsb
    stosb
    cmp al, 0
    jne copy_string
    ret

; 输入数字
input_number:
    xor ax, ax
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je done_input_number
    sub al, '0'
    imul ax, 10
    jmp input_number
done_input_number:
    idiv cx
    ret

; 打印数字
print_number:
    ; ...
    ret

code ends

end start