.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    li t0, 1           
    blt a1, t0, quit   # if length < 1, exit
    
    li t0, 0          # initialize offset to 0
    slli t3, a1, 2    # calculate total bytes (n * 4)

    li t4, 0 # max val
    li t5, 0 # offset of max val


loop_start:
    bge t0, t3, loop_end      # if offset >= total bytes, exit loop
    add t6, a0, t0            # calculate current address
    lw t1, 0(t6)              # load current value
    ble t1, t4, loop_continue # if value >= 0, skip to next iteration
    mv t4, t1
    mv t5, t0

loop_continue:
    addi t0, t0, 4            # increment offset by 4 bytes
    j loop_start

loop_end:
    # Epilogue
    srli a0, t5, 2 # calculate index (offset / 4)
    jr ra

quit:
    li a0, 36
    j exit