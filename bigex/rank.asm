assume cs:code,ds:data
data segment
    LIST db 13,10
            db '*~*~*~*~*~*~*~*~LIST*~*~*~*~*~*~*~*~*~*',13,10
            db '@             1.INPUT                 @',13,10
            db '@             2.OUTPUT                @',13,10
            db '@             3.FIND                  @',13,10
            db '@             4.CAL                   @',13,10
            db '@             5.RANK                  @',13,10
            db '@             0.QUIT                  @',13,10
            db '*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*',13,10
            db 'PLEASE INPUT YOUR CHOICE: ',13,10,'$'
    student db '            ','$'  ; 学生姓名，最多12个字符，以0结束
    id db '          ','$'     ; 学生学号，最多10个字符，以0结束
    hos db '090 090 090 090 090 090 090 090 091 092 093 091 090 090 094 092 $'
    hos_total db '099 ','$'
    lastgrade dw 0,'$'         ; 大作业成绩
    total db 0,0        ; 总成绩
    

    ave_total dw 0,'$'

    rankis db 'rank: ',0,'$'

    huangchong db 101 dup(0),'$' ;成绩信息交换的时候的缓冲区
    final1 db 0,0
    final2 db 0,0

    data_s db 'Alice        2021111223 100 100 100 100 090 090 090 090 090 090 090 090 090 090 090 090 090 Dai Las 094',0dh,0ah
        db 'Askeladd     2021233666 090 090 090 090 090 099 099 099 095 095 095 095 095 095 095 095 099 Dai Las 093',0dh,0ah
        db 'lvwanlang    NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las 092',0dh,0ah
        db 'wOcaAnima    NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las 091',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las 060',0dh,0ah
        ;db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai las Fin',0dh,0ah
        db '$'
    
    hint1 db 13,10,'     NAME        ID           GRADE',13,10,'$'
    hint2 db 13,10,'student found! $'
    hint_lastgrade db 13,10,'lastgrade: ',13,10,'$'
    hint3 db 13,10,'INPUT ERROR! PLEASE AFRESH.',13,10,'$'
    hint4 db 13,10,'choose it:','$'
    hint5 db 13,10,'sorry,can not find this student!','$'
    hint6 db 'The last 3 number is homework,last homework,and final score',13,10,'$'



    ; 提示信息
    name_prompt db 13,10,'Please enter student name: $'
    id_prompt db 13,10,'Please enter student id: $'
    home_prompt db 13,10,'Please enter student homework scores: $'
    lastgrade_prompt db 13,10,'Please enter student lastgrade work score: $'
    total_prompt db 13,10,'Final score: $'
    search_prompt db 13,10,'Search by name input 1,search by id input 2: $'
    rank_prompt db 13,10,'Please wait ranking...',13,10,'$'
    output_prompt db 13,10,'Please wait outputing... ',13,10,'$'
    thanks db 13,10,'Thank you for your using! $'
    WARNING db 13,10,'Wrong input! $'
    after_cal db 13,10,'                Rank: | Daily score:    | Last score:    | Final score:    ','$'
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

exchange_stu macro 
    
    mov dx,105
    mov si,0
chs:
    mov al,ds:[bx+si]
    mov ah,ds:[bx+si+105]     ;下一行
    mov ds:[bx+si],ah
    mov ds:[bx+si+105],al
    inc si
    dec dx
    cmp dx,0
    jne chs
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
;菜单选项子程序
choice proc near
    mov ax,data
    mov ds,ax
    shuchu hint4
	shuru		;调用宏输入一个字符

	cmp al,50   ;if al==2
    je out_p
    cmp al,51   ;if al==3
    je sear
    cmp al,52   ;if al==4
    je ran
    cmp al,48   ;if al==0	
    je Exit
    shuchu WARNING
    ret         ;返回调用的地方
out_p:
    call out_put
    jmp choice
ran:
    call ra_nk
    jmp choice

sear:
    call search
    shuchu thanks
    jmp choice

choice endp


