/** 
 *
 * MIT Free Software License
 *
 * Copyright (c) 2011 Susanna Kaukinen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

/**
 *
 * Usage: 
   gcc -Wall -std=c99 -gstabs+ gcc_var_len_arrays.c && valgrind --leak-check=full ./a.out 200000
 *
 * GCC sweetness test: variable length arrays
 *
 * - http://gcc.gnu.org/onlinedocs/gcc-4.5.2/gcc/Variable-Length.html#Variable-Length
 * - http://gcc.gnu.org/onlinedocs/gcc-4.5.2/gcc/Designated-Inits.html#Designated-Inits
 *
 * @author Susanna Kaukinen (Susanna)
 *
 * @version 1.0-1 2011-05-06 (Susanna) o Initial sample of GCC utter sweetness. No memleak.
 *
 */


#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>

void gcc_fill_array(uint64_t len; uint64_t buf[len], uint64_t len)
{
	for(uint64_t i=0;i<len; i++) {
		buf[i] = i;
	}
}

void gcc_output_array(uint64_t len; uint64_t buf[len], uint64_t len)
{
	for(uint64_t i=0;i<len; i++) {
		if(i%5==1) {
			printf("\n");
		}
		printf("buf[%8.8llu]=[%8.8llu] ", buf[i], i);
	}
	printf("\n");
}

void verify_sandwich_buffer(const char* buf, int filler, int sz)
{
	for(int i=0;i<sz;i++) {
		assert(buf[i]==filler);
	}
}

int main (int argc, char** argv)
{
	if(argc!=2) {
		printf("Please provide buffer size as argument.\n");
		return 1;
	}

	uint64_t sz = strtol(argv[1], NULL,10);

	printf("Using sz=%llu\n",sz);

	char     buf_before[] = { [0 ... 99] = 5 };
	uint64_t buf[sz];
	char     buf_after[]  = { [0 ... 99] = 6 };

	gcc_fill_array(buf,sz);
	gcc_output_array(buf,sz);
	verify_sandwich_buffer(buf_before,5,100);
	verify_sandwich_buffer(buf_after,6,100);

	return 0;
}
