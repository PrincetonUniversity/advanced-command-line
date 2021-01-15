# find
Now that you have a grip on regular expressions, the expansions and globbing
provided by bash don't seem nearly as powerful.  Recall the question of finding
files without an `a` in the name; this wasn't possible with the basic set of
globbing metacharacters but the regex for it is simply `/^[^a]+$/`.

In this section we will cover using `find` to search for files.  `find` has
a lot of options to help pinpoint exactly the files you want to capture.
`find` can also perform operations on the files it finds, but for reasons
we will cover later, `xargs` is usually a better choice.

The files generated in this section are small but numerous, be sure to clean
up this directory when you are done.  They are mostly empty or full of textual
nonsense that we will explore through exercises.  Since they are randomly
generated, your results will vary.

## find execution
The `find` command is invoked as
```
find [options] [starting-path...] [expression]
```
The options define how links are handled and allow you to activate some
optimizations and debug logging; we will ignore these.  The starting path
determines the root of `find`'s execution.  The expression will filter which
files are ultimately returned.

I always mix up the order of path and expression as it seems reverse of most
commands, especially grep.  It may help to remember the argument order mimics
`find`'s algorithm, you start at the starting path then use expressions to
filter your matches.

### EXERCISE
Since all the arguments are optional, let's start with a simple find command.
```
find | less
find | wc -l  # number of files/directories
```
Find works by searching the *entire directory* tree, reporting each directory
and file it finds.  As such, you should be refine the starting path as much
as possible.  Don't run `find /` unless you have *no idea* where to start.
Try the following to see how the starting path affects the results:
```
find tree | less
find deep wide | less
```

You should have noticed that the default starting path is the current directory
and you can list multiple starting points.

## Global Options
The first set of expressions we will cover are options that affect how find
operates and traverses the file tree.
 - `-regextype <type>`: specify the type of regex syntax.  Includes egrep and
   posix-extended.
 - `-depth`: process directory contents before directories themselves.
 - `-maxdepth/-mindepth <level>`: limit directory traversal depth.

### EXERCISE
Explore the effect of the `depth` options in the `deep` directory.
```
find deep
find deep -depth
find deep -maxdepth 10
find deep -maxdepth 10 -mindepth 5
```

## Refine by time
For the all the following, numeric arguments to expressions can be
 - `n` for exactly the value `n`
 - `-n` for less than `n`
 - `+n` for greater than `n`

Files can be filtered by time of accession, `a`, status change, `c`, or
modification, `m`.  Accession is when the file is opened, status change refers
to a change in file type or permissions, modification is a change in the file
contents.  You can test these values by minutes, `min`, or days, `time`.
All together, the expressions are `/-[acm](min|time)/`.  These are harder to
demonstrate as all the files were created recently.  Here are some example
commands and their English translations:
```
find -atime 0  # files accessed today
find -atime 1  # files accessed yesterday
find -atime +1  # files modified at least two days ago
find deep -cmin 10  # files changed exactly 10 minutes ago
find deep -cmin -10  # files changed within the last 10 minutes
find deep -mmin +10  # files not modified within the last 10 minutes
```

You will usually want the `m` version of these commands.  A mistake I make
constantly is searching for `-mmin 60` to try to find files modified in the
last hour.  *This only finds files modified exactly 60 minutes ago and is
usually nothing!*

The last version of time refinement is `/-[ac]newer/`, which takes as an
argument a reference to a file or a time stamp to compare each file against.
The expression `-newer` examines the modification time; `-mnewer` doesn't
exist.

## Refine by permissions
You can also refine files by access permissions.  There are 3 urinary
expressions that do what you expect:
- `-writeable`
- `-readable`
- `-executable`

Finally there is `-perm`, which allows you to specify an exact octal or
symbolic access code for a file.  There are also versions of `-perm` that
match files with more or less restrictive access patterns.  Search for
examples if you have this need.

## Refine by user and group
There are expressions to refine the matches based on the user and group
ownership of a file.  Again, these are about what you expect:
 - `-group <name>`: matches if the file has group `<name>`
 - `-nogroup`: matches if the file has no group
 - `-uid <id>`: matches if the file belongs to the numeric user id
 - `-user <user>`: matches if the file belongs to `<user>`
 - `-nouser`: matches if the file has no user

## Refine by content, miscellany
Finally, before we jump to file names, find can filter matches by content to
a limited extent:
 - `-empty`: matches if the file is empty
 - `-size n[kMG]`: matches if the file uses `n` units of space.  Remember to
   use `+n` for matching sizes larger than `n`, and `-n` for smaller than `n`.
 - `type [fdpl]`: matches if the file is a normal file, directory, pipe, link.
   Multiple types are specified by listing them as a comma separated list.

You will typically want to search with `-type f`.  The same caveats for `mmin`
apply to `size`, you will almost always want to use `+/-` instead of bare
numbers!

