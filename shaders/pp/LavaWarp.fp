// underwater overlay adapted from original Hexmas sanity effect shader
// lava version

vec2 calcdist( vec2 duv )
{
	vec2 uv = vec2(0.);
	vec2 dist = 2.*texture(warptex,duv*.2).xy-1.;
	dist.x *= abs(mod(dist.y+timer*0.34536,4.)-2.)-1.;
	uv.x += dist.x*.02*dfact;
	dist = 2.*texture(warptex,(duv+uv)*.3).xy-1.;
	dist.y *= abs(mod(dist.x+timer*0.25363,4.)-2.)-1.;
	uv.y -= dist.y*.03*dfact;
	return uv;
}

void main()
{
	vec2 uv = TexCoord+calcdist(TexCoord-vec2(0.,timer*.02));
	vec2 bresl = textureSize(InputTexture,0);
	vec2 sr = vec2(1.,bresl.y/bresl.x);
	float p = distance(uv,vec2(.5));
	uv = (uv-.5)*(1.-dfact*.07)+.5;
	vec4 res = texture(InputTexture,uv);
	vec4 flood = texture(fluidtex,uv*sr+vec2(timer*.02,timer*.01))*.4
		+texture(fluidtex,uv*sr*2.+vec2(-timer*.03,timer*.04))*.6;
	flood.rgb *= lightcol;
	res.rgb += flood.rgb*dfact;
	FragColor = vec4(res.rgb,1.);
}
