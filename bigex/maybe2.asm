assume cs:code,ds:data
data segment
    LIST db 13,10
            db '  *~*~*~*~*~*~*~*~*~LIST*~*~*~*~*~*~*~*~*~*',13,10
            db '  @               1.INPUT                 @',13,10
            db '  @               2.OUTPUT                @',13,10
            db '  @               3.SEARCH                @',13,10
            db '  @               4.CAL                   @',13,10
            db '  @               5.RANK                  @',13,10
            db '  @               0.QUIT                  @',13,10
            db '  *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*',13,10
            db 13,10,'$'
    student db '            ','$'  ; 学生姓名，最多12个字符，以0结束
    id db '          ','$'     ; 学生学号，最多10个字符，以0结束
    hos db '090 090 090 090 090 090 090 090 091 092 093 091 090 090 094 092 $'
    hos_total db '099 ','$'
    lastgrade dw 0,'$'         ; 大作业成绩
    total db 0,0        ; 总成绩
    huiche db 13,10,'$';一个回车

    ave_total dw 0,'$'

    rankis db 'rank: ',0,'$'

    final1 db 0,'$'
    final2 db 0,'$'

    data_s db '                                                                                            Dai Las Fin',0dh,0ah
        db '                                                                                            Dai Las Fin',0dh,0ah
        db '                                                                                            Dai Las Fin',0dh,0ah
        db '                                                                                            Dai Las Fin',0dh,0ah
        db '                                                                                            Dai Las Fin',0dh,0ah
        ;db 'NAMESXXXXXXX NUMBERSXXX 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 Dai las Fin',0dh,0ah
        db '$'
    
    hint1 db 13,10,'     NAME        ID           GRADE',13,10,'$'
    hint2 db 13,10,'student found! $'
    hint_lastgrade db 13,10,'lastgrade: ',13,10,'$'
    hint3 db 13,10,'INPUT ERROR! PLEASE AFRESH.',13,10,'$'
    hint4 db 13,10,'(Press 2 to show list)INPUT YOUR CHOICE:','$'
    hint5 db 13,10,'sorry,can not find this student!','$'
    hint6 db 'The last 3 number is homework,last homework,and final score',13,10,'$'

    student_final_score db 0,0,0,0,0      ;存储学生最终成绩
    student_level db 0,0,0,0,0,'$'            ;存储所在分段学生个数
    lev1 db 'level 1:100 ~90:  ',13,10,'$'
    lev2 db 'level 2:89 ~ 80:  ',13,10,'$'
    lev3 db 'level 3:79 ~ 60:  ',13,10,'$'
    lev4 db 'level 4:60 ~ 0 :  ',13,10,'$'
    high_score db 'Highest | Daily:    Last:    Final:    ','$'
    low_score  db 'lowest  | Daily:    Last:    Final:    ','$'
    av_da db 'the average daliy score:   ',13,10,'$'
    av_la db 'the average last_ score:   ',13,10,'$'
    av_fi db 'the average final score:   ',13,10,'$'
    average_daily dw 0,'$'
    average_last dw 0,'$'
    average_final dw 0,'$'
    ; 提示信息
    name_prompt db 13,10,'Please enter student name: $'
    id_prompt db 13,10,'Please enter student id: $'
    home_prompt db 13,10,'Please enter student homework scores: $'
    lastgrade_prompt db 13,10,'Please enter student lastgrade work score: $'
    total_prompt db 13,10,'Final score: $'
    search_prompt db 13,10,'Search by name input 1,search by id input 2(input other keys to quit): $'
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

;学生成绩排序交换宏定义
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
choice proc near;;
    mov ax,data
    mov ds,ax
    shuchu hint4
	shuru		;调用宏输入一个字符
    cmp al,49   ;if al==1
    je  inp	    ;调用输入功能
	cmp al,50   ;if al==2
    je out_p
    cmp al,51   ;if al==3
    je sear
    cmp al,52   ;if al==4
    je calculate
    cmp al,53   ;if al==5
    je ran
    cmp al,48   ;if al==0	
    je Exit
    shuchu WARNING
    ret         ;返回调用的地方
