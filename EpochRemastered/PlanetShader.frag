#extension GL_ARB_gpu_shader_fp64 : enable
double abs(double x) { if (x<0.0) x=-x; return x; }

varying vec3 pixel_nor;              // camera direction in ellipsoid space
varying vec4 pixel_pos;              // pixel in ellipsoid space
varying vec4 pixel_scr;              // pixel in screen space
varying vec3 p_r;                    // rx,ry,rz

uniform vec3 planet_r;               // rx^-2,ry^-2,rz^-2 - surface
uniform vec3 planet_R;               // Rx^-2,Ry^-2,Rz^-2 - atmosphere
uniform float planet_h;              // atmoshere height [m]
uniform float view_depth;            // max. optical path length [m] ... saturation

// lights are only for local stars-atmosphere ray colision to set start color to star color
const int _lights=3;
uniform int  lights;                 // actual number of lights
uniform vec3 light_dir[_lights];     // direction to local star in ellipsoid space
uniform vec3 light_col[_lights];     // local star color * visual intensity
uniform vec4 light_posr[_lights];    // local star position and radius^-2 in ellipsoid space
uniform vec4 B0;                     // atmosphere scattering color coefficients (r,g,b,ambient)

// compute length of ray(p0,dp) to intersection with ellipsoid((0,0,0),r) -> view_depth_l0,1
// where r.x is elipsoid rx^-2, r.y = ry^-2 and r.z=rz^-2
const double view_depth_max=100000000.0; // > max view depth
double view_depth_l0=-1.0, // view_depth_l0 first hit
view_depth_l1=-1.0; // view_depth_l1 second hit
bool  _view_depth_l0=false;
bool  _view_depth_l1=false;
bool _view_depth(vec3 _p0,vec3 _dp,vec3 _r)
{
    dvec3 p0,dp,r;
    double a,b,c,d,l0,l1;
    view_depth_l0=-1.0; _view_depth_l0=false;
    view_depth_l1=-1.0; _view_depth_l1=false;
    // conversion to double
    p0=dvec3(_p0);
    dp=dvec3(_dp);
    r =dvec3(_r );
    // quadratic equation a.l.l+b.l+c=0; l0,l1=?;
    a=(dp.x*dp.x*r.x)
    +(dp.y*dp.y*r.y)
    +(dp.z*dp.z*r.z);
    b=(p0.x*dp.x*r.x)
    +(p0.y*dp.y*r.y)
    +(p0.z*dp.z*r.z); b*=2.0;
    c=(p0.x*p0.x*r.x)
    +(p0.y*p0.y*r.y)
    +(p0.z*p0.z*r.z)-1.0;
    // discriminant d=sqrt(b.b-4.a.c)
    d=((b*b)-(4.0*a*c));
    if (d<0.0) return false;
    d=sqrt(d);
    // standard solution l0,l1=(-b +/- d)/2.a
    a*=2.0;
    l0=(-b+d)/a;
    l1=(-b-d)/a;
    // alternative solution q=-0.5*(b+sign(b).d) l0=q/a; l1=c/q; (should be more accurate sometimes)
    //  if (b<0.0) d=-d; d=-0.5*(b+d);
    //  l0=d/a;
    //  l1=c/d;
    // sort l0,l1 asc
    if ((l0<0.0)||((l1<l0)&&(l1>=0.0))) { a=l0; l0=l1; l1=a; }
    // exit
    if (l1>=0.0) { view_depth_l1=l1; _view_depth_l1=true; }
    if (l0>=0.0) { view_depth_l0=l0; _view_depth_l0=true; return true; }
    return false;
}

// determine if ray (p0,dp) hits a sphere ((0,0,0),r)
// where r is (sphere radius)^-2
bool _star_colide(vec3 _p0,vec3 _dp,float _r)
{
    dvec3 p0,dp,r;
    double a,b,c,d,l0,l1;
    // conversion to double
    p0=dvec3(_p0);
    dp=dvec3(_dp);
    r =dvec3(_r );
    // quadratic equation a.l.l+b.l+c=0; l0,l1=?;
    a=(dp.x*dp.x*r)
    +(dp.y*dp.y*r)
    +(dp.z*dp.z*r);
    b=(p0.x*dp.x*r)
    +(p0.y*dp.y*r)
    +(p0.z*dp.z*r); b*=2.0;
    c=(p0.x*p0.x*r)
    +(p0.y*p0.y*r)
    +(p0.z*p0.z*r)-1.0;
    // discriminant d=sqrt(b.b-4.a.c)
    d=((b*b)-(4.0*a*c));
    if (d<0.0) return false;
    d=sqrt(d);
    // standard solution l0,l1=(-b +/- d)/2.a
    a*=2.0;
    l0=(-b+d)/a;
    l1=(-b-d)/a;
    // alternative solution q=-0.5*(b+sign(b).d) l0=q/a; l1=c/q; (should be more accurate sometimes)
    //  if (b<0.0) d=-d; d=-0.5*(b+d);
    //  l0=d/a;
    //  l1=c/d;
    // sort l0,l1 asc
    if (abs(l0)>abs(l1)) { a=l0; l0=l1; l1=a; }
    if (l0<0.0)          { a=l0; l0=l1; l1=a; }
    if (l0<0.0) return false;
    return true;
}

