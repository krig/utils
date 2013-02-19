/*
If there is no license information in the file, assume the following license:

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2013 Kristoffer Grönlund <code@koru.se>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
*/
#include <time.h>

/*  parses only YYYY-MM-DDTHH:MM:SSZ */
time_t parseiso8601utc(const char *date) {
	struct tm tt = {0};
	double seconds;
	if (sscanf(date, "%04d-%02d-%02dT%02d:%02d:%lfZ",
	           &tt.tm_year, &tt.tm_mon, &tt.tm_mday,
	           &tt.tm_hour, &tt.tm_min, &seconds) != 6)
		return -1;
	tt.tm_sec   = (int) seconds;
	tt.tm_mon  -= 1;
	tt.tm_year -= 1900;
	tt.tm_isdst =-1;
	return mktime(&tt) - timezone;
}

