.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    li t0, 1
    blt a1, t0, matmul_error
    blt a2, t0, matmul_error
    blt a4, t0, matmul_error
    blt a5, t0, matmul_error
    bne a2, a4, matmul_error

    li t0, 0 # !!! outer_row, need to save
    li t1, 0 # !!! inner_col, need to save

    # save all ax registers
    addi sp, sp, -48
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp)
    sw a5, 24(sp)
    sw a6, 28(sp)


outer_loop_start:
    lw a1, 8(sp) # load a1: # of rows (height) of m0
    bge t0, a1, outer_loop_end
    
    lw a0, 4(sp) # load a0
    
    lw a2, 12(sp) # load a2: columns (width) of m0
    mul t2, t0, a2 # compute offset without word size
    #!!! t2 means start of the row. use later
    slli t2, t2, 2 # 4 bytes per word
    add t2, a0, t2 # compute addr of the start of the row

    j inner_loop_start


inner_loop_start:
    lw a5, 24(sp) # load a5: columns (width) of m1
    bge t1, a5, inner_loop_end

    mv a0, t2 # start of the arr0

    lw a3, 16(sp) # load a3: pointer to the start of m1
    slli t3, t1, 2 # 4 bytes per word
    add a1, a3, t3 # compute offset

    lw a2, 12(sp) # load a2: columns (width) of m0
    li a3, 1 # the stride of arr0
    lw a4, 24(sp) # load a5 to a4: the stride of arr1
    
    # !!! save t0, t1, t2
    sw t0, 32(sp)
    sw t1, 36(sp)
    sw t2, 40(sp)
    
    call dot

    # restore t0, t1, t2
    lw t0, 32(sp)
    lw t1, 36(sp)
    lw t2, 40(sp)

    
    lw a6, 28(sp) # load a6: pointer to the start of d
    lw a5, 24(sp) #laod a5: columns (width) of m1

    mul t3, t0, a5 # compute offset without word size
    add t3, t3, t1 # compute offset without word size
    slli t3, t3, 2 # 4 bytes per word

    add t3, t3, a6 # addr to save
    sw a0, 0(t3) # save the result

    addi t1, t1, 1 # increment inner_col

    j inner_loop_start


inner_loop_end:
    addi t0, t0, 1 # increment outer_row
    mv t1, zero # reset inner_col
    j outer_loop_start


outer_loop_end:
    # restore stack
    lw ra, 0(sp)
    mv a0, x0
    addi sp, sp, 48
    jr ra

matmul_error:
    li a0, 38
    j exit