Clearly size and empty don't provide much filtering for the content of files.
Recall that grep can also search the contents of a directory tree for a regex
with the `-r` option.  `-n` is useful for getting the line number of each
match and `-l` just prints the matching files.
```
grep -r cat wide  # search the regex `cat` in all files in the wide directory
grep -nr cat wide  # report line numbers of matches
grep -nl cat wide  # report just file names with matches
```

### EXERCISE
In the files directory, search for:
 - Regular files that are larger than 1k
 - Regular files smaller than 100 bytes
 - Find the file containing `needle`.

## Refine by name
So far the expressions have been looking for a file based on its
characteristics, size, modification time, etc.  But if you know the name (or
part of it) that's much more precise.  `find` offers 3 flavors of matching
by filename:
 - `-name` Search for the file's basename, can use shell glob syntax
 - `-path` Search for a file's path, can use shell glob syntax
 - `-regex` Search the full path with the supplied regex

Note that glob names have to be provided in single quotes to prevent shell
expansion before find can operate on the pattern.  If you prepend any of the
above with `i`, the search becomes case-insensitive, e.g. `-iname`.

### EXERCISE
 - Try the following commands in the files directory:
   ```
   find -name d
   find -name '*d*'
   find -name d/e
   find -path d/e
   find -path '*d/e'
   find -regex 'd/e'
   find -regex '.*d/e'
   ```
   Note that each pattern has an implicit anchor for the front and end of the
   name or path!  If you want to search anywhere in a file, you need `*GLOB*`
   or `.*regex.*`.
 - Search for files that don't contain the letter `a`.
 - Search for the file `text.txt`.  Use command substitution and cat to display
   the contents.
 - Do you have any files with 3 vowels in a row?  You may have to change the
   `-regextype` to egrep or escape your braces if you are using quantifiers.

## Operators
Expressions can be combined to generate more complex matching criteria.  By
default, if you supply multiple expressions, all must be satisfied to match
a file.  I tend to use the non POSIX compliant forms as they are easier to
remember.  For expressions `expr1` and `expr1`:
 - `-not expr1`: True if `expr1` is false
 - `expr1 -or expr2`: True if `expr1` or `expr2` are true.
 - `expr1 -and expr2`: True if `expr1` and `expr2` are true.  Same as
   `expr1 expr2`

Of these, `-not` is the most useful though occasionally `-or` is handy.  You
can group expressions by surrounding them with `\( expr \)`.

### EXERCISE
In the files directory, search for:
 - Regular files smaller than 100 bytes that are not empty.
 - Regular files that are not empty or contain the letter 'e'.

## Actions
Once you have a list of files, you may like to operate on them. We will cover
`xargs` next, which is more powerful and general than the `-exec` of find, but
two actions are worth mentioning:
 - `-delete`: Delete the matching files.  Importantly, this reverse traversal
   to use the `-depth` option so directory contents are deleted before
   attempting to delete the directory itself.  Deleting all empty files, slurm
   outputs, or files above/below a certain size is very handy!
 - `-print0`: This prints matches separated by a null character and simplifies
   piping to xargs.

### EXERCISE
Find all empty files and directories and delete them.  Remove the `text.txt`
file at the bottom of the deep directory and rerun the deletion command.

## xargs
We are going to use a limited set of `xargs` which will hopefully be enough to
do basic jobs while motivating you to learn more if needed.

If you have tried to use process substitution to pass a lot of files as
arguments, say `rm $(ls *.txt)` you may have run into an error about providing
an input longer than some maximum length.  `xargs` allows you to get around
this in a few ways.  Let's start basic:
```
echo $(find -type f -size +1k)
find -type f -size +1k | xargs echo
find -type f -size +1k -print0 | xargs -0 echo
```
Because we don't have very many files and none with spaces or newlines, those
commands should be identical.  However, if we had a few hundred files, `xargs`
would automatically split them into multiple invocations of `echo`.  If our
filenames had spaces, the final command would properly handle them.  Always
use `-print0` and `-0` if you don't know what the filenames will be!

If you want to control how many files are grouped into each invocation, you
can set the `-L` option.  For example,
```
find -type f -size +1k | xargs -L 3 echo
find -type f -size +1k | xargs -L 2 cmp
```

You should start to see that `xargs` just places the arguments from `stdin`
at the end of whatever command you supply, in the order they arrive.  There
are a few more tricks worth mentioning.  If your command is slow, you can
run multiple processes simultaneously with the `-P` option.  If you need the
command argument to go somewhere besides the end of the string, you can specify
a placeholder with `-I`.  Typically you will see `-I{}`, like so
```
find -type f -size +1k | xargs -I{} -P 3 sh -c "echo {} ; sleep 2"
```
With the `-I` option, `-L` is set to 1, so the above uses three processes to
echo 3 files then sleeps for 2 seconds to see the multiprocessing.

If that all seems abstract, consider the operation to replace a string in
all files in a directory:
```
find -type f | xargs sed -i 's/target/replacement/g'
```
This can allow you to refactor a variable name or rename a library in a
single line.

If you have more complex operations, such a multiple commands or piping for
xargs, consider wrapping everything in a separate script to invoke with
xargs or script a for loop.
