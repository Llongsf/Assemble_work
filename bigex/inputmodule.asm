assume cs:code,ds:data

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

;****************************************

;子程序功能定义

;****************************************
start:
; 输入字符串定义
input_string:
    mov si, buffer
    rep lodsb
    mov ah, 1
    int 21h
    cmp al, 0dh     ;检测是否是回车
    je done_input_string
    rep stosb
    jmp input_string
done_input_string:
    rep stosb
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
    mul ax, 10
    jmp input_number
done_input_number:
    div cx
    ret
	
code ends
end start