# Miscellaneous Commands
This section contains miscellaneous commands that I use frequently which aren't
large enough to be stand alone topics.

The setup script in this section downloads 6 files we will work with in the
following sections.
 - metamorphosis.txt: The Metamorphosis by Franz Kafka from project gutenberg
 - words.txt: The list of words commonly found on unix systems for use with
   spell check programs.
 - word\_counts.txt: alphabetically sorted list of words with their
   frequencies.
 - sample.fasta: A sample file with amino acid sequences
 - human.chrom.sizes: A table of hg19 contigs and their associated sizes

The last three files are common formats in bioinformatics and are examples of
structured text.

From the base directory,
```
./scripts/setup.sh 02_misc/
```
will setup a tmux session with each exercise as a separate window.  `setup.sh`
also accepts a second argument with the viewer to load each exercise with
instead of the default `less`.  `"vim -c 'set ft=markdown'"` uses vim with
proper syntax highlighting for markdown.

As we venture further into sed, grep, and awk you will find you can do very
complex processing from the command line.  Always be mindful that your bash
history is ethereal.  The awk command from last month may no longer exist and
with tmux sessions the command history becomes more convoluted.  If 1) your
command is longer than 80 characters OR 2) will be run more than twice you
should wrap it in a shell script and keep it under version control with the
relevant project.  A fellow lab member or future you will be thankful you did!

## bc
The basic calculator has its own programming language and allows for arbitrary
precision in calculations.  Its syntax is similar to C and has builtin
functions for sqrt, e (exponential), l (natural log) and trig functions.

I only use it as an interactive calculator.

### EXERCISE
Try the following
```
bc
sqrt(4)
1+2
1/2
C-d  # to exit bc
```

The default precision, called scale, is 0, which is why `1/2 == 0`.  The
following alias makes `bc` more useful.
```
# in ~/.bashrc
alias calc="bc -lq"
```

I choose calc because I can never remember `bc` and I'm used to searching my
local computer for a calculator by typing `calc`.  The `-l` option sets the
scale to 20 and loads trig functions.  `-q` removes information at startup.

### EXERCISE
Add this alias to your `~/.bashrc`
```
alias calc="bc -lq"
```
Re-source with `. ~/.bashrc` and then run
```
calc  # or bc -lq if you don't want the alias
s(0)  # sin
c(0)  # cos
1/2
C-d
```
If you don't like the alias, change or remove it from your bashrc.

## cut, paste, column
If you frequently work with large, tabular data you have probably had to
extract a few columns to examine a subset of the output.  To demonstrate,
we will look at the `sample.vcf` file.  This file describes genetic mutations
in individuals and consists of a header, which starts with `#` and tabular
data.  Run the following to look at the file contents with the headers removed.
We will cover sed in more detail later, for now just copy the command.
```
sed '/^##/d' sample.vcf
```
Because some cell contents are larger than others, the layout is hard to read.
A useful command to align columns is `column`.  With no arguments, `column`
interprets the contents as entries to make into columns, effectively placing
everything on one line matching the width of the terminal.  `column -t`,
however, nicely spaces the contents assuming blank space delimits columns.
```
sed '/^##/d' sample.vcf | column -t
# may need to press `C-b z` to make pane full window
```
Because column needs to read the entire file to determine column widths,
be sure to only run it on small files (<100 lines) or the head of a larger
file. Use the `-s` option to specify a character set to split on.

Now that we can see the file, let's extract column 3 (ID) with cut.
```
sed '/^##/d' sample.vcf | cut -f3 | column -t
```
Note that `column` is the last command as it needs to format the extracted
text.  Switching the order prints all columns as `column` uses spaces to align
columns and `cut` expects tabs.

You can specify the delimiter with the `-d` option, by default it is tab.
To work with a csv, you would use `cut -d,`.

The fields to extract are specified with the `-f` option.  The argument can
be a range or list of ranges separated by `,`.  Ranges can be
 - `N`      N'th field, counted from 1
 - `N-`     from N'th field, to end of line
 - `N-M`    from N'th to M'th (included) field
 - `-M`     from first to M'th (included) field
For example, `-f1-3,5,9-` would print columns 1 to 3, 5 and 9 to the end.