out_put proc near
    mov ax,data
    mov ds,ax
    shuchu output_prompt
    mov si,0
    mov bx,offset data_s
    shuchu LIST
    shuchu hint1
    shuchu data_s       ;输出内存存储的学生数据

    ret
out_put endp

search proc near
    mov ax,data
    mov ds,ax
    shuchu search_prompt
    ret
search endp

ra_nk proc near
    mov ax,data
    mov ds,ax
    shuchu rank_prompt

    mov ax,data
    mov ds,ax
    
    mov di,offset final1
    mov bp,offset final2
    
    mov cx,4            ;循环次数=n-1，n就是数据总行数
cal_final_inputs:
    ;这里采用最简单的冒泡排序
    mov bx,offset data_s    ;每次外循环需要重置bx，指向第一个存储位置
    push cx                 ;入栈外循环的cx
cal_final:
    ;将字符数字存入缓冲区并比较
    
    mov si,0
    mov ax,0
    mov al,ds:[bx+si+100]   ;百位,100为最终成绩存储百位数的偏移地址
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[di],al      ;存储

    mov al,ds:[bx+si+205]    ;下一个学生的最终成绩的百位偏移地址，205=100+105
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[bp],al
    inc si

    mov al,ds:[bx+si+100]   ;十位
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[di],al      ;存储

    mov al,ds:[bx+si+205]    ;下一个学生的最终成绩的十位偏移地址
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[bp],al
    inc si

    mov al,ds:[bx+si+100]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[di],al     ;存储

    mov al,ds:[bx+si+205]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[bp],al      ;存储
    inc si
;*******比较，判断是否要交换
    mov al,ds:[di]      ;final1,即目前循环指到的对象,前一个学生
    mov ah,ds:[bp]      ;final2
    cmp ah,al           ;对比学生的总成绩
    ja continue_cal_final      ;前一个小于等于后一个就不用交换,大于就交换

    mov al,0
    mov ds:[di],al
    mov ds:[bp],al

    exchange_stu                ;交换

continue_cal_final:
    add bx,105          ;进入到下一行比较
    loop cal_final        ;和上面的loop一起消耗着内循环的cx

    pop cx                      ;出栈外循环的cx
    dec cx
    cmp cx,0
    je call_rank_output
    jmp far ptr cal_final_inputs
call_rank_output:
    call rank_output
    ret
ra_nk endp

rank_output proc near
    mov bx,offset data_s
    
    mov cx,5
    mov si,0
    mov di,0
    shuchu data_s
ran_output_s0:
    push cx
    mov cx,12
    push si
ran_output_s1:
    mov al,ds:[bx+si]
    mov bx,offset after_cal
    mov ds:[bx+di+2],al      ;姓名字符串复制
    
    mov bx,offset data_s
    inc si
    inc di
    loop ran_output_s1
    pop si          ;将下面需要的si拿出来
     ;成绩排序后输出
    pop cx
    mov al,cl
    add al,30h
    mov bx,offset after_cal
    mov ds:[bx+23],al
    push cx
   
    push si
    call rank_last_output
    pop si
    pop cx

    add si,105           ;将指针指到下一行，+105 
    mov di,0
    loop ran_output_s0
    ret
rank_output endp
rank_last_output proc near
   

    mov bx,offset data_s
    mov di,offset after_cal
ran_output_s2:
    mov al,ds:[bx+si+92]       ;平时成绩
    mov ds:[di+38],al
    mov al,ds:[bx+si+93]
    mov ds:[di+39],al
    mov al,ds:[bx+si+94]
    mov ds:[di+40],al

    mov al,ds:[bx+si+96]       ;大作业成绩
    mov ds:[di+55],al
    mov al,ds:[bx+si+97]
    mov ds:[di+56],al
    mov al,ds:[bx+si+98]
    mov ds:[di+57],al

    mov al,ds:[bx+si+100]       ;最终成绩
    mov ds:[di+73],al
    mov al,ds:[bx+si+101]
    mov ds:[di+74],al
    mov al,ds:[bx+si+102]
    mov ds:[di+75],al
    
    shuchu after_cal
    ret
rank_last_output endp
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