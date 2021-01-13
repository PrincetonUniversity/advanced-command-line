# sed
sed (and we will see later, awk) are specialized derivatives of the line editor
ed.  You will probably never use ed, but there is overlap in the command syntax
between the three programs and vim.  The `s` in sed is for stream.  Unlike
ed which operates on a file, sed works with streams, taking stdin, performing
an operation and printing to stdout.  You should be familiar with redirection,
but it is worth mentioning: if you want to modify the file, `file.txt` the
operation
```
sed [script] file.txt > file.txt  # NO
```
Will make an empty file as output and erase the contents of `file.txt`!  Be
sure to use a second output file and copy over the original when you are
happy with the edits.  The script can also be provided as a separate file
using the `-f` option, which is useful for repeating several commands and
keeping a record in a VCS.

The setup script in this module uses the same files as `02_misc`.

## When to use sed
sed is very expressive and can perform operations similar to awk, grep, or an
interactive file editor.  Generally, you should use sed over other options if
 - Your file is large.  Loading a multi-GB file into an interactive editor can
   take a long time.  If you just need to perform some replacements on the file
   sed is much more efficient because it works line-wise.
 - You can do the operation in the middle of a stream.  Even if the file is
   small, working on a pipe is better than making unnecessary, intermediate
   files.
 - You need to replace or extract some part of the text.  If you need to
   perform an arithmetic operation, awk is a better choice.  If you need more
   complex control flow, use a modern scripting lanugage.

## Substitutions
If you have used sed before, it probably was with the `s` command to perform
substitution.  The syntax is `s/TARGET/REPLACEMENT/FLAGS`.  Let's look at the
first 15 lines of metamorphosis.txt and perform a few substitutions.

### EXERCISE
Try the following sed commands.
```
head -n 15 metamorphosis.txt
head -n 15 metamorphosis.txt | sed 's/Kafka/Ferdinand/'
head -n 15 metamorphosis.txt | sed 's/Kafka/Wyllie/ ; s/Wyllie/Willy'
head -n 15 metamorphosis.txt | sed 's/it/Metamorphosis/'
head -n 15 metamorphosis.txt | sed -n 's/it/Metamorphosis/p'
head -n 15 metamorphosis.txt | sed -n 's/it/Metamorphosis/gp'
head -n 15 metamorphosis.txt | sed -n 's/\<it\>/Metamorphosis/gp'
head -n 15 metamorphosis.txt | sed -E 's/([A-Z])/+\1+/g'
head -n 15 metamorphosis.txt | sed -i 's/gutenberg/Gutenburg/'
```

