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

static_vector_memblock* static_vector_init (mutable void *raw_memblock, size_t item_size);
//static_vector_memblock* static_vector_init_(mutable void *raw_memblock, size_t sizeof_memblock, size_t item_size);

unsigned int static_vector_add_item     (mutable static_vector_memblock* memblock_start_addr, void* item);
unsigned int static_vector_set_item     (mutable static_vector_memblock* memblock_start_addr, void* item, unsigned int index);

void*        static_vector_get_item     (const   static_vector_memblock* memblock_start_addr, int   index);
unsigned int static_vector_get_max_size (const   static_vector_memblock* memblock_start_addr);

#endif // __STATIC_LIST_H__









