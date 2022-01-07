# awk
awk is a general scripting language whose name is derived from the surnames
of the original authors.  As a motivating example, consider a python script
to print the sum of the second and third columns in a file:
```
with open(INPUT) as infile:
    for line in infile:
        line = line.strip()
        tokens = line.split()
        print(int(tokens[1]) + int(tokens[2]))
```
If you were trying to type that on the command line, you may also need to
import sys to read stdin.  The equivalent awk program is:
```
awk '{print $2+$3}'
```

Similar to sed, the general command is
```
awk [script] INPUT
```
The script can be provided as a separate file using the `-f` option.

The setup script in this module uses the same files as `02_misc`.

## When to use awk
We are going to omit many features in awk, so don't think that awk is
not capable of performing complex tasks.  Suitable tasks for command line awk
are intermediate in complexity.  Simple things like searching a file or
printing a column are better for `grep` or `cut` respectively.  Generating a
histogram or using one file to map/translate another are possible in awk, but
before developing that solution ask yourself if python isn't a better choice so
you can perform additional analyses on the results.  If your awk spreads over
more than 2 lines, start writing python!

Said another way, if you are thinking "I just want to do x", awk is probably
suitable.  If you are thinking "awk could probably do this", you are right
but spending an hour learning awk will have fewer benefits than learning
about a new library or feature in a modern scripting language to do the same
task.

Some general hints for when to use awk:
 - Your input file is well structured and you want to perform basic arithmetic
   operations.  Think of doing a simple operation in a spreadsheet program.
 - Your file is large.  Similar to sed, awk works line-wise and can be faster
   than loading an editor or spreadsheet program.

Finally, don't be afraid to split a task into multiple steps in a pipe.  Say
you need to perform text substitution and do arithmetic.  awk can do both
operations, but substitutions in sed are easier to read and write.

## awk Script Basics
awk scripts have three main parts, `BEGIN`, the main loop, and `END`.  Let's
take the following python script to sum the values in the first column and
translate it to awk:
```
# BEGIN
total = 0
# main loop
for line in open(INPUT):
    total += int(line.split()[0])
# END
print(total)
```
Each part is optional, but here we will use all three.
```
# total.awk
BEGIN {total = 0}
{total += $1}
END {print total}
```
Note that lines starting with `#` are comments.
You would then invoke the above script from the command line
```
awk -f total.awk INFILE
```

The above can be written directly on the console like so
```
awk 'BEGIN {total = 0} {total += $1} END {print total}' INFILE
```
Note the script is wrapped in single quotes to prevent shell expansions.

Some observations you should be making:
 - awk is a scripting language with variables and functions.
 - awk doesn't have declared types.  In actuality we don't have to initialize
   variables to use them.  Uninitialized variables have the string type ""
   and numeric type 0.
 - The main loop is run for each line of input.
 - awk appears to split each line and provide the tokens in $n, where the first
   token is $1.
 - awk implicitly casts numeric text to numbers

### EXERCISE
The `human.chrom.sizes` file has the name and size of all chromosomes in the
human genome, with the size listed in the second column.  Using awk, find the
total size of the human genome.

## Nomenclature and Variables
In awk, text is broken into records which are further broken into fields.  By
default, records are separated by newlines and fields are separated by one or
more tabs or spaces, `/[ \t]+/`.  The record and field separators can be
modified as described later.

Variables are separated into user-defined, built-ins and fields.  A variable
can contain letters, digits and underscores but cannot start with a number,
`/[a-zA-Z_][0-9a-zA-Z_]*/`.  As mentioned above, variables don't need to
be declared or initialized and have default values of "" or 0 depending on
their type context.

Variables can be set with the command line option `-v`, e.g.
```
awk -v target=10 '{print target}'
```
which is useful for passing bash arguments into an awk script.  Note these
variables are initialized during the main loop and aren't set or available in a
BEGIN block.

Built-in variables are all upper case.  The ones we will use are:
 - `FILENAME`  The current filename
 - `NR`        The number of the current record
 - `FNR`       The number of the current record, for the current file
 - `NF`        The number fields in the current record
 - `FS`        The input field separator
 - `RS`        The input record separator
 - `OFS`       The output field separator
 - `ORS`       The output record separator

