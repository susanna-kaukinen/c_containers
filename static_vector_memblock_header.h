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

#ifndef __STATIC_VECTOR_MEMBLOCK_HEADER__
#define __STATIC_VECTOR_MEMBLOCK_HEADER__

#include <sys/types.h>
#include <stdint.h>

#include "c_containers.h"

/**
 *
 *
 * @TODO wouldn't hurt to have test for this class as well
 *
 */

typedef struct
{
	size_t       size;
	size_t       chunk_size;
	unsigned int chunks;
	unsigned int chunks_free;

	uint8_t          forbid_get;
	uint8_t          forbid_add;
	uint8_t          forbid_set;

} static_vector_memblock_header;

// <privileges>
uint8_t svm_head__allow_get  (mutable static_vector_memblock_header* header);
uint8_t svm_head__allow_add  (mutable static_vector_memblock_header* header);
uint8_t svm_head__allow_set  (mutable static_vector_memblock_header* header);
uint8_t svm_head__forbid_get (mutable static_vector_memblock_header* header);
uint8_t svm_head__forbid_add (mutable static_vector_memblock_header* header);
uint8_t svm_head__forbid_set (mutable static_vector_memblock_header* header);

uint8_t svm_head__is_get_allowed(const static_vector_memblock_header* header);
uint8_t svm_head__is_set_allowed(const static_vector_memblock_header* header);
// </privileges>

// <mutators>

static_vector_memblock_header* svm_head__clone(mutable static_vector_memblock_header* new_header, const static_vector_memblock_header* old_header);

size_t svm_head__set_size              (mutable static_vector_memblock_header* header, size_t size);
size_t svm_head__set_chunk_size        (mutable static_vector_memblock_header* header, size_t chunk_size);
size_t svm_head__set_amt_chunks        (mutable static_vector_memblock_header* header, unsigned int chunks);
size_t svm_head__set_chunks_free       (mutable static_vector_memblock_header* header, unsigned int chunks_free);
size_t svm_head__dec_chunks_free       (mutable static_vector_memblock_header* header );

// </mutators><readers>

size_t svm_head__get_amt_chunks        (const static_vector_memblock_header* header);
size_t svm_head__get_size              (const static_vector_memblock_header* header);
size_t svm_head__get_chunk_size        (const static_vector_memblock_header* header);
unsigned int svm_head__get_chunks_free (const static_vector_memblock_header* header);
size_t svm_head__get_header_size       (const static_vector_memblock_header* header);

// </readers>

#endif // __STATIC_VECTOR_MEMBLOCK_HEADER__


