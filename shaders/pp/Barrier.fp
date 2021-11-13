// barrier shimmering warp overlay

void main()
{
	vec2 uv = TexCoord;
	vec2 bresl = textureSize(InputTexture,0);
	vec2 sr = vec2(1.0,bresl.y/bresl.x);
	vec2 flood = texture(WarpTex,uv*sr+vec2(timer*.02,-timer*.04)).xy;
	flood += texture(WarpTex,uv*sr*2.+vec2(-timer*.07,-timer*.13)).xy;
	flood += texture(WarpTex,uv*sr*.5+vec2(0.,-timer*.06)).xy;
	flood /= 3.;
	vec3 col = texture(InputTexture,uv).rgb*6.;
	for ( int i=0; i<3; i++ )
	{
		uv = (uv*.995)+.0025;
		uv += (flood-.5)*.003;
		col += texture(InputTexture,uv).rgb;
	}
	col.rgb /= 8.;
	col.rgb = pow(max(col.rgb,vec3(0.)),vec3(1.2,1.15,.77))*vec3(1.03,1.32,.98);
	FragColor = vec4(col,1.);
}