The `FS` and `RS` variables are actually regular expressions used for splitting
a file by records and fields.  It is good practice to set this in the `BEGIN`
block, though command line options can also be used to set their values.
It is common to set `FS` to parse comma-separated files or restrict splitting
to tabs only.  `RS` is less frequently utilized, but can be very helpful for
parsing multiline content.  For example, setting `RS=">"` for the
`sample.fasta` would make each record contain a sequence alignment.

The final class of variables are fields which are stored in numeric indices
accessed with `$`.  The variable `$0` contains the entire line.  Changing
other field variables will cause `$0` to be rebuilt with the current `OFS`.
Calling `print` with no arguments will default to printing `$0`.  A variable
can be used as input to the field reference operator, e.g. `$i` where `i` is
a numeric variable.

### EXERCISE
Work through the following commands to see how `OFS` is utilized with `$0`.
```
head human.chrom.sizes
# space between strings is used for concatenation
head human.chrom.sizes | awk 'BEGIN{OFS=","} {print $1 $2}'
# using a comma specifies separate arguments to print OFS
head human.chrom.sizes | awk 'BEGIN{OFS=","} {print $1, $2}'
# printing entire line
head human.chrom.sizes | awk 'BEGIN{OFS=","} {print}'
# rebuilding $0 by setting $1
head human.chrom.sizes | awk 'BEGIN{OFS=","} {$1=$1; print}'
# set ORS
head human.chrom.sizes | awk 'BEGIN{OFS=","; ORS="<>"} {$1=$1; print}'
# C-l to clear screen
```

Note that setting `FS` leaves `OFS` unmodified.  The default `OFS` is a single
space, which is not super useful...

## Operators
We have used a few operators, but here is an extensive list
 - `+ - * / % ^`          Add, subtract, multiply, divide, modulus, exponent
 - `= += -= *= /= %= ^=`  Assignment with addition, subtraction, etc
 - `? :`                  Ternary conditional statement
 - `|| && !`              Logical or, and, not
 - `~ !~`                 Test regex match and negate match
 - `< <= > >= != ==`      Relational operators
 - `<SPACE>`              String concatenation
 - `++ --`                Increment and decrement, postfix or prefix

### EXERCISE
The file `word_counts.txt` contains a space-separated table of frequencies of
words within the British National Corpus, with the following columns:
 - Sort order
 - Number of appearances
 - Word
 - Part of speech
Parts of speech are encoded as:
 - conj                 conjunction
 - adv                  adverb
 - v                    verb
 - det                  determiner
 - pron                 pronoun
 - a                    adjective
 - n                    noun
 - prep                 preposition
 - interjection
 - modal
 - infinitive-marker
Find the mean and standard deviation of the counts.  HINTS: the variable `NR`
is set to the total number of records in the END block.  The standard deviation
is `sqrt((sum_squares - sums^2 / NR) / (NR - 1)`.  Useful for a running tally
of data...

## Patterns and Actions
When I said awk scripts have 3 main parts, that was a simplification.
awk scripts are a sequence of pattern-matching rules and associated actions.
```
[pattern] { action }
```
If a pattern is not present, the action is performed for every line.  If
a pattern has no action, the default is `print $0`.  This means you can use
awk like grep.  Printing every line containing `cat` would be performed like
```
awk '/cat/' words.txt
```

Patterns may be:
 - `BEGIN` and `END` special patterns executed at the beginning and end of the
   program.
 - `/regex/` perform action when the regex matches.  Can negate like `!/regex/`
 - Boolean expression.  Examples are testing specific fields for equality or
   pattern matching (using `~` and `!~`).
 - A range, similar to sed without using line numbers.

All patterns are evaluated for each record unless the command `next` is
encountered, which causes execution to resume with the next record.

### EXERCISE
Recalculate the size of the human genome considering only the autosomes.
For reference, this command provides the total for all contigs
```
awk '{total += $2} END{print total}' human.chrom.sizes
```
and autosomes match `chr` followed by one or two digits.  Try a regex as the
pattern to match the full line and a boolean expression with `~`.

### EXERCISE
Recalculate the mean and standard deviation of `word_counts.txt` considering
only words that appear fewer than 1000 times.  Repeat with more than 1000
occurrences.  The following command calculates the mean and standard deviation
for all entries
```
awk 'BEGIN{OFS="\t"}
{total += $2; sqr += $2**2}
END {print "mean", total/NR;
print "std", sqrt((sqr - total**2 / NR) / (NR-1))}' word_counts.txt
```

