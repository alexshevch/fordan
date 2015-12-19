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

I really like to use something like

    nodemon index.coffee -t a83e1150-a227-419a-8113-03b8de85e597 -s ip-10-0-0-149.ec2.internal

so on file change the program will restart.

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
    |  +-------+X+-------+Unit ^ector       |
    |     |     X     |                     |
    |     |       X   |                     |
    |     +--------+X++  240° ~= 4.18879rad |
    |                 X                     |
    |                   X                   |
    |                     X                 |
    |                                       |
    +---------------------------------------+
