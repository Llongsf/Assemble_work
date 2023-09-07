assume cs:code,ds:data
;字符检测
data segment
    LIST db 13,10
            db '*~*~*~*~*~*~*~LIST*~*~*~*~*~*~*~*~*~*~*',13,10
            db '@             1.INPUT                 @',13,10
            db '@             2.OUTPUT(RANK)          @',13,10
            db '@             3.FIND                  @',13,10
            db '@             0.QUIT                  @',13,10
            db '*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*',13,10
            db 'PLEASE INPUT YOUR CHOICE:$',13,10
    students db 15, 0  ; 学生姓名，最多15个字符，以0结束
    id db 10, 0        ; 学生学号，最多10个字符，以0结束
    hos dw 16 dup(0)   ; 16次作业成绩
    final dw 0         ; 大作业成绩
    total dw 0
    hint3 db 13,10,'INPUT ERROR! PLEASE AFRESH',13,10,'$'
    hos_prompt db 'Please enter student homework scores: $'
    thanks db 'Thank you for your using! $'
    huanchong db 2 dup(0)
data ends



;单字符输入宏定义
shuru macro
	mov ah,1	;键盘输入并回显
	int 21h
endm

;字符串输出宏定义
shuchu macro ad	
    lea dx,ad
	mov ah,09h
	;mov dx,offset ad
	int 21h
endm

;平时成绩输入错误检查宏定义
gr_numcheck macro ale 
    cmp ale,0dh  ;这里要先检查回车
    je gr_con
    cmp ale,'9'
    ja iferror
    cmp ale,'0'
    jb iferror
    jmp gr_con
iferror:
	shuchu hint3        ;提示输入错误;跳回重新输入
    jmp  gr_s0			
endm

;****************************************

;****************************************


code segment

start:
;菜单显示子程序
show proc near
    mov ax,data
    mov ds,ax
	mov ax,3  ;清屏
    int 10h
    shuchu LIST
    jmp GR_shuru
show endp

;成绩输入子程序
GR_shuru:
    mov cx,16
gr_s0:
    mov ax,data
    mov ds,ax
    mov ax,cx
    sub ax,16
    neg ax          ;利用求补运算算出当前si应该指向内存的哪个位置
    mov si,ax
    mov bx,offset hos
    shuchu hos_prompt
gr_s:
	shuru			;键盘接收一个字符

gr_panduan:  
    gr_numcheck al
    ;jcxz endcode;*****************************接口，接上后面的
gr_con:
    mov [bx+si],al
    inc si
    cmp al,0dh  ;检查回车
    jne gr_s
    loop gr_s0

endcode:
    shuchu thanks
    mov ax,4c00h
    int 21h
code ends
end start