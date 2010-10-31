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

#include <sys/types.h>
#include "c_containers.h"
#include "static_vector_memblock_header.h"

/**
 *
 * This is what we store in the memblock we receive in init
 *
 */
typedef struct
{
	static_vector_memblock_header header;
	byte data[0]; // we allow this portion to have any size, because 
                      // we don't know in advance what the size of the
                      // memblock will be
		      //
                      // the data portion will contain all the actual items,
                      //  like [item] [item] ... [lost]
                      // ,where items have the sizeof(item) given in init and
                      //  where lost portion will be a residue are that is so
                      //  so small that another item cannot be stored there.
                      // 
                      // optimally, the user should, of course not create a
                      // lost area at all, but rather have the sizeof the
                      // memblock to be such that it has the size:
                      // sizeof(header) + N*item.
                      //
                      // There are two helper methods towards this end,
                      // @see static_vector__get_exact_fit_for_a_buf_size
                      // @see static_vector__get_exact_fit_for_n_items
                      // 

} static_vector_memblock;





