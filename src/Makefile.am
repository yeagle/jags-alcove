SUBDIRS = functions

jagsmod_LTLIBRARIES = alcove.la

alcove_la_SOURCES = alcove.cc

alcove_la_CPPFLAGS = -I$(includedir)/JAGS

alcove_la_LIBADD = functions/alcovefunc.la \
									 -ljags

alcove_la_LDFLAGS = -module -avoid-version
if WINDOWS
alcove_la_LDFLAGS += -no-undefined
endif
