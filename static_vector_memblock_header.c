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

#include "static_vector_memblock_header.h"

size_t svm_head__set_size(
	static_vector_memblock_header* obj, 
	size_t size)
{
	obj->size = size;
	return obj->size;
}

size_t svm_head__set_chunk_size(
	static_vector_memblock_header* obj, 
	size_t chunk_size)
{
	obj->chunk_size = chunk_size;
	return obj->chunk_size;
}


size_t svm_head__set_amt_chunks(
	static_vector_memblock_header* obj, 
	unsigned int chunks)
{
	obj->chunks = chunks;
	return chunks;
}

size_t svm_head__set_chunks_free(
	static_vector_memblock_header* obj, 
	unsigned int chunks_free
	)
{
	obj->chunks_free = chunks_free;
	return chunks_free;
}


uint8_t svm_head__allow_get( static_vector_memblock_header* obj)
{
	obj->allow_get = 1;
	return obj->allow_get;
}

uint8_t svm_head__allow_add(static_vector_memblock_header* obj)
{
	obj->allow_add = 1;
	return obj->allow_add;
}

uint8_t svm_head__allow_set(static_vector_memblock_header* obj)
{
	obj->allow_set = 1;
	return obj->allow_set;

}



uint8_t svm_head__forbid_get( static_vector_memblock_header* obj)
{
	obj->allow_get = 0;
	return obj->allow_get;
}

uint8_t svm_head__forbid_add(static_vector_memblock_header* obj)
{
	obj->allow_add = 0;
	return obj->allow_add;
}

uint8_t svm_head__forbid_set(static_vector_memblock_header* obj)
{
	obj->allow_set = 0;
	return obj->allow_set;

}




