## Conditionals and loops
As you may expect from a scripting language, awk has support for if, else, for,
while, and do.  The syntax for conditionals is
```
if (condition) {
statement1;
statement2}
else if (condition)
statement3
else
statement4
```
Notice that conditions are surrounded with parentheses, multiple statements
can be contained in braces, and the `else if` and `else` blocks are optional.

In addition to the relation operators, the operator `in` can be used to test
if an element is an index of an array, more below.

Loops syntax should also be unsurprising.  Here are 3 ways to print 1 through
3:
```
i = 1
while(i < 4){
print i
i++}

i = 1
do{
print i
i++}while( i < 3)

for(i = 1; i < 4; i++)
print i
```
You can also loop over the indices of an array with:
```
for (index in array)
```

Frequently, you need to loop over every field in a record.
```
for (i = 1; i < NF; i++)
# do something with $i
```

We aren't spending much time on these constructs because they are common
in many programming languages.  awk also has `break` and `continue`. Remember,
complicated awk scripts are likely better written in another language!

### EXERCISE
Find *the* most frequent word in `word_counts.txt` using an if statement.
You may not have initialized the count variable for this because the default
value is 0.  *Considering* this behavior, try to find the least frequent word.

## Arrays
Arrays in awk are associative, meaning the index can be a number or a string.
Array values are set like
```
array[index] = value
```
Some notes:
 - If the index is uninitialized, it will be interpreted as a string context,
   not numeric.
 - You can set the value to a constant and then use `if(index in array)` to
   treat the array like a set.

To get a feeling for how arrays work in awk, here is a script to count the
number of occurrences of each word in `metamorphosis.txt`
```
awk '{for(i=1; i<NF; i++) counts[$i]++}
END{for(i in counts) print counts[i], i}' metamorphosis.txt | sort -nr -k1 | less
```

### BONUS EXERCISE
Find the mean and standard deviation of each word count separated by part of
speech.

## Pipes and redirects
I hope it is clear that awk is not the answer to all your scripting needs.
While it can do a lot, it lacks a large standard library and unit testing
capabilities to make it a robust solution.  I hope you can find uses where
needing the sum or max of a column provide some quick feedback on results
until you can get to an interactive statistical framework.  Almost everything
in awk you can do in another language.  However, if I had to present one
killer feature for awk, this is it, the ability to pipe and redirect print
output.

A word of warning.  Be sure you have some sort of test to check you are
creating a reasonable number of files.  A typo could fill up your directory
with thousands of files and make the system administrators very angry.  As
such, I will provide examples for us to explore.  When developing your own
scripts, check the filenames you are creating by printing them first.

The syntax is simple enough
```
print > "test.out"
print | "sort -n"
```
The first line redirects print output to the file `test.out` and the second
pipes the output through sort with a numeric key.  What makes this so useful
is that any expression can be used for the filename.  If you need to perform
multiple pipes or a pipe and a redirect, combine them all in the command
as a string.

Consider the following script before running and checking the output:
```
awk '{print | "sort -n -k1 | head > " $4 ".out"}' word_counts.txt
```

Notice that the string used in the pipe contains a redirection and uses
string concatenation to build the filenames with the contents of the fourth
column, the part of speech.  This creates 11 files with the most common words
for each part of speech.

One more example, this time with the chromosome sizes:
```
awk '$1 ~ /^chr[[:digit:]]{1,2}$/{print > "autosomes.out" ; next}
{print > "others.out"}' human.chrom.sizes
```

It is also worth mentioning the commands `split` to split files based on size
or number of lines, and `csplit` to split files based on regular expressions.
However, neither would work properly for the presented examples.

## More functions
awk has several built in functions for mathematical operations and string
manipulations.  You can get user input, call system functions, and make 
interactive programs.  You can also write your own functions.  `printf` is
useful for structured output and follows similar conventions to shell or c
printf.

### BONUS EXERCISE
Repeat the word counting of `metamorphosis.txt` but remove leading and trailing
punctuation and cast everything to lowercase.  Search how to perform string
substitution in awk.

## Closing
I hope you have an appreciation for the utility of regular expressions to
specify what you are looking for in text.  As you've seen, they are common
language constructs in sed and awk and replace complex string subset and
testing functions that would otherwise be required.  Now that you have an
idea of the kinds of problems sed and awk can solve and their strengths, I
hope you know enough to find solutions when you need them.  The more you
practice, the less time you spend needing to look up common patterns.

Finally, I hope the exercises have given you practice with tmux!
