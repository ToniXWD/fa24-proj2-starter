.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # ebreak
    # save ra, a1, a2
    addi sp, sp, -24
    sw a2, 0(sp) # ptr to w
    sw a1, 4(sp) # ptr to h
    sw ra, 8(sp)

    ### open file ###
    mv a1, x0
    
    call fopen

    # check if file descriptor is valid
    li t1, -1
    beq a0, t1, fopen_error

    # !!! save file descriptor
    sw a0, 12(sp)

    ### read h ###
    # load a1
    lw a1, 4(sp)
    addi a2, x0, 4 # 1 * int
    call fread
    li t1, 4
    bne a0, t1, fread_error
    
    ### read w ###
    # load file descriptor to a0
    lw a0, 12(sp)
    # load a2 (ptr to w) to a1
    lw a1, 0(sp)
    addi a2, x0, 4 # 1 * int
    call fread
    li t1, 4
    bne a0, t1, fread_error
    
    ### malloc matrix ###
    lw t1, 0(sp) # ptr to w
    lw t2, 4(sp) # ptr to h
    lw t1, 0(t1) # w
    lw t2, 0(t2) # h
    mul a0, t2, t1 # h * w
    slli a0, a0, 2 # (h * w) * 4 bytes
    call malloc # malloc matrix
    beq a0, x0, malloc_error

    sw a0, 16(sp) # !!! save pointer to matrix
    mv a1, a0 # buffer: ptr to matrix

    # load  h, w
    lw t1, 0(sp) # ptr to w
    lw t2, 4(sp) # ptr to h
    lw t1, 0(t1) # w
    lw t2, 0(t2) # h

    mul a2, t1, t2 # h * w
    slli a2, a2, 2 # (h * w) * 4 bytes

    # save a2 (size of matrix)
    sw a2, 20(sp)

    # load file descriptor to a0
    lw a0, 12(sp)

    call fread
    lw t0, 20(sp)
    bne a0, t0, fread_error

    # load file descriptor to a0
    lw a0, 12(sp)
    call fclose
    bne a0, x0, fclose_error

    # restore ra, a1, a2
    lw a2, 0(sp)
    lw a1, 4(sp)
    lw ra, 8(sp)
    lw a0, 16(sp)
    addi sp, sp, 24
    jr ra
    

fopen_error:
    li a0, 27
    j exit


malloc_error:
    li a0, 26
    j exit

fread_error:
    li a0, 29
    j exit

fclose_error:
    li a0, 28
    j exit
