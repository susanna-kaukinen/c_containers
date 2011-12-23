#!/bin/sh

###
#
# unrtf_tree.sh
#
# Convert rtf files to html files from a directory tree.
#
# Processing steps:
# 1. A backup of the directory is created to current dir as ${dirname}.bak.$$
# 2. All files in the directory tree w/non-unix filenames are converted to unix filenames via detox.
# 3. All rtf files are converted to html files via unrtf.
# 4. The original rtf files are removed.
# 5. Logfiles for both stdout and stderr are provided to current dir as ${dirname}.log and ${dirname}.err
#
# @author Susanna Kaukinen
# @version 1.0 / 2011-12-23
# 

ME=$(basename $0)

check_dep()
{
	which $1 1>&2 > /dev/null
	if [ $? -ne 0 ] ; then
		 echo "Cannot find \`$1', use apt to install it and try again." 
		 exit 1
	fi
}

check_deps()
{
	check_dep detox
	check_dep unrtf
}

unrtf_tree()
{

	for file in $(find $1 -iname '*.rtf') ; do
		local outfile=$(echo $file | sed -e 's/...$/html/')
		echo Processing: $file '->' $outfile
		unrtf $file > $outfile 2>&1 
		echo done.

		rm -f $file
	done

}

usage()
{
	echo usage: $ME directory
	exit
}

main()
{
	if [ "$1" = "" ] || [ ! -d $1 ] ; then
		usage
	fi

	check_deps

        exec 6>&1       # store stdout
	exec 1> $1.log  # redirect stdout to file
	exec 2> $1.err  # redirect stderr to file

	cp -r $1 $1.bak.$$
	detox -r $1     # remove whitespace from filenames
	unrtf_tree $1   # foreach rtf -> html

        exec 1>&6 6>&-  # restore stdout

	echo "Conversion complete."
	echo
	echo "logfiles:"
	ls -l $1.log $1.err
	echo
	echo "errors:"
	cat $1.err
	echo
	echo "backup:"
	ls -l | grep $1.bak.$$

}


main $*
