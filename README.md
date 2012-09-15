# Team Fortress 2 Funpack

## Development Example

    $ vagrant up
    $ vagrant ssh
    
    -- in guest
    
    $ ./team-fortress-2.funpack/bin/compile ~/build ~/cache
    $ FUNPACK_HOME=~/team-fortress-2.funpack GAME_HOME=~/build PORT=28015 team-fortress-2.funpack/bin/run