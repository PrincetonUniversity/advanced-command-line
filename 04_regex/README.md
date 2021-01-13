# Regular Expressions

Regular expressions are powerful, ubiquitous and daunting when first
encountered.  They are general text matching patterns that can be as specific
as you like.  Reading regular expressions (or regexes) is similar to learning
to read.  You probably started with words like 'cat', 'bat', 'hat'.  Now you
can read words like 'ubiquitous'!  When you find a regex that looks like
nonsense, take the same approach as reading a complex word the first time.
Break it apart, sound it out (try it out) a part at a time, and see what the
pieces do when reassembled.

We can think of regular expressions in several ways.  First, as a function
mapping all combinations of characters into two sets, matching and
non-matching.  The universe of all character combinations is infinite and
generally you will want to start with a function that captures too much input
and restrict what matches to remove false positives.  With capturing, regexes
can also parse values from strings.

A more useful method to construct regexes is to think of them like describing
your match to a computer.  Regexes are terse ways to say something akin to "a
ZIP code is a series of 5 numbers with an optional dash and 4 more digits
(ZIP+4), does this address have a valid zip code?"  A simple regex matching
this is 
```
\b\d{5}(-\d{4})?\b
```
Which will match "Princeton, NJ 08540" but not "My number is 867-5309".  It
will also match "12345 Fake St.", which we know is not a zip code by context.
The problem is we haven't told the regex to consider this context, we are only
looking for 5 numbers.  We can make this regex more specific, which in turn
will make it longer and more convoluted to read.

Keeping with the idea of describing your match, think about describing what you
want to a child that has no idea what your data will look like.  The more often
you say things like "but not always", "unless", "or" the more complex the regex
will be.  For ZIP codes, we could maybe say the context should be "A ZIP code
will have a state postal code before it, unless it's in text in which case the
phrase 'zip code' should be within 2 words of the match".  The point is complex
specifications require complex regexes.  Unless you are working with a corpus
of literature or scrapping web pages, simple regexes will take you a long ways.
The more you use regexes the more often you can identify cases when they are
useful.

You won't come out of this section a master of regex, but hopefully you will
get enough to be useful and maybe inspiration to learn more.  I am a fan of
"Mastering Regular Expressions" by Jeffrey E.F. Friedl if you have a few weeks
to enjoy reading about regexes!

## Getting Started
Most programming languages have support for regexes but to start we will use
grep to pull out matches.  Everything we learn will be applicable to sed, awk,
perl, python, vim, ...

grep comes in 3 different flavors: grep, egrep and fgrep:
 - grep: the base program, uses basic regexes, `?+{|()` are literals
 - egrep: same as `grep -E`, has extended regexes with `?+{|()`  as
   metacharacters
 - fgrep: same as `grep -F`, uses no metacharacters.  Useful for fast,
   exact matches

I find the most frustrating part of regexes are the flavors.  You can see even
within grep, the set of metacharacters changes and the default grep has very
few metacharacters.  Usually I write a regex, it matches nothing, I start
escaping metacharacters to try to fix it, then change my engine to use a more
expanded set.  I always have to lookup complex metacharacters like
positive-lookahead since they change between languages and I don't use them
often.  Some character classes are supported or named differently between
tools.

We will stick to egrep for our exercises.  Note egrep and fgrep are deprecated
so if you are writing a script, use grep -E/F instead.  On the command line
we can be more casual.  To search for a PATTERN in a FILE, use:
```
egrep 'PATTERN' FILE
```
The single quotes are important to prevent the shell from interpreting
characters as pipes, redirects, etc.

If you want to match multiple patterns, they may be listed with the `-e`
option.
```
egrep -e cat -e dog FILE
```
Will find lines with cat OR dog in them.

## Literals, Metacharacters, and Anchors
Like globs, characters in regexes are either taken literally or have a special
meaning and are called metacharacters.  For now, we will say all alpha-numeric
characters are literal and limit our discussion of metacharacters to anchors.

Literals are used to match a specific series of characters.  Let's look for
'cat' in the words.txt
```
$ egrep cat words.txt | head
adjudicate
adjudicated
adjudicates
adjudicating
adjudication
adjudications
advocate
advocated
advocates
advocating
```
Note that 'cat' can appear anywhere in the line for a match.  It's good
practice to read the regex in a verbose way to mimic how it is evaluated.
Here we ask for the character c, followed by the character a, followed by
the character t.

The first two metacharacters we will discuss are `^` and `$` which represent
the start and end of a line, respectively.  Note these are not text specific
but position specific.