### EXERCISE
Print the columns CHROM, POS, REF, ALT from the vcf file using cut.
Try to change the order to CHROM, REF, ALT, POS.

You should have noticed that the order of printing from cut is determined by
the file, not the listing of the fields.  We have to do some more work to
reorder columns.

`paste` is the inverse of `cut` and is used to combine different files into
one table.  Again the delimiter is tab unless set with the `-d` option.
Let's look at paste in action using the list of words in `words.txt`

### EXERCISE
Execute the following
```
head -n 5 words.txt > 5words.txt
head -n 7 words.txt | paste 5words.txt -
head -n 7 words.txt | paste - 5words.txt
head -n 7 words.txt | paste 5words.txt
head -n 9 words.txt | paste - - -
```
Remove `5words.txt` when you are done.

## Process Substitutions
You should be familiar with piping to chain commands together and using `-` as
a placeholder for stdin/stdout.  However, `-` is a convention and may not be
supported in a specific program.  It also doesn't help if you need to chain
together multiple commands for input.  Consider the problem of printing from
`sample.vcf` the columns in order of CHROM, REF, ALT, POS.  We want to run
something like `cut -f1,4,5,2` but have seen that doesn't work.

We also just learned about paste, which can combine two or more files together
so how do we pipe two cut commands into a paste command?  You could use
named pipes, but bash has a nice shortcut called process substitution.
When you place a process in `<(CMD)` it acts as a file containing the stdout
of `CMD`.  Similarly, `>(CMD)` can be used for piping output to a command, like
`>(sort | uniq -c > out.txt)`.

So to print our vcf, we can use
```
paste <(sed '/^##/d' sample.vcf | cut -f1,4,5) \
<(sed '/^##/d' sample.vcf | cut -f2) \
| column -t
```
Note that the contents of the process substitution can contain pipes or
additional process substitutions.  Line continuations `\` are used to space
the command for this readme.

The advantage of process substitutions is that you can prevent using temporary
files in a command.  The substitution is done by the operating system so
even if `-` isn't implemented in a program you can still use `<()` and `>()`
to pipe input or output.  The disadvantages have to do with repeated
computation.  Clearly we are repeating our `sed '/^##/d` command above.
As with pipes, the named pipes produced by process substitution can't be used
for seeking/searching in a file which is required for some programs.

I mostly use process substitution for performing preprocessing or with
`diff` and `cmp` where I don't want the intermediate files.  It's also helpful
working with zipped files that you don't want to decompress.  We will cover
`diff` and `cmp` below.

## fc and C-x C-e
As I mentioned in the introduction, if your command line operations get too
complex they should probably be wrapped in a script and version controlled.
If you ignore that, or are using long, absolute paths as filenames, your
commands can stretch over many lines and get difficult to modify.

### EXERCISE
The commands we are about to learn use the environment variable EDITOR to
launch your editor of choice.  Let's make sure that's set how you like:
```
echo $EDITOR
```
If you are comfortable with that, carry on.  Otherwise open your `~/.bashrc`
and add the following line:
```
export EDITOR=<FULL PATH>
```
where `<FULL PATH>` is the full path to the editor you want to use.  You will
have to use `. ~/.bashrc` to re source the dotfile in a shell that already
exists.

Let's keep working with the following command
```
paste <(sed '/^##/d' sample.vcf | cut -f1,4,5) \
<(sed '/^##/d' sample.vcf | cut -f2) \
| column -t
```
Paste that into your shell and execute it so it is in your history for
the current tmux pane.

To recall the last command and modify it in your terminal editor, run the
command `fc` for fix command.  When you save and close the temporary file
the command is automatically executed.  If you have vim open and don't know
what to do, hit escape then type `:q!<ENTER>`.  You may have to re source
your bashrc to update the EDITOR variable.

There are also times when you are in the middle of writing a command and decide
it is time to move to an editor.  Recall the last command with `C-p` or the
up arrow, then type `C-xC-e` to open your editor with the current command.
Again, save and close to run the command.

`fc` and the `C-xC-e` chord are nice ways to use your full editor power on a
command you don't to keep around.

## cmp, diff and comm
The commands `cmp`, `diff` and `comm` all compare two files to find
differences.  During development, I will frequently have a 'ground truth'
file that I want to ensure is still produced when I modify some source code.
This is called an acceptance test and is a good practice to make sure code
runs as expected on non-trivial data.

