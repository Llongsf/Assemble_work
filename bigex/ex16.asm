assume cs:code,ds:data

data segment
	; 提示信息
	list_d db '***Setting your name and password***',0dh,0ah,'$'
	name_p1 db 'Please enter your name(0-20 characters): ','$'
	password_p1 db 'Please enter your password(0-20 characters): ','$'
	name_p2 db 'Please enter your name again: ','$'
	password_p2 db 'Please enter your password again: ','$'
	setsuccessful db 'Account setting is successful!: ','$'
	wrongstring db 0dh,0ah,'The input is not correct! ',0dh,0ah,'$'
	;账号和密码放置缓冲区
    buffer1 db 20 dup(0)
	buffer2 db 20 dup(0)
	bufferc1 db 20 dup(0)
	bufferc2 db 20 dup(0)
	
data ends

;****************************************

;****************************************

;单字符输入宏定义
shuru macro
	mov ah,1	;键盘输入并回显
	int 21h
ENDM

;字符串输出宏定义
shuchu macro ad	
	mov ah,09h
	mov dx,offset ad
	;lea dx,ad
	int 21h
ENDM
;****************************************

code segment

;****************************************
;子程序功能定义

start:	

; 输入账号定义
input_account:
	mov ax,data
	mov ds,ax
	shuchu list_d ;输出开头
	shuchu name_p1	;调用宏输出	
	mov si,offset buffer1
shuru_a:
	shuru
	cmp al,0dh     ;检测是否是回车
	je input_password
	mov [si],al
	inc si
	jmp shuru_a
	


; 输入密码定义
input_password:
	shuchu password_p1	;调用宏输出
	mov ax,data
	mov ds,ax
	mov si,offset buffer2
shuru_p:
	shuru
	cmp al,0dh     ;检测是否是回车
	je check_name
	mov [si],al
	inc si
	jmp shuru_p

;**********************************
;检查部分
;**********************************	

;完成第一次输入,检查账号
check_name:
	mov ax,data
	mov ds,ax	
	mov bx,offset buffer1
	mov si,0
	mov cx,0
	shuchu name_p2
	
cshurua:
	shuru
	cmp al,0dh	;检测回车
	je c_n
	mov [bx+si+40],al
	inc si
	inc cx			;累计cx
	jmp cshurua		;没回车继续输入
c_n:
	mov si,0
	mov di,0
	mov cx,20
check_error1:
	mov ah,[bx+di]	;检测错误
	mov al,[bx+si+40]
	cmp al,ah	;逐个字节检测
	jne outputwrong1	;错了就回炉重造
	inc di
	inc si
	dec cx
	jcxz check_password		;cx=0就跳走
	jmp check_error1
	
;输错账号了   
outputwrong1:
	mov ax,data
	mov ds,ax
	shuchu wrongstring
	jmp check_name
	
;**********************************

;**********************************	

;检查完账号检查密码
check_password:
	mov ax,data
	mov ds,ax	
	mov bx,offset buffer2
	mov si,0
	mov cx,0
	shuchu password_p2
	
cshuru_p:
	shuru
	cmp al,0dh	;检测回车
	je c_p
	mov [bx+si+40],al
	inc si
	inc cx			;累计cx
	jmp cshuru_p		;没回车继续输入
c_p:
	mov si,0
	mov di,0
	mov cx,20
check_error2:
	mov ah,[bx+di]	;检测错误
	mov al,[bx+si+40]
	cmp al,ah	;逐个字节检测
	jne outputwrong2	;错了就回炉重造
	inc di
	inc si
	dec cx
	jcxz endcode	;cx=0就跳走
	jmp check_error2

;输错密码了
outputwrong2:
	mov ax,data
	mov ds,ax
	shuchu wrongstring
	jmp check_password
	
endcode:
	shuchu setsuccessful
	mov ax,4c00h
	int 21h
code ends
end start 