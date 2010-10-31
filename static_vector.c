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


#include "static_vector.h"

#include "debug_levels.h"
#define DBG_LVL LVL_FLOOD
//#define DBG_LVL LVL_DEBUG
#include "debug.h"


/**
 *
 */

static_vector_memblock* 
static_vector_init (mutable void *raw_memblock, size_t memblock_size, size_t item_size)
{

	/* if(memblock_size < sizeof(static_vector_memblock)) {
		debugfln(LVL_ERROR, "Not enough space, sizeof_memblock=%d, sizeof(static_vector_memblock+static_vector_memblock_header)",
		sizeof_memblock, sizeof(static_vector_memblock+static_vector_memblock_header));
		return 0;
	}*/

	// <init_vars>

	memset(raw_memblock, 0, memblock_size);

	static_vector_memblock* svm = raw_memblock;
	static_vector_memblock_header* head = &svm->header;

	debugfln(LVL_DEBUG, "raw_memblock_size=%u, header_size=%u, waste=%u%%\n", memblock_size, sizeof(*head), (100*sizeof(*head))/memblock_size);

	// </init_vars>

	head        = (static_vector_memblock_header*) raw_memblock;
	//svm.data    = (void*) (raw_memblock+(sizeof(static_vector_memblock_header)));

	svm_head__set_size         (head, memblock_size);
	svm_head__set_chunk_size   (head, item_size);

	svm_head__set_amt_chunks   (head, (memblock_size / item_size));
	svm_head__set_chunks_free  (head, svm_head__get_amt_chunks(head));

	svm_head__allow_get(head);
	svm_head__allow_add(head);
	svm_head__allow_set(head);

	//static_vector_forbid_get = 0;
	//static_vector_forbid_add = 0;
	//static_vector_forbid_insert = 0;

	debugfln(LVL_FLOOD, "memblock=(%x -> %x), svm=(%x), header=(%x), data=(%x), size=(%u), chunk_size=(%u), amt_chunks=(%u), chunks_free=(%u)",
		raw_memblock, 
		(raw_memblock + memblock_size),
		svm,
		svm->header,
		svm->data,
		svn_head__get_size(head),
		svm_head__get_chunk_size(head),
		svm_head__get_amt_chunks(head),
		svm_head__get_chunks_free(head)
	);

	if(svm_head__get_chunks_free(head)==0) {
		debugfln(LVL_WARNING, "No chunks generated, too little memory offered!");
	}

	return svm;
}


/**
 *
 * Pushes an item to the back of the container, like STL:s push_back.
 * 
 *
 * @param any pointer that has the size sizeof_memblock you passed to static_vector_init
 * @return how many memory chunks are left
 *
 */ 
unsigned int
static_vector_add_item     (mutable static_vector_memblock* memblock_start_addr, void* item)
{
	static_vector_memblock_header* h = &memblock_start_addr->header;

	debugfln(LVL_DEBUG, "memblock_start_addr=%x, header=%x", memblock_start_addr, h);

	unsigned int amt_chunks  = svm_head__get_amt_chunks  (h);
	unsigned int chunks_free = svm_head__get_chunks_free (h);
	size_t       chunk_size  = svm_head__get_chunk_size  (h);
	size_t       used_space  = (amt_chunks-chunks_free) * chunk_size;


	if(svm_head__is_get_allowed(h)) {
		debugfln(LVL_ERROR, "Cannot insert, you have used insert.");
		return 0;
	}

	void* to = memblock_start_addr->data + used_space;

	debugfln(LVL_FLOOD, "add: {{{%x}}} %x+(%x*%x)",
		(to>( (void*) memblock_start_addr->data + (amt_chunks*chunk_size))),
		to,
		amt_chunks,
		chunk_size
	);

	if(chunks_free <=1 ||  ( to > ( ((void*) memblock_start_addr->data) + (amt_chunks*chunk_size)))) {
		debugfln(LVL_WARNING, "Run out of chunks, chunks total=%u, chunks free=%u",
			amt_chunks, chunks_free);

		svm_head__forbid_get(h);
	
		return 0;
	}

	svm_head__forbid_set(h);

	memmove(to, item, chunk_size);

	return svm_head__dec_chunks_free(h);
}

/**
 *
 * @return pointer to item as void pointer, cast it to your type and use
 *         after making sure it's not zero!
 *
 */
void*
static_vector_get_item     (const   static_vector_memblock* memblock_start_addr, int   index)
{
	
	const static_vector_memblock_header* h = &memblock_start_addr->header;

	size_t       chunk_size  = svm_head__get_chunk_size  (h);
	unsigned int amt_chunks  = svm_head__get_amt_chunks  (h);

	if(!svm_head__is_set_allowed(h)) {
		debugfln(LVL_ERROR, "Cannot get, something went wrong w/add.");
		return 0;
	}

	void *from = ((void*) (memblock_start_addr->data)) + (chunk_size * index);

	if(from< (void*) memblock_start_addr || 
			from>((void*) memblock_start_addr + (amt_chunks * chunk_size))) {
		debugfln(LVL_WARNING, "Tried to access out of bounds!");
		return 0;
	}

	return from;
}

/**
 *
 *
 *
 */
unsigned int 
static_vector_set_item (
	mutable static_vector_memblock* memblock_start_addr, 
	void*                           item, 
	unsigned int                    index
)
{
	static_vector_memblock_header* h = &memblock_start_addr->header;

	unsigned int amt_chunks  = svm_head__get_amt_chunks  (h);
	size_t       chunk_size  = svm_head__get_chunk_size  (h);

	if(svm_head__is_set_allowed(h)) {
		debugfln(LVL_ERROR, "Cannot insert, you have used add.");
		return 0;
	}

	void* to = memblock_start_addr + (amt_chunks*index);

	if(to< (void*) memblock_start_addr || to>( (void*) memblock_start_addr+(amt_chunks*chunk_size))) {
		debugfln(LVL_WARNING, "Tried to access out of bounds!");
		return 0;
	}

	svm_head__forbid_add(h);

	memmove(to, item, chunk_size);

	return index;
}



unsigned int static_vector_get_max_size (const static_vector_memblock* memblock_start_addr)
{ 
	const static_vector_memblock_header* h = &memblock_start_addr->header;

	return svm_head__get_amt_chunks(h);
}




