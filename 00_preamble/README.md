# Preamble

A good starting point for getting to a cluster is the 
[removing tedium workshop](https://github.com/PrincetonUniversity/removing_tedium).
Specifically, look into:
 - [Suppressing Duo](https://github.com/PrincetonUniversity/removing_tedium/tree/master/01_suppressing_duo)
 - [Passwordless Login](https://github.com/PrincetonUniversity/removing_tedium/tree/master/02_passwordless_logins)
 - [Navigating Command Lines](https://github.com/PrincetonUniversity/removing_tedium/tree/master/04_navigating_command_line)

The recommendations in this workshop are what works best for the author and
may not be optimal for everyone.  Back up any rc files before you modify them.

## What we will gain
When I first started using the command line to write software, it felt like
working in honey.  Everything took so much mental effort, I couldn't see all
my files with an explorer and copy-paste editing was slower than an IDE.  I
could navigate the file system and open an editor, but then would have to
close the editor to see the file I was operating on.  Clearly, this wasn't the
way to get work done!

I will share some of my favorite methods to smooth the seams of working on the
command line.  In some ways, command line navigation will begin to feel like
a game.  You learn new moves/chords/combos to perform actions with more
precision.  You can upgrade your workflow to get more done with less effort.
My favorite example is vim.  After a few days of *really* learning vim,
I started to view files as a game board instead of a stream of text.  Editing
is then just jumping and operating around the board until it looks how you want.

Since you can't memorize 3 hours of tips in 3 hours, I hope you will come away
remembering the following:
 - Excellence and continual improvement are goals in themselves.  The
   tangible benefits of some tips are nearly non-existent.  If you have
   intrinsic joy in learning them you will be driven to improve without
   clear evidence it will pay off.  Shaving seconds here and there will
   add up eventually, but not always and not immediately!
 - There is always a better way to do something.  If you become complacent in
   how you currently work, you won't want to spend time learning how to work
   better.  If something feels slow or awkward, rest assured you can do it better!
 - Work to make new moves second nature.  Once you decide to research how to
   improve your workflow, you have to use positive reinforcement to start using
   your new knowledge and negative reinforcement to stop using the old method.
 - Spend minutes to save seconds.  Overall, what I'm recommending is to stop
   doing tangible work for a few minutes to look up how to do something a new
   way.  Then mentally work on using this new tool until it's second nature.
   At the end of the day, using the new movement may save seconds, but if you
   are lucky you will use it several times a day for the next few decades.

Let's solidify these with an example.  Say you wanted to change to your
`projects` directory.  So you type:
```
cd proejcts
```
A typo!  For any moderately fast touch typist, it is faster to delete the
misspelled word and start again.  So how do you delete the word behind your
cursor?  Hold down backspace?  Hit backspace half-a-dozen times?  Both feel
slow, so you decide to improve this part of your work.  You search
'bash delete word behind cursor' and see that `Ctrl + w`
is the chord to press.  You have spent the minutes to learn something new.

After lunch, you are back at the command line and make another typo.  How can
you make sure you use `Ctrl + w` instead of reaching for backspace?  You have
to change how backspace works to make it slower than stopping, remembering
`Ctrl + w`, and hitting that instead.  I would recommend you increase your
keyboard repeat delay and decrease the repeat rate.  Then when you hold down
backspace, it will delete one character and sit there for a few seconds
deleting a character at a time.  At this point, you should notice what's
happening and stop to recall `Ctrl + w`.  Since this will also slow down using
arrows to navigate, delete to delete forward, and `hjkl` to navigate in vim,
here are some shortcuts to start practicing!
 - `Ctrl + a` and `Ctrl + e`: move to start/end of line
 - `Alt + b` and `Alt + f`: move back/forward a word
 - `Ctrl + w` and `Alt + d`: delete back/forward a word
 - `Ctrl + u` and `Ctrl + k`: delete entire line behind/ahead of cursor.
   I like to just hit `Ctrl + ku` to delete everything regardless of cursor
   position.

Give yourself a few weeks to learn these movements before changing your repeat
rates back to normal.  If you are trying to stop using a commend or other
chord, consider setting an alias or remap to perform a no-op.

## Customization
A great thing about the unix shell is that if you don't like something you
can change it.  Say you don't like `Ctrl + w` because it closes web browser
tabs and you are already used to `Ctrl + Bksp` in programs like word.  You can
change that.  However, the more custom you make your shell, the less able you
are to work on a stock shell or help someone else.  Unless you have a good
reason, consider learning the defaults.

However, there are plenty of modifications that just change how things look
or add features instead of changing existing features.  Most of these
customizations are in 'rc files' or found in `~/.config` and are generally.
called dotfiles because they are hidden on unix systems with a '.'.  
Place all of your dotfiles into a git repo called 'dotfiles' and keep 
them version controlled.  When you start on a new cluster, simply clone the
repo and install them into the correct spot.  There are plenty of examples
on github to get started, but I recommend the following:

```
# in .bashrc
# use .'s to move up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../'

# truncate promt display, with chevron.  Can add color
PS1='$(printf ''%-11.10s'' "${PWD##*/}")❯❯❯ '
```

```
# in .inputrc
# use partial search history with up and down arrows
"\C-p":history-search-backward
"\C-n":history-search-forward

"\e[A":history-search-backward
"\e[B":history-search-forward
```

We will cover `tmux.conf` separately.  You will have to log out and in to use
changes in `.inputrc`.  The key binds may differ on mac or windows.

## What we will do
The course will use tmux throughout to demonstrate some advanced command-line
usage.  Once you are comfortable with tmux, you are ready to work on the
exercises!
