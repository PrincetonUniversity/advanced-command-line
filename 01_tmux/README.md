# tmux
tmux is a terminal multiplexer, allowing you to run other terminals inside of
it.  Through sessions, tmux helps you keep processes running while logged out
of a cluster, as long as the server is running.  You can do a lot with tmux,
but we will focus on it's use as a session manager for remote servers and as a
window manager.

## Installation
tmux is installed on most Princeton RC clusters.  If it is not installed on
your cluster or you need a newer version, tmux is also hosted on conda-forge.
```
conda install -c conda-forge tmux
```
There are some breaking changes in syntax between versions, so be careful
with `.tmux.conf` when moving between servers.

## Sessions
When you connect to a remote server, your shell is running on one process on
the server.  If you open another terminal and connect again, you will have two
shells running on separate processes.  tmux sessions allow you to open multiple
"connections" to the server without having to ssh again.  When you are done
with a session, you can kill it or detach.  As long as the server doesn't shut
down, detached sessions persist, can be reattached, and continue running
processes.  You can keep separate sessions for projects or just use them to
pick up your work between logging off or when your vpn client disconnects.

Give tmux a shot by starting a new session and detaching.
```
tmux  # this starts a new session
```
Once the session starts, it should look the same as your normal login shell.
Run a command to test it out:
```
echo "Hello tmux"
```
Hit `Ctrl + b` then `?` (will be notated as `C-b ?` in the future) to see all
the commands available.  `prefix` means the prefix key, `C-b` by default,
though `C-a` is a common binding to mimic `screen`.  You can search for a word
by pressing `/` and typing the word.  Search for `detach`.  You should see
something like:
```
C-b d       detach-client
# or
prefix  d   detach-client
```
In either case, type `C-b d` to detach from this session.  You will be back
in your starting shell.

To reattach to a session, type `tmux a`.  This reattaches to the most recent
session.  You should see `Hello tmux` from the last echo.

To terminate a session, type `C-d` to signal end of file.  This is a shell
convention, not tmux specific and is used to exit a connection.  If you now
type `tmux a`, you should get an error that there are no sessions to connect
to.

*This is my usage with sessions.  I keep one session and run `tmux a` when I
first log in.  Projects are separated by windows (explained below).*  

There are several more uses of sessions:
```bash
tmux new -s <NAME>           # start a session with a specific name
tmux new -- <COMMAND>        # start a session with a command, killed on exit
tmux a -t <NAME>             # attach to a session by name
tmux ls                      # list active sessions
tmux kill-session -t <NAME>  # kill session by name
```
If you prefer to keep projects in separate sessions, it makes sense to name
them to simplify attachment.

### EXERCISE
Take a moment to practice starting, detaching, killing and reattaching
sessions.  If you need a long running command, you can use `slow_process.sh` in
this directory.

Try the following series of commands in another terminal window.

```bash
tmux new -s manualPrint
./slow_process.sh
# C-b d
tmux new -s autoPrint -- ./slow_process.sh
# C-b d
tmux ls
tmux  # will start a new session
# C-b d
tmux a -t manualPrint
# C-c to stop print, C-d to kill session
tmux ls
tmux kill-session -t 2  # the unnamed session
tmux ls
tmux a -t autoPrint
# C-c to stop print, will exit
tmux a  # will error
```

## Windows
Each tmux session can contain one or more windows, which contain one or more
panes.  Each pane has an independent shell process.  If you use vim, a vim
window is equivalent to a tmux pane and a vim tab is equivalent to a tmux
window.  You are probably familiar with a web browser supporting multiple tabs
in the same window.  Here is a mapping of terminology:
 - tmux session -> Browser window 
 - tmux window -> Browser tab
 - tmux pane -> Not typical

For brevity, when I say window I am referring to a tmux window.

Let's try working with a few windows:
```bash
tmux  # new session
echo Window 0
# C-b c  # create a new window
echo Window 1
# C-b c  # create another window
echo Window 2
```
You have now made 3 separate windows in one tmux session.  If you detach and
reattach, the windows (and panes) are all preserved.  Also note that the
windows are numbered, starting at 0.  To switch between windows, try some
of the following chords:
 - `C-b 0` change to window 0
 - `C-b '` prompt for window index to switch to.  Useful to get to window 10
 - `C-b n` change to 'next window' by number (e.g. go to 1 from 0)
 - `C-b p` change to 'previous window'

 Depending on your usage, this may be fine.  If you are working on a small
 screen, you may prefer to have a project per session and multiple windows to
 move between.  The default mapping is good for this usage as your hands stay
 on the home keys.  Personally, I have a window per project and rarely switch
 between them.  As such, I have the following lines in my `~/.tmux.conf`:
```
# Shift arrow to switch windows
bind -n S-Left  previous-window
bind -n S-Right next-window
```
This maps shift and the left and right arrow keys to cycle through the windows.

### EXERCISE
Create a `~/.tmux.conf` file and add the above lines to it.  Changes to the
tmux conf file will register when the server is restarted (e.g. all sessions
are killed and a new session is created).  To have the changes take immediate
effect, in a tmux session, type:
```
C-b :  # this brings up the tmux command prompt
source-file ~/.tmux.conf  # this runs the source-file command and supplies the filename
```

You can also add the following to your `~/.tmux.conf` to make re-sourcing faster:
```
# Reload tmux config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded..."
```

