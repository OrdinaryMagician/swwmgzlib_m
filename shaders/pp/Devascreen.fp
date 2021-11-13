// hateful pulses

vec2 heatdist( in vec2 uv )
{
	vec2 ofs = texture(BumpTex,uv*8.-vec2(0.,.5)*timer).xy;
	ofs = (ofs-.5)*2.;
	ofs *= pow(length(ofs),.5);
	ofs *= .025;
	return ofs;
}

void main()
{
	vec2 uv = TexCoord;
	vec2 bresl = textureSize(InputTexture,0);
	vec2 sr = vec2(1.,bresl.y/bresl.x);
	// vignette fade, will be needed later
	vec2 vuv = uv.xy*(1.-uv.yx)*4.;
	float fade = 1.-(vuv.x*vuv.y);
	fade = pow(clamp(fade-(.6-.3*pow(xtrastr,.5)),0.,1.),3.);
	fade = pow(fade,.9+.2*texture(NoiseTex,vec2(timer*.05)).x-.1*xtrastr);
	vec3 col = texture(InputTexture,uv+fade*heatdist(uv*sr)).rgb;
	col += texture(InputTexture,uv+.001*xtrastr*texture(NoiseTex,vec2(timer*.4536,timer*.7835)).xy+fade*heatdist(uv*sr)).rgb;
	col += texture(InputTexture,uv-.001*xtrastr*texture(NoiseTex,vec2(timer*.6735,timer*.4335)).xy+fade*heatdist(uv*sr)).rgb;
	col *= .4*vec3(.97,.75,1.12);
	col = pow(col,vec3(1.1,1.2,1.));
	fade = pow(fade,.75);
	col = mix(col,col-vec3(.4,.8,.3),fade*1.2);
	// overlay first pulse
	vec3 ovr = texture(WarpTex1,uv*2.+heatdist(uv*sr*.25)-vec2(0.,.15)*timer).rgb;
	col += ovr*fade;
	ovr = texture(WarpTex2,uv*2.+heatdist(uv*sr*.25)+vec2(0.,.15)*timer).rgb;
	col -= ovr*fade;
	FragColor = vec4(clamp(col,0.,1.),1.);
}
