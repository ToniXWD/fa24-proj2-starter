.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    li t0, 1           
    blt a1, t0, quit   # if length < 1, exit
    
    li t0, 0          # initialize counter to 0
    slli t3, a1, 2    # calculate total bytes (n * 4)

loop_start:
    bge t0, t3, loop_end      # if offset >= total bytes, exit loop
    add t4, a0, t0            # calculate current address
    lw t1, 0(t4)              # load current value
    bge t1, x0, loop_continue # if value >= 0, skip to next iteration
    sw x0, 0(t4)               # if value < 0, set to 0

loop_continue:
    addi t0, t0, 4            # increment offset by 4 bytes
    j loop_start

loop_end:
    jr ra

quit:
    li a0, 36
    j exit