To check if two files match, simply use `cmp FILE1 FILE2`.  `cmp` will check
that the bytes in each file match and will print an error on the first
mismatch.
```
cmp words.txt word_counts.txt
cmp words.txt words.txt
```
`cmp` is useful as a conditional in an `if` statement in a bash script or
to quickly confirm two files match.  When files mismatch it simply tells
you the line number and exits.  From here you can use `less` and `tmux` to
investigate the problem or use one of the other commands to get more
information.

`diff` lists all differences between two files in a somewhat cryptic output.
Fasta files contain header lines that start with a `>` and then a protein or
nucleic acid sequence beneath.  Run the following
```
diff sample.fasta <(sed '/^>/d' sample.fasta)
```
We are using process substitution to strip out headers in the second 'file'.
The first two lines of diff output are
```
1d0
< >crab_anapl ALPHA CRYSTALLIN B CHAIN (ALPHA(B)-CRYSTALLIN).
```
The `1d0` means that line 1 of the left input and 0 of the right input were
affected.  `d` is the specific operation, a deletion in this case.
The next line shows what the change is.  Lines starting with `<` signify the
first file while a `>` signifies the second.  Here we only have a line for the
first file because the line is missing in the second.

`diff` has a few issues for use in debugging.  Usually you only care about the
first difference as that's what you need to correct to get the test to pass.
However, `diff` will generate the entire diff before printing anything, even
if you pipe through head.  Say you have a difference on line 3 between two
GB-sized files; diff will find all differences before reporting the difference
on line 3.  I would recommend running cmp first to get an idea of where the
files differ and then pipe your inputs through head to get just the first
part of the differences.
```
# this only considers first 5 lines
diff <(head -n 5 sample.fasta) <(sed '/^>/d' sample.fasta | head -n 5)
# this diffs the entire file and outputs head
diff sample.fasta <(sed '/^>/d' sample.fasta) | head
```

`comm` compares two *sorted* files line-by-line.  The default output is
3 columns consisting of lines unique in file1, lines in file2, and lines
in both files.  If you have sorted outputs anyways, `comm` is great to
see which file has what lines.  You can also use process substitution to
sort input files.  Used in the context of comparing files, you will almost
always want to use the option `-3` to suppress the common output column.

### EXERCISE
Run the following commands to understand the output of `comm`.  We will cover
sed in a later section, so just copy the commands for now.  They delete the
third line and change 'ment' to 'mont'
```
comm <(head words.txt) <(head words.txt | sed '3d ; s/ment/mont/')
comm -3 <(head words.txt) <(head words.txt | sed '3d ; s/ment/mont/')
```

## watch and entr
After you have used tmux for a while, you may notice yourself working on a
file, saving your change, going to another pane to press `C-p ENTER` to run
something.  Or maybe you are repeatedly checking a job on the slurm queue.
Any time you are simply repeating the last command, you could use `watch` or
`entr` to do it automatically!

`watch` is a standard command that is present on RC clusters.  It allows you
to invoke a command every `n` seconds.

### EXERCISE 
Try these sample `watch` commands.  Exit `watch` with `C-c`.
```
watch -n 5 date  # run date every 5 seconds
watch -n 10 squeue -u $USER  # poll squeue every 10 seconds
watch -n 5 'ls -lth *'
```

While `squeue` has a `-i` option to repeatedly print the output, `watch` also
clears the screen.  If you need to use glob expansions, wrap the command
in single quotes.

`entr` is not standard but much more powerful.  Instead of repeatedly
executing a command, `entr` waits for one or more files to change before
performing the command. For example
```
find -name '*.py' | entr -c bash -c 'sleep 1 && pytest'
```
runs pytest any time a `.py` file is changed in the current directory
structure.
```
ls command.sh | entr -c bash -c 'sleep 1 && ./command.sh'
```
runs the `command.sh` script whenever it changes. Combined with tmux, you can
simulate a lot of IDE capabilities with command line editors.

You can install entr as a user on the RC clusters.  To learn more, visit
the [entr homepage](http://eradman.com/entrproject/).  You will have to change
the prefix to your local bin directory.  We will not cover this here.
