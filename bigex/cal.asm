assume cs:code,ds:data
data segment
    LIST db 13,10
            db '*~*~*~*~*~*~*~*~LIST*~*~*~*~*~*~*~*~*~*',13,10
            db '@             1.INPUT                 @',13,10
            db '@             2.OUTPUT                @',13,10
            db '@             3.FIND                  @',13,10
            db '@             4.CAL                   @',13,10
            db '@             4.RANK                  @',13,10
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

    data_s db 'Alice        2021111223 100 100 100 100 100 100 090 090 090 090 090 090 090 090 090 090 090 Dai Las Fin',0dh,0ah
        db 'Askeladd     2021233666 090 090 090 090 090 099 099 099 095 095 095 095 095 095 095 095 099 Dai Las Fin',0dh,0ah
        db 'lvwanlang    NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las Fin',0dh,0ah
        db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai Las Fin',0dh,0ah
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
    call output_final
    pop cx
    loop calculate_s

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
    cal:
; 计算总成绩
    mov ax,0
    mov di,offset lastgrade
    mov ds:[di],ax
    mov di,offset ave_total
    mov ds:[di],ax      ;开始前先将对应的存储空间清零
   
    mov si,0        
    mov cx, 16
calc_avg:
    ;计算总数
    push cx
    mov ax,0
    mov al,ds:[bx+si+24]   ;百位，平时成绩的存储偏移地址为每一行的第24个字节位
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+24]   ;十位
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+24]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[di],ax      ;存储
    inc si

    inc si          ;每个成绩之后的空格
    pop cx
    loop calc_avg

    ;存储平均数
    mov ax, data
    mov ds,ax
    mov dx,0            ;清零防止后面出错
    
    mov al,ds:[di]      ;低位在前，高位在后
    mov ah,ds:[di+1]    ;将平均数算平均前的总数传给ax

    mov cx,4            ;设置右移位数
    shr ax,cl            ;将ax寄存器中的值向右移动4位，相当于除以16

    push ax
    push di
    ;将平时成绩乘以0.4,先将其数据处理并加入到最终成绩计算区域中，再进行字符串输出
    mov dx,4
    mul dl
    mov dx,10
    div dl
    mov di,offset total
    mov ds:[di],al
    pop di
    pop ax
    
;平时成绩处理**************************
;****************************
;十六进制转为十进制——平时作业
    cmp al,64h          ;如果平均分=100分
    je one_hundred

    ;将平时成绩乘以0.4
    ;mov dx,10
    ;mul dl
    ;mov dx,40
    ;div dl
    ;****************
    push ax             ;输出一个0在前面
    mov al,'0'
    mov ds:[bx+92],al    ;将字符保存
    pop ax

sixteen_to_ten: 
    ;push ax
    ;shl ax,1            ;把ax寄存器左移一位，用ah拿到16进制的高位
    mov dx,0
    mov si,2            ;存余数由个位存起   
    mov cx,2
one_or_zero:
    mov ah,0            ;每次进来余数位先清零,用上次的商去除
    mov dl,10           ;将得到的数除以10
    div dl

	add ah,30h          ;将余数转换为字符
    mov ds:[bx+si+92],ah    ;将字符保存
    dec si
    loop one_or_zero
    jmp last_score_turning

one_hundred:        ;平时成绩为100分的情况
   ;默认平时成绩40分
   mov ax,data
   mov ds,ax
   ;mov bx,offset data_s
   mov di,92        ;平时成绩存放处
   mov al,'1'
   mov ds:[bx+di],al
   mov al,'0'
   mov ds:[bx+di+1],al
   mov al,'0'
   mov ds:[bx+di+2],al
   
   
   ;mov bx,offset data_s    ;每次外循环需要重置bx，指向第一个存储位置

;大作业成绩处理**************************
last_score_turning:
    ;将字符数字变成实数并存入缓冲区
    mov di,offset lastgrade
    mov si,0
    mov ax,0
    mov ds:[si],ax          ;先对缓冲区清零
    mov al,ds:[bx+si+88]   ;百位,88为大作业存储百位数的偏移地址
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+88]   ;十位
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+88]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[di],ax      ;存储
    
    mov al,ds:[di]
    mov ah,0

    push ax
    push di
    ;将大作业成绩乘以0.6,先将其数据处理并加入到最终成绩计算区域中，再进行字符串输出
    mov dx,6
    mul dl
    mov dx,10
    div dl
    mov di,offset total
    add ds:[di],al
    pop di
    pop ax
    ;****************

    cmp al,64h          ;如果平均分=100分
    je las_one_hundred

    mov al,ds:[bx+88]
    mov ds:[bx+96],al   ;第1个字符

    mov al,ds:[bx+89]
    mov ds:[bx+97],al   ;第2个字符

    mov al,ds:[bx+90]
    mov ds:[bx+98],al   ;第3个字符
    jmp final_score_turning

las_one_hundred:        ;大作业成绩为100分的情况
    ;默认大作业满分60分
    mov ax,data
    mov ds,ax
    mov di,96        ;大作业成绩存放处
    mov al,'1'
    mov ds:[bx+di],al
    mov al,'0'
    mov ds:[bx+di+1],al
    mov al,'0'
    mov ds:[bx+di+2],al
   
   
;大期末总分成绩处理**************************  
final_score_turning:
    mov di,offset total
    mov al,ds:[di]
    ;****************************
;十六进制转为十进制——期末总分
    cmp al,64h          ;如果平均分=100分
    je final_one_hundred

    push ax             ;输出一个0在前面
    mov al,'0'
    mov ds:[bx+100],al    ;将字符保存
    pop ax

    mov dx,0
    mov si,2            ;存余数由个位存起   
    mov cx,2   
final_one_or_zero: 
    mov ah,0            ;每次进来余数位先清零,用上次的商去除
    mov dl,10           ;将得到的数除以10
    div dl

	add ah,30h          ;将余数转换为字符
    mov ds:[bx+si+100],ah    ;将字符保存
    dec si
    loop final_one_or_zero
    ret

final_one_hundred:        ;期末总成绩为100分的情况
    mov ax,data
    mov ds,ax
    mov di,100        ;最终成绩存放处
    mov al,'1'
    mov ds:[bx+di],al
    mov al,'0'
    mov ds:[bx+di+1],al
    mov al,'0'
    mov ds:[bx+di+2],al
    
    ret

cal_culate endp
ra_nk proc near;;
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