// compute atmosphere color between ellipsoids (planet_pos,planet_r) and (planet_pos,planet_R) for ray(pixel_pos,pixel_nor)
vec4 atmosphere()
{
    const int n=8;
    const float _n=1.0/float(n);
    int i;
    bool b0,b1;
    vec3 p0,p1,dp,p,b;
    vec4 c;     // c - color of pixel from start to end
    
    float h,dl,ll;
    double l0,l1,l2;
    bool   e0,e1,e2;
    c=vec4(0.0,0.0,0.0,0.0);    // a=0.0 full background color, a=1.0 no background color (ignore star)
    b1=_view_depth(pixel_pos.xyz,pixel_nor,planet_R);
    if (!b1) return c;                          // completly outside atmosphere
    e1=_view_depth_l0; l1=view_depth_l0;        // first atmosphere hit
    e2=_view_depth_l1; l2=view_depth_l1;        // second atmosphere hit
    b0=_view_depth(pixel_pos.xyz,pixel_nor,planet_r);
    e0=_view_depth_l0; l0=view_depth_l0;        // first surface hit
    if ((b0)&&(view_depth_l1<0.0)) return c;    // under ground
    // set l0 to view depth and p0 to start point
    dp=pixel_nor;
    p0=pixel_pos.xyz;
    if (!b0)                                    // outside surface
    {
        if (!e2)                                // inside atmosphere to its boundary
        {
            l0=l1;
        }
        else{                                   // throu atmosphere from boundary to boundary
            p0=vec3(dvec3(p0)+(dvec3(dp)*l1));
            l0=l2-l1;
        }
        // if a light source is in visible path then start color is light source color
        for (i=0;i<lights;i++)
            if (_star_colide(p0.xyz-light_posr[i].xyz,dp.xyz,light_posr[i].a*0.75)) // 0.75 is enlargment to hide star texture corona
            {
                c.rgb+=light_col[i];
                c.a=1.0; // ignore already drawed local star color
            }
    }
    else{                                       // into surface
        if (l1<l0)                              // from atmosphere boundary to surface
        {
            p0=vec3(dvec3(p0)+(dvec3(dp)*l1));
            l0=l0-l1;
        }
        else{                                   // inside atmosphere to surface
            l0=l0;
        }
    }
    // set p1 to end of view depth, dp to intergral step
    p1=vec3(dvec3(p0)+(dvec3(dp)*l0)); dp=p1-p0;
    dp*=_n;
    
    dl=float(l0)*_n/view_depth;
    ll=B0.a; for (i=0;i<lights;i++)             // compute normal shaded combined light sources into ll
        ll+=dot(normalize(p1),light_dir[0]);
    for (p=p1,i=0;i<n;p-=dp,i++)                // p1->p0 path throu atmosphere from ground
    {
        //      _view_depth(p,normalize(p),planet_R);   // too slow... view_depth_l0=depth above atmosphere top [m]
        //      h=exp(view_depth_l0/planet_h)/2.78;
        
        b=normalize(p)*p_r;                     // much much faster
        h=length(p-b);
        h=exp(h/planet_h)/2.78;
        
        b=B0.rgb*h*dl;
        c.r*=1.0-b.r;
        c.g*=1.0-b.g;
        c.b*=1.0-b.b;
        c.rgb+=b*ll;
    }
    if (c.r<0.0) c.r=0.0;
    if (c.g<0.0) c.g=0.0;
    if (c.b<0.0) c.b=0.0;
    h=0.0;
    if (h<c.r) h=c.r;
    if (h<c.g) h=c.g;
    if (h<c.b) h=c.b;
    if (h>1.0)
    {
        h=1.0/h;
        c.r*=h;
        c.g*=h;
        c.b*=h;
    }
    return c;
}

void main(void)
{
    gl_FragColor.rgba=atmosphere();
}