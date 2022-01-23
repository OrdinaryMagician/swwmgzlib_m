// emulate keycard blink cycle on hud model

void SetupMaterial( inout Material mat )
{
	float mixfct = floor(mod(timer*35.,20.)/10.);
	vec2 uv = vTexCoord.st*vec2(.5,1.);
	uv.x += mixfct*.5;
	mat.Base = getTexel(uv);
	mat.Normal = ApplyNormalMap(vTexCoord.st);
	mat.Bright = vec4(mix(vec3(1.),vec3(0.),mixfct),1.);
}
