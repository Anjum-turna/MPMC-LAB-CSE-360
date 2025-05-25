.model small
.stack 100h
.data
    msg1 db "Enter first two-digit number: $"
    msg2 db 0Dh, 0Ah, "Enter second two-digit number: $"         ;$ for DOS interrupt 21h function
    msg3 db 0Dh, 0Ah, "Enter operation (+, -, *, /): $"
    msg4 db 0Dh, 0Ah, "Result: $"
    num1 db ?
    num2 db ?
    op db ?              ;to store the operator char op
    result dw 0
.code
main:
    mov ax, @data
    mov ds, ax

    ; Display msg1
    lea dx, msg1         ;Load Effective Address,loads the offset(mem add) of msg1 to dx
    call print_string
    call read_number
    mov num1, al

    ; Display msg2
    lea dx, msg2
    call print_string
    call read_number
    mov num2, al

    ; Display msg3
    lea dx, msg3
    call print_string
    call read_char
    mov op, al

    ; Perform operation
    mov al, num1
    mov bl, num2
    mov ah, 0

    mov cl, op
    cmp cl, '+'
    je add_nums
    cmp cl, '-'
    je sub_nums
    cmp cl, '*'
    je mul_nums
    cmp cl, '/'
    je div_nums
    jmp end_program

add_nums:
    add al, bl
    jmp store_result

sub_nums:
    sub al, bl
    jmp store_result

mul_nums:
    mul bl    ; AL * BL ? AX
    mov result, ax
    jmp show_result

div_nums:
    cmp bl, 0
    je end_program ; Prevent divide by zero
    xor ah, ah
    div bl    ; AL / BL ? AL = quotient
    jmp store_result

store_result:
    mov ah, 0
    mov result, ax

show_result:
    ; Display msg4
    lea dx, msg4
    call print_string
    mov ax, result
    call print_number

end_program:
    mov ah, 4ch
    int 21h


; Subroutine: print_string

print_string proc
    mov ah, 09h
    int 21h
    ret
print_string endp



; Subroutine: read_char
read_char proc
    mov ah, 01h
    int 21h
    ret
read_char endp


; Subroutine: read_number
read_number proc
    call read_char
    sub al, '0'
    mov ah, 0
    mov cx, 10
    mul cx    ; tens digit * 10

    mov bh, al ; save tens in BH

    call read_char
    sub al, '0'
    add bh, al ; BH = full number
    mov al, bh
    ret
read_number endp   



;Subroutine: print_number
print_number proc
    mov bx, 10
    xor cx, cx

next_digit:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz next_digit

print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop
    ret
print_number endp

end main