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
    final1 db 0,'$'
    final2 db 0,'$'

    data_s db 'Alice        2021111223 100 100 100 100 100 100 090 090 090 090 090 090 090 090 090 090 090 Dai Las 055',0dh,0ah
        db 'Askeladd     2021233666 090 090 090 090 090 099 099 099 095 095 095 095 095 095 095 095 099 Dai Las 080',0dh,0ah
        db 'lvwanlang    NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las 077',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las 055',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las Fin',0dh,0ah
        ;db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai las Fin',0dh,0ah
        db '$'
    
    hint1 db 13,10,'     NAME        ID           GRADE',13,10,'$'
    hint2 db 13,10,'student found! $'
    hint_lastgrade db 13,10,'lastgrade: ',13,10,'$'
    hint3 db 13,10,'INPUT ERROR! PLEASE AFRESH.',13,10,'$'
    hint4 db 13,10,'choose it:','$'
    hint5 db 13,10,'sorry,can not find this student!','$'
    hint6 db 'The last 3 number is homework,last homework,and final score',13,10,'$'

    student_final_score db 0,0,0,0      ;存储学生最终成绩
    student_level db 0,0,0,0,'$'            ;存储所在分段学生个数
    lev1 db 'level 1:100 ~90:  ',13,10,'$'
    lev2 db 'level 2:89 ~ 80:  ',13,10,'$'
    lev3 db 'level 3:79 ~ 60:  ',13,10,'$'
    lev4 db 'level 4:60 ~ 0 :  ',13,10,'$'

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
    after_cal db 13,10,'             Daily average score:   ,lasthomework score:   ,Final score:   ','$'
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
;菜单选项子程序
choice proc near;;
    mov ax,data
    mov ds,ax
    shuchu hint4
	shuru		;调用宏输入一个字符

	cmp al,50   ;if al==2
    je out_p
    cmp al,51   ;if al==3
    je sear
    cmp al,52   ;if al==4
    je calculate
    ;cmp al,53   ;if al==5
    ;je ra_nk
    cmp al,48   ;if al==0	
    je Exit
    shuchu WARNING
    ret         ;返回调用的地方
out_p:
    call out_put
    jmp choice
calculate:
    mov ax,data
    mov ds,ax
    shuchu rank_prompt
    mov cx,4
calculate_s:
    
    push cx
    mov ax,4
    sub ax,cx
    mov bl,105
    mul bl
    mov bx,offset data_s
    add bx,ax
    call cal_culate
    pop cx
    loop calculate_s
    call grade_levels
    jmp choice

sear:
    call search
    shuchu thanks
    jmp choice


choice endp


out_put proc near;;
    mov ax,data
    mov ds,ax
    shuchu output_prompt
    mov si,0
    mov bx,offset data_s
    shuchu LIST
    shuchu hint6
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
cal_culate proc near
    shuchu hint1
    
    ret

cal_culate endp
grade_levels proc near
;期末成绩评级
;将期末成绩的字符串转化为数字并比较
    mov bx,offset data_s
    mov di,offset student_final_score
    
    mov cx,4
grade_levs:
    mov si,0
    mov ax,0

    mov al,ds:[bx+si+100]   ;百位,期末成绩存储百位数的偏移地址
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[di],al      ;存储
    inc si

    mov al,ds:[bx+si+100]   ;十位
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[di],al      ;存储
    inc si

    mov al,ds:[bx+si+100]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[di],al      ;存储

    inc di
    add bx,105      ;下一行
    loop grade_levs

    mov si,offset student_level
    mov ah,1
    mov di,offset student_final_score
    mov cx,4
    ;换数字完毕，开始比较
lev_1:
    mov al,ds:[di]   

    cmp al,90       ;100-90
    ja lev_1_add

lev_2:
    cmp al,80       ;89-80
    jnb lev_2_add   

lev_3:  
    cmp al,60       ;79-60
    jnb lev_3_add

lev_4:
    cmp al,60       ;60-
    jb lev_4_add

lev_continue:
    inc di
    loop lev_1
    jmp lev_output

lev_1_add:
    add ds:[si],ah
    jmp lev_continue
lev_2_add:
    add ds:[si+1],ah
    jmp lev_continue
lev_3_add:
    add ds:[si+2],ah
    jmp lev_continue
lev_4_add:
    add ds:[si+3],ah
    jmp lev_continue

    ;输出分段个数
    
lev_output:
    mov al,30h
    add ds:[si],al
    mov ah,ds:[si]      ;将字符串移动
    inc si
    lea di,lev1
    mov ds:[di+16],ah
    
    add ds:[si],al
    mov ah,ds:[si]      ;将字符串移动
    inc si
    lea di,lev2
    mov ds:[di+16],ah

    add ds:[si],al
    mov ah,ds:[si]      ;将字符串移动
    inc si
    lea di,lev3
    mov ds:[di+16],ah

    add ds:[si],al
    mov ah,ds:[si]      ;将字符串移动
    inc si
    lea di,lev4
    mov ds:[di+16],ah
    shuchu lev1
    shuchu lev2
    shuchu lev3
    shuchu lev4

    mov si,offset student_level
    mov di,offset student_final_score
    mov al,0        ;输出后便重置
    mov cx,4
level_reset:
    
    mov ds:[si],al
    mov ds:[di],al
    inc si
    inc di
    loop level_reset

    ret
grade_levels endp

ra_nk proc far;;
    mov ax,data
    mov ds,ax
    

ra_nk endp

output_final proc near
    mov ax,data
    mov ds,ax

    ret 
output_final endp

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