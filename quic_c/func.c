#include <stdio.h>

void
output_array(char *name, unsigned char *p, int len)
{
	unsigned char *line = p;
	int i, thisline, offset = 0;

	printf("uint8_t %s[] = \n{\n", name);

	while (offset < len)
	{
		thisline = len - offset;

		if (thisline > 16)
		  thisline = 16;

		printf("\t");
		for (i = 0; i < thisline; i++)
		{
			printf("0x%02x", (unsigned int)(line[i]));
			if ((thisline == 16) || (i < (thisline-1)))
			  printf(", ");
		}

		printf("\n");
		offset += thisline;
		line += thisline;
	}
	printf("};\n\n");
}

/* produce a hex dump */
void
hexdump(unsigned char *p, int len)
{
	unsigned char *line = p;
	int i, thisline, offset = 0;

	while (offset < len)
	{
		printf("%04x ", (unsigned int)offset);
		thisline = len - offset;
		if (thisline > 16)
		  thisline = 16;

		for (i = 0; i < thisline; i++)
		  printf("%02x ", (unsigned int)(line[i]));

		for (; i < 16; i++)
		  printf("   ");

		for (i = 0; i < thisline; i++)
		  printf("%c", ((int)(line[i]) >= 0x20 && (int)(line[i]) < 0x7f) ? line[i] : '.');

		printf("\n");
		offset += thisline;
		line += thisline;
	}
}
