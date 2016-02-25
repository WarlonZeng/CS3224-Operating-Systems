.code16         # Use 16-bit assembly
.globl start    # This tells the linker where we want to start executing

start:
    	movw $prompt, %si	# load the offset of our message into %si
    	movb $0x00, %ah		# 0x00 - set video mode
    	movb $0x03, %al		# 0x03 - 80x25 text mode
    	int $0x10       	# call into the BIOS
	movb $0x00, %al		# reset al
    	outb %al, $0x70		# read from port
    	inb $0x71, %al		# store seconds to al
    	and $0x0F, %al		# reset bits 5-8 to 0
    	add $0x30, %al		# add al to get hex format (ascii)
		#movb $0x0e, %ah		# FOR TESTING: ANSWER
		#int $0x10			# FOR TESTING: ANSWER
	movb %al, %bl # 	# store into bl register


print_prompt:
    	lodsb           	 # loads a single byte from (%si) into %al and increments %si
    	testb %al,%al  	 	 # checks to see if the byte is 0
    	jz get_input 		 # if so, jump out (jz jumps if ZF in EFLAGS is set)
    	movb $0x0e,%ah 		 # 0x0E is the BIOS code to print the single character
    	int $0x10       	 # call into the BIOS using a software interrupt
    	jmp print_prompt  	 # go back to the start of the loop


get_input:
	movb $0x00,%al		# reset al
	movb $0x00,%ah 		# read character
	int $0x16 		# keyboard mode
	movb $0x0e,%ah 		# display character
	int $0x10 		# see screen of display
	movb %al, %cl 		# store to cl register 
	movb $0x0d,%al		# carriage return
	movb $0x0e,%ah		# 0x0E is the BIOS code to print the single character
	int $0x10		# call into the BIOS using a software interrupt
	movb $0x0a,%al		# line feed
	movb $0x0e,%ah		# 0x0E is the BIOS code to print the single character
	int $0x10		# call into the BIOS using a software interrupt
	jz check		# move to check

check:
	movw $right, %si 	# prepare right
	cmp %bl, %cl		# check if it's right
	je print_right		# go to print right
	movw $wrong, %si	# prepare wrong
	jne print_wrong		# go to wrong

print_right:
	lodsb			# load the offset of our message into %si
	testb %al,%al		# checks to see if the byte is 0
	jz done			# move to done
	movb $0x0e,%ah		# print character
	int $0x10		# see screen of display
	jmp print_right		# go back to the start of the loop

print_wrong:
	lodsb			# load the offset of our message into %si
	testb %al, %al		# checks to see if the byte is 0
	je start_over		# jump to star_over
	movb $0x0e,%ah		# print character
	int $0x10		# see display
	jmp print_wrong		# go back to the start of the loop

start_over:
	movb $0x0d,%al		# print new line
	movb $0x0e,%ah		# print character
	int $0x10		# see display
	movw $prompt, %si	# load the offset of our message into %si
   	cmpb %al, %al		# compare if they are equal
	je print_prompt		# jump back to print_prompt

done:
    jmp done     		# loop forever


# The .string command inserts an ASCII string with a null terminator

prompt:
    .string    "What number am I thinking of (0-9)? "

newLine:
	.string "\n \r"

wrong:
	.string "Wrong! \n \r"

right:
	.string "Right! Congratulations."


# This pads out the rest of the boot sector and then puts
# the magic 0x55AA that the BIOS expects at the end, making sure
# we end up with 512 bytes in total.
#
# The somewhat cryptic "(. - start)" means "the current address
# minus the start of code", i.e. the size of the code we've written
# so far. So this will insert as many zeroes as are needed to make
# the boot sector 510 bytes log, and

.fill 510 - (. - start), 1, 0
.byte 0x55
.byte 0xAA
