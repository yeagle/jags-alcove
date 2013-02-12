SUBDIRS = functions

jagsmod_LTLIBRARIES = alcove.la

wiener_la_SOURCES = alcove.cc

wiener_la_CPPFLAGS = -I$(includedir)/JAGS

wiener_la_LIBADD = functions/alcovefunc.la \
									 -ljags

wiener_la_LDFLAGS = -module -avoid-version
if WINDOWS
wiener_la_LDFLAGS += -no-undefined
endif
