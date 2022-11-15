TITLE Project 5: Arrays, Addressing, and Stack Passed Parameters     (Proj5_dyerma.asm)

; Author: Matthew Dyer
; Last Modified: 11/14/22
; OSU email address: dyerma@oregonstate.edu
; Course number/section:   CS271
; Project Number: 5              Due Date: 11/20/22
; Description: This program will introduce itself

INCLUDE Irvine32.inc

ARRAYSIZE = 200
LO = 15
HI = 50

.data

; (insert variable definitions here)
intro1			BYTE	"Generating, Sorting, and Counting Random Integers! Programmed by Matthew Dyer",13,10,13,10,
					"This program generates 200 random integers between 15 and 50, inclusive.",0
intro2			BYTE	"It then displays the original list, sorts the list, displays the median value of the list,",13,10,
					"displays the list sorted in ascending order, and finally displays the number of instances",13,10,
					"of each generated value, starting with the lowest number.",13,10,0
randArray		DWORD	ARRAYSIZE	DUP(?)
space			BYTE	" ",0
unsortedString	BYTE	"Your unsorted random numbers:",0
medianString	BYTE	"The median value of the array: ",0
sortedString	BYTE	"Your sorted random numbers:",0
instanceString	BYTE	"Your list of instances of each generated number, starting with the smallest value:",0
outtro			BYTE	"Goodbye, and thanks for using my program!",0

.code

main PROC

; Initialize starting seed value of the RandomRange procedure
	CALL	Randomize

; Introduce the title and author, and describe the program
	PUSH	OFFSET	intro1
	PUSH	OFFSET	intro2
	CALL	introduction

; Generate ARRAYSIZE random numbers between LO and HI inclusive, and store them consecutively in an array
	PUSH	OFFSET	randArray
	CALL	fillArray

; Loop through randArray and print all numbers, 10 per line
	PUSH	OFFSET	randArray
	PUSH	OFFSET	space
	PUSH	OFFSET	unsortedString
	CALL	displayList
	CALL	CrLf

	PUSH	OFFSET	randArray
	CALL	sortList



	PUSH	OFFSET	randArray
	PUSH	OFFSET	space
	PUSH	OFFSET	sortedString
	CALL	displayList
	CALL	CrLf

	PUSH	OFFSET	randArray
	PUSH	OFFSET	space
	PUSH	OFFSET	instanceString
	CALL	displayList
	CALL	CrLf





	Invoke ExitProcess,0	; exit to operating system
main ENDP

introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX
	MOV		EDX, [EBP+12]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP+8]
	CALL	WriteString
	CALL	CrLf
	POP		EDX
	POP		EBP
	RET		8
introduction ENDP

fillArray PROC
	PUSH	EBP	
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	ECX
	PUSH	EDI
	MOV		ECX, ARRAYSIZE
	MOV		EDI, [EBP+8]
	_fillLoop:
		MOV		EAX, HI
		SUB		EAX, LO
		INC		EAX
		CALL	RandomRange
		ADD		EAX, LO
		MOV		[EDI], EAX
		ADD		EDI, 4
		LOOP	_fillLoop
	POP		EDI
	POP		ECX
	POP		EAX
	POP		EBP
	RET		4
fillArray ENDP

sortList PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	ECX
	PUSH	EDX
	_sortLoop:
		MOV		EDX, 0			; Exchange made boolean, 1 if exchange was made, 0 if not
		MOV		ESI, [EBP+8]
		MOV		ECX, ARRAYSIZE
		DEC		ECX
		_exchangeLoop:
			MOV		EAX, [ESI]
			CMP		EAX, [ESI+4]
			JLE		_noExchange
; Push the array onto the stack as a by reference param for exhangeElements, set EDX to 1 to flag as exchange made
			PUSH	ESI
			CALL	exchangeElements
			MOV		EDX, 1

			_noExchange:
				ADD		ESI, 4
				LOOP	_exchangeLoop
; If EDX is 1, an exchange was made, so start the loop again
			CMP		EDX, 1
			JE		_sortLoop


	POP		EDX
	POP		ECX
	POP		ESI
	POP		EBP
	RET		4

sortList ENDP

exchangeElements PROC
	PUSH	EBP
	MOV		EBP, ESP
	MOV		ESI, [EBP+8]
	MOV		EAX, [ESI]
	MOV		EBX, [ESI+4]
	MOV		[ESI+4], EAX
	MOV		[ESI], EBX
	POP		EBP
	RET		4
exchangeElements ENDP

displayMedian PROC
	PUSH	EBP
	MOV		EBP, ESP
	MOV		ESI, [EBP+8]
	MOV		ESI[

displayMedian ENDP

displayList PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	MOV		EBX, 0
	MOV		ECX, ARRAYSIZE
	MOV		ESI, [EBP+16]
	MOV		EDX, [EBP+8]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP+12]
	_displayLoop:
		MOV		EAX, [ESI]
		CALL	WriteDec
		CALL	WriteString
		ADD		ESI, 4
		INC		EBX
		CMP		EBX, 20
		JL		_noNewLine
		CALL	CrLf
		MOV		EBX, 0
		_noNewLine:
			LOOP	_displayLoop
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8	
displayList ENDP

countList PROC
countList ENDP

END main