You should have noticed:
 - Commands are wrapped in single quotes to prevent shell substitutions.
 - By default, sed will print every line and substitute the first occurrence
   of TARGET with REPLACEMENT.
 - Multiple scripts/commands can be separated by a `;` in the argument. An
   equivalent syntax is `sed -e 'CMD1' -e 'CMD2'`.  The commands are performed
   in order and can modify previous substitutions.
 - TARGET is a regex and can match anywhere in a word.
 - The sed option, `-n` suppresses automatic printing.  To print a command, use
   the command flag, `p`.  `p` is also a command by itself we will cover later.
 - The command flag `g` performs the substitution on every occurrence of
   TARGET in the line.
 - The TARGET is a regex and can contain word boundaries, ranges, quantifiers,
   etc.  With the sed option `-E` it behaves similar to egrep.
 - The REPLACEMENT has a limited set of metacharacters.  `+*.` and more can be
   used without escaping.  Back reference is supported and therefore `\` must
   be escaped if you want a literal `\`.
 - The sed option `-i` makes the matching case-insensitive.

You can also invoke sed on the entire file like so:
```
sed 's/Kafka/KAFKA/' metamorphosis.txt
```
Multiple file arguments are processed as if concatentated.

### EXERCISE
The `human.chrom.sizes` contains several contigs besides the sex chromosomes
(X, Y) and the autosomes (chr1-22).  Using sed, print only the 22 autosomes
and 2 sex chromosomes and remove the leading `chr` from each entry.

## Ranges
By default, sed will apply the expression to every line in the input file.
The affected lines can be limited by supplying a range.  The syntax is
```
start,end[command]
```
where start and end can be regular expressions, line numbers or the
metacharacter `$` for the last line.  A range is negated by adding `!` before
the command, e.g. `start,end!command`.

You can perform multiple commands in a range by grouping them with `{}`.
```
/target/{ command1 ; command2 ; command3 }
```
If you wrap your command in a single quote you can use line continuation in
bash to make the command easier to write and read.  Don't forget about `fc`
and `C-xC-e`.

### EXERCISE
Keeping with the substitute and print commands, let's work with the
`sample.fasta` file.  Fasta files contain header lines that start with a `>`
and then a protein or nucleic acid sequence below.
 - Print only the headers.
 - Print only the headers and mark the start and end of the line with `^` and
   `$`.
 - Print only the headers, trim any whitespace, and mark the start and end of
   the line with `^` and `$`.
 - Print the entry for `crab_human`.  You may have to pipe the output through
   head.
 - Remove the last `.` from the header lines
 - Replace all occurrences of `ST` with `*st*`, but only in the header lines.
 - For each non-header line, highlight palindromes of length 5 with a `*` to
   either side.

As you try to do more complex operations, here are some tips:
 - Look over your input carefully.  Use grep, cut, and uniq to get
   representative tokens to operate over.
 - You can start with a small sample input file (frequently head) to get
   started.
 - Work iteratively to build complexity.
 - You don't have to do it all with sed in one line!  It may take several
   pipes and other commands to get the job done.  If it seems too complex,
   consider making a wrapper script so you have a record of what was done.

## More commands
### Substitute
We have seen substitute extensively but there are a few more details worth
mentioning.

The separator in the command can be any character except newline.  This is not
the case for the range argument.  If you were searching for a filename, for
example, a suitable command would be `s|/usr/bin/|~/.local/bin|`, where `|`
is used instead of `/` to separate the command from the target and replacement.
If you need a `/` you can also escape it in the target or replacement.  Common
separators are `|` and `!`.

We have already seen back references using `\1`, but you can also use `&` to
get the text of the entire target.  For the palindrome problem above, you
could use a command like `s/(.)(.).\2\1/*&*/g`.

The flag `g` substitutes each occurrence of target on the line.  You can also
specify a number to replace the i'th occurrence of a target.  To replace the
third tab in a tsv with a comma, you would use `s/\t/,/3`.

### Transform
Transform, `y`,  performs character-wise replacements of a set of characters.
This is similar to the `tr` command with fewer features.  A sample command is
```
sed 'y/abc/xyz/' file
```
This maps any occurrence of a to x, b to y, and c to z.

### Print
We have used print as a flag for substitute to print just lines with matches.
You can use print as a standalone flag to perform some common tasks similar to
`grep` or `head`.
```
sed -n '1,10p'   # print first 10 lines of file
sed -n '5p'      # print 5th line
sed -n '/cat/p'  # print lines with 'cat', like grep
```
Note that if the `-n` option is omitted, the desired lines will be printed
twice and all lines will be printed.

Another use-case of print is to repeatedly check the contents of the line
buffer during development of a complex command.  Taking the whitespace
trimming exercise from above, you could run:
```
sed -nE '/^>/{
p
s/[[:space:]]+//
p
s/^/^/
p
s/$/$/
p}' sample.fasta
```
To see the contents of the line before each substitution.  This is helpful
when troubleshooting, but if you develop complex commands iteratively it's not
necessary.

Most often you will see `p` used before a next command, which overwrites the
replacement buffer as we will see below.

A related command to print is `=`, which reports the current line number.  In
large files this can be helpful to determine where a match occurs.  To get
the line number and content of each header in `sample.fasta`:
```
sed -n '/^>/{=;p}' sample.fasta
```

### EXERCISE
`metamorphosis.txt` contains three sections, `I`, `II`, and `III` signified
by a line containing those numerals followed by some space.  Write a sed
command to print the line numbers of each section.  Also look into `grep -n`.

### Next
The next command reads the next line of the file into the line buffer.  It
comes in two variants, `n` and `N`.  `n` overwrites the contents of the line
buffer while `N` appends the next line with a newline between.

### EXERCISE
Run the following sed commands on `sample.fasta` to explore the behavior of
`n` and `N`.
```
sed -n '/^>/{p;n;p}' sample.fasta
sed -n '/^>/{N;p}' sample.fasta
sed -n '/^>/{s/A/@/g;N;p}' sample.fasta
sed -n '/^>/{N;s/A/@/g;p}' sample.fasta
```

As you can see, `N` can be helpful with multiline substitutions and can perform
matches across lines.  Generally, perl-style regexes are more useful for
multiline regex operations.

### Delete
The delete command clears the line buffer.  Any commands after delete are not
run as execution resumes on the next line in the file.  To remove all header
lines in `sample.fasta`
```
sed '/^>/d' sample.fasta
sed '/^>/{d;p;s/>/#/}' sample.fasta
```
The commands are identical.  For the second, once the delete command is
performed, neither print nor substitute are executed.

A common command is `sed '/^$/d'` to delete blank lines in a file.

### EXERCISE
 - Create an outline of `02_misc/README.md` by printing only lines that start
   with `#` and substituting `#` with a tab or two spaces.
 - Try to delete all block code sections in this README.  Remember ranges can
   accept regular expressions.
 - Combine the two commands to get a clean outline

### Quit
The quit command, `q`, exits sed when it is encountered.  In
`metamorphosis.txt`, the preamble ends with `*** START OF...`.  To print
just the preamble, you can run:
```
sed '/^\*\*\* START/q' metamorphosis.txt
sed '/^\*\*\* START/Q' metamorphosis.txt
```
The `q` variant prints the contents of the line buffer before quiting, `Q`
exits immediately.

You can also use quit to improve efficiency of a sed command by exiting
once a match is no longer possible.

### Advanced commands
sed also has the ability to store lines and perform branching execution,
similar to if statements.  If your programming logic requires these features,
chances are you could also benefit from other features present in a more
advanced scripting language.
