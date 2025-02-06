
.data
    # Messages for equals operations
    msg_equals:    .asciiz "EQUALS\n"
    msg_no_equals: .asciiz "NOTHING EQUALS\n"
    
    # Messages for order operations
    msg_asc:       .asciiz "ASCENDING\n"
    msg_desc:      .asciiz "DESCENDING\n"
    msg_all_equal: .asciiz "ALL EQUAL\n"
    msg_unordered: .asciiz "UNORDERED\n"
    
    # Message for reverse operations 
    msg_reverse:   .asciiz "REVERSE\n"
    
    # Messages for print operations
    msg_red:       .asciiz "red: "
    msg_orange:    .asciiz "orange: "
    msg_yellow:    .asciiz "yellow: "
    msg_green:     .asciiz "green: "
    msg_blue:      .asciiz "blue: "
    msg_purple:    .asciiz "purple: "
    newline:       .asciiz "\n"

.text
    # Register usage:
    # $s0 - equals flag
    # $s1 - order flag
    # $s2 - reverse flag
    # $s3 - print flag
    # $t0-$t5 - color values (red, orange, yellow, green, blue, purple)
    # $t6-$t9 - temporary calculations

.globl studentMain
studentMain:
    # Function prologue
    addiu $sp, $sp, -24     # allocate stack space
    sw    $fp, 0($sp)       # save caller's frame pointer
    sw    $ra, 4($sp)       # save return address
    addiu $fp, $sp, 20      # setup main's frame pointer
    
    # Load all flag variables
    la    $t9, equals
    lw    $s0, 0($t9)       # load equals flag
    la    $t9, order
    lw    $s1, 0($t9)       # load order flag
    la    $t9, reverse
    lw    $s2, 0($t9)       # load reverse flag
    la    $t9, print
    lw    $s3, 0($t9)       # load print flag
    
    # Load all color values
    la    $t9, red
    lw    $t0, 0($t9)       # load red value
    la    $t9, orange
    lw    $t1, 0($t9)       # load orange value
    la    $t9, yellow
    lw    $t2, 0($t9)       # load yellow value
    la    $t9, green
    lw    $t3, 0($t9)       # load green value
    la    $t9, blue
    lw    $t4, 0($t9)       # load blue value
    la    $t9, purple
    lw    $t5, 0($t9)       # load purple value

check_equals:
    beq   $s0, $zero, check_order    # skip if equals flag is 0
    
    # Compare all pairs (first 4 colors only)
    beq   $t0, $t1, print_equals     # red vs orange
    beq   $t0, $t2, print_equals     # red vs yellow
    beq   $t0, $t3, print_equals     # red vs green
    beq   $t1, $t2, print_equals     # orange vs yellow
    beq   $t1, $t3, print_equals     # orange vs green
    beq   $t2, $t3, print_equals     # yellow vs green
    
    # If we get here, nothing equals
    la    $a0, msg_no_equals
    addiu $v0, $zero, 4     
    syscall
    j     check_order

print_equals:
    la    $a0, msg_equals
    addiu $v0, $zero, 4
    syscall

check_order:
    beq   $s1, $zero, check_reverse  # skip if order flag is 0
    
    # Check if all equal first
    bne   $t0, $t1, check_ascending  # if any pair not equal
    bne   $t1, $t2, check_ascending  # then move to ascending check
    bne   $t2, $t3, check_ascending
    bne   $t3, $t4, check_ascending
    bne   $t4, $t5, check_ascending
    
    # If we get here, all are equal
    la    $a0, msg_all_equal
    addiu $v0, $zero, 4
    syscall
    j     check_reverse

check_ascending:
    # Check if ascending 
    # For each pair, check if first > second (violation of ascending)
    slt   $t6, $t1, $t0              # t6 = 1 if orange < red 
    bne   $t6, $zero, check_descending
    slt   $t6, $t2, $t1              # t6 = 1 if yellow < orange 
    bne   $t6, $zero, check_descending
    slt   $t6, $t3, $t2              # t6 = 1 if green < yellow 
    bne   $t6, $zero, check_descending
    slt   $t6, $t4, $t3              # t6 = 1 if blue < green 
    bne   $t6, $zero, check_descending
    slt   $t6, $t5, $t4              # t6 = 1 if purple < blue 
    bne   $t6, $zero, check_descending
    
    # If we get here, it's ascending
    la    $a0, msg_asc
    addiu $v0, $zero, 4
    syscall
    j     check_reverse

