# lastlog

A tiny hack to the old unix tool lastlog, to make the output nicer.

New stuff:

    lastlog -q

Prints all the last logins of any user. Doesn't print a header, and
doesn't print the users who have never logged in.

New format:

Either prints a line of the general format:

    Last login for user bill: 2011-07-05 02:18:08 from example.com (:0).

Or, in the case of a user that hasn't logged in:

    nobody never logged in before.

That's it.

