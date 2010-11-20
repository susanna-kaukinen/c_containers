CC=gcc
CFLAGS=-Wall -gstabs+
INCLUDES=

STATIC_VECTOR_SOURCES=\
	static_vector.c\
	static_vector_memblock.c\
	static_vector_memblock_header.c

LIB=libc_containers.a

LIB_SOURCES=$(STATIC_VECTOR_SOURCES)

LIB_OBJS=$(LIB_SOURCES:.c=.o)

$(LIB) : $(LIB_OBJS)
	ar cru $(LIB) $(LIB_OBJS)
	ranlib $(LIB)

lib: $(LIB)

#
############################################
#

tests: $(TEST_EXECUTABLE)


TESTS_SOURCES=\
	test_static_vector.c

TESTS_OBJS=$(TESTS_SOURCES:.c=.o)

TEST_EXECUTABLE=tests

$(TEST_EXECUTABLE): $(TESTS_OBJS) $(LIB)
	$(CC) $(CFLAGS) $(TESTS_OBJS) $(LIB) -o $(TEST_EXECUTABLE)

#
###########################################
#

run_tests: clean tests
	./tests

valgrind_run_tests: clean tests
	valgrind ./tests

r: run_tests

v: valgrind_run_tests


#
############################################
#


.c.o:
	$(CC) $(INCLUDES) -c $(CFLAGS) $< -o $@

tgz:
	tar czfv c_containers.tgz $(LIB_SOURCES) $(TESTS_SOURCES) *.h makefile

clean:
	\rm -f *.o 
	\rm -f $(LIB)
	\rm -f $(TEST_EXECUTABLE)

release_clean: clean
	\rm -f *~ .sw?
