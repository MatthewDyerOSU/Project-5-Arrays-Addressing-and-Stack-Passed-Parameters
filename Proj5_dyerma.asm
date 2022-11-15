TITLE Project 5: Arrays, Addressing, and Stack Passed Parameters     (Proj5_dyerma.asm)

; Author: Matthew Dyer
; Last Modified: 11/14/22
; OSU email address: dyerma@oregonstate.edu
; Course number/section:   CS271/Fall 2022
; Project Number: 5              Due Date: 11/20/22
; Description: This program will introduce itself by supplying the program title and author.
;	Then it will generate ARRAYSIZE amount of numbers between LO and HI, inclusive. The program
;	will then sort those numbers in ascending order, display the median of the list of numbers,
;	then display the sorted list. Lastly the program will count up each instance of each number,
;	and display those counts starting with the lowest value. The program will end with an outtro,
;	thanking the user for using the program.

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
outtro			BYTE	"Goodbye, and thanks for using my program!",13,10,0
countArray		DWORD	(HI-LO)+1	DUP(0)	
countLength		DWORD	LENGTHOF countArray
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
	PUSH	ARRAYSIZE
	PUSH	OFFSET	randArray
	PUSH	OFFSET	space
	PUSH	OFFSET	unsortedString
	CALL	displayList
	CALL	CrLf

; Sort randArray in ascending order
	PUSH	OFFSET	randArray
	CALL	sortList

; Calculate the median number and display it
	PUSH	OFFSET	randArray
	PUSH	OFFSET	medianString
	CALL	displayMedian
	CALL	CrLf
	CALL	CrLf

; Display the sorted array
	PUSH	ARRAYSIZE
	PUSH	OFFSET	randArray
	PUSH	OFFSET	space
	PUSH	OFFSET	sortedString
	CALL	displayList
	CALL	CrLf

; Count each instance of each number and place those counts in new array (countArray)
	PUSH	OFFSET	countArray
	PUSH	OFFSET	randArray
	CALL	countList

; Display countArray
	PUSH	countLength
	PUSH	OFFSET	countArray
	PUSH	OFFSET	space
	PUSH	OFFSET	instanceString
	CALL	displayList
	CALL	CrLf
	CALL	CrLf

; Goodbye to user
	PUSH	OFFSET	outtro
	CALL	goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-----------------------------------------------------------------------------------------
; Name: introduction
;
; Introduces the user to the program with title, author name, and description of program
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: intro1 and intro2 by reference
;
; Returns: None
;
;-----------------------------------------------------------------------------------------
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
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Name: fillArray
;
; Generates random numbers within inclusive bounds of LO to HI, ARRAYSIZE amount of times,
;	filling randArray.	
;
; Preconditions: array filled with DWORDS
;
; Postconditions: NONE
;
; Receives: empty randArray by reference
;
; Returns: filled randArray by reference
;
;-----------------------------------------------------------------------------------------
fillArray PROC
	PUSH	EBP	
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	ECX
	PUSH	EDI
	MOV		ECX, ARRAYSIZE
	MOV		EDI, [EBP+8]
	_fillLoop:
; Subtract LO from HI and add 1, take that number and generate a random one between 0 and that number,
;	then add LO to random number. This will give number between LO and HI, inclusive
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
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Name: sortList
;
; Takes randArray and bubble sorts it in ascending order, returning a sorted array.
;
; Preconditions: array filled with DWORDS
;
; Postconditions: None
;
; Receives: unsorted randArray by reference
;
; Returns: sorted randArray by reference
;
;-----------------------------------------------------------------------------------------
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
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Name: exchangeElements
;
; Exchanges adjacent elements in an array
;
; Preconditions: DWORD sized elements
;
; Postconditions: None
;
; Receives:	randArray by reference
;
; Returns: randArray by reference
;
;-----------------------------------------------------------------------------------------
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
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Name: displayMedian
;
; Finds and displays the median element in array. If array has odd amount of elements, 
;	finds the middle element. If array has even amount of elements, finds the middle 2
;	elements, and finds the average between them, rounding up.
;
; Preconditions: DWORD sized elements
;
; Postconditions: None
;
; Receives: randArray by reference, medianString by reference
;
; Returns: Writes median found to terminal
;
;-----------------------------------------------------------------------------------------
displayMedian PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX
	MOV		ESI, [EBP+12]
; Check if ARRAYSIZE is even or odd
	MOV		EAX, ARRAYSIZE
	MOV		EBX, 2
	CDQ
	DIV		EBX
	CMP		EDX, 0
	JE		_isEven
; If odd, find the middle element
	MOV		EDX, [EBP+8]
	MOV		EAX, [ESI+((4*ARRAYSIZE+1)/2)]
	JMP		_medianFound
	_isEven:
		MOV		EAX, [ESI+4*ARRAYSIZE/2]
		MOV		EBX, [ESI+(4*ARRAYSIZE/2)+4]		; EAX = middle element, EBX = middle element +1	
		ADD		EAX, EBX
		MOV		EBX, 2
		CDQ
		DIV		EBX
		CMP		EDX, 1			; we divide by 2 so if remainder (EDX) is 1, then decimal would end in .5, so round up
		JNE		_dontRound
		INC		EAX
		_dontRound:
			MOV		EDX, [EBP+8]
	_medianFound:
		CALL	WriteString
		CALL	WriteDec
		POP		EDX
		POP		EBX
		POP		EAX
		POP		ESI
		POP		EBP
		RET		8
displayMedian ENDP
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Name: displayList
;
; Displays the array to the terminal, 20 elements per line, each with 1 space between them.
;
; Preconditions: DWORD sized elements
;
; Postconditions: None
;
; Receives: someTitle string and space string by reference, someArray by reference,
;	someArraySize by value
;
; Returns: Writes list to terminal
;
;-----------------------------------------------------------------------------------------
displayList PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	MOV		EBX, 0
	MOV		ESI, [EBP+16]
	MOV		EDX, [EBP+8]
	MOV		ECX, [EBP+20]
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
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Name: countList
;
; Counts the instances of each element in a provided array, and places those counts in a new
;	array.
;
; Preconditions: DWORD sized elements
;
; Postconditions: None
;
; Receives: randArray by reference
;
; Returns: countArray by reference
;
;-----------------------------------------------------------------------------------------
countList PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EDI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	MOV		ESI, [EBP+8]	; randArray
	MOV		EDI, [EBP+12]	; countArray
	MOV		EBX, LO
	MOV		ECX, ARRAYSIZE
	_countLoop:
		MOV		EAX, [ESI]
		ADD		ESI, 4
		CMP		EAX, EBX
		JNE		_noMatch
		INC		DWORD PTR [EDI]
		MOV		EDX, [EDI]
		JMP		_matchFound
		_noMatch:
			ADD		EDI, 4
			INC		DWORD PTR [EDI]
			INC		EBX
		_matchFound:
			LOOP	_countLoop
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EDI
	POP		ESI
	POP		EBP
	RET		8
countList ENDP
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Name: goodbye
;
; Says goodbye to the user
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: outtro string by reference
;
; Returns: Writes outtro to terminal
;
;-----------------------------------------------------------------------------------------
goodbye	PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX
	MOV		EDX, [EBP+8]
	CALL	WriteString
	POP		EBP
	RET		4
goodbye ENDP
;-----------------------------------------------------------------------------------------

END main
