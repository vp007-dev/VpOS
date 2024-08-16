BITS 16
%INCLUDE 'mikedev.inc'
ESC equ 0x1B

ORG 32768
start:
    mov ax, .string1
    mov bx, .string2
    mov cx, .string3
    mov dx, 1
    call os_dialog_box

    cmp ax, 1
    je .first_option_chosen

    call os_clear_screen
    call os_file_selector
    ; mov si, ax
    pop si
    mov ax, si
	mov cx, 32768			; Where to load the program file
	call os_load_file		; Load filename pointed to by AX

	call os_clear_screen		; Clear screen before running

	mov ax, 32768
	mov si, 0			; No params to pass
	call os_run_basic		; And run our BASIC interpreter on the code!

	mov si, program_finished_msg
	call os_print_string
	call os_wait_for_key

	call os_clear_screen
    ret
	
    


.first_option_chosen:
    call os_clear_screen
    mov ax, 1
    call os_print_horiz_line
    call os_wait_for_key
    cmp al, ESC
    je .end_game
    .string1 db "Welcome to my program", 0
    .string2 db "Please choose Male or Female", 0
    .string3 db "As There are only 2 genders", 0


    ; ret
.end_game:
    mov ax, 0x2000
    mov es, ax
    call os_clear_screen
    call os_show_cursor
    ret

program_finished_msg	db '>>> Program finished -- press a key to continue...', 0