/** 
 *
 * MIT Free Software License
 *
 * Copyright (c) 2010 Susanna Kaukinen
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

#ifndef __TEST_STATIC_VECTOR_H__
#define __TEST_STATIC_VECTOR_H__

#include <stdlib.h>
#include "c_containers.h"

typedef struct _test_struct {
	int i;
	char c;
	const char* str;
	char buf[80];
} test_struct; 

void test_struct_print                 (byte after, test_struct* s);
int  test_static_vector_with_struct    (size_t guess_buf_size);
int  test_static_vector_for_size_calcs (int amt_items);
int  test_static_vector_with_int       (size_t buf_size);
int  test_static_vector_copy           (void);
int  test_static_vector_main           (int argc, char** argv);

#endif // __TEST_STATIC_VECTOR_H__
