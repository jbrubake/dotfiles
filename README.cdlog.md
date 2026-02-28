## What is this?

`cdlog` is a small amount of GNU Bash code that provides a better
interactive experience for directory changes than
Bash's built-in directory stack mechanism (commands `pushd`, `popd`
and `dirs`, plus `~-` expansion).

## How to use

Install the file `cdlog.sh` somewhere, and source it from your
`.bashrc` script.

When `cdlog` is loaded, a number of commands become available:

* `cd` is an alias which calls the function `cdlog.chdir`.
Every time you change directory, it pushes the previous directory
into a history log which is stored in the `cdlog_hist` array. The log maintains
nine entries. The ninth entry is erased. The entries are copied into
the variables `c1` through `c9`.  The first four entries are also
copied into the variables `x`, `y`, `z` and `w` for shorter access.
If the argument of `cd` is a number from 1 to 9, it changes to the
specified `cdlog` history element.

* `cs` (cd swap) is an alias for a command which exchanges
the current directory with a selected `cslog` entry selected
by a numeric argument, which defaults to 1. The current directory
overwrites that entry in the log, and then the shell changes to the directory
which was previously in that entry. If `cs` is given two or more
arguments, it rotates among those. The directory is changed to the
`cdlog` item indicated by the first argument. That item is overwritten
by the second item, the second by the third and so on. The last item
receives the previously current directory.

* `pd` (pop dir) is an alias for a command which changes to (by default) the
most recent directory in the log, and removes that entry from the log. The second most
recent directory becomes most recent and so on. If it is given an argument
value in the range 1 to 9, it changes to the specified entry, and removes it,
moving the others down to close the gap. Thus `pd 1` is equivalent to `pd`.
`pd` takes a `-f` option which means "force". This is useful when it's
not possible to change to the indicated directory, in which case `-f`
causes it to be removed in spite of this.

* `cdlog` function shows a listing of the four most recent entries in the
log, or all nine if given the `-l` argument. The `cl` command is an alias for
for `cdlog` with no arguments and `cll` for `cdlog -l`.

* The `mcd` and `mcs` are menu-selection-based analogs of `cd` and `cs`.
They print the contents of the history (first nine entries), and you can
pick which directory to change to or swap with. The terminal cursor is then
retraced back to the top of the menu, and the screen is erased from
that point to the bottom.

* The `cdr` command is used for switching to and managing previous sessions.
Though the `r` stands for "recovery", it may actually be used at any time and
may be usefully used multiple times.  When `cdlog` starts, it initially
allocates a new session.  The `cdr` recovery command presents you with a
numbered menu of previous sessions. Entering an empty input line exits the
menu.  You can recover to one of the sessions by entering its number.  The menu
accepts additional notations for useful actions.  Use a `c` prefix on the
numeric selection to clone the session into the current session.  Deleting
unwanted sessions is possible with a `d` prefix; the specified entry is deleted
and you remain in the recovery menu.  There is an `n` command which will make
current again that new new session that `cdlog` had allocated on startup. That
new session does not appear in the numbered list of recoverable sessions unless
it has been already persisted by the execution of a directory-changing command.

* The `cdalias` command is used for defining or listing "cd aliases"; see below.

* The `cdunalias` command removes a cd alias.

* The `c` command provides an API into `cdlog`'s name resolution.
It takes one argument. If it successfully resolves the argument to a path,
that path it is printed, and the termination status is successful. Otherwise
nothing is printed and the termination status is failed. If the argument is a
digit in the range 1 to 9, then it resolves to the specified element in the
`cdlog` history, if it is nonblank.  If the argument begins with `@`, then it
resolves as a search; see Searches below. Otherwise, it is tried as a
`cdlog` alias; see Aliases below.

In addition, the `cdlog.sh` script sets the Bash `direxpand` option.
With the `direxpand` option, Tab completion on a directory coming
from a variable name will expand that variable into the command line.

The directory changing commands do nothing if you attempt to change into the
same directory you are already in. There is no effect on the history.

## Aliases

`cdlog` provides its own "cd alias" feature. If the argument to
`cd` contains no slashes, then it is used as a key to look up an
alias, which replaces it. The replacement is not considered to
be an alias even if it looks like one. Aliases are defined using
the `cdalias` command. It takes two arguments.

Implementation notes: aliases are stored in the `cdlog_alias`
array.  The `cdlog.chdir` function recognizes an alias only if
it is invoked as `cdlog.chdir -p <alias>`, which is the way
`cd` invokes it.

If the replacement (second argument) of `cdalias` is a digit
from 1 to 9, then it refers to that entry in the `cdlog`.
The path at that index will be retrieved and used as the alias value.

If the replacement begins with `@` then it is a search. If
the search succeeds, then the result will be used as the alias
value.

When `cdalias` is invoked with no arguments, it lists all the
currently defined aliases.

