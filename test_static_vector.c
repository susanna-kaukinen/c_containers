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

typedef struct _test_struct {
	int i;
	char c;
	const char* str;
	char buf[80];
} test_struct; 

void test_struct_print(test_struct* s)
{
	printf("%x\n", (unsigned int) s);

	if(s!=0) {
		printf("<%d,%c,%s,%s>\n",
			s->i,
			s->c,
			s->str,
			s->buf);
	}
}

int test_static_vector(size_t buf_size)
{
	//debugfpln(LVL_FLOOD, "<test_static_vector>");
	printf("<test_static_vector>\n");

	int buf[buf_size];
	static_vector_init(&buf, sizeof(buf), sizeof(test_struct));

	int flag=0;
	int i;
	for(i=0;; i++) {

		test_struct s0;

		s0.i = i;
		s0.c = 'a'+i;
		s0.str = "just some test for the str";
		sprintf(s0.buf, "some texts for the buf, too1 %d bar", i*10);

		test_struct_print(&s0);

		int chunks_free = static_vector_add_item(&s0);

		printf("chunks free=%u\n", chunks_free); 

		test_struct* s0_p = (void*) static_vector_get_item(0);

		test_struct_print(s0_p);

		if(chunks_free==0) {
			if(flag) {
				printf("no more chunks, done.");
				break;
			}
		
			printf("Let's force one more op to see how it's handled\n");
			flag=1;

		}

	}

	//



	printf("</test_static_vector>\n");
	//debugfpln(LVL_FLOOD, "</test_static_vector>");

	return 1;
}


int main()
{
	test_static_vector(10);
	test_static_vector(1024);

	return 0;
}
