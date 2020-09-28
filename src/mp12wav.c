/**
 * mp12wav: Convert mp1 to wav.
 * Copyright (C) 2020 by Mahyar Koshkouei <mk@deltabeard.com>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#include <stdlib.h>
#include <stdio.h>

#include <jo_mp1.h>

#define DR_WAV_IMPLEMENTATION
#include <dr_wav.h>

void *load_file(FILE *f, long *sz)
{
	void *out;

	fseek(f, 0, SEEK_END);
	*sz = ftell(f);
	rewind(f);

	out = malloc(*sz);
	if(out == NULL)
		goto err;

	fread(out, 1, *sz, f);

err:
	return out;
}

int main(int argc, char *argv[])
{
	int hz, channels;
	long outputSize;
	short *output;
	void *input;
	long inputSize;
	FILE *f;
	bool err;

	if(argc != 3)
	{
		fprintf(stderr, "Usage: mp12wav in.mp1 out.wav\n");
		return EXIT_FAILURE;
	}

	f = fopen(argv[1], "rb");
	if(f == NULL)
	{
		fprintf(stderr, "Unable to open input file\n");
		return EXIT_FAILURE;
	}

	input = load_file(f, &inputSize);
	fclose(f);
	if(input == NULL)
	{
		fprintf(stderr, "Unable to load file\n");
		return EXIT_FAILURE;
	}

	err = jo_read_mp1(input, inputSize, &output, &outputSize, &hz, &channels);
	free(input);

	if(err == false)
	{
		fprintf(stderr, "MP1 error %d\n", err);
		return EXIT_FAILURE;
	}

	/* Write WAV file. */
	{
		drwav_data_format format;
		drwav wav;
		format.container = drwav_container_riff;
		format.format = DR_WAVE_FORMAT_PCM;
		format.channels = channels;
		format.sampleRate = hz;
		format.bitsPerSample = 16;
		drwav_init_file_write(&wav, argv[2], &format, NULL);
		drwav_write_raw(&wav, outputSize * sizeof(short), output);
		drwav_uninit(&wav);
	}

	free(output);
	return EXIT_SUCCESS;
}