When `cdalias` is invoked with one argument, and that argument
names an alias, it lists that alias. Otherwise it fails
with an error message.

The deprecated `cdaliases` command also lists aliases; it
will disappear in a future version of `cdlog`.

## Searches

A search is an arguments which begins with `@`. The rest
of the argument is interpreted as a pattern which is applied
against the history to find the most recent matching path.

In commands which accept a numeric argument denoting a reference
to the `cdlog` history by position, the `@` prefix may be omitted
from the search pattern. For instance `cs foo` will
swap the current directory with the most recent history entry
whose path contains a match for `foo`, and `cs @foo` will do
exactly the same thing.

To include a leading `@` as part of the search pattern, write `@@`:
the first `@` is recognized as the prefix, and removed; the
second `@` remains as part of the pattern.

## Persistence

Whenever the history changes, the current directory and the
contents of the history are written to the file `~/.cslog.N.dirs`,
one path per line, where `N` is an internal session number.
(This location for the session file is only a default; see the
section Alternative Session Directory below which describes the
`cdlog_sess_dir` variable.)

When `cdlog` initializes, it allocates a session by finding a free
value `N` in the range 1 to 10. If it cannot find one due to the
session store being full, it erases the one with the oldest time
stamp and chooses its index.

When one or more persisted session are present, `cdlog`'s initialization
mentions this, suggesting that the `cdr` command may be used to recover
to one of the sessions. See also the Auto Recovery section below.

## LRU Mode

When the configuration variable `cdlog_lru` is set to the value `y`, LRU mode
is enabled in the `cdlog.chdir` function, affecting the `cd` and `mcd`
commands. LRU mode modifies the history algorithm in the following way.

If the directory change successfully takes place to a directory which
already exists in the history, then the most recent (topmost) occurrence
of that directory is removed from the history before the previous
directory is pushed into the history. Thus, in effect, a rotation is
taking place: the existing entry in the history becomes the current
directory, and is removed; the entries above it shift down to take
its place, and the previous current directory becomes the top of
the history.

LRU mode is disabled when the `cdlog_lru` variable is empty,
which is its initial value.

LRU mode keeps duplicate directories out of the history and while
promoting recently used directories toward the top.

## Alternative Session Directory

By default, `cdlog` keeps the session recovery files in your home
directory. They have numbered names like `.cdlog.1.dirs`.
The variable `cdlog_sess_dir` may be assigned a directory path
to specify an alternative directory. This path should omit the
trailing slash. If the variable is empty, it denotes the
root directory. If the directory doesn't exist, `cdlog` will try
to create it. The main use for this configuration is to support
the situation when a home directory is shared among multiple
host machines with different environments. You can interpolate the
value of `$HOSTNAME` into `cdlog_sess_dir` to have sessions specific
to a host.

## Auto Recovery

When the `cdlog_autorecover` variable is set to `y`, `cdlog` will
automatically recover the session without the need for using the
`cdr` command. This only happens when these two conditions hold:

1. Bash is either a login shell, or the `SHLVL` variable is `1`.

2. There is only one saved session.

This feature exists because it is extremely common to use `cdr`
upon logging in and to choose the only available session, by
selecting `1`. However, automatic recovery may navigate away from
the home directory, which may surprise the user who has not logged
into that host in a long time. Thus it is not default behavior.

When `cdlog_autorecover` is empty, which is the initial value,
the feature is disabled.

## Completion

`cdlog` provides its own Tab completion for the `cd` command, overriding
the built-in completion. It includes the cd aliases, while completing
on directories, taking into account `CDPATH`.

## How is this better?

* It's not hard-coded C code inside the shell; it consists of a small amount of
code whose behavior that can be customized by the end-user.

* Uses simple variables, which are better supported for completion
and require fewer keystrokes.

* The `dirs` command for accessing the directory stack in Bash is too
clumsy and won't be discussed here any more.

* Bash's shorthand notation for accessing the nth element, namely `~-n`, takes
more keystrokes than `cdlog`'s aliases for the first four elements, `$x`
through `$w`.

* Bash's shorthand notation requires an explicit slash to be typed
in order for completion to work. `~-n` followed by tab is not sufficient.
You must type a slash and then Tab. Whereas completing on the variable `$x`
just requires Tab. One tab will automatically add the slash and then additional
tabs engage further completion.

* Bash's `direxpand` option does not work for `~-n` notation. Completion
works, but the notation remains unexpanded.

* Bash's `~-n` notation does not expand inside double quotes, whereas
variables do.

* `cdlog` has intuitive, simpler commands. The actions of pushing entries into
the log, and rotating among them aren't conflated into a single command.
The rotating command `cs` is usefully different from `pushd [+/-]n`,
taking only positive integer arguments with no sign, and rotating among
specified places, rather than a contiguous block of top entries.

* The persistence feature recovers the directories from a previous session.

## License

This is under distributed under a modified two-clause BSD license.
See the license block at the bottom of the `cdlog.sh` file.
