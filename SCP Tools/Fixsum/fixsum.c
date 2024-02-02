#include <stdio.h>
#include <stdlib.h>
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
	FILE* fp;
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

int main(int argc, char **argv)
{
	if (argc < 3)
	{
		printf("fixsum <input> <output>\n");
		return 1;
	}
	buffer_t buffer = read_all_bytes(argv[1]);
	if (!buffer.data)
	{
		fprintf(stderr, "Failed to read input file.\n");
		return 2;
	}

	uint8_t sumbyte = 0;
	for (size_t i = 0; i < buffer.size - 1; i++)
	{
		sumbyte += ((uint8_t *)buffer.data)[i];
	}
	sumbyte = 0 - sumbyte;
	((uint8_t *)buffer.data)[buffer.size - 1] = sumbyte;

	if (!write_all_bytes(argv[2], buffer))
	{
		free(buffer.data);
		fprintf(stderr, "Failed to write output file.\n");
		return 3;
	}

	free(buffer.data);
	return 0;
}
