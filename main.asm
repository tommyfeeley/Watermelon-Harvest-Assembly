TITLE Lab for i09 Spring 20						(main.asm)

; Programmed by:	Thomas Feeley
;
; Description:		Final Project - Watermelon Harvest
;
; Date Written:     5/3/2021 - Portions of Final Project based on Lab i09 written by Professor Brower
;										

INCLUDE Irvine32.inc

; (insert symbol definitions here)

MAX_ROWS = 12			; constant for num rows
MAX_COLS = 12			; constant for num cols

M = 8					; constant for 80% calculation
D = 10					; constant for 80% calculation

.data

my2DArray dword MAX_ROWS * MAX_COLS dup(0)		; creates 2-d array

rowEntered DWORD 0		; to hold row entered by user
colEntered DWORD 0		; to hold column entered by user

											; labels and prompts
spaceStr byte " ",0							; for displaying a space
columnHeaderSpaces byte "     ",0			; 5 spaces for column headers			
												  
displayHeader BYTE "Field of Watermelons: ",0				; string to display before report
rowPrompt BYTE "Enter row (Type 99 to Quit): ",0			; prompt for row
colPrompt BYTE "Enter col: ",0								; prompt for col
valueLabel BYTE "Watermelon within the section: ",0			; label for value from array
pickedLabel BYTE "Watermelon Picked: ", 0					; label for total amount value
totalLabel BYTE "Total Watermelon Picked: ", 0				; label for total watermelons picked
amountLabel BYTE "Different Field Sections Visited: ", 0	; label for amount of times program was used
errorLabel BYTE "Row/Column Chosen Does Not Exist", 0		; label for failing to enter within the range

watermelonPicked DWORD ?	; holds watermelons picked per turn
totalWatermelon DWORD 0		; holds the total amount of watermelons picked
timesPicked DWORD 0			; holds the amount of times harvested

.code
main PROC
	call randomize			; stir the pot of random numbers

	; code  to generate the 2D array

	MOV ECX, MAX_ROWS * MAX_COLS		; load ECX with total # of elements
	MOV ESI, OFFSET my2DArray			; load ESI with the address of the array (logically)

genLoop:

	MOV EAX, 100						; load EAX with 100 for generating a random number
	call randomRange					; EAX now has a random number 0-99
	INC EAX								; EAX now has a random number 1-100
	
	MOV [ESI], EAX						; store random number to array

	ADD ESI, TYPE my2DArray				; move ESI to next element in array
	
	LOOP genLoop						; ECX --; if ECX > 0 goto genLoop



	call CRLF						; \n
									; display after generation  message

topLoop:
	call displayMy2DArray			; call proc to display array

	call CRLF						; \n

	
	mov edx, offset rowPrompt		; prompt user for row
	call writeString
	call readDec					; EAX has user input
	MOV rowEntered, EAX				; hold on to row

	CMP EAX, 99						; compare EAX to 99
	JE getOutOfHere					; if EAX is 99, leave!

	CMP EAX, MAX_ROWS				; compare eax to max_rows
	JGE error						; jump if greater than or equal to error function

	mov edx, offset colPrompt		; prompt user for col
	call writeString
	call readDec					; EAX has user input
	MOV colEntered, EAX				; hold on to col

	CMP EAX, 99						; compare EAX to 99
	JE getOutOfHere					; if EAX is 99, leave!
	
	CMP EAX, MAX_COLS				; compare eax to max_cols
	JGE error						; jump if greater than or equal to error function

									; for this lab we will assume the user entered a valid row/col
	mov eax, rowEntered				; load EAX with row for call to getElementFromArray
	mov ebx, colEntered				; load EbX with col for call to getElementFromArray
	call getElementFromArray		; ecx will have value

	mov eax, ecx					; move value from array into EAX for displaying

	call CRLF

	; display value 
	mov edx, offset valueLabel		; display label for value
	call writeString
	call writeDec					; display value from array
	call CRLF						; \n

	call CRLF						; \n

	call getAmountOfValue			; run through code to get 80% of total watermelons
	mov eax, watermelonPicked		; load eax with watermelons picked
	mov edx, offset pickedLabel		; load edx with caughLabel
	call writeString				; display label
	call writeDec					; display watermelonPicked value
	call CRLF						; \n

	jmp topLoop						; unconditional jump to top of loop

error:
	call CRLF						; \n

	mov edx, offset errorLabel		; load edx with errorLabel
	call writeString				; display label
	call CRLF						; \n
	JMP getOutOfHere				; jump to getOutOfHere

getOutOfHere:
	call CRLF

	mov eax, totalWatermelon		; load eax with totalWatermelon
	mov edx, offset totalLabel		; load edx with totalLabel
	call writeString				; display label
	call writeDec					; display totalWatermelon value
	call CRLF						; \n

	call CRLF						; \n
	
	mov eax, timesPicked			; load eax with timesPicked
	mov edx, offset amountLabel		; load edx with amountLabel
	call writeString				; display label
	call writeDec					; display timesPicked value
	call CRLF						; \n

	exit							; let's get out of here!
