.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    ebreak
    # check the number of command line args
    li t0, 5
    bne a0, t0, argc_error

    # save context
    addi sp, sp, -72
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)

    # Read pretrained m0
    lw t0, 8(sp) # load a1 to t0
    addi a0, t0, 4 # load pointer to the filepath string of m0 to a0'
    lw a0, 0(a0)
    addi a1, sp, 16 # !!! the number of rows in m0
    addi a2, sp, 20 # !!! the number of columns in m0
    call read_matrix
    sw a0, 24(sp) # !!! save the ptr to m0 to 24(sp)

    # Read pretrained m1
    lw t0, 8(sp) # load a1 to t0
    addi a0, t0, 8 # load pointer to the filepath string of m1 to a0'
    lw a0, 0(a0)
    addi a1, sp, 28 # !!! the number of rows in m1
    addi a2, sp, 32 # !!! the number of columns in m1
    call read_matrix
    sw a0, 36(sp) # !!! save the ptr to m1 to 36(sp)

    # Read input matrix
    lw t0, 8(sp) # load a1 to t0
    addi a0, t0, 12 # load pointer to the filepath string of input
    lw a0, 0(a0)
    addi a1, sp, 40 # !!! the number of rows in input
    addi a2, sp, 44 # !!! the number of columns in input
    call read_matrix
    sw a0, 48(sp) # !!! save the ptr to input to 48(sp)

    # allocate space for h
    # load the number of rows in m0
    lw t0, 16(sp)
    # load the number of columns in input
    lw t1, 44(sp)
    # compute the space needed for h
    mul t2, t0, t1
    slli t2, t2, 2 # 4 bytes per word
    sw t2, 56(sp) # !!! save the size of h to 56(sp)
    # malloc for h
    mv a0, t2
    call malloc
    sw a0, 52(sp) # !!! save the ptr to h to 52(sp)

    # Compute h = matmul(m0, input)
    lw a0, 24(sp) # load the ptr to m0
    lw a1, 16(sp) # load of rows (height) of m0
    lw a2, 20(sp) # load of columns (width) of m0
    lw a3, 48(sp) # load the ptr to input
    lw a4, 40(sp) # load of rows (height) of input
    lw a5, 44(sp) # load of columns (width) of input
    lw a6, 52(sp) # load the ptr to h
    call matmul

    # Compute h = relu(h)
    lw a0, 52(sp) # load the ptr to h
    lw a1, 56(sp) # load the size of h
    srli a1, a1, 2 # convert size to number of elements
    call relu

    # allocate space for o
    lw t0, 28(sp) # load of rows (height) of m1
    lw t1, 44(sp) # load of columns (width) of h
    mul t2, t0, t1
    slli t2, t2, 2 # 4 bytes per word
    sw t2, 60(sp) # !!! save the size of o to 60(sp)
    mv a0, t2
    call malloc
    sw a0, 64(sp) # !!! save the ptr to o to 64(sp)

    # Compute o = matmul(m1, h)
    lw a0, 36(sp) # load the ptr to m1
    lw a1, 28(sp) # load of rows (height) of m1
    lw a2, 32(sp) # load of columns (width) of m1
    lw a3, 52(sp) # load the ptr to h
    lw a4, 16(sp) # load of rows (height) of h
    lw a5, 44(sp) # load of columns (width) of h
    lw a6, 64(sp) # load the ptr to o
    call matmul

    # Write output matrix o
    lw t0, 8(sp) # load a1 to t0
    addi a0, t0, 16 # load pointer to the filepath string of output
    lw a0, 0(a0)
    lw a1, 64(sp) # load ptr to o
    lw a2, 28(sp) # # load the number of rows in o
    lw a3, 44(sp) # load the number of columns in o
    call write_matrix

    # Compute and return argmax(o)
    lw a0, 64(sp) # load the ptr to o
    lw a1, 60(sp) # load the size of o
    srli a1, a1, 2 # convert size to number of elements
    call argmax
    sw a0, 68(sp) # !!! save the result to 68(sp)

    # If enabled, print argmax(o) and newline
    lw t0, 12(sp) # load silent mode
    addi t0, t0, -1
    beq t0, x0, classify_done
    ebreak
    call print_int
    li a0, '\n'
    call print_char

classify_done:
    # free all allocated memory
    lw a0, 24(sp) # load the ptr to m0
    call free
    lw a0, 36(sp) # load the ptr to m1
    call free
    lw a0, 48(sp) # load the ptr to input
    call free
    lw a0, 52(sp) # load the ptr to h
    call free
    lw a0, 64(sp) # load the ptr to o
    call free

# restore context
    lw ra, 0(sp)
    lw a0, 68(sp) # load the result

    addi sp, sp, 72
    jr ra

argc_error:
    li a0, 31
    j exit