# Team Fortress 2 Funpack

## How it works

`bin/compile` runs at publish time and gets the latest version of sourcemod.

`bin/bootstrap` runs once for multiple game runs and downloads the latest version of Steam/TF2.

`bin/run` configures the app with runtime params and starts it.

## Development Example

    $ vagrant up
    $ vagrant ssh
    
    -- in guest
    
    $ cd /vagrant
    $ rake start
