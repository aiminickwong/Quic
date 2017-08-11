#include<stdint.h>
#include<gtk/gtk.h>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#if 0
void* dump_surface(int depth,uint8_t *data,int width,int height,int stride)
{
	static uint32_t file_id = 0;
	int cache=0;
	int i, j;
	char *file_str=malloc(200*sizeof(char));
	bzero(file_str,200);
	uint32_t id = ++file_id;

#ifdef WIN32
	sprintf(file_str, "c:\\tmp\\spice_dump\\%d\\%u.ppm", cache, id);
#else
	sprintf(file_str, "/tmp/spice_dump/%u.ppm", id);
#endif

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
#endif

int window_create(char* buf)
{
//	char *file_name=dump_surface(32,(uint8_t*)buf,1280,768,5120);
	GtkWidget *image;
	GdkPixbuf *pixbuf;
	GtkWidget *window;

	window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
	gtk_window_set_title(GTK_WINDOW(window), "SPICEc:O");
	gtk_window_set_default_size(GTK_WINDOW(window), 1280, 768);
	gtk_window_move(GTK_WINDOW(window),0,0);
	//pixbuf = gdk_pixbuf_new_from_file(file_name,NULL);
	pixbuf = gdk_pixbuf_new_from_data ((guchar*)buf, GDK_COLORSPACE_RGB, FALSE,8,1280,768, 1280*3,0,0);
	image = gtk_image_new_from_pixbuf(pixbuf);
	gtk_container_add(GTK_CONTAINER(window),image);
	
	g_signal_connect_swapped(G_OBJECT(window),"destroy",G_CALLBACK(gtk_main_quit), NULL);
	gtk_widget_show_all(window);
	gtk_main();
	
	return 0;
}