### EXERCISE
Try the following and see if the results are what you expect:
```
egrep '^cat' words.txt | head
egrep '^cat$' words.txt | head
egrep 'cat$' words.txt | head
egrep '^' words.txt | head
egrep '^$' words.txt | head
```
Search for your name or part of your name in the words list.  Try to anchor
and see how the results change.

Note especially the regex `^`.  The phrase 'anchor' is slightly misleading
as we aren't actually anchoring anything with the match.  Instead we are
literally asking for the beginning of the line.  A verbose reading of `^cat`
would be "the beginning of the line, the letter c, the letter a, and the letter
t."  It is a subtle difference but will prevent confusion later.

## Character Classes
Similar to globbing, a set of characters in square brackets represent as set of
acceptable characters for a given position.  If we wanted to get the American
and English spelling of gray/grey, we would use the regex `gr[ae]y`.  Read
verbosely, we have g, followed by r, followed by a OR e, followed by y.

Sets can include ranges, `[a-z]`, and be negated `[^ae]`.  Negation has a
bit of subtly.  It is reasonable to assume it indicates not an a or an e, but
it also implicitly requires there to be *some* character.  If you need a `^` in
a character class, make sure it is not the first character.  `[^a]` means not
an `a`, `[a^]` means an `a` or a `^`

### EXERCISE
Search for any words in `words.txt` that have a `q` not followed by a `u`.
Why is Qatar not returned?  How about Iraq?

Some character classes are common enough to have metacharacters associated with
them:
 - `\s`/`[[:blank:]]`: Whitespace (space, tab, newline, formfeed, etc)
 - `\S`: Not whitespace
 - `\w`/`[[:word:]]`: `[a-zA-Z0-9_]` alpha numerics with `_`
 - `\W`: `[^a-zA-Z0-9_]` non alpha numerics and whitespace
 - `\d`/`[[:digit:]]`: `[0-9]`
 - `\D`: `[^0-9]`
Perl, python, and vim use the `\x` shorthand while the POSIX standard specifies
`[[:class:]]`.  The negated POSIX classes are written like:
```
[^[:digit:]]
```
for a non digit, equivalent to `\D`.

### EXERCISE
Search for any words in words.txt with a digit.  Remember egrep uses POSIX
classes.

Note that character classes can contain multiple ranges.  If you need a `-` in
a character class, place it as the first character in the class.

The last special character class is `.`, *dot*.  This matches any single
character.  The dot is usually not specific enough to do what you want.  This
is because regexes are evaluated *greedily* and in order.  We will come back to
this point after discussing quantifiers in the next session.  If you want to
match a literal `.`, you can use the escape sequence `\.`.

### EXERCISE
Search for words in `words.txt` that contain part of your name again, this
time replacing characters with a `.`.  Note that when the `.` is at the start
or end of the regex, it still has to match *some* character.

A similar concept to character classes are alternation, `|`.  Tokens on either
side of the alternation are taken as valid matches for the regex.
```
egrep 'gr[ae]y' # equivalent to
egrep 'gr(a|e)y'

egrep -e cat -e dog -e hat  # equivalent to
egrep cat|dog|hat
```
Note that unlike character classes, alternation uses entire subexpressions
instead of single characters.  `gr(a|e)y` matches 'gray' or 'grey'  but
`gra|ey` matches 'gra' or 'ey'.  The parentheses define the extent of the
alternation in the first example.

## Quantifiers
Consider searching `words.txt` for words with two `a`'s in a row.
```
egrep 'aa' words.txt
```
Easy enough.  How about 2 vowels in a row?
```
egrep '[aeiou][aeiou]' words.txt
```
Clearly this would be repetitive for say, 5 vowels in a row.  Quantifiers
allow you to specify a range of excepted occurrences of a character.  The
simplest syntax is asking for a specific number of occurrences.
```
egrep '[aeiou]{5}' words.txt
```

### EXERCISE
Search `words.txt` for exactly 4 vowels in a row.  If you match 'queueing',
the regex is too general.  If you don't see 'dequeue' it is too restrictive.

A range is specified like so:
```
egrep 'a{1,3}' words.txt  # match between 1 and 3 a's, inclusive
egrep 'a{0,1}' words.txt  # match 0 or 1 a
```

There are three short-hand notations for ranges that occur frequently:
 - `?` matches `{0,1}` occurrences
 - `*` matches `{0,unlimited}` occurrences
 - `+` matches `{1,unlimited}` occurrences
*Unlimited is not a valid end point.*  Similar to `.`, if you need to match
a literal `?`, `*`, or `+`, escape them first, i.e. `\?`, `\*`, or `\+`.

