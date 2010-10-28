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

/**
 * 
 * You need to always include this file before defining DBG_LVL. Include "debug.h" last.
 *
 * @author Susanna Kaukinen (Susanna)
 *
 * @version 0.6-1 2009-02-26 (Susanna) o Pre-release, there are several options missing from this tool.
 *
 */ 


#ifndef __DEBUG_LEVELS_H__
#define __DEBUG_LEVELS_H__

const int LVL_ALWAYS  = 800;
const int LVL_ASSERT  = 700;
const int LVL_PANIC   = 600;
const int LVL_ERROR   = 500;
const int LVL_WARNING = 400;
const int LVL_NOTICE  = 300;
const int LVL_DEBUG   = 200;
const int LVL_FLOOD   = 100;

#endif // __DEBUG_LEVELS_H__
