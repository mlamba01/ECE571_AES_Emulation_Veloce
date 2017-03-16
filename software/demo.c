/*  
*   Byte-oriented AES-256 implementation.
*   All lookup tables replaced with 'on the fly' calculations. 
*
*   Copyright (c) 2007 Ilya O. Levin, http://www.literatecode.com
*
*   Permission to use, copy, modify, and distribute this software for any
*   purpose with or without fee is hereby granted, provided that the above
*   copyright notice and this permission notice appear in all copies.
*
*   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
*   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
*   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
*   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
*   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
*   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
*   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "aes256.h"

#define DUMP(s, i, buf, sz)  {printf(s);                   \
                              for (i = 0; i < (sz);i++)    \
                                  printf("%02x ", buf[i]); \
                              printf("\n");}
#define LINELENGTH 96

int main (int argc, char *argv[]) {

    aes256_context ctx; 

    uint8_t key[32];
    uint8_t buf[16], i;

    FILE * input_file;
    char buffer [LINELENGTH];

    char strHexData[2];

    unsigned int keybyte[32];
    unsigned int databyte[16];


    // check for input text file argument -- print help if needed
   if(argc != 2 || strcmp(argv[1], "-h") == 0) {
        fprintf(stderr, "Usage: ./demo <input file>\n\n");
        return -1;
	}

	// attempt to open text file -- return error if not found
    input_file = fopen(argv[1], "r");

    if (input_file == NULL) {
    	fprintf(stderr, "ERROR: Could not open input file. Check <file location> argument.\n");
    	return -1;
    }

    // read file line-by-line

    while(fgets(buffer, LINELENGTH, input_file) != NULL) {

    	int j = 0;
    	int k = 0;
    	int line = 1;

    	if (buffer[0] == 'k') {

			for (k = 2; k < 66; k=k+2) {

				strHexData[0] = buffer[k];
				strHexData[1] = buffer[k+1];

				sscanf(strHexData, "%x", &keybyte[j]);
				j++;

			}
		}

		else if (buffer[0] == 'd') {

			for (k = 2; k < 34; k=k+2) {

				strHexData[0] = buffer[k];
				strHexData[1] = buffer[k+1];

				sscanf(strHexData, "%x", &databyte[j]);
				j++;
			}
		}

		else if (buffer[0] == 'r') {

		    /* put a test vector */
		    for (i = 0; i < sizeof(buf);i++) buf[i] = databyte[i];
		    for (i = 0; i < sizeof(key);i++) key[i] = keybyte[i];

		    DUMP("txt: ", i, buf, sizeof(buf));
		    DUMP("key: ", i, key, sizeof(key));
		    printf("---\n");

		    aes256_init(&ctx, key);
		    aes256_encrypt_ecb(&ctx, buf);

		    DUMP("enc: ", i, buf, sizeof(buf));

		    aes256_init(&ctx, key);
		    aes256_decrypt_ecb(&ctx, buf);
		    DUMP("dec: ", i, buf, sizeof(buf));

		    aes256_done(&ctx);
		}

		else {fprintf(stderr, "\nERROR: Failed on line %d - check the input text file.\n", line);}

		// increment the line for debugging and keeping track

		line++;
	}

		fclose(input_file);

	    return 0;
}