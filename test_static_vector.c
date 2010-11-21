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

#include "test_static_vector.h"
#include "static_vector.h"

#include "debug_levels.h"
#define DBG_LVL LVL_FLOOD
//#define DBG_LVL LVL_DEBUG
#include "debug.h"

typedef struct _test_struct {
	int i;
	char c;
	const char* str;
	char buf[80];
} test_struct; 

void test_struct_print(byte after, test_struct* s)
{
	if(!after) {
		debugfp(LVL_DEBUG, "<before>");
	} else {
		debugfp(LVL_DEBUG, "<after_>");
	}
		

	debugfp(LVL_DEBUG, "%x : ", (unsigned int) s);

	if(s!=0) {
		debugfp(LVL_DEBUG, "%d,%c,%s,%s>",
			s->i,
			s->c,
			s->str,
			s->buf);
	}

	if(!after) {
		debugfpln(LVL_DEBUG, "</before>");
	} else {
		debugfpln(LVL_DEBUG, "</after_>");
	}
}


int test_static_vector_with_struct(size_t guess_buf_size)
{
	debugfpln(LVL_FLOOD, "<test_static_vector_with_struct>");

	size_t buf_size = static_vector__get_exact_fit_for_a_buf_size(guess_buf_size, sizeof(test_struct));

	int buf[buf_size];
	void* obj = static_vector__init(&buf, sizeof(buf), sizeof(test_struct));

	int flag=0;
	int i;
	for(i=0;; i++) {

		test_struct s0;

		s0.i = i;
		s0.c = 'a'+i;
		s0.str = "just some test for the str";
		sprintf(s0.buf, "some texts for the buf, too1 %d bar", i*10);

		test_struct_print(0,&s0);

		int chunks_free = static_vector__add_item(obj, &s0);

		debugfpln(LVL_DEBUG, "chunks free=%u", chunks_free); 

		test_struct* s0_p = (void*) static_vector__get_item(obj, i);

		test_struct_print(1,s0_p);

		if(chunks_free==0) {
			if(flag) {
				debugfpln(LVL_DEBUG, "no more chunks, done.");
				break;
			}
		
			debugfpln(LVL_DEBUG, "Let's force one more op to see how it's handled");
			flag=1;

		}

	}

	debugfpln(LVL_FLOOD, "</test_static_vector_with_struct>");

	return 1;
}

int test_static_vector_for_size_calcs(int amt_items)
{
	debugfpln(LVL_DEBUG, "<test_static_vector_for_size_calcs>");

	precondition ((amt_items>0), "amt_items=%d can't be negative", amt_items);

	unsigned int buf_size = static_vector__get_exact_fit_for_n_items(amt_items, sizeof(test_struct));
	byte buf[buf_size];
	void *vector = static_vector__init(&buf, sizeof(buf), sizeof(test_struct));

	debugfpln(LVL_DEBUG, "amt_items=%d, buf_size=%d, vector max size=%d",
		amt_items, buf_size, static_vector__get_max_size(vector)
	);

	postcondition ((amt_items==static_vector__get_max_size(vector)), 
		"Size problem, amt_items=%d != vector max size=%d" ,amt_items, static_vector__get_max_size(vector));

	debugfpln(LVL_DEBUG, "</test_static_vector_for_size_calcs>");
}

int test_static_vector_with_int(size_t buf_size)
{

	int buf[buf_size];
	void* obj = static_vector__init(&buf, sizeof(buf), sizeof(int));

	int items_free=0;
	
	int i,j;
	int comparison_buf[buf_size];
	for(i=0,j=0;; i++,j=i*10) {

		debugfp(LVL_DEBUG, "items_free=%d, ", items_free);
		debugfpln(LVL_DEBUG, "i=%d", i); fflush(stdout); 

		//int c = getchar();


		comparison_buf[i] = j;
		debugfpln(LVL_DEBUG, "comparison_buf[%d] = %d", i, j);

		items_free = static_vector__add_item(obj, &j);

		if(items_free<=0) {
			debugfpln(LVL_DEBUG, "loop break, i=%d", i);
			break;
		}

		if(i==0) {
			debugfpln(LVL_DEBUG, "Vector can hold %d items", static_vector__get_max_size(obj));
		}


	}

	for(i=0;;i++) {
		debugfpln(LVL_DEBUG, "i=%d", i); fflush(stdout); 
		//int c = getchar();

		int *item = static_vector__get_item(obj,i);

		if(item) {
			debugfpln(LVL_DEBUG, "%2d:%10d (%x)", i, *item, (unsigned int) item); fflush(stdout);
			debugfpln(LVL_DEBUG, "*item=(%d), comparison_buf[%d]=%d", *item, i, comparison_buf[i]);

			if(*item != comparison_buf[i]) {
				debugfpln(LVL_DEBUG, "mismatch, %d!=%d", *item, comparison_buf[i]);
				return 1;
			}

		} else {
			break;
		}
	}


	return 0;
}

int test_static_vector_copy()
{
	debugfpln(LVL_DEBUG, "<test_static_vector_copy>");
	// @TODO
	debugfln(LVL_PANIC, "@TODO");

	debugfpln(LVL_DEBUG, "</test_static_vector_copy>");

}


int main()
{
	// @TODO check return values
	test_static_vector_with_struct(100);
	test_static_vector_with_struct(1024);
	test_static_vector_with_int(100);
	test_static_vector_for_size_calcs(123);
	test_static_vector_copy();
	return 0;
}
