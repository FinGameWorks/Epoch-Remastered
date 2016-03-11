varying vec3 pixel_nor;       // camera direction in ellipsoid space
varying vec4 pixel_pos;       // pixel in ellipsoid space
varying vec4 pixel_scr;       // pixel in screen space <-1,+1>

varying vec3 p_r;               // rx,ry,rz
uniform vec3 planet_r;          // rx^-2,ry^-2,rz^-2 - surface

void main(void)
{
    p_r.x=1.0/sqrt(planet_r.x);
    p_r.y=1.0/sqrt(planet_r.y);
    p_r.z=1.0/sqrt(planet_r.z);
    pixel_nor=gl_Normal;
    pixel_pos=gl_Vertex;
    pixel_scr=gl_Color;
    gl_Position=gl_Color;
}