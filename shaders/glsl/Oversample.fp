// This should act as a virtual NormalNx upscaler when using texture filtering

void SetupMaterial( inout Material mat )
{
	vec2 size = textureSize(tex,0);
	vec2 pxsize = vec2(1./size.x,1./size.y);
	vec2 pos = vTexCoord.st-vec2(.5)*pxsize;
	vec2 fcoord = fract(pos*size-vec2(.5));
	vec2 coeff = fcoord*6.;	// virtual upscale factor I guess?
	float threshold = 0.;	// this controls sharpness, kinda
	coeff = (coeff-threshold)*1./(1.-2*threshold);
	coeff = clamp(coeff,0.,1.);
	mat.Base = texture(tex,pos+pxsize*(coeff-fcoord));
	mat.Normal = ApplyNormalMap(vTexCoord.st);
}
