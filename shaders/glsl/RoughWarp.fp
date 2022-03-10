// rough warp overlay

#define overlay(a,b) (a<0.5)?(2.0*a*b):(1.0-(2.0*(1.0-a)*(1.0-b)))
const float pi = 3.14159265358979323846;

vec2 warpcoord( in vec2 uv )
{
	vec2 offset;
	offset.y = sin(pi*2.*(uv.x*4.+timer*.25))*.02;
	offset.y += timer*.1;
	offset.x = cos(pi*2.*(uv.y*4.+timer*.25))*.02;
	offset.x -= timer*.1;
	return fract(uv+offset);
}
vec2 warpcoord2( in vec2 uv )
{
	vec2 offset;
	offset.y = sin(pi*2.*(uv.x*4.+timer*.25))*.02;
	offset.y += timer*.1;
	offset.x = cos(pi*2.*(uv.y*4.+timer*.25))*.02;
	offset.x += timer*.1;
	return fract(uv+offset);
}

void SetupMaterial( inout Material mat )
{
	vec4 col = getTexel(vTexCoord.st);
	vec2 coord = floor(vTexCoord.st*BASE_RES)/BASE_RES;
	coord.y *= BASE_RES.y/BASE_RES.x;
	coord *= BASE_RES.x/128.;
	float ovr = texture(warptex,warpcoord(coord)).x;
	coord = floor(vTexCoord.st*BASE_RES)/BASE_RES;
	coord.y *= BASE_RES.y/BASE_RES.x;
	coord *= BASE_RES.x/64.;
	ovr += texture(warptex,warpcoord2(coord)).x;
	ovr /= 2.;
	col.r = overlay(col.r,ovr);
	col.g = overlay(col.g,ovr);
	col.b = overlay(col.b,ovr);
	mat.Base = col;
	mat.Normal = ApplyNormalMap(vTexCoord.st);
}