inp:
    mov cx,5            ;存储的数组有多少行，跟着in_put的第二行的ax改动
inp_s:
    call in_put
    loop inp_s
    jmp choice
out_p:
    call out_put
    jmp choice
calculate:
    mov ax,data
    mov ds,ax
    shuchu rank_prompt
    mov cx,5
calculate_s:
    
    push cx
    mov ax,5
    sub ax,cx
    mov bl,105
    mul bl
    mov bx,offset data_s
    add bx,ax
    call cal_culate
    pop cx
    loop calculate_s
    call grade_levels
    call average_and_hilo
    jmp choice

ran:
    call ra_nk
    jmp choice

sear:
    call search
    shuchu huiche
    jmp choice


choice endp

;*****************************************
;已知一个学生所有数据的一行数组有105个字节
;*****************************************
in_put proc near
    push cx         ;关乎第几行的记录，返回前先存着
    mov ax,5                ;算出现在是第几行的操作
    sub ax,cx               ;用总行数减去当前循环的次数，等于现在第几行，保存到ax中             
    mov bx,105              ;一行数组有101个字节
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

;******************************************

;总输出子程序

;******************************************

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

;*****************************************

;成绩排序子程序

;*****************************************
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


    exchange_stu                ;交换

continue_cal_final:
    mov al,0
    mov ds:[di],al
    mov ds:[bp],al
    add bx,105          ;进入到下一行比较
    loop cal_final        ;loop一起消耗着内循环的cx

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

;****************************

;搜索查找子程序

;****************************

search proc near
    mov ax,data
    mov ds,ax
sear_again:
    shuchu search_prompt
    shuru
    cmp al,49       ;al==1
    je sear_by_name
    cmp al,50       ;al==2
    je sear_by_id
    shuchu WARNING
    ret

;****************************
;用名字搜索
;****************************
sear_by_name:
    shuchu name_prompt
    mov cx,12
    mov bx,offset student
    mov si,0
n_in_search:
    shuru
    cmp al,0dh              ;检查回车
    je n_ss_search
    mov ds:[bx+si],al       ;先将输入的字符串存好
    inc si
    loop n_in_search
    
n_ss_search:
    mov cx,5                ;一共5行数据
    mov si,0                ;si记得清零！
    mov bx,offset student
    mov bp,offset data_s
    
n_s1_search:
    push cx
    mov cx,12               ;姓名12个空间  
n_s2_search:   
    mov ah,ds:[bx+si]
    mov al,ds:[bp+si]    
    cmp ah,al
    jne n_s3_search                ;相等就继续比较,不相等就跳走

    inc si
    cmp si,12               ;是不是12个字符都准确
    je output_student
    
    loop n_s2_search
n_s3_search:
    mov si,0               ;到下一行开始
    add bp,105
    pop cx
    loop n_s1_search
    shuchu hint5
    jmp far ptr sear_again

;********************************************
;用id搜索
sear_by_id:
    shuchu id_prompt
    mov cx,11               ;学号10个位
    mov bx,offset id
    mov si,0
id_in_search:
    shuru
    cmp al,0dh              ;检查回车
    je id_ss_search
    mov ds:[bx+si],al       ;先将输入的字符串存好
    inc si
    loop id_in_search
    
id_ss_search:
    mov cx,5                ;一共5行数据
    mov si,0                ;si记得清零！
    mov bx,offset id
    mov bp,offset data_s
    
id_s1_search:
    push cx
    mov cx,10               ;学号10个空间  
id_s2_search:   
    mov ah,ds:[bx+si]
    mov al,ds:[bp+si+13]      ;学号字符开始的位置为13
    cmp ah,al
    jne id_s3_search                 ;相等就继续比较,不相等就跳走

    inc si
    cmp si,10               ;是不是10个字符都准确
    je output_student
    
    loop id_s2_search
