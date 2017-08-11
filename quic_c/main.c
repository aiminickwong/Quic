#include "quic.h"
//#include <gtk/gtk.h>

#if defined(__GNUC__) && (__GNUC__ > 2) && defined(__OPTIMIZE__)
#define _SPICE_BOOLEAN_EXPR(expr)                  \
	__extension__ ({                               \
				int _g_boolean_var_;               \
				if (expr)                          \
				_g_boolean_var_ = 1;               \
				else                               \
				_g_boolean_var_ = 0;               \
				_g_boolean_var_;                   \
				})
#define SPICE_LIKELY(expr) (__builtin_expect (_SPICE_BOOLEAN_EXPR(expr), 1))
#define SPICE_UNLIKELY(expr) (__builtin_expect (_SPICE_BOOLEAN_EXPR(expr), 0))
#else
#define SPICE_LIKELY(expr) (expr)
#define SPICE_UNLIKELY(expr) (expr)
#endif

void* dump_surface(int depth,uint8_t *data,int width,int height,int stride)
{
	static uint32_t file_id = 0;
	int cache=0;
	int i, j;
	char *file_str=malloc(200*sizeof(char));
	bzero(file_str,200);
	uint32_t id = ++file_id;

	sprintf(file_str, "./spice_dump/%u.ppm", id);

	FILE *f = fopen(file_str, "wb");
	if (!f)
	{
		return NULL;
	}
	fprintf(f, "P6\n");
	fprintf(f, "%d %d\n", width, height);
	fprintf(f, "#spicec dump\n");
	fprintf(f, "255\n");
	for (i = 0; i < height; i++, data += stride)
	{
		uint8_t *now = data;
		for (j = 0; j < width; j++)
		{
			fwrite(&now[2], 1, 1, f);
			fwrite(&now[1], 1, 1, f);
			fwrite(&now[0], 1, 1, f);
			now += 4;
		}
	}
	fclose(f);
	return file_str;
}


static void quic_usr_error(QuicUsrContext *usr, const char *fmt, ...)
{
	QuicData *usr_data = (QuicData *)usr;
	va_list ap;

	va_start(ap, fmt);
	vsnprintf(usr_data->message_buf, sizeof(usr_data->message_buf), fmt, ap);
	va_end(ap);

	longjmp(usr_data->jmp_env, 1);
}

static void quic_usr_warn(QuicUsrContext *usr, const char *fmt, ...)
{
	QuicData *usr_data = (QuicData *)usr;
	va_list ap;

	va_start(ap, fmt);
	vsnprintf(usr_data->message_buf, sizeof(usr_data->message_buf), fmt, ap);
	va_end(ap);
}

static void quic_usr_free(QuicUsrContext *usr, void *ptr)
{
	free(ptr);
}

static int quic_usr_more_space(QuicUsrContext *usr, uint32_t **io_ptr, int rows_completed)
{
	QuicData *quic_data = (QuicData *)usr;

	if (quic_data->current_chunk == quic_data->chunks->num_chunks -1) {
		return 0;
	}
	quic_data->current_chunk++;

	*io_ptr = (uint32_t *)quic_data->chunks->chunk[quic_data->current_chunk].data;
	return quic_data->chunks->chunk[quic_data->current_chunk].len >> 2;
}

static int quic_usr_more_lines(QuicUsrContext *usr, uint8_t **lines)
{
	return 0;
}


void *spice_malloc(size_t n_bytes)
{
	void *mem;

	if (SPICE_LIKELY(n_bytes)) {
		mem = malloc(n_bytes);

		if (SPICE_LIKELY(mem != NULL)) {
			return mem;
		}

		printf("unable to allocate %lu bytes", (unsigned long)n_bytes);
	}
	return NULL;
}


static void *quic_usr_malloc(QuicUsrContext *usr, int size)
{
	return spice_malloc(size);
}

int main(int argc,char* argv[])
{
	if(argc<2)
	{
		printf("put file_name\n");
		return 0;
	}

	quic_init();
	int res;
	int depth;
	QuicContext *quic;
	QuicUsrContext usr;
	QuicImageType out_type;
	int out_width, out_height;
	int stride;
//	gtk_init(&argc,&argv);
	usr.error = quic_usr_error;
	usr.warn = quic_usr_warn;
	usr.info = quic_usr_warn;
	usr.malloc = quic_usr_malloc;
	usr.free = quic_usr_free;
	usr.more_space = quic_usr_more_space;
	usr.more_lines = quic_usr_more_lines;

	quic = quic_create(&usr);
	int size;

	FILE* fp = fopen(argv[1], "r");
	fseek(fp, 0, SEEK_END);
	size = ftell(fp);
	printf("size=%d\n", size);
	fseek(fp, 0, SEEK_SET);
	char* data=malloc(size);
	bzero(data,size);
	res=fread(data,1,size,fp);
	fclose(fp);
	
	quic_decode_begin(quic, (uint32_t *)data, (size/4), &out_type, &out_width, &out_height);
	printf("width:%d,height:%d\n",out_width,out_height);
	switch(out_type)
	{
		case QUIC_IMAGE_TYPE_RGB32:
		case QUIC_IMAGE_TYPE_RGBA:
			depth=32;
			break;
		default:
			printf("bad depth\n");
			return -1;
	}
	stride=(out_width*4);
	uint8_t* buf=malloc(out_width*out_height*4);
	memset(buf,0xff,out_width*out_height*4);
	
	if(quic_decode(quic, out_type,(uint8_t*)(buf), stride)==QUIC_ERROR)
	{
		printf("quic decode failed");
		return -1;
	}
	dump_surface(depth,(uint8_t*)buf,out_width,out_height,stride);
//	hexdump(buf,32*51*4);
	
	free(buf);
	return 1;
}
