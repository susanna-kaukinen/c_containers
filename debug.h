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
 * This file provides a simple but very useful output interface.
 *
 * @author Susanna Kaukinen (Susanna)
 *
 * @version 0.6-1 2009-02-26 (Susanna) o Pre-release, there are several options missing from this tool.
 *
 */

#ifndef __DEBUG_H__
#define __DEBUG_H__

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#ifndef __GNUC__
#error "Debug.h is GNUC only."
#endif

#ifndef DBG_LVL
#error "Cannot include debug.h w/o defining debug level!";
#endif

static const char* COLOUR_RED        = "\033[22;31m";
static const char* COLOUR_GREEN      = "\033[22;32m";
static const char* COLOUR_YELLOW     = "\033[01;33m";
static const char* COLOUR_RESET      = "\033[0m";

#define	OPTS_NONE         0
#define	OPTS_PLAIN        1
#define OPTS_LINEFEED     2

/**
 *
 * Don't call this function directly, use the macros.
 *
 * This functions always flushes the output to make sure that you get all of it, if your program crashes.
 * However, this is a performance problem, so act accordingly.
 *
 * If even more performance is required, you can enhance the macros to compile out the debug lines
 * that won't be printed in the chosen level. 
 *
 * @todo add logging to files.
 * @todo add possibility to not use colors.
 * @todo add possibility to not output linefeed.
 * @todo add possibility of not flushing the output.
 *
 */
static void _debugf(int options, int level, const char* file, int line, const char* function, const char* format, ...)
{
	FILE *stream = stdout;

	if(DBG_LVL>level)
		return;

	if(level>=LVL_ERROR) {
		fprintf(stream, "%s", COLOUR_RED); 
	} else if (level==LVL_WARNING) {
		fprintf(stream, "%s", COLOUR_YELLOW); 
	} else if (level==LVL_NOTICE) {
		fprintf(stream, "%s", COLOUR_GREEN); 
	}

	if(options!=OPTS_PLAIN) {
		fprintf(stream, " [ (%5u) ] { %s:%4d } [ %s ] (errno=`%s') : ", getpid(), file, line, function, strerror(errno));
	}

	va_list ap;
	va_start(ap, format);
	vfprintf(stream, format, ap);
	va_end(ap);

	if(options|OPTS_LINEFEED) {
		fprintf(stream, "\n");
	}

	fprintf(stream, "%s", COLOUR_RESET);
	fflush(stream);
	
}


/**
 *
 * debugf, and this family of macros outputs debug-information w/different added informations. This one is the basic
 *         form, adding all kinds of useful state information to the output from your program.
 *
 */
#define debugf(level, format, args...)         _debugf(OPTS_NONE, level, __FILE__, __LINE__,__FUNCTION__, format, ## args)
#define debugfln(level, format, args...)       _debugf(OPTS_LINEFEED, level, __FILE__, __LINE__, __FUNCTION__, format, ## args)

/**
 *
 * Like debugf, but uses __PRETTY_FUNCTION__ rather than __FUNCTION__. This means that you also get the class name
 *              the output.
 *
 */
#define pretty_debugf(level, format, args...)  _debugf(OPTS_NONE, level, __FILE__, __LINE__,__PRETTY_FUNCTION__, format, ## args)

/**
 *
 * Like debugf, but doesn't print any added information. Current version still uses colours and honors given levels.
 *
 */
#define debugfp(level, format, args...)    _debugf(OPTS_PLAIN, level, __FILE__, __LINE__,__FUNCTION__, format, ## args)
#define debugfpln(level, format, args...)  _debugf(OPTS_LINEFEED|OPTS_PLAIN, level, __FILE__, __LINE__, __FUNCTION__, format, ## args)

/**
 *
 * Like debugf, but cond_debugf will only print if condition is met (i.e. condition==true).
 *
 */
#define cond_debugf(condition, level, format, args...) \
	if((condition)) {\
		 _debugf(OPTS_NONE, level, __FILE__, __LINE__,__FUNCTION__, format, ## args); \
	}

/**
 *
 * assertf will cause the termination of the program, if the condition is false.
 * 
 * @warning You should call this macro like this: assertf((condition), ...); to make sure your condition gets evaluated correctly.
 *
 */
#define assertf(condition, format, args...) \
	if((!condition)) {\
		_debugf(OPTS_NONE, LVL_ASSERT, __FILE__, __LINE__, __FUNCTION__, format, ## args); \
		exit(-1);\
	}

#endif // __DEBUG_H__
