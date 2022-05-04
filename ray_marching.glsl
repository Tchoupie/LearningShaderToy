const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

float hash(float h) {
	return fract(sin(h) * 43758.5453123);
}

float noise(vec3 x) {
	vec3 p = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);

	float n = p.x + p.y * 157.0 + 113.0 * p.z;
	return mix(
			mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
					mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
			mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
					mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

float fbm(vec3 p) {
	float f = 0.0;
	f = 0.5000 * noise(p);
	p *= 2.01;
	f += 0.2500 * noise(p);
	p *= 2.02;
	f += 0.1250 * noise(p);

	return f;
}

float fbm2 ( in vec2 _st) {
    int numOctaves = int(min(10.0, log2(iResolution.x))) - 3;
    
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), 
                    -sin(0.5), cos(0.50));
    
    // Unrolled loop; because GL won't let me compare against a non-constant.
    if (numOctaves >= 1) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 2) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 3) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 4) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 5) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 6) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 7) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 8) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 9) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    if (numOctaves >= 10) {
        v += a * noise(vec3(_st.x,_st.y,0));
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}


// smooth min
float smin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

// smooth max
float smax(float a, float b, float k) {
  return -smin(-a, -b, k);
}

float sdSphere(vec3 p, float r, vec3 offset )
{
  return length(p - offset) - r;
}

float opRep(vec3 p, float r, vec3 c)
{
  vec3 q = mod(p+0.5*c,c)-0.5*c;
  return sdSphere(q, r, vec3(0));
}

float sdScene(vec3 p) {
  p.x *= fbm(vec3(p.x,p.y,p.z+iTime));
  p.y *= noise(vec3(p.x,p.y,p.z+iTime));
  //p.x *= fbm2(vec2(p.x,p.y));
  //p.y *= fbm2(vec2(p.x,p.y));
  
  float sphereLeft = sdSphere(p, 1., vec3(-2.5, 0, -2));
  float sphereRight = sdSphere(p, 1., vec3(2.5, 0, -2));
  //float rep = opRep(p,0.1,vec3(2,2,2));
  return smin(sphereLeft, sphereRight,iTime);
  //return rep;
}

float rayMarch(vec3 ro, vec3 rd, float start, float end) {
  float depth = start;

  for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
    vec3 p = ro + depth * rd;
    float d = sdScene(p);
    depth += d;
    if (d < PRECISION || depth > end) break;
  }

  return depth;
}

vec3 calcNormal(in vec3 p) {
    vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
    float r = 1.; // radius of sphere
    return normalize(
      e.xyy * sdScene(p + e.xyy) +
      e.yyx * sdScene(p + e.yyx) +
      e.yxy * sdScene(p + e.yxy) +
      e.xxx * sdScene(p + e.xxx));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
  vec3 backgroundColor = vec3(0.835, 1, 1);

  vec3 col = vec3(0);
  //vec3 ro = vec3(0.5, 0.3, -iTime/10.); // ray origin that represents camera position
  vec3 ro = vec3(0, 0, iTime/2.); // ray origin that represents camera position
  vec3 rd = normalize(vec3(uv, -1)); // ray direction

  float d = rayMarch(ro, rd, MIN_DIST, MAX_DIST); // distance to sphere

  if (d > MAX_DIST) {
    col = backgroundColor; // ray didn't hit anything
  } else {
    vec3 p = ro + rd * d; // point on sphere we discovered from ray marching
    vec3 normal = calcNormal(p);
    vec3 lightPosition = vec3(2, 2, 7);
    vec3 lightDirection = normalize(lightPosition - p);

    // Calculate diffuse reflection by taking the dot product of 
    // the normal and the light direction.
    float dif = clamp(dot(normal, lightDirection), 0.3, 1.);

    // Multiply the diffuse reflection value by an orange color and add a bit
    // of the background color to the sphere to blend it more with the background.
    //col = dif * vec3(1, 0.58, 0.29) + backgroundColor * .2;
    col = dif * fbm(vec3(p.x+iTime, p.y+iTime, p.z+iTime)) + backgroundColor * .2;
    //col = dif * fbm2(vec2(p.x+iTime, p.y+iTime)) + backgroundColor * .2;
  }

  // Output to screen
  fragColor = vec4(col, 1.0);
}