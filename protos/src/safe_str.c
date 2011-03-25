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



#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

// <strnchr>
//
// https://gist.github.com/855214
//
const char const *strnchr(const char *str, size_t len, int character) {
    const char *end = str + len;
    char c = (char)character;
    while (str++ < end) {
        if (*str == c) {
            return str;
        }
    }
    return NULL;
}
//
// </strnchr>


// <safe_str>
//
// 

#define byte char

typedef struct sstring {
	size_t size;
	byte   *data;
} sstring;

// <debug>
const int DEBUG=0;
void print_str(sstring* sstr)
{
#if (DEBUG)
	printf("0123456789012345678901234567890123456789\n");
	printf("%s\n", sstr->data);
#endif
}
// </debug>

void sstring_zero(sstring* str)
{
	assert(str!=0);
	memset(str->data, 0, str->size);
}

sstring* sstring_init(sstring* sstr, byte* str, size_t sz)
{
	assert(sstr!=0);
	assert(str!=0);
	assert(sz>0);

	sstr->data = str;
	sstr->size = sz;

	sstring_zero(sstr);

	return sstr;

}

sstring* sstring_init_dynamic(byte* str, size_t sz)
{
	assert(str!=0);
	assert(sz>0);

	sstring* sstr = malloc(sizeof(byte)*sz);

	sstr->data = str;
	sstr->size = sz;

	sstring_zero(sstr);

	return sstr;

}

void sstring_free_dynamic(sstring* sstr)
{
	free(sstr);
}

void sstring_copy(sstring* sstr, const char const *source_str)
{
	assert (sstr!=NULL && source_str!=NULL);

	size_t i,sz = sstr->size;

	for(i=0; i<sz; i++) {
		sstr->data[i] = source_str[i];
	}
	sstr->data[sz-1] = '\0'; // demand zero terminate

	print_str(sstr);
}

void sstring_cat(sstring* sstr, const char const* source_str)
{

	assert (sstr!=NULL && source_str!=NULL);

	char*  sstr_end = sstr->data;
	size_t write_sz = sstr->size;

	if(sstr->data[0]!=0) {
		sstr_end = (char*) (strnchr(sstr->data, sstr->size, '\0'));

		assert (sstr_end!=NULL);

		size_t bytes_already_in_str = sstr_end - sstr->data;
		write_sz = (sstr->size - bytes_already_in_str);
	}

	printf("<free=%u>\n", write_sz);

	snprintf(sstr_end, write_sz, "%s", source_str);

	assert(sstr_end+write_sz!='\0'); // demand zero terminate

	print_str(sstr);
}

//
//
// </safe_str>

sstring* tests(sstring* sstr, sstring* output)
{
	sstring_zero(output);

	sstring_copy(sstr, "koira on mukava");
	sstring_cat(output, sstr->data);
	sstring_copy(sstr, "1issa2issa3issa4issa5issa6issa7issa8issa9issa0issa1issa2issa");
	sstring_cat(output, sstr->data);

	sstring_zero(sstr);
	sstring_cat(output, sstr->data);
	sstring_cat(sstr, "kana on punainen");
	sstring_cat(output, sstr->data);

	sstring_zero(sstr);
	sstring_cat(output, sstr->data);
	sstring_copy(sstr, "X");
	sstring_cat(output, sstr->data);
	sstring_cat(sstr, "kana on punainen");
	sstring_cat(output, sstr->data);

	sstring_zero(sstr);
	sstring_cat(output, sstr->data);
	sstring_copy(sstr, "ZZ");
	sstring_cat(output, sstr->data);
	sstring_cat(sstr, "kana on punainen");
	sstring_cat(output, sstr->data);
	sstring_cat(sstr, "kana on punainen");
	sstring_cat(output, sstr->data);
	sstring_cat(sstr, "________________");
	sstring_cat(output, sstr->data);

	return output;
}

sstring* test_static(sstring* soutput)
{
	const size_t sstr_sz = 40;
	char         buf[sstr_sz];
	sstring      sstr_struct;

	sstring *sstr = sstring_init(&sstr_struct, buf, sstr_sz);

	return tests(sstr,soutput);
}


sstring* test_dynamic()
{
	const size_t sstr_sz = 40;
	char         buf[sstr_sz];

	sstring *sstr = sstring_init_dynamic(buf, sstr_sz);

	const size_t output_sz = 4096;
	char         obuf[output_sz];
	
	sstring *soutput = sstring_init_dynamic(obuf, output_sz);

	soutput = tests(sstr,soutput);

	sstring_free_dynamic(sstr);

	return soutput;

}



int main()
{
	const size_t output_sz = 4096;
	char         obuf[output_sz];
	sstring      obuf_s;
	
	sstring *soutput = sstring_init(&obuf_s, obuf, output_sz);

	sstring* static_output  = test_static(soutput);
	sstring* dynamic_output = test_dynamic();

	int rv = strncmp(static_output->data, dynamic_output->data, static_output->size); // yea, I need sstring_cmp

	printf("strncmp rv=(%d) for static vs dynmic alloc, should be zero.\n", rv);

	printf(" <static>%s</static>\n", static_output->data);
	printf("<dynamic>%s</dynamic>\n", static_output->data);

	sstring_free_dynamic(dynamic_output);

	return 0;
}
