.model small
.stack 100h
.data
    welcome_msg db "Student Score Calculator", 0Dh, 0Ah, "$"
    prompt_name db "Enter student name: $"
    prompt_subjects db 0Dh, 0Ah, "Enter number of subjects (1-9): $"
    prompt_score db 0Dh, 0Ah, "Enter score for subject $"
    prompt_score_end db ": $"
    total_msg db 0Dh, 0Ah, "Total score: $"
    average_msg db 0Dh, 0Ah, "Average score: $"
    grade_msg db 0Dh, 0Ah, "Grade: $"
    
    ; Input buffer for student name (max 19 chars + CR)
    name_buffer db 20        
                db ?        
                db 20 dup(?) 
    
    num_subjects db ?
    current_subject db 1
    total_score dw 0
    average_score db ?
    grade db ?
    
    ; Grade thresholds
    grade_a db 90
    grade_b db 80
    grade_c db 70
    grade_d db 60
    
.code
main:
    mov ax, @data
    mov ds, ax
    
    ; Display welcome message
    lea dx, welcome_msg
    call print_string
    
    ; Get student name
    lea dx, prompt_name
    call print_string
    call read_name
    
    ; Get number of subjects
    lea dx, prompt_subjects
    call print_string
    call read_digit
    mov num_subjects, al
    
    ; Initialize subject counter
    mov current_subject, 1
    
input_scores:
    ; Display score prompt
    lea dx, prompt_score
    call print_string
    
    ; Display current subject number
    mov dl, current_subject
    add dl, '0'
    mov ah, 02h
    int 21h
    
    lea dx, prompt_score_end
    call print_string
    
    ; Read score (0-100)
    call read_score
    add total_score, ax
    
    ; Move to next subject
    inc current_subject
    mov al, current_subject
    cmp al, num_subjects
    jbe input_scores
    
calculate_results:
    ; Calculate average
    mov ax, total_score
    mov bl, num_subjects
    div bl          ; AL = AX / BL (average)
    mov average_score, al
    
    ; Determine grade
    cmp al, grade_a
    jae set_a
    cmp al, grade_b
    jae set_b
    cmp al, grade_c
    jae set_c
    cmp al, grade_d
    jae set_d
    mov grade, 'F'
    jmp display_results
    
set_a:
    mov grade, 'A'
    jmp display_results
set_b:
    mov grade, 'B'
    jmp display_results
set_c:
    mov grade, 'C'
    jmp display_results
set_d:
    mov grade, 'D'
    
display_results:
    ; Display student name
    lea dx, name_buffer+2  ; Skip first two bytes of buffer
    call print_string
    
    ; Display total score
    lea dx, total_msg
    call print_string
    mov ax, total_score
    call print_number
    
    ; Display average score
    lea dx, average_msg
    call print_string
    mov al, average_score
    mov ah, 0
    call print_number
    
    ; Display grade
    lea dx, grade_msg
    call print_string
    mov dl, grade
    mov ah, 02h
    int 21h
    
    ; End program
    mov ah, 4ch
    int 21h

; Subroutine: print_string
print_string proc
    mov ah, 09h
    int 21h
    ret
print_string endp

; Subroutine: read_name
read_name proc
    mov ah, 0Ah
    lea dx, name_buffer
    int 21h
    
    ; Null-terminate the string
    mov si, dx
    mov al, [si+1]         ; Get actual length
    xor ah, ah
    add si, ax
    add si, 2              ; Skip to end of string
    mov byte ptr [si], '$' ; Replace CR with string terminator
    ret
read_name endp

; Subroutine: read_digit
read_digit proc
    mov ah, 01h
    int 21h
    sub al, '0'
    ret
read_digit endp

; Subroutine: read_score 
read_score proc
    call read_digit      ; Read first digit
    mov bl, 10
    mul bl               ; Multiply by 10
    mov bh, al           ; Store in BH
    
    call read_digit      ; Read second digit
    add bh, al           ; Add to BH
    
    ; Check if there's a third digit (for 100)
    mov ah, 01h
    int 21h
    cmp al, 0Dh          ; Check for Enter
    je score_done
    
    ; If we get here, it's 100 (only 3-digit score possible)
    sub al, '0'
    mov bh, 100
    ret
    
score_done:
    mov al, bh
    mov ah, 0
    ret
read_score endp

; Subroutine: print_number (prints a 16-bit number)
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