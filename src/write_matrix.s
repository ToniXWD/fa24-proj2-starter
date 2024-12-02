.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # ebreak
    # save ra, a1, a2, a3
    addi sp, sp, -24
    sw a3, 0(sp) # ptr to w
    sw a2, 4(sp) # ptr to h
    sw a1, 8(sp) # ptr to matrix
    sw ra, 12(sp)

    ### open file ###
    addi a1, x0, 1
    
    call fopen

    # check if file descriptor is valid
    li t1, -1
    beq a0, t1, fopen_error

    # !!! save file descriptor
    sw a0, 16(sp)
    
    ### write h ###
    addi a1, sp, 4 # ptr to h
    addi a2, x0, 1 # 1 * int
    addi a3, x0, 4 # size of int
    call fwrite
    # check if fwrite is successful
    li t1, 1
    bne a0, t1, fwrite_error

    ### write w ###
    lw a0, 16(sp) # file descriptor
    add a1, sp, x0 # ptr to w
    addi a2, x0, 1 # 1 * int
    addi a3, x0, 4 # size of int
    call fwrite
    # check if fwrite is successful
    li t1, 1
    bne a0, t1, fwrite_error

    ### write matrix ###
    lw a0, 16(sp) # file descriptor
    lw t0, 0(sp) # ptr to w
    lw t1, 4(sp) # ptr to h
    mul a2, t0, t1 # a2 = w * h
    # save number of elements
    sw a2, 20(sp)
    lw a1, 8(sp) # ptr to matrix
    addi a3, x0, 4 # size of int
    call fwrite
    # check if fwrite is successful
    lw a2, 20(sp)
    bne a0, a2, fwrite_error

    ### close file ###
    lw a0, 16(sp) # file descriptor
    call fclose
    # check if fclose is successful
    li t1, 0
    bne a0, t1, fclose_error

    ### restore ra, a1, a2, a3 ###
    lw ra, 12(sp)
    addi sp, sp, 24

    jr ra

fopen_error:
    li a0, 27
    j exit

fwrite_error:
    li a0, 30
    j exit

fclose_error:
    li a0, 28
    j exit