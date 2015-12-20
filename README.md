    __               _             
    / _| ___  _ __ __| | __ _ _ __  
    | |_ / _ \| '__/ _` |/ _` | '_ \
    |  _| (_) | | | (_| | (_| | | | |
    |_|  \___/|_|  \__,_|\__,_|_| |_|


# Development

Running in the root directory

`./rsync`

Should sync from local to remote

# running in Development

Nodemon will watch for changes and restart.

    nodemon index.coffee -t a83e1150-a227-419a-8113-03b8de85e597 -s ip-10-0-0-149.ec2.internal

# Remote running

Now that syncing is working?
SSH into the remote machine and run `npm install`
This is necessary so that compiled libraries work.
Running like this also works

    coffee . -t a83e1150-a227-419a-8113-03b8de85e597 -s ip-10-0-0-149.ec2.internal

# Map layout

        +---------------------+
        |                     |
        |                     |
        |                     |
        |                     |
        |                     |
        |                     |
        |                     |
        |                     |
    y:0 +---------------------+
        x:0

# How radians are given

    Map
    +---------------------------------------+
    |                 X                     |
    |                X 30° ~= 0.523599rad   |
    |               X                       |
    |     +-------+X+-+                     |
    |     |       X   |  Tank               |
    |     |      X    |                     |
    |  +-------+X+-------+Unit Vector       |
    |     |     X     |                     |
    |     |       X   |                     |
    |     +--------+X++  240° ~= 4.18879rad |
    |                 X                     |
    |                   X                   |
    |                     X                 |
    |                                       |
    +---------------------------------------+

    * unit vector doesn't change if the tank were rotated in this image (hard to draw)

# function conventions

- Function arguments that need to know enemy tanks and friendly tanks will have enemies first
