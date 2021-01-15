# Globbing
You should have some familiarity with wildcard expansion used in bash.  We
will cover some more advanced glob syntax and, later, contrast this with
regular expressions.  The `files` directory contains some targets to
practice selecting subsets of files.

## Globs
Globs are a bash feature that provide a simple syntax that is less expressive
than regular expressions.  You have probably used `*.txt` to get all text files,
but there are more advanced expressions to target more specific files.

## Literals
Most characters are taken literally by bash.  For example,
```
cat 2.a
```
The glob here is `2.a` which literally matches the file `2.a`.  Metacharacters
include `*`, `?`, `[]`, `{}` which we will cover next.  If you want to match a
file with a literal metacharacter, first, consider renaming the file and
using a different scheme!  This is especially true for spaces in filenames
since, by default, a space in bash separates arguments.  But if you must, you
can escape a single character with `\` or surround the glob with single quotes.

## Wildcards
The characters `*` and `?` are wildcards that match any character.  `*` will
match 0 or more characters while `?` matches exactly one character.

### EXERCISE
Try some of the following to see how each wildcard is evaluated.  In the 
`files` directory:
```
ls *
ls *.img
ls ?.a
ls ??a
ls *a
ls *a*
ls 1*a*
```

Note that since `*` matches 0 or more characters, `1*a*` matches `1.a`,
and `1a.img`.

The utility of globs is passing these expanded file lists to commands.
Try calling `cat` on all the `.img` files or the `.a` files.  Don't
underestimate the value of `?`.  When files are named sequentially it's useful
for looking at just the files in the 30's, or 1-9.

### EXERCISE
Compare the outputs of `ls *` and `ls -A`.  Which files aren't present in
`ls *`?  How can you show those?

## Character sets
Character sets are groups or ranges of characters that match to a single
character in the output.  They are specified by listing the target characters
in square braces.  The following produce identical results:
```
ls [abc].txt  # matches a.txt, b.txt, or c.txt
cat !$  # recall last argument
cat [abcd].txt  # d.txt doesn't exist
cat [a-c].txt  # can use a range
cat [bca].txt  # order not determined by glob
```

Notice how `-` has special meaning inside the square bracket.  To match a
literal `-` set it as the first or last character of the set.

Character sets can be negated by including `!` as the first character.  To
get all files that don't start with a or b:
```
ls [!ab]*
```

### EXERCISE
You want all files as long as an `a` doesn't appear anywhere in the filename.
Does `ls *[!a]*` work?  What does this tell you about how the glob is
evaluated?  Does `*[!a]*` match a file called `a`?  (Use `touch a` to create an
empty file).

## Character sequences
Character sequences specify an exact set of values to replace.  They are less
of a regular expression and more of a simplified for loop.  Values are
specified in curly braces.  Specific values are given separated by commas and
ranges are given with `..`.
```
cat {a,b,c}.txt
cat {b,b,c}.txt  # can repeat
cat {c,b,a}.txt  # order matters
cat {.1hidden,c,b}.txt  # can have multiple characters
cat {a..c}.txt  # range of values
cat {1..6}.a
```

Note that unlike character sets, sequences yield all values, even if the file
does not exist:
```
cat {a..d}.txt
```

You can't directly combine ranges and values, e.g.
```
cat {1..4,a..c}.txt  # ERROR
cat {1..4}.txt {a..c}.txt  # works
```

Using numeric ranges is much easier than trying to list, sort, and process a
set of files.  Character sequences can also be used as inputs to for loops in a
bash script.

## More options
Bash offers more options to expand globbing that are disabled by default and
make globs behave a little closer to a regular expression.  Before you look up
and activate these options ask the following:
 - Is a bash script the best tool for finding the files I need?  The work
   may be better suited for a python script with a full regex engine or `find`.
 - Why is my file pattern so complex?  Can I use subdirectories to better
   organize my files?
