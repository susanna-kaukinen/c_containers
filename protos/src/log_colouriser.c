#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <features.h>
#include <stdio.h>
#include <string.h>

// http://www.gnu.org/s/hello/manual/libc/Creating-a-Pipe.html

static const char* COLOUR_RED        = "\033[22;31m";
static const char* COLOUR_GREEN      = "\033[22;32m";
static const char* COLOUR_YELLOW     = "\033[01;33m";
static const char* COLOUR_RESET      = "\033[0m";

const int limit = 1024*1024;

/**
 * @warning: prints only `limit' bytes.
 */
void read_from_pipe (int file)
{
	FILE* out = fdopen (file, "r");

	size_t sz=limit;
	char buf[sz+1];
	fread(buf, sz, 1, out);
	printf("%s", buf); 

	fclose (out);
	fflush(stdout);
}


void write_to_pipe (int file)
{
	const char* filname = "/var/log/syslog";

	struct stat s;
	stat(filname, &s);
	off_t file_size = s.st_size; 

	FILE* in  = fopen (filname, "r");
	FILE* out = fdopen (file, "w");

	size_t sz = (file_size > limit ? limit : file_size);
	size_t n=1, n_read=0;
	char buf[sz];

	do {

		if(!fread(buf,  sz, n, in)) {
			sz = file_size-n_read;
			memset(buf, 0, sizeof(buf));
			fseek(in, (sz*-1), SEEK_END);
			fread(buf, sz, n, in);
		}
		n_read += sz;

		char* needle;
		const char* needle1  = "demeter";
		const char* needle2 = "kernel";

		char* needle_colour;
		const char* needle1_colour = COLOUR_RED;
		const char* needle2_colour = COLOUR_YELLOW;


		size_t offset = 0;
		char* at = (char*) (NULL + 1);

		while(at!=NULL) {

			at = strstr(&buf[offset], needle1);
			char* at2 = strstr(&buf[offset], needle2);

			if(at>at2) {
				at = at2;
				needle = needle2;
				needle_colour = needle2_colour;
			} else {
				needle = needle1;
				needle_colour = needle1_colour;
			}

			size_t len = (at-&buf[offset]);

			if(at!=NULL) {

				fwrite(&buf[offset], len, n, out);

				fwrite(needle_colour, strlen(needle_colour), 1, out);
				fwrite(needle,  strlen(needle), 1, out);
				fwrite(COLOUR_RESET, strlen(COLOUR_RESET), 1, out);

			} else {
				fwrite(&buf[offset], sz-offset, n, out);
			}

			offset += len+strlen(needle);
		} 

	} while (file_size>n_read);


	fclose (in);
	fclose (out);
}

int main (void)
{
	pid_t pid;
	int mypipe[2];

	/* Create the pipe. */
	if (pipe (mypipe))
	{
		fprintf (stderr, "Pipe failed.\n");
		return EXIT_FAILURE;
	}

	/* Create the child process. */
	pid = fork ();
	if (pid == (pid_t) 0)
	{
		/* This is the child process.
		   Close other end first. */
		close (mypipe[1]);
		read_from_pipe (mypipe[0]);
		return EXIT_SUCCESS;
	}
	else if (pid < (pid_t) 0)
	{
		/* The fork failed. */
		fprintf (stderr, "Fork failed.\n");
		return EXIT_FAILURE;
	}
	else
	{
		/* This is the parent process.
		   Close other end first. */
		close (mypipe[0]);
		write_to_pipe (mypipe[1]);
		return EXIT_SUCCESS;
	}
}

