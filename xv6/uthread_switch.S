	.text

/* Switch from current_thread to next_thread. Make next_thread
 * the current_thread, and set next_thread to 0.
 * Use eax as a temporary register; it is caller saved.
 */
	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */

    /* save current thread state in current_thread */

    pushal /* push all normal registers */ 

    movl current_thread, %eax     /* save esp */   
    movl %esp, (%eax)

    /* restore next_thread's state
        make current_thread point to where next_thread was pointing to */

    movl next_thread, %eax      /* current_thread = next_thread */
    movl %eax, current_thread
    movl (%eax), %esp           /* restore esp */
    popal                       /* restore all the normal registers */

	ret				/* pop return address from stack */