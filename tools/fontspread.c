/*
	fontspread.c : Spread font atlas texture from font texture generator
	into a linear texture with all characters one after another, or reverse
	the process. This allows applying effects such as gradients with ease.
	(https://evanw.github.io/font-texture-generator/)

	Copyright (c) 2022 Marisa the Magician, UnSX Team

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include <jansson.h>

// TODO: use PNGs instead of goddamn raw RGBA8 image data

typedef struct
{
	int x, y, width, height, xofs, yofs, advance;
} glyph_t;

uint32_t getpixel( uint32_t *buf, int bw, int bh, int x, int y )
{
	if ( (x < 0) || (x >= bw) || (y < 0) || (y >= bh) )
		return 0;
	return buf[x+y*bw];
}

void putpixel( uint32_t px, uint32_t *buf, int bw, int bh, int x, int y )
{
	if ( (x < 0) || (x >= bw) || (y < 0) || (y >= bh) )
		return;
	buf[x+y*bw] = px;
}

int main( int argc, char **argv )
{
	int rev = 0;
	int barg = 1;
	if ( (argc > 1) && !strcmp(argv[1],"-i") )
	{
		rev = 1;
		barg++;
	}
	if ( argc < barg+3 )
	{
		fprintf(stderr,"usage: fontspread [-i] <data.json> <atlas.data> <texture.data>\n");
		return 0;
	}
	glyph_t glyphs[256] = {{0}};
	json_error_t error;
	json_t *root = json_load_file(argv[barg],0,&error);
	if ( !root )
	{
		fprintf(stderr,"fontspread: parse error at line %d: %s\n",
			error.line,error.text);
		return 1;
	}
	json_t *fontheight = json_object_get(root,"size");
	int fonth = json_integer_value(fontheight);
	json_t *atlaswidth = json_object_get(root,"width");
	int atlasw = json_integer_value(atlaswidth);
	json_t *atlasheight = json_object_get(root,"height");
	int atlash = json_integer_value(atlasheight);
	json_t *chars = json_object_get(root,"characters");
	const char *key;
	json_t *val;
	json_object_foreach(chars,key,val)
	{
		int ch = 0;
		if ( key[1] )
		{
			ch = (key[0]&0b00011111)<<6;
			ch |= key[1]&0b00111111;
		}
		else ch = key[0];
		json_t *go = json_object_get(val,"x");
		glyphs[ch].x = json_integer_value(go);
		go = json_object_get(val,"y");
		glyphs[ch].y = json_integer_value(go);
		go = json_object_get(val,"width");
		glyphs[ch].width = json_integer_value(go);
		go = json_object_get(val,"height");
		glyphs[ch].height = json_integer_value(go);
		go = json_object_get(val,"originX");
		glyphs[ch].xofs = json_integer_value(go);
		go = json_object_get(val,"originY");
		glyphs[ch].yofs = json_integer_value(go);
		go = json_object_get(val,"advance");
		glyphs[ch].advance = json_integer_value(go);
	}
	json_decref(root);
	int iw = 0, ih = fonth, xx = 0;
	for ( int i=0; i<256; i++ )
	{
		int yy = fonth-glyphs[i].yofs;
		if ( yy+glyphs[i].height > ih ) ih = yy+glyphs[i].height;
		xx += glyphs[i].width;
		iw = xx;
	}
	printf("Estimated texture dimensions: %dx%d\n",iw,ih);
	if ( rev )
	{
		FILE *f = fopen(argv[barg+2],"rb");
		if ( !f )
		{
			fprintf(stderr,"fontspread: failed to open texture: %s\n",strerror(errno));
			return 2;
		}
		uint32_t *tdata = calloc(iw*ih,sizeof(uint32_t));
		int got = fread(tdata,sizeof(uint32_t),iw*ih,f);
		if ( got < (iw*ih) )
		{
			fprintf(stderr,"fontspread: size mismatch in texture, should be %d, got %d\n",iw*ih,got);
			free(tdata);
			fclose(f);
			return 4;
		}
		fclose(f);
		uint32_t *adata = calloc(atlasw*atlash,sizeof(uint32_t));
		xx = 0;
		for ( int i=0; i<256; i++ )
		{
			int yy = fonth-glyphs[i].yofs;
			for ( int y=0; y<glyphs[i].height; y++ ) for ( int x=0; x<glyphs[i].width; x++ )
			{
				uint32_t px = getpixel(tdata,iw,ih,xx+x,yy+y);
				putpixel(px,adata,atlasw,atlash,glyphs[i].x+x,glyphs[i].y+y);
			}
			xx += glyphs[i].width;
		}
		free(tdata);
		f = fopen(argv[barg+1],"wb");
		if ( !f )
		{
			fprintf(stderr,"fontspread: failed to open atlas: %s\n",strerror(errno));
			free(adata);
			return 8;
		}
		fwrite(adata,sizeof(uint32_t),atlasw*atlash,f);
		free(adata);
		fclose(f);
		return 0;
	}
	else
	{
		FILE *f = fopen(argv[barg+1],"rb");
		if ( !f )
		{
			fprintf(stderr,"fontspread: failed to open atlas: %s\n",strerror(errno));
			return 2;
		}
		uint32_t *adata = calloc(atlasw*atlash,sizeof(uint32_t));
		int got = fread(adata,sizeof(uint32_t),atlasw*atlash,f);
		if ( got < (atlasw*atlash) )
		{
			fprintf(stderr,"fontspread: size mismatch in atlas, should be %d, got %d\n",atlasw*atlash,got);
			free(adata);
			fclose(f);
			return 4;
		}
		fclose(f);
		uint32_t *tdata = calloc(iw*ih,sizeof(uint32_t));
		xx = 0;
		for ( int i=0; i<256; i++ )
		{
			int yy = fonth-glyphs[i].yofs;
			for ( int y=0; y<glyphs[i].height; y++ ) for ( int x=0; x<glyphs[i].width; x++ )
			{
				uint32_t px = getpixel(adata,atlasw,atlash,glyphs[i].x+x,glyphs[i].y+y);
				putpixel(px,tdata,iw,ih,xx+x,yy+y);
			}
			xx += glyphs[i].width;
		}
		free(adata);
		f = fopen(argv[barg+2],"wb");
		if ( !f )
		{
			fprintf(stderr,"fontspread: failed to open texture: %s\n",strerror(errno));
			free(tdata);
			return 8;
		}
		fwrite(tdata,sizeof(uint32_t),iw*ih,f);
		free(tdata);
		fclose(f);
	}
	return 0;
}
