BITS 32
ORG 32768

; Include the necessary libraries
%INCLUDE "mikedev.inc"

section .data
    prompt db "Enter the name of the Python file: ", 0
    prompt_len equ $ - prompt
    buffer db 256 dup(0)        ; Initialize buffer to hold 256 bytes
    buffer_len equ 256
    output_file db "output.py", 0
    output_file_len equ $ - output_file

section .bss
    file_handle resd 1          ; Reserve 1 double word for file handle
    output_handle resd 1        ; Reserve 1 double word for output file handle
    char resb 1                 ; Reserve 1 byte for reading a character
    in_comment resb 1           ; Reserve 1 byte to flag comment lines

section .text
    global _start

_start:
    ; Ask for the file name
    mov eax, 4                  ; sys_write
    mov ebx, 1                  ; file descriptor (stdout)
    mov ecx, prompt             ; message to write
    mov edx, prompt_len         ; message length
    int 0x80

    ; Read the file name
    mov eax, 3                  ; sys_read
    mov ebx, 0                  ; file descriptor (stdin)
    mov ecx, buffer             ; buffer to store input
    mov edx, buffer_len         ; buffer length
    int 0x80

    ; Open the input file
    mov eax, 5                  ; sys_open
    mov ebx, buffer             ; file name
    mov ecx, 0                  ; read-only
    int 0x80
    mov [file_handle], eax

    ; Open the output file
    mov eax, 5                  ; sys_open
    mov ebx, output_file        ; output file name
    mov ecx, 2                  ; write-only, create
    int 0x80
    mov [output_handle], eax    ; Store output file handle

    ; Read from the input file and process
read_loop:
    mov eax, 3                  ; sys_read
    mov ebx, [file_handle]      ; input file handle
    mov ecx, char               ; buffer for a single character
    mov edx, 1                  ; read one byte
    int 0x80
    cmp eax, 0                  ; check for end of file
    je close_files

    ; Check for comment start
    cmp byte [char], '#' 
    je in_comment_start

    ; If not in comment, write to output file
    mov eax, 4                  ; sys_write
    mov ebx, [output_handle]    ; output file handle
    mov ecx, char               ; character to write
    mov edx, 1                  ; write one byte
    int 0x80
    jmp read_loop

in_comment_start:
    ; Skip the comment
    mov byte [in_comment], 1
skip_comment:
    mov eax, 3                  ; sys_read
    mov ebx, [file_handle]      ; input file handle
    mov ecx, char               ; buffer for a single character
    mov edx, 1                  ; read one byte
    int 0x80
    cmp eax, 0                  ; check for end of file
    je close_files
    cmp byte [char], 10         ; check for newline
    je read_loop
    jmp skip_comment

close_files:
    ; Close the input file
    mov eax, 6                  ; sys_close
    mov ebx, [file_handle]      ; input file handle
    int 0x80

    ; Close the output file
    mov eax, 6                  ; sys_close
    mov ebx, [output_handle]    ; output file handle
    int 0x80

    ; Exit the program
    mov eax, 1                  ; sys_exit
    xor ebx, ebx                ; return 0
    int 0x80
