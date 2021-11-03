// pseudo-matcap

void SetupMaterial( inout Material mat )
{
	vec3 rnorm = normalize(vEyeNormal.xyz)*vec3(1,-1,1);
#ifdef BARRIER_MAP
	vec4 basemap = getTexel(rnorm.xy*.49+.5);
	basemap.rgb *= .25;
	vec3 grad = texture(bartex,vec2(0.,vTexCoord.t*5.+timer)).rgb;
	grad *= .25;
	mat.Base = basemap+vec4(grad,0.);
#else
	mat.Base = getTexel(rnorm.xy*.49+.5);
#endif
	mat.Normal = ApplyNormalMap(vTexCoord.st);
}

vec4 ProcessLight( Material mat, vec4 color )
{
#ifdef AMBIENT_GLOW
	float glow = .75+.25*sin(timer*8);
	return vec4(vec3(glow),color.a);
#else
	return color;
#endif
}
