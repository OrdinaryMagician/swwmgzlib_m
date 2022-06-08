// simple gradient map

vec4 BilinearSample( in sampler2D tex, in vec2 pos, in vec2 size, in vec2 pxsize )
{
	vec2 f = fract(pos*size);
	pos += (.5-f)*pxsize;
	vec4 p0q0 = texture(tex,pos);
	vec4 p1q0 = texture(tex,pos+vec2(pxsize.x,0));
	vec4 p0q1 = texture(tex,pos+vec2(0,pxsize.y));
	vec4 p1q1 = texture(tex,pos+vec2(pxsize.x,pxsize.y));
	vec4 pInterp_q0 = mix(p0q0,p1q0,f.x);
	vec4 pInterp_q1 = mix(p0q1,p1q1,f.x);
	return mix(pInterp_q0,pInterp_q1,f.y);
}

vec3 GradientMap( in float gray )
{
	vec2 size = vec2(512.,4.);
	vec2 pxsize = 1./size;
	return BilinearSample(gradtex,vec2(gray/2.+.25,0),size,pxsize).rgb;
}

void SetupMaterial( inout Material mat )
{
	vec4 base = getTexel(vTexCoord.st);
	base.rgb = GradientMap(base.x);
	mat.Base = base;
	mat.Normal = ApplyNormalMap(vTexCoord.st);
}
