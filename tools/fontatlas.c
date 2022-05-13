/*
	fontatlas.c : Convert json data from font texture generator to a
	plaintext format that's easier to read from zscript code.
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
#include <math.h>
#include <jansson.h>

typedef struct
{
	int x, y, width, height, xofs, yofs, advance;
} glyph_t;

int main( int argc, char **argv )
{
	if ( argc < 2 )
	{
		fprintf(stderr,"usage: fontatlas <data.json>\n");
		return 0;
	}
	glyph_t glyphs[256] = {{0}};
	json_error_t error;
	json_t *root = json_load_file(argv[1],0,&error);
	if ( !root )
	{
		fprintf(stderr,"fontatlas: parse error at line %d: %s\n",
			error.line,error.text);
		return 1;
	}
	json_t *fontheight = json_object_get(root,"size");
	int fonth = json_integer_value(fontheight);
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
	glyphs[' '].advance = ceilf(glyphs['m'].advance/4.);	// set space width (quarter-em)
	printf("%d\n",fonth);
	for ( int i=0; i<256; i++ )
		printf("%d %d %d %d %d %d %d\n",glyphs[i].x,glyphs[i].y,
			glyphs[i].width,glyphs[i].height,glyphs[i].xofs,
			glyphs[i].yofs,glyphs[i].advance);
	return 0;
}
