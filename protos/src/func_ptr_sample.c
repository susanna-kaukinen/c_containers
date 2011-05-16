
#include <stdio.h>

typedef struct
{
	int type;
	char* ptr;
} s0;

typedef struct
{
	int type;
	char* ptr;
	int i;
	char c;

} s1;

typedef struct
{
	int type;
	char* ptr;
	long l;
	float f;
} s2;

void* s1_init(void* o, void* buf)
{
	s1* x = (s1*) o;

	x->type = 1;
	x->i = 3;
	x->c = 'Z';
	x->ptr = buf;
	

	return o;
}

void* s2_init(void* o, void* buf)
{
	s2* x = (s2*) o;

	x->type = 2;
	x->l = 4;
	x->f = 5.3;
	x->ptr = buf;

	return o;
}

const char* buf = "koira on punainen";

void* (*initialiser)(void*,void*) = NULL;


void run_inits(void* (*initialiser)(void*,void*), const char* buf, void* object)
{
	s0* v = (s0*) (*initialiser)(object, (void*) buf);

	printf("v0: %s\n", v->ptr);

	if(v->type==1) {
		s1* v1 = (s1*) v;
		printf("v1: %d %c %s\n", v1->i, v1->c, v1->ptr);
		
	} else if (v->type==2) {
		s2* v2 = (s2*) v;
		printf("v2: %ld %f %s\n", v2->l, v2->f, v2->ptr);
	}

}


int main()
{

	s1 _s1;
	s2 _s2;

	run_inits(&s1_init, buf, &_s1);
	run_inits(&s2_init, buf, &_s2);

	printf("s1: %d %c %s\n", _s1.i, _s1.c, _s1.ptr);
	printf("s2: %ld %f %s\n", _s2.l, _s2.f, _s2.ptr);


	return 0;
}