Practice moving around with `C-b n/p` and `S-Left/Right`.  If you don't like
the shift bindings, delete those lines from your `.tmux.conf` and re-source
the config file.

### EXERCISE
You may have noticed the name of the window changes when a new process is running.
I find this distracting and not very informative.  Add the following to your
`.tmux.conf` and re-source:
```
# Automatically set window title
set-window-option -g allow-rename off
set-option -g set-titles on
bind , command-prompt "rename-window '%%'"
bind c command-prompt -p "window name:" "new-window; rename-window '%%'"

# prevent updates to shell from changing window titles
setw -g monitor-activity off
```
Now when you create a new window, you will be prompted for the name, which
will persist.  If you want to rename a window, you can use `C-b ,`.  Create
some new windows with names and rename some existing windows.

## Panes
Panes allow you to split a window into multiple shells and view them
simultaneously.  Maybe you need to view an input file while editing a script to
process it or you want to check resource usage with `htop` while running some
code.  I tend to split my screen to have an editor open on one half and use the
other for running code and navigating the file system.

### EXERCISE
Let's practice some panes, in a tmux window:
```
echo Starting pane
C-b %  # split the pane left/right (I would say vertically)
echo Second pane
C-b "  # split the pane top bottom
echo pane the third
```
To work with panes, the defaults are:
```
C-b <ARROW>         # move in the direction of the arrow
C-b q               # display pane numbers, press a number to move to that pane
C-b { and C-b }     # swap panes
C-b z               # zoom in on pane (make full window)
C-b x               # kill active pane
C-d                 # end of file, exit pane
```

I can't use these defaults and prefer something closer to vim.  The relevant
lines in my .tmux.conf are:
```
# Change window splits to match vim
bind v split-window -h
bind s split-window -v

# Vim style pane selection
bind h select-pane -L
bind j select-pane -D 
bind k select-pane -U
bind l select-pane -R

# Use Alt-vim keys without prefix key to switch panes
bind -n M-h select-pane -L
bind -n M-j select-pane -D 
bind -n M-k select-pane -U
bind -n M-l select-pane -R

# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n M-h if-shell "$is_vim" "send-keys M-h"  "select-pane -L"
bind -n M-j if-shell "$is_vim" "send-keys M-j"  "select-pane -D"
bind -n M-k if-shell "$is_vim" "send-keys M-k"  "select-pane -U"
bind -n M-l if-shell "$is_vim" "send-keys M-l"  "select-pane -R"
```
The `vim-tmux-navigator` plugin provides seamless navigation between vim
windows and tmux panes.  The installation instructions provide some reasonable
key bindings for navigating in vim windows.

If you use vim, try it out.  If you don't modify the key bindings above to
suit your needs and practice navigating between panes.

## Scrolling, copying, pasting
Since we haven't run any commands that print a lot of output, you may not have
encountered a very common use case.

### EXERCISE
 - Create a window with a left-right split pane.
 - In one pane, open your favorite editor.
 - In the other, run `ps -aux` to get all running processes

`ps` will spit out all of the processes running on the head node and since
we didn't pipe the outputs, it will scroll over multiple screens.  Your tmux
terminal doesn't have a scroll bar, so how do we see the input?  If you want
to copy and paste multiple lines from the ps output, you will notice the
selection covers both panes, also not what you want!

To scroll and copy/paste, we will use copy mode.  The default navigation keys
are similar to emacs/bash, but if you prefer vim-like navigation, add the
following to your .tmux.conf and re-source:
```
setw -g mode-keys vi
set -g status-keys vi
```

To enter copy mode, press `C-b [`.  This will make the currently selected pane
behave like a file and allow you to navigate and copy its content.  Use the
arrow keys (or hjkl in vim mode) to move around and  `C-r` (or `/` or `?` in
vim mode) to search for a string.  Word-wise movements are also supported as
are `C-u/d` to make larger jumps through the buffer.  Hitting `q` will exit
copy mode.

To start selecting text, press `Space`.  This anchors the current cursor
position and allows you to move the cursor to specify the other end point.
Unlike using a mouse, the selection is kept within a pane.  To confirm the
selection and copy the selected text, press `C-w` (or `Enter`).
 - Search for a process with your user name and copy a few lines around it
   into the default buffer.

tmux keeps 50 buffers that can be specified or named.  I usually just use one
buffer, similar to the system clipboard.  To paste the contents of the default
buffer at the current cursor location, press `C-b ]`.  Paste the contents of
the buffer into your editor (you have to enter insert mode in vim).

You can remap the keys to perform select, copy and paste, but the syntax
changed in version tmux 2.3.  Note the tmux buffer and your system clipboard
(where `C-c` goes) are distinct.  You can have tmux interact with the
system clipboard, the vim registers `*` and `+`, or use the mouse for
selection.  Search for specifics if you are interested.

## Conclusions
This section covers a lot of tmux usage.  Don't try to use everything at once!
Start with one session to keep things running when you log out of a cluster.
Make a window, split a pane, get frustrated when you try to scroll and look
up how to enter copy mode again.  Remember that `C-b ?` will show all the key
bindings.  There are entire books on tmux and much more advanced usage.  If you
want to learn more, consider looking into:
 - Scripting specific window/pane layouts with certain commands
 - Personalizing the status bar
 - Sharing tmux sessions across clients

The remaining sessions will use tmux to set up exercises.  Look at the scripts
for examples of how to set up tmux sessions programmatically.
