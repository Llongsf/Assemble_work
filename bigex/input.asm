assume cs:code,ds:data
data segment
    LIST db 13,10
            db '*~*~*~*~*~*~*~LIST*~*~*~*~*~*~*~*~*~*~*',13,10
            db '@             1.INPUT                 @',13,10
            db '@             2.OUTPUT(RANK)          @',13,10
            db '@             3.FIND                  @',13,10
            db '@             4.RANK                  @',13,10
            db '@             0.QUIT                  @',13,10
            db '*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*',13,10
            db 'PLEASE INPUT YOUR CHOICE: ',13,10,'$'
    student db '            ','$'  ; 学生姓名，最多12个字符，以0结束
    id db '          ','$'     ; 学生学号，最多10个字符，以0结束
    hos db '090 090 090 090 090 090 090 090 091 092 093 091 090 090 094 092 $'
    lastgrade db '095 ','$'         ; 大作业成绩
    total db '   ',13,10,'$'         ; 总成绩
    

    ave_total dw 0
    ave db ' ','location','$'

    data_s db 'Alice        2021111223 080 090 075 091 088 077 095 086 079 099 090 088 076 078 091 093 095 Dai Fin',0dh,0ah
        db 'Askeladd     2021233666 090 090 090 090 090 099 099 099 095 095 095 095 095 095 095 095 099 Dai Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Fin',0dh,0ah,'$'
    hint1 db 13,10,'NAME      ID    GRADE',13,10,'$'
    hint2 db 13,10,'student found! $'
    hint_lastgrade db 13,10,'lastgrade: ',13,10,'$'
    hint3 db 13,10,'INPUT ERROR! PLEASE AFRESH.',13,10,'$'
    hint4 db 13,10,'choose it:','$'
    hint5 db 13,10,'sorry,can not find this student!','$'

    ; 提示信息
    name_prompt db 13,10,'Please enter student name: $'
    id_prompt db 13,10,'Please enter student id: $'
    home_prompt db 13,10,'Please enter student homework scores: $'
    lastgrade_prompt db 13,10,'Please enter student lastgrade work score: $'
    total_prompt db 13,10,'Final score: $'
    search_prompt db 13,10,'Search by name input 1,search by id input 2: $'
    rank_prompt db 13,10,'Please wait ranking... $'
    output_prompt db 13,10,'Please wait outputing... $'
    thanks db 13,10,'Thank you for your using! $'
    WARNING db 13,10,'Wrong input! $'
data ends
;****************************************

;功能宏定义

;****************************************

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

;大作业成绩输入错误检查宏定义
lastgrade_numcheck macro alf 
    cmp alf,20h  ;检查空格
    je las_con
    cmp alf,'9'
    ja ierror
    cmp alf,'0'
    jb ierror
    jmp las_con         ;没错就继续
ierror:
	shuchu hint3        ;提示输入错误;跳回重新输入
    jmp  lastgrade_shuru			
endm

;平时成绩输入错误检查宏定义
gr_numcheck macro ale 
    cmp ale,20h  ;这里要先检查空格
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
;*****************************************

;*****************************************
code segment
start:
    call show
    call choice
Exit:
    mov ax,data
    mov ds,ax
    shuchu thanks
    mov ax,4c00h
    int 21h

;*****************************************

;*****************************************

;菜单选项子程序
choice proc near
    mov ax,data
    mov ds,ax
    shuchu hint4
	shuru		;调用宏输入一个字符
	cmp al,49   ;if al==1
    je  inp	    ;调用输入功能

	cmp al,50   ;if al==2
    je ran
    cmp al,51   ;if al==3
    je sear
    cmp al,48   ;if al==0	
    je Exit
    shuchu WARNING
    ret         ;返回调用的地方

inp:
    mov cx,2        ;存储的数组有多少行，跟着in_put的第二行的ax改动
inp_s:
    call in_put
    loop inp_s
    jmp choice
ran:
    call out_put
    jmp choice
sear:
    ;call search
    jmp choice

choice endp

;*****************************************

;*****************************************
;已知一个学生所有数据的一行数组有101个字节
in_put proc near
    push cx         ;关乎第几行的记录，返回前先存着
    mov ax,2                ;算出现在是第几行的操作
    sub ax,cx               ;用总行数减去当前循环的次数，等于现在第几行，保存到ax中             
    mov bx,101              ;一行数组有101个字节
    mul bx                  ;乘法的结果保存在ax中
    
    mov bx,offset data_s  ;先取得存储空间的偏移地址
    add bx,ax
;姓名输入
    mov ax,data
    mov ds,ax
    shuchu name_prompt      
    mov si,0                ;开头第一个字节
name_in:
    shuru                   ;输入名字
    mov ds:[bx+si],al          ;复制字符串
    inc si
    cmp al,20h  ;检查空格
    jne name_in

;学号输入
    shuchu id_prompt
    mov si,13               ;定位ID的存储偏移地址,为每一行的第13个位
id_in:          
    shuru                   ;输入ID  
    mov ds:[bx+si],al          ;复制字符串
    inc si
    cmp al,20h  ;检查空格
    jne id_in

;平时成绩输入子程序
    
GR_shuru:
    mov cx,16       ;16个平时成绩
    mov si,24        ;平时成绩的存储偏移地址为每一行的第24个字节位,这个要一开始就设置好了，不然后面每一次循环都要重置
gr_s0:
    mov ax,data
    mov ds,ax
    shuchu home_prompt
gr_s:
	shuru			;键盘接收一个字符
gr_panduan:  
    gr_numcheck al      ;检查有没有输错
gr_con:
    mov [bx+si],al      ;复制字符串
    inc si          
    cmp al,20h      ;检查空格，是否要输入下一个成绩
    jne gr_s
    loop gr_s0

;大作业成绩输入子程序
lastgrade_shuru:
    shuchu lastgrade_prompt
    mov si,88               ;定位每一行第88位为大作业成绩偏移位置
las_s:
    shuru                   ;输入大作业成绩
    lastgrade_numcheck al
las_con:
    mov [bx+si],al          ;复制字符串
    inc si
    cmp al,20h              ;检查空格
    jne las_s               ;不是空格就继续接收输入
    pop cx
    ret
in_put endp

out_put proc near
    mov ax,data
    mov ds,ax
    shuchu output_prompt
    shuchu hint1
    mov si,0
    mov bx,offset data_s
    shuchu LIST
    shuchu data_s       ;输出内存存储的学生数据

    ret
out_put endp


;菜单显示子程序
show proc near
    mov ax,data
    mov ds,ax
	mov ax,3  ;清屏
    int 10h
    shuchu LIST
    ret
show endp

code ends
end start