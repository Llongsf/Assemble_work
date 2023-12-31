DATA SEGMENT
	TIP DB 'INPUT THE NUMBER: ','$'
	TIP1 DB '  <=>  ','$'
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA
START:
	MOV AX,DATA
	MOV DS,AX
	LEA DX,TIP
	MOV AH,09H
	INT 21H

INPUT:
	MOV AH,1
	INT 21H
	CMP AL,30H
	JB EXIT
	CMP AL,39H
	JA COMPER1
	JMP CHANGE1    ;在0~9之间
COMPER1:
	CMP AL,41H
	JB EXIT
	CMP AL,46H
	JA COMPER2
	JMP CHANGE2    ;在A-F之间
COMPER2:
	CMP AL,61H
	JB EXIT
	CMP AL,66H
	JA EXIT
	JMP CHANGE3    ;在a~f之间

CHANGE1:
	SUB AL,30H
	JMP ENT
CHANGE2:
	SUB AL,37H
	JMP ENT
CHANGE3: 
	SUB AL,57H
	JMP ENT
ENT:
	MOV BL,AL
	LEA DX,TIP1
	MOV AH,09H
	INT 21H
	MOV AL,BL
	MOV AH,0
	MOV BL,10
	DIV BL
	MOV DH,AH
	CMP AL,0
	JE ONE
	MOV DL,AL      ;十位数是1
	ADD DL,30H
	MOV AH,02H
	INT 21H
ONE:	                        ;十位数是0
	MOV DL,DH
	ADD DL,30H
	MOV AH,02H
	INT 21H
EXIT:
	MOV AH,4CH
	INT 21H
CODE ENDS
END START
