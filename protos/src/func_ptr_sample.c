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

/**
 *
 * Usage: 
   gcc -Wall -std=c99 -gstabs+ func_ptr_sample.c && valgrind --leak-check=full ./a.out
 *
 * Sample of how to build something object oriented w/C. Sampled are initialising
 * objects in accordance w/their type using function pointer to achieve this. Just
 * for fun, I also added a parent class to the mix.
 *
 * @author Susanna Kaukinen (Susanna)
 *
 * @version 1.0-1 2011-05-16 (Susanna) o Initial sample. Por que no. :-)
 *
 */



#include <stdio.h>
#include <string.h>

typedef struct
{
	int type; // @warning: This is a bit of a hack, this struct and all child structs _must_ start w/this field or this will not work.
                  //           The other option is to have a type-field only in the parent and set that from the init funcs of the children. 
	const char* ptr; // common
} parent_class;

typedef struct
{
	int type; // type to determine object type
	parent_class* parent;
	int i;    // obj data
	char c;   // obj data

} class_type_1;

typedef struct
{
	int type;
	parent_class* parent;
	long l;
	float f;
} class_type_2;

void parent_initialiser(parent_class* parent, const char* buf)
{
	parent->type = 0;
	parent->ptr = buf;	
}

void* class_1_initialiser(parent_class* parent, void* object, const char* buf)
{
	class_type_1* o1 = (class_type_1*) object;

	o1->parent = parent;             // grab parent
	parent_initialiser(o1->parent,buf);  // init parent (super) as well

	o1->type = 1;          // set my type
	o1->i = 3;             // init my data
	o1->c = 'Z';           // -""-

	return o1;
}

void* class_2_initialiser(parent_class* parent, void* object, const char* buf)
{
	class_type_2* o2 = (class_type_2*) object;

	o2->parent = parent;
	parent_initialiser(o2->parent,buf);

	o2->type = 2;
	o2->l = 4;
	o2->f = 5.3;

	return o2;
}

const char* buf = "koira on punainen";

// class_object-type agnostic class initialiser 
void* (*class_initialiser_func)(parent_class* parent_object, void* class_object, const char* sample_string) = NULL;

/**
 *
 * Initialises object according to their type. 
 *
 */
void run_inits(parent_class* parent, void* object, void* (*class_initialiser_func)(parent_class*,void*,const char*), const char* buf)
{
	(*class_initialiser_func)(parent, object, buf);

	printf("parent: %s\n", parent->ptr); // ok, we can access parent

	// figure out what type our child is:
	int type = ((parent_class*) object)->type; 

	if(type==1) {
		class_type_1* obj1 = (class_type_1*) object;
		printf("obj1: %d %c %s\n", obj1->i, obj1->c, obj1->parent->ptr);
		
	} else if (type==2) {
		class_type_2* obj2 = (class_type_2*) object;
		printf("obj2: %ld %f %s\n", obj2->l, obj2->f, obj2->parent->ptr);
	} else {
		printf("Unknown obj type=(%d)\n", type);
	}

}


int main()
{

	parent_class parent;
	class_type_1 object_type_1;
	run_inits(&parent, &object_type_1, &class_1_initialiser, buf);

	printf("class_type_1: %d %c %s\n",  object_type_1.i, object_type_1.c, object_type_1.parent->ptr);

	parent_initialiser(&parent,""); // zero parent for the clarity of the exanple, but no real reason for this.

	class_type_2 object_type_2;
	run_inits(&parent, &object_type_2, &class_2_initialiser, buf);

	printf("class_type_2: %ld %f %s\n", object_type_2.l, object_type_2.f, object_type_2.parent->ptr);

	return 0;
}
