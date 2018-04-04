#include "str_utils.h"

char *to_upper(char *s) {
	int i = 0;

	while (s[i] != '\0') {
		if (s[i] <= 'z' && s[i] >= 'a') {
			s[i] -= 'a' - 'A';
		}
		i++;
	}

	return s;
}

char *to_lower(char *s) {
	int i = 0;

	while (s[i] != '\0') {
		if (s[i] <= 'Z' && s[i] >= 'A') {
			s[i] += 'a' - 'A';
		}
		i++;
	}

	return s;
}