All quantifiers apply to the character immediately before them.
```
egrep 'bot+' words.txt  # matches Ab<bott>
egrep '(alf)+' words.txt  # matches <alfalf>a
```
Grouping parentheses are extremely common with quantifiers.

Matching with quantifiers is *greedy*.  A regex will try to match as much
as possible before considering the next token.  This has consequences for
matching and efficiency.

### EXERCISE
Search `words.txt` for `z*` and `z+`.  What can you say about the quantifiers
`?` and `*`?

### EXERCISE
Consider the problem of extracting quoted text from `metamorphosis.txt`.  A
good first guess on this regex would be `".*"`, that is literally, a double
quote, any number of characters followed by a double quote.  Here's the
first two results with the matching characters shown below:
```
$ egrep '".*"' metamorphosis.txt | head -n 2
"What's happened to me?" he thought.  It wasn't a dream.  His room,
^        match         ^
"Oh, God", he thought, "what a strenuous career it is that I've
^        match         ^
```
The first line is ok, but the second is matching too much.  This is because
quantifiers are greedy by default.  `.*` will match as much as possible and
only "give up" characters to satisfy the rest of the regex.  I find `.*` is
used frequently but is not specific enough in most cases.
 - Come up with a better regex for this job.  Non-greedy (lazy) quantifiers
   are a regex feature but not in egrep.  You may have to use `--color=always`
   to see what part is matching.
 - What are some remaining issues with the matches?  What feature would you
   need to address this?  Does egrep have it?

Regexes are evaluated sequentially and greedily.  Consider matching `.*i` to
`Mississippians`.  The regex will start by consuming the *entire* string into
`.*`.  It then sequentially removes a letter from `.*` until an i matches:
```
Mississippians  # matched entire string to .*, no i
^            ^
Mississippians  # pop back one character, no i
^           ^
Mississippians  # pop back one character, no i
^          ^
Mississippians  # MATCH i
^         ^
```

## Backreferences and grouping parentheses
Let's try to find all words with a repeated 3 character
sequence, similar to `(alf)+`.  A first guess may be `(...){2}`, which is any
three characters seen two times.  This is effectively `(...)(...)`, and
matches anything with 6 or more characters.

Instead, we want the second appearance of `(...)` to match what is seen the
first time.  So far we have used parentheses to group together characters to
apply a quantifier to, `(alf)+`, and to limit the scope of alternation,
`gr(a|e)y`.  Parentheses have another effect, they capture their content and
can be used again in the regex.  The matches are recalled with `\<N>` where 
`<N>` is `[1-9]` matching the first through ninth set of parentheses.  The
regex we are after is then `(...)\1`, which is any 3 characters followed by
the same 3 characters.

When multiple parentheses are in the regex, they are numbered according to the
appearance of the opening parenthesis.  So `((.)..)\2\1` matches:
```
overseers
  ^     ^
  ...2111
```
`ers` matches to the `...` and `\1` gets `ers` and `\2` gets `e`.

### EXERCISE
Again with `words.txt`
 - Check the difference between `(.){3}\1` and `(.{3})\1`
 - What word has the same four characters repeated in it?
 - Palindromes in general are not regular, but for a given length we can
   still write a regex for them.  Find palindromes of length 3, 4, and 5.
   Palindromes are the same forward and backwords, e.g. 'rotator' is a length
   7 palindrome.

## Topics to look into
We didn't cover a lot, partially because the usage is very tool-specific.
Some useful topics to research on your tool of interest are:
 - Case insensitive matching
 - Word boundaries
 - Non-capturing parentheses

Consider the more challenging problem of matching text in parentheses
while allowing escaped quotes:
```
She said, "Woah, look at \"that\"!"
#         ^         target        ^
"Woah, look at \"that\" thing
# no match
```
Think about the following regex candidates.  Describe them in words and see
how they match the two examples.  If you invoke egrep without a filename it
takes stdin as input.
 - `"(\\.|[^"])*"`
 - `"([^"]|\\.)*"`
 - `"([^\\"]|\\.)*"`
 - `"([^\\"]+|\\.)*"`

The regex `"([^\\"]+|\\.)*"` has a `+` with alternation, nested within a `*`.
You should be extremely careful with such regexes!  Some regex engines need to
evaluate every possible assignment before declaring a string does not match.
Since there is ambiguity in where a character falls (does it belong to `+` or
`*`?) the number of possibilities increases exponentially with the size of the
string!  An efficient and non-exponential version is `"[^\\"]*(\\.[^\\"]*)*"`.

The general form is `opening normal* (special normal*)* closing` where:
 - normal is more common than special, though both are allowed in the sequence
 - the start of special and normal are distinct
 - special must no match nothing
 - special is atomic (does not contain `*` or `+`)