check_descending:
    # Check if descending
    # For each pair, check if first < second (violation of descending)
    slt   $t6, $t0, $t1              # t6 = 1 if red < orange 
    bne   $t6, $zero, print_unordered
    slt   $t6, $t1, $t2              # t6 = 1 if orange < yellow 
    bne   $t6, $zero, print_unordered
    slt   $t6, $t2, $t3              # t6 = 1 if yellow < green 
    bne   $t6, $zero, print_unordered
    slt   $t6, $t3, $t4              # t6 = 1 if green < blue 
    bne   $t6, $zero, print_unordered
    slt   $t6, $t4, $t5              # t6 = 1 if blue < purple 
    bne   $t6, $zero, print_unordered
    
    # If we get here, it's descending
    la    $a0, msg_desc
    addiu $v0, $zero, 4
    syscall
    j     check_reverse

print_unordered:
    la    $a0, msg_unordered
    addiu $v0, $zero, 4
    syscall

check_reverse:
    beq   $s2, $zero, check_print    # skip if reverse flag is 0
    
    # Store values in reverse order
    add   $t6, $zero, $t0            # Save original values
    add   $t7, $zero, $t1
    add   $t8, $zero, $t2
    
    la    $t9, red
    sw    $t5, 0($t9)                # store purple in red
    la    $t9, orange
    sw    $t4, 0($t9)                # store blue in orange
    la    $t9, yellow
    sw    $t3, 0($t9)                # store green in yellow
    la    $t9, green
    sw    $t8, 0($t9)                # store yellow in green
    la    $t9, blue
    sw    $t7, 0($t9)                # store orange in blue
    la    $t9, purple
    sw    $t6, 0($t9)                # store red in purple
    
    # Update registers to reflect new order
    add   $t0, $zero, $t5            # red = purple
    add   $t1, $zero, $t4            # orange = blue
    add   $t2, $zero, $t3            # yellow = green
    add   $t3, $zero, $t8            # green = yellow
    add   $t4, $zero, $t7            # blue = orange
    add   $t5, $zero, $t6            # purple = red
    
    # Print reverse message
    la    $a0, msg_reverse
    addiu $v0, $zero, 4
    syscall

check_print:
    beq   $s3, $zero, exit           # skip if print flag is 0
    
    # Print red
    la    $a0, msg_red
    addiu $v0, $zero, 4
    syscall
    add   $a0, $zero, $t0
    addiu $v0, $zero, 1
    syscall
    la    $a0, newline
    addiu $v0, $zero, 4
    syscall
    
    # Print orange
    la    $a0, msg_orange
    addiu $v0, $zero, 4
    syscall
    add   $a0, $zero, $t1
    addiu $v0, $zero, 1
    syscall
    la    $a0, newline
    addiu $v0, $zero, 4
    syscall
    
    # Print yellow
    la    $a0, msg_yellow
    addiu $v0, $zero, 4
    syscall
    add   $a0, $zero, $t2
    addiu $v0, $zero, 1
    syscall
    la    $a0, newline
    addiu $v0, $zero, 4
    syscall
    
    # Print green
    la    $a0, msg_green
    addiu $v0, $zero, 4
    syscall
    add   $a0, $zero, $t3
    addiu $v0, $zero, 1
    syscall
    la    $a0, newline
    addiu $v0, $zero, 4
    syscall
    
    # Print blue
    la    $a0, msg_blue
    addiu $v0, $zero, 4
    syscall
    add   $a0, $zero, $t4
    addiu $v0, $zero, 1
    syscall
    la    $a0, newline
    addiu $v0, $zero, 4
    syscall
    
    # Print purple
    la    $a0, msg_purple
    addiu $v0, $zero, 4
    syscall
    add   $a0, $zero, $t5
    addiu $v0, $zero, 1
    syscall
    la    $a0, newline
    addiu $v0, $zero, 4
    syscall

exit:
    lw    $ra, 4($sp)                # get return address from stack
    lw    $fp, 0($sp)                # restore the caller's frame pointer
    addiu $sp, $sp, 24               # restore the caller's stack pointer
    jr    $ra                        # return to caller's code
 