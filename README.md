SquidGolem - A SquidGuard replacement

SquidGolem is a drop-in replacement for squidGuard,
as long as you're inclined in rewriting its configuration
into a more modern way: using a SQL backend.

The core of ACL processing and checking is lent to the
RDBMS, with the usage of Views and Stored Procedures.

Benchmarks will tell whether caching is necessary inside
squidGolem itself.

Currently the code is incomplete, it doesn't work, and
it needs to be completed. It has been started during a
trip from Bari to Rome, thus it has got only 5 hours of
work. Then, because of time constraints, the server on
which it had to be installed is currently running ufdbGuard,
but there's the opportunity that work on squidGolem
will continue. Take it as a proof of concept, fork it
and complete it. I'd be more than happy to use Golem
instead of UFDB, but time is a precious resource :-).

It wants to implement:

  * The squid redirector interface
  * Sources definition, basing on IP addresses and/or User
  * Destination definition, currently only domain-based
  * ACLs, that link together Sources, Destinations and
    the current time.

It will implement:

  * A nifty web interface to manage its settings.

SquidGolem is written in Ruby by <vjt@openssl.it>, and
uses EventMachine for its event-based IO Loop.
