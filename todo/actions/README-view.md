# `view` addon for [todotxt-cli]

Show todo items containing `TERM`, grouped by `[OPTION]`, and displayed in priority order. If no `TERM` provided, displays entire _todo.txt_.

## Quick Install
```
git submodule add https://github.com/todotxt/plugin-view.git $TODOTXT_DIR/actions/view
```

## Usage
```
$ todo.sh view help

  Usage
    $ todo.sh view [OPTION] [TERM]

  Options
    project           Show todo items group by project
    context           Show todo items group by context
    date              Show todo items group by date
    nodate            Show todo items group by date without date
    past              Show todo items group by date from today to past
    future            Show todo items group by date from today to future
    today             Show todo items group by date only today
    yesterday         Show todo items group by date from today to yesterday
    tomorrow          Show todo items group by date from today to tomorrow
    ?length           Show todo items group by date from today to ?length
                      ? could be signed(+-) or unsigned numbers.
                      Length could be (days|weeks|months|years)

  Examples
    $ todo.sh view project              # Show todo items grouped by project
    $ todo.sh view project @context     # Show todo items grouped by project and filtered by @context
    $ todo.sh view context              # Show todo items grouped by context
    $ todo.sh view date +project        # Show todo items grouped by date and filtered by +project
    $ todo.sh view -3days               # Show todo items grouped by date from today to 3days before today
    $ todo.sh view 4weeks               # Show todo items grouped by date from today to 4weeks after today
```

## Known Issues

- On OSX/macOS, the `date` command does not match the Linux `date` command. To fix this, install `coreutils` view brew
```
brew install coreutils
```

## Team
 - [Mark Wu](http://blog.markplace.net) - Original Author
 - [Ali Karbassi](https://karbassi.com) - todotxt maintainer
 - Inspired by and based on Paul Mansfield's [projectview](http://github.com/the1ts/todo.txt-plugins/)

## License
GPL3


[todotxt-cli]: https://github.com/todotxt/todotxt-cli
