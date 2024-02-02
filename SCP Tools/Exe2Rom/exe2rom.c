#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct
{
	void *data;
	size_t size;
} buffer_t;

buffer_t read_all_bytes(const char *name)
{
	buffer_t buffer = {0};
	FILE *fp;
	fopen_s(&fp, name, "rb");
	if (fp)
	{
		fseek(fp, 0, SEEK_END);
		buffer.size = (size_t)ftell(fp);
		rewind(fp);
		buffer.data = malloc(buffer.size);
		if (buffer.data)
		{
			if (fread(buffer.data, sizeof(uint8_t), buffer.size, fp) != buffer.size)
			{
				free(buffer.data);
				buffer.data = NULL;
			}
		}
		fclose(fp);
	}
	return buffer;
}

bool write_all_bytes(const char *name, buffer_t buffer)
{
	bool result = false;
	FILE* fp;
	fopen_s(&fp, name, "wb");

	if (fp)
	{
		if (fwrite(buffer.data, sizeof(uint8_t), buffer.size, fp) == buffer.size)
		{
			result = true;
		}
		fclose(fp);
	}
	return result;
}

typedef struct
{
	uint16_t segment;
	uint16_t offset;
} farptr_t;

uint8_t memory[1048576];

size_t seg_to_linear(farptr_t ptr)
{
	return ((size_t)ptr.segment * 16 + ptr.offset) % 1048576;
}

void read(farptr_t ptr, void *_data, size_t length)
{
	uint8_t *data = (uint8_t *)_data;
	size_t linear = seg_to_linear(ptr);
	while (length)
	{
		linear = linear % 1048576;
		size_t tocopy = min(length, 1048576 - linear);
		memcpy(data, &memory[linear], tocopy);
		length -= tocopy;
		data += tocopy;
		linear += tocopy;
	}
}

void write(farptr_t ptr, const void *_data, size_t length)
{
	const uint8_t *data = (const uint8_t *)_data;
	size_t linear = seg_to_linear(ptr);
	while (length)
	{
		linear = linear % 1048576;
		size_t tocopy = min(length, 1048576 - linear);
		memcpy(&memory[linear], data, tocopy);
		length -= tocopy;
		data += tocopy;
		linear += tocopy;
	}
}

void fill(farptr_t ptr1, farptr_t ptr2)
{
	size_t linear1 = seg_to_linear(ptr1);
	size_t linear2 = seg_to_linear(ptr2);
	size_t minaddr = min(linear1, linear2);
	size_t filllen = max(linear1, linear2) - minaddr;
	memset(&memory[minaddr], 0xFF, filllen);
}

bool dump(size_t address, size_t length, const char *name)
{
	address = address % 1048576;
	if ((address > 1048576) || (length > 1048576 - address))
	{
		// Invalid address or length.
		return false;
	}
	return write_all_bytes(name, (buffer_t){&memory[address], length});
}

#define BIOSEG 0xF000 // BIOS segment.
#define ROMADR 0xFE000 // Linear address of BIOS ROM.
#define ROMLEN 8192 // Length BIOS ROM.

int main(int argc, char **argv)
{
	farptr_t pbios = {BIOSEG, 0}; // Start of BIOS segment, F000:0000
	farptr_t pboot = {0xFFFF, 0}; // Start of boot segment, FFFF:0000
	farptr_t pvect = {0}; // Start of VECTOR segment

	if (argc < 3)
	{
		printf("exe2rom <input> <output>\n");
		return 1;
	}
	void *exedat = read_all_bytes(argv[1]).data;
	if (!exedat)
	{
		fprintf(stderr, "Failed to read input executable.\n");
		return 2;
	}

	// Get location of code in .EXE.
	uint16_t codpos = ((uint16_t *)exedat)[4] * 16;
	// Get size of code in .EXE.
	size_t lastpglen = (size_t)((uint16_t *)exedat)[1];
	size_t numpages = (size_t)((uint16_t *)exedat)[2];
	if (lastpglen)
	{
		numpages--;
	}
	size_t codlen = numpages * 512 + lastpglen - codpos;
	if (codlen > 1048576 - seg_to_linear(pbios))
	{
		free(exedat);
		fprintf(stderr, ".EXE too big for BIOS image.\n");
		return 3;
	}
	// Copy code to BIOS segment.
	write(pbios, (uint8_t *)exedat + codpos, codlen);
	// Get relocation table as WORD array.
	uint16_t *reloctbl = (uint16_t *)((uint8_t *)exedat + ((uint16_t *)exedat)[0xC]);
	// Get number of relocations.
	size_t relocs = (size_t)((uint16_t *)exedat)[3];
	// Apply relocations.
	for (size_t i = 0; i < relocs; i++)
	{
		uint16_t segment;
		farptr_t addr = {reloctbl[i * 2 + 1] + BIOSEG, reloctbl[i * 2]}; // Relocation address
		read(addr, &segment, sizeof(segment));
		segment += BIOSEG;
		write(addr, &segment, sizeof(segment));
		pvect = addr;
	}
	free(exedat);
	// Get address of the VECTOR segment.
	if (pvect.offset -= 3)
	{
		fprintf(stderr, "Failed to find VECTOR segment - not BIOS ROM?\n");
		return 4;
	}
	// Move VECTOR segment to end of memory.
	uint8_t vector[16];
	read(pvect, vector, sizeof(vector));
	write(pboot, vector, sizeof(vector));
	fill(pvect, pboot); // Fill memory between end of code and boot segment
	// Dump BIOS ROM to file.
	if (!dump(ROMADR, ROMLEN, argv[2]))
	{
		fprintf(stderr, "Failed to write output image.\n");
		return 5;
	}
	return 0;
}
