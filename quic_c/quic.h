#ifndef __QUIC_H
#define __QUIC_H

#include <stdio.h>
#include <setjmp.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdint.h>
#include "quic_config.h"

typedef struct SpiceChunk {
	uint8_t *data;
	uint32_t len;
} SpiceChunk;

typedef struct SpiceChunks {
	uint32_t     data_size;
	uint32_t     num_chunks;
	uint32_t     flags;
	SpiceChunk   chunk[0];
} SpiceChunks;

typedef void *QuicContext;

typedef struct QuicUsrContext QuicUsrContext;
struct QuicUsrContext {
    void (*error)(QuicUsrContext *usr, const char *fmt, ...);
    void (*warn)(QuicUsrContext *usr, const char *fmt, ...);
    void (*info)(QuicUsrContext *usr, const char *fmt, ...);
    void *(*malloc)(QuicUsrContext *usr, int size);
    void (*free)(QuicUsrContext *usr, void *ptr);
    int (*more_space)(QuicUsrContext *usr, uint32_t **io_ptr, int rows_completed);
    int (*more_lines)(QuicUsrContext *usr, uint8_t **lines); // on return the last line of previous
                                                             // lines bunch must still be valid
};

typedef struct QuicData { 
	QuicUsrContext usr; 
	QuicContext *quic; 
	jmp_buf jmp_env; 
	char message_buf[512]; 
	SpiceChunks *chunks; 
	uint32_t current_chunk; 
} QuicData;

typedef enum {
    QUIC_IMAGE_TYPE_INVALID,
    QUIC_IMAGE_TYPE_GRAY,
    QUIC_IMAGE_TYPE_RGB16,
    QUIC_IMAGE_TYPE_RGB24,
    QUIC_IMAGE_TYPE_RGB32,
    QUIC_IMAGE_TYPE_RGBA
} QuicImageType;

#define QUIC_ERROR -1
#define QUIC_OK 0



int quic_encode(QuicContext *quic, QuicImageType type, int width, int height,
                uint8_t *lines, unsigned int num_lines, int stride,
                uint32_t *io_ptr, unsigned int num_io_words);

int quic_decode_begin(QuicContext *quic, uint32_t *io_ptr, unsigned int num_io_words,
                      QuicImageType *type, int *width, int *height);
int quic_decode(QuicContext *quic, QuicImageType type, uint8_t *buf, int stride);


QuicContext *quic_create(QuicUsrContext *usr);
void quic_destroy(QuicContext *quic);

#endif
