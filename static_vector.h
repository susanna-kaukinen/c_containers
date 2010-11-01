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


#ifndef __STATIC_LIST_H__
#define __STATIC_LIST_H__

#include <stdio.h>

#include "c_containers.h"
#include "static_vector_memblock.h"

// @TODO consider naming, needed methods, consistency of interface
//
// perhaps interesting methods.
//
// compare (const static_vector_memblock* v1, const static_vector_memblock* v2);
// compare_at (const static_vector_memblock* v1, const static_vector_memblock* v2, unsigned int index);
// zero_item
// resize

/**
 *
 * Helpers for avoiding choosing a memblock_size that results in a residue part in the memblock
 * that cannot be used because it's too small to hold an item.
 *
 * Call these to get an even size for the buffer that you can give to the static_vector__init method.
 *
 */
size_t static_vector__get_exact_fit_for_n_items     (unsigned int max_items, size_t item_size);
size_t static_vector__get_exact_fit_for_a_buf_size  (size_t buf_size, size_t item_size);

/**
 *
 * Constructor. Use this to build your vector.
 *
 */
static_vector_memblock* static_vector__init         (mutable void *raw_memblock, size_t memblock_size, size_t item_size);

/**
 *
 * Adds an item to the end of the vetor.
 *
 */
unsigned int static_vector__add_item                (mutable static_vector_memblock* memblock_start_addr, void* item);

/**
 *
 * Sets/overwrite an item at the given index.
 *
 */
unsigned int static_vector__set_item                (mutable static_vector_memblock* memblock_start_addr, void* item, unsigned int index);

/**
 *
 * 
 * Returns an item from the given index. Just cast it to the type you know that item really is.
 *
 */
void*        static_vector__get_item                (const   static_vector_memblock* memblock_start_addr, int   index);

/**
 *
 * Tells the capacity of the vector.
 *
 */
unsigned int static_vector__get_max_size            (const   static_vector_memblock* memblock_start_addr);



#endif // __STATIC_LIST_H__









