#-------------------------------------------------------------------------
# separate compilation and linking - multiple files (a couple of macros)
# set the default C compiler macro from cc to gcc
#--------------------------- MACROS ---------------------------------
CC = gcc

# set the flags (options) to be used with the default compiler
CFLAGS = -Wall -g
#CFLAGS+= -DDEBUG

# use macro to give the program name (simplify change of it)
PROG = fprog

# list all the object files (to be used by the pattern target)
objects = $(PROG).o str_utils.o

# list test cases
tests   = in01.txt in02.txt

#--------------------------- TARGETS -------------------------------
# 'make' will not expect file to be created for the dependencies
.PHONY: all $(tests) clean

# standard target all - preforms all logically necessary tasks
all: $(PROG)

# Specify the group of .o files as a dependency
$(PROG): $(objects)

# for each file in $(objects) with .o extension, look for corresponding
# .c file (all .c files must have corresponding .h files!)
$(objects): %.o: %.c %.h

# for each test case, run the program with the test-file
$(tests): in%.txt: out%.txt
	./$(PROG) < $@ | diff - $<

# remove all object files to ensure complete rebuild (when problems arise)
clean:
	$(RM) *.o $(PROG)
