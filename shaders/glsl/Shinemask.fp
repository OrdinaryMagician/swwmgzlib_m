// basic texture + masked pseudo-matcap

void SetupMaterial( inout Material mat )
{
	vec4 base = getTexel(vTexCoord.st);
	float mask = texture(masktex,vTexCoord.st).x;
	vec3 rnorm = normalize(vEyeNormal.xyz)*vec3(1,-1,1);
	mat.Base = vec4(base.rgb+texture(envtex,rnorm.xy*.49+.5).rgb*mask,base.a);
	mat.Normal = ApplyNormalMap(vTexCoord.st);
	if ( (uTextureMode&TEXF_Brightmap) != 0 )
		mat.Bright = texture(brighttexture,vTexCoord.st);
}
