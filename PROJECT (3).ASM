
;ronen yakobov-207688581
data segment
    msg1 db '>> please choose one of the following options: ', 10 , '1.Prime number checker',10,'2.Ceasars shift coder',10, '3.Exit $' , 10
    msg2 db '>>Enter a positive integer number N (255>N>2):$',10
    msg3 db '>>Type a string(only small characters in English):$',10
    msg4 db '>>Enter one decimal digit(between 2 to 9): $',10
    offset1 db ?
    
    msg5 db 'this is a prime number$',10
    msg6 db 'this is not a prime number$',10

    
    string1 db 20 dup(?)
    string2 db 20 dup(?)
    
    number dw ?
    
data ends

st1 segment stack
    db 256 dup(?)
    st1 ends

code segment
assume ds:data,cs:code,ss:st1
start:  
    mov ax,data
    mov ds,ax

menu:
    mov dx, offset msg1
    mov ah, 9 
    int 21h
    call newLine
    mov ah, 1
    int 21h
    cmp al, '1'
    je prime
    cmp al, '2'
    je shift
    cmp al, '3'
    jne menu
    je quit
prime:
    call newLine
    mov dx, offset msg2
    mov ah, 9 
    int 21h
    call input
    push number ;pushing to the stack the number recived from the user 
    call is_prime
    add sp,2 ;clear stack
    jmp menu


shift:
    mov dx, offset msg3
    mov ah, 9 
    int 21h
    call caesar
    jmp menu
quit:
    jmp sof

input proc
    call newLine
    xor bx,bx
    xor ax,ax
input_loop:
    mov ah,1
    int 21h
    cmp al,'.' ;end the loop
    je end_input
    sub al,'0' ;convert cahr to digit
    mov cl,al  ;temp register
    mov dx,10
    mov ax,bx  ;save the number in ax
    mul dx
    add ax,cx ;adding a new digit
    mov bx,ax 
    jmp input_loop

end_input:
    mov number,bx ;updating number 
    ret 
input endp

is_prime proc
    mov bp,sp
    push bx
    push cx
    push dx
    mov ax,[bp+2];load the number to ax
    mov bx,ax

    mov cx,2 ;the first divisor is 2
prime_test:
    xor dx,dx ;reset the reminder in dx each iteration
    div cx
    cmp dx,0
    je not_prime
    inc cx 
    mov ax,bx ;resting ax to the original value
    cmp cx,ax 
    jae primeNum ;if the divisor equal to the number then the number is prime
    jmp prime_test
primeNum:
    mov dx, offset msg5
    mov ah, 9 
    int 21h
    call newLine
    mov cx,ax   
    call triangel
    jmp endPrime

not_prime:
    mov dx, offset msg6
    mov ah, 9 
    int 21h
   call newLine
   call square
   jmp endPrime

endPrime:
;clearing the stack
    pop cx 
    pop dx
    pop bx
    ret
is_prime endp

    
caesar proc
    mov bp, sp
    mov si, offset string1
    mov di, offset string2

    ; Input the string
caesar_input:
    mov ah, 1
    int 21h
    cmp al, '.'        ; End of string
    je caesar_offset   ; Jump to offset input if '.' is entered
    mov [si], al       ; Store character in string1
    inc si
    jmp caesar_input

caesar_offset:
    mov bl,'$'
    mov [si], bl  ;end of string
    
    
    mov dx, offset msg4
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    
    sub al, '0'        ; Convert ASCII to decimal
    mov offset1, al    ; Store shift amount in offset1

    
    mov si, offset string1
    mov di, offset string2

shift_loop:
    mov al, [si]       ; Load the next character from string1
    cmp al, '$'        
    je shift_done
    sub al, 'a'        ; making sure the letters are in range of 0-25
    add al, offset1    
    cmp al, 26         ; Check if wrapping is needed
    jl no_wrap
    sub al, 26         ; else we go back to start if the number is bigger then 26
no_wrap:
    add al, 'a'        ; Convert back to ASCII

store_char:
    mov [di], al       ; Store the result in string2
    inc si
    inc di
    jmp shift_loop

shift_done:
    mov dl, '$'      ; end of string
    mov [di],dl

    call newLine
    mov dx, offset string2
    mov ah, 9
    int 21h
    call newLine

    ret
caesar endp


triangel proc
    push cx    ; Save the original value of cx

    mov bx, 1  ; Start with row 1

print_row:
    push bx    
    mov cx, bx 

print_column:
    mov dl, '@'
    mov ah, 2
    int 21h    ; Print '@'
    loop print_column  ; Loop until all '@' for the row are printed

    call newLine  

    pop bx  ; Restore the row number
    inc bx  ; Move to the next row
    cmp bx, [bp+2]  
    jbe print_row   ; If bx <= input number repeat 

    pop cx    ; Restore the original value of cx
    ret
triangel endp

square proc
    push cx    

    mov bx, [bp+2] 

print_square_row:
    push bx   ; the row counter
    mov cx, [bp+2] 

print_square_column:
    mov dl, '*'
    mov ah, 2
    int 21h   
    loop print_square_column  

    call newLine  

    pop bx   ; Restore the row counter
    dec bx   ; Decrease the row counter
    jnz print_square_row  ; If bx is not zero repeat 

    pop cx   ; Restore the original value of cx
    ret
square endp



newLine proc
    mov dl, 10
    mov ah, 2
    int 21h
    ret 
    newLine endp
sof:
    mov ah, 4Ch
    int 21h

code ends
end start
    