main ENDP

setElementOfArray PROC uses edx edi

	mov edx, 0				; prepare for mul
	push ebx				; put ebx the column on the stack
	mov ebx, MAX_COLS*4		; calculate the number of bytes in a row
	mul ebx					; eax is now rowNum * MAX_COLS*4
	mov edi, eax			; byte offset into edi
	pop eax					; ebx on the stack which was the colNum
	mov ebx, 4				; load ebx with 4 for size of element
	mul ebx					; eax is  colNum*4 
	add edi, eax			; edi is rowNum * MAX_COLS*4 + colNum*4

	mov my2DArray[edi], ecx ; load value in ecx into array
	ret
setElementOfArray ENDP

getElementFromArray PROC 

	mov edx, 0				; prepare for mul
	push ebx				; put ebx the column on the stack
	mov ebx, MAX_COLS*4		; calculate the number of bytes in a row
	mul ebx					; eax is now rowNum * MAX_COLS*4
	mov edi, eax			; byte offset into edi
	pop eax					; ebx on the stack which was the colNum
	mov ebx, 4				; load ebx with 4 for size of element
	mul ebx					; eax is colNum*4 
	add edi, eax			; edi is rowNum * MAX_COLS*4 + colNum*4

	mov ecx, my2DArray[edi] ; load value of array into ecx

	ret
getElementFromArray ENDP

getAmountOfValue PROC
	
	mov eax, ecx			; load eax with value from ecx
	mov ebx, M				; load ebx with constant value M

	iMul ebx				; multiply eax and ebx -- product stored in eax

	mov ebx, D				; load ebx with constant value D

	IDiv ebx				; divide eax by ebx -- quotient stored in eax

	mov watermelonPicked, eax		; load watermelonPicked with value from eax

	add totalWatermelon, eax		; add the eax to the totalWatermelon

	add timesPicked, 1		; increase timesPicked by 1


	ret
getAmountOfValue ENDP

displayMy2DArray PROC uses edx edi ecx eax

	call crlf							; blank line
	mov edx, offset displayHeader		; load edx with address of header
	call writestring					; display header
	call crlf							; move to beginning of next line

	; display columns

										; first, display 5 spaces
	mov edx, offset columnHeaderSpaces
	call writeString					; display spaces so columns start over data

	mov ECX, MAX_COLS					; prep ECX for loop
	mov EAX, 0							; start at column 0

displayColumnHeaderLoop:
	call padOnLeft						; display spaces on left so col #s line up with columns
	call writeDec						; display ECX aka column number

	mov edx, offset spaceStr			; display a space
	call writestring

	inc eax								; next column
	
	LOOP displayColumnHeaderLoop		; ECX--; if ECX > 0 goto displayColumnHeaderLoop

	call crlf							; \n

	mov edi, 0							; load edi with 0 offset

	mov ecx, MAX_ROWS					; load ecx with number of rows so we can loop through rows

displayRow:								; top of outerloop on rows

    mov eax, MAX_ROWS					; load EAX with the # of rows
	sub eax, ecx						; subtract the ECX to get row #

	call padOnLeft						; display spaces on left so row #s line up if double digit rows
	call writeDec						; display row#

	mov eax, ':'						; prep for display char
	call writeChar						; display :

	push ecx							; preserve ecx from outloop to use innerloop

	mov ecx, MAX_COLS					; load ecx with number of cols so we can loop through cols

displayCol:								; top of innerloop on cols

	mov eax, my2DArray[edi]				; move element from array to eax for display
	call padOnLeft						; pad with spaces

										; for debugging purposes show . instead of 0
    cmp eax, 0
	jne displayDec
		push eax						; preserve EAX
		mov al, '.'						; display .
		call writeChar
		pop eax							; restore EAX
		jmp skipDisplayDec

displayDec:
		call writedec					; display element			
		

skipDisplayDec:


continue:

	mov edx, offset spaceStr			; display a space
	call writestring

	add edi,4							; advance dsi to next element

	loop displayCol						; bottom of innerloop (loop on cols)

	call crlf							; now that a row has been displayed, move to beginning of next line for next row

	pop ecx								; restore ecx for outerloop on rows

	loop displayRow						; bottom of outerloop (loop on rows)

	ret									; done with this method
displayMy2DArray ENDP

padOnLeft PROC uses edx

    cmp eax, 1000						; compare eax to 1000
	jae maxedOut						; if eax >= 1000 - no need to further pad

										; < 1000 display space
	mov edx, offset spaceStr			; display space
	call writestring

nextDigit100:

	cmp eax, 100						; compare eax to 100
    jae maxedOut						; if eax >= 100 no need to further pad

										; < 100 display space
	mov edx, offset spaceStr			; display space
	call writestring

nextDigit10:

    cmp eax, 10							; compare eax to 10
	jae maxedOut						; if eax >= 10 no need to further pad

										; < 10 display space
	mov edx, offset spaceStr			; display space
	call writestring

maxedOut:		

	ret
padOnLeft ENDP

END main