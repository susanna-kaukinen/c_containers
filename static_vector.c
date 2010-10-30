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
static_vector_init (mutable void *raw_memblock, size_t item_size)
{

	if(sizeof(raw_memblock)<sizeof(static_vector_memblock+static_vector_memblock_header)) {
		debugfln(LVL_ERROR, "Not enough space, sizeof_memblock=%d, sizeof(static_vector_memblock+static_vector_memblock_header)",
		sizeof_memblock, sizeof(static_vector_memblock+static_vector_memblock_header));
		return 0;
	}

	memset(raw_memblock, 0, sizeof_memblock);

	static_vector_memblock* svm;

	svm->header = (static_vector_memblock*) raw_memblock;
	svm->data   = (static_vector_memblock_header*) (raw_memblock+sizeof(static_vector_memblock+static_vector_memblock_header);


	memblock_p        = memblock;
	memblock_sz       = sizeof_memblock;
	memblock_chunk_sz = item_size;

	memblock_chunks   = memblock_sz / memblock_chunk_sz;
	memblock_chunks_free = memblock_chunks;

	static_vector_forbid_get = 0;
	static_vector_forbid_add = 0;
	static_vector_forbid_insert = 0;

	debugfln(LVL_FLOOD, "memblock=(%x -> %x), memblock_sz=(%u), memblock_chunk_sz=(%u), memblock_chunks=(%u), memblock_chunks_free=(%u)",
		memblock_p, (memblock_p + memblock_sz),
		memblock_sz,
		memblock_chunk_sz,
		memblock_chunks,
		memblock_chunks_free);

	if(memblock_chunks_free==0) {
		debugfln(LVL_WARNING, "No chunks generated, too little memory offered!");
	}

	return memblock_chunks_free;
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
unsigned int static_vector_add_item(void* item)
{
	if(static_vector_forbid_add) {
		debugfln(LVL_ERROR, "Cannot insert, you have used insert.");
		return 0;
	}

	void* to = memblock_p + (memblock_chunks-memblock_chunks_free)*memblock_chunk_sz;

	debugfln(LVL_FLOOD, "add: {{{%x}}} %x+(%x*%x)",
		(to>(memblock_p+(memblock_chunks*memblock_chunk_sz))),
		to,
		memblock_chunks,
		memblock_chunk_sz
	);

	if(memblock_chunks==0 ||  (to>(memblock_p+(memblock_chunks*memblock_chunk_sz)))) {
		debugfln(LVL_WARNING, "Run out of chunks, chunks total=%u, chunks free=%u",
			memblock_chunks, memblock_chunks_free);

		static_vector_forbid_get = 1;
	
		return 0;
	}

	static_vector_forbid_insert = 1;



	memmove(to, item, memblock_chunk_sz);

	return --memblock_chunks_free;
}

/**
 *
 * @return pointer to item as void pointer, cast it to your type and use
 *         after making sure it's not zero!
 *
 */
void* static_vector_get_item(int index)
{
	if(static_vector_forbid_get) {
		debugfln(LVL_ERROR, "Cannot get, something went wrong w/add.");
		return 0;
	}

	void *from = memblock_p + (memblock_chunk_sz*index);

	if(from<memblock_p || from>(memblock_p+(memblock_chunks*memblock_chunk_sz))) {
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
unsigned int static_vector_set(void* item, int index)
{
	if(static_vector_forbid_insert) {
		debugfln(LVL_ERROR, "Cannot insert, you have used add.");
		return 0;
	}

	void* to = memblock_p + (memblock_chunks*index);

	if(to<memblock_p || to>(memblock_p+(memblock_chunks*memblock_chunk_sz))) {
		debugfln(LVL_WARNING, "Tried to access out of bounds!");
		return 0;
	}

	static_vector_forbid_add = 1;

	memmove(to, item, memblock_chunk_sz);

	return index;
}



unsigned int static_vector_get_max_size() { return memblock_chunks; }



