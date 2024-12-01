.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    li t0, 1           
    blt a2, t0, quit_36   # if number of elements < 1, exit
    blt a3, t0, quit_37   # if stride of the first array < 1, exit
    blt a4, t0, quit_37   # if stride of the second array < 1, exit

    li a5, 0 # sum
    li a6, 0 # offset of arr1
    li a7, 0 # offset of arr2
    li t0, 0 # current epoch

loop_start:
    bge t0, a2, loop_end      # if epoch >= number of elements, exit loop
    add t1, a6, a0      # addr of elem in arr1
    lw t2, 0(t1)        # elem of arr1
    add t1, a7, a1      # addr of elem in arr2
    lw t3, 0(t1)        # elem of arr2
    mul t4, t2, t3
    add a5, a5, t4

    slli t1, a3, 2 # stride * 4, the offset
    add a6, a6, t1
    slli t1, a4, 2 # stride * 4, the offset
    add a7, a7, t1
    addi t0, t0, 1
    j loop_start

loop_end:
    mv a0, a5 
    jr ra

quit_36:
    li a0, 36
    j exit

quit_37:
    li a0, 37
    j exit