id_s3_search:
    mov si,0               ;到下一行开始
    add bp,105
    pop cx
    loop id_s1_search
    shuchu hint5
    jmp far ptr sear_again

;最后找到正确的学生信息并输出
output_student:
    shuchu hint2    ;shuchuaccu data_s
    mov ah,2
    mov dl,13
    int 21h         ;补一个回车
    mov dl,10
    int 21h         ;补一个换行
    mov cx,104      ;每一行105个字符,0-104
    mov si,0
output_student_s:
    mov ah,2
    mov dl,ds:[bp+si]
    int 21h
    inc si
    loop output_student_s
    jmp far ptr choice
search endp

;********************************

;成绩计算子程序

;********************************

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
    mov ds:[si],ax          ;先对缓冲区清零;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;*************************************

;期末成绩评级

;*************************************

grade_levels proc near
;期末成绩评级
;将期末成绩的字符串转化为数字并比较
    mov bx,offset data_s
    mov di,offset student_final_score
    
    mov cx,5
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
    mov cx,5
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
    mov cx,5
level_reset:
    
    mov ds:[si],al
    mov ds:[di],al
    inc si
    inc di
    loop level_reset
    
    ret
grade_levels endp

average_and_hilo proc near
    ;平时成绩
    ;将字符数字变成实数并存入缓冲区
    shuchu huiche
    mov bx,offset data_s
    mov cx,5
av_and_hilo_s0:
    mov di,offset average_daily
    mov si,0
    mov ax,0
    mov al,ds:[bx+si+92]   ;百位,92为平时作业存储百位数的偏移地址
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+92]   ;十位
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+92]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[di],ax      ;存储
    add bx,105
    loop av_and_hilo_s0

    mov al,ds:[di]      ;低位在前，高位在后
    mov ah,ds:[di+1]    ;将平均数算平均前的总数传给ax
    
    mov bx,offset av_da
    mov dl,5
    div dl

    push ax             ;输出一个0在前面
    mov al,'0'
    mov ds:[bx+24],al    ;将字符保存
    pop ax

    mov dx,0
    mov si,2            ;存余数由个位存起   
    mov cx,2   
daily_av_oz: 
    mov ah,0            ;每次进来余数位先清零,用上次的商去除
    mov dl,10           ;将得到的数除以10
    div dl

	add ah,30h          ;将余数转换为字符
    mov ds:[bx+si+24],ah    ;将字符保存
    dec si
    loop daily_av_oz
    shuchu av_da
    mov al,0
    mov ds:[bx+24],al   ;清零
    mov ds:[bx+25],al
    mov ds:[bx+26],al
    mov ax,0
    mov ds:[di],al
    mov ds:[di+1],al

    mov bx,offset data_s
    mov cx,5
av_and_hilo_s1:
    ;大作业成绩
    ;将字符数字变成实数并存入缓冲区
    mov di,offset average_last
    mov si,0
    mov ax,0
    mov al,ds:[bx+si+96]   ;百位,96为大作业存储百位数的偏移地址
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+96]   ;十位
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+96]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[di],ax      ;存储
    add bx,105
    loop av_and_hilo_s1

    mov al,ds:[di]
    mov ah,ds:[di+1]

    mov bx,offset av_la
    mov dl,5
    div dl

    push ax             ;输出一个0在前面
    mov al,'0'
    mov ds:[bx+24],al    ;将字符保存
    pop ax

    mov dx,0
    mov si,2            ;存余数由个位存起   
    mov cx,2   
last_av_oz: 
    mov ah,0            ;每次进来余数位先清零,用上次的商去除
    mov dl,10           ;将得到的数除以10
    div dl

	add ah,30h          ;将余数转换为字符
    mov ds:[bx+si+24],ah    ;将字符保存
    dec si
    loop last_av_oz
    shuchu av_la
    mov al,0
    mov ds:[bx+24],al
    mov ds:[bx+25],al
    mov ds:[bx+26],al
    mov ax,0
    mov ds:[di],al
    mov ds:[di+1],al

    mov bx,offset data_s
    mov cx,5
av_and_hilo_s2:
    ;大作业成绩
    ;将字符数字变成实数并存入缓冲区
    mov di,offset average_final
    mov si,0
    mov ax,0
    mov al,ds:[bx+si+100]   
    sub al,30h          ;将字符串转换为数字
    mov dl,100      ;百位的数乘100
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+100]   ;十位
    sub al,30h          ;将字符串转换为数字
    mov dl,10       ;十位的数乘10
    mul dl
    add ds:[di],ax      ;存储
    inc si

    mov al,ds:[bx+si+100]   ;个位
    sub al,30h          ;将字符串转换为数字
    add ds:[di],ax      ;存储
    add bx,105
    loop av_and_hilo_s2

    mov al,ds:[di]
    mov ah,ds:[di+1]

    mov bx,offset av_fi
    mov dl,5
    div dl

    push ax             ;输出一个0在前面
    mov al,'0'
    mov ds:[bx+24],al    ;将字符保存
    pop ax

    mov dx,0
    mov si,2            ;存余数由个位存起   
    mov cx,2   
final_av_oz: 
    mov ah,0            ;每次进来余数位先清零,用上次的商去除
    mov dl,10           ;将得到的数除以10
    div dl

	add ah,30h          ;将余数转换为字符
    mov ds:[bx+si+24],ah    ;将字符保存
    dec si
    loop final_av_oz

    shuchu av_fi
    mov al,20h
    mov ds:[bx+24],al
    mov ds:[bx+25],al
    mov ds:[bx+26],al
    mov ax,0
    mov ds:[di],al
    mov ds:[di+1],al

    mov bx,offset data_s
    mov bp,offset low_score
    ;最高最低输出
    mov si,0
    mov al,ds:[bx+si+92]
    mov ds:[bp+si+16],al
    inc si
    mov al,ds:[bx+si+92]
    mov ds:[bp+si+16],al
    inc si
    mov al,ds:[bx+si+92]
    mov ds:[bp+si+16],al
    mov si,0

    mov al,ds:[bx+si+96]
    mov ds:[bp+si+25],al
    inc si
    mov al,ds:[bx+si+96]
    mov ds:[bp+si+25],al
    inc si
    mov al,ds:[bx+si+96]
    mov ds:[bp+si+25],al
    mov si,0

    mov al,ds:[bx+si+100]
    mov ds:[bp+si+35],al
    inc si
    mov al,ds:[bx+si+100]
    mov ds:[bp+si+35],al
    inc si
    mov al,ds:[bx+si+100]
    mov ds:[bp+si+35],al
    mov si,0
    shuchu low_score
;最高成绩输出
    shuchu huiche
    shuchu huiche
    mov si,0
    mov bx,offset data_s
    mov bp,offset high_score
    add bx,420
    mov al,ds:[bx+si+92]
    mov ds:[bp+si+16],al
    inc si
    mov al,ds:[bx+si+92]
    mov ds:[bp+si+16],al
    inc si
    mov al,ds:[bx+si+92]
    mov ds:[bp+si+16],al
    mov si,0

    mov al,ds:[bx+si+96]
    mov ds:[bp+si+25],al
    inc si
    mov al,ds:[bx+si+96]
    mov ds:[bp+si+25],al
    inc si
    mov al,ds:[bx+si+96]
    mov ds:[bp+si+25],al
    mov si,0

    mov al,ds:[bx+si+100]
    mov ds:[bp+si+35],al
    inc si
    mov al,ds:[bx+si+100]
    mov ds:[bp+si+35],al
    inc si
    mov al,ds:[bx+si+100]
    mov ds:[bp+si+35],al
    mov si,0
    shuchu high_score
    ret
average_and_hilo endp
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