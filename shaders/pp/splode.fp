// exploding GZDoom logo (very silly)

void main()
{
	vec4 res = texture(InputTexture,TexCoord);
	vec2 bresl = vec2(textureSize(InputTexture,0));
	vec2 lresl = vec2(256.);
	float ar = bresl.x/bresl.y;
	vec2 uv = TexCoord-vec2(.5);
	uv.x *= ar;
	uv *= (bresl.y/256.)/cleanfac;
	vec4 col;
	if ( sframe > 0 )
	{
		double xf = ((sframe-1)%4)*.125;
		double yf = ((sframe-1)/4)*.125;
		vec2 uv1 = clamp(uv*.4+vec2(.5),vec2(0.),vec2(1.));
		uv1 = floor(uv1*128.)/128.;
		vec2 uv2 = clamp(uv*.2+vec2(.5),vec2(0.),vec2(1.));
		uv2 = floor(uv2*128.)/128.;
		col = texture(splodanm,vec2(uv1.x*.125+xf,(1.-uv1.y)*.125+yf));
		col.rgb += texture(splodanm,vec2(uv2.x*.125+xf+.5,(1.-uv2.y)*.125+yf)).rgb;
	}
	else
	{
		uv += shake*.2;
		uv = clamp(uv*1.6+vec2(.5),vec2(0.),vec2(1.));
		col = texture(gzlogo,vec2(uv.x,1.-uv.y));
	}
	FragColor = mix(col,res,fade);
}
