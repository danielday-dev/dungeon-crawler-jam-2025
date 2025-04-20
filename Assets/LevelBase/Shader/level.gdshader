shader_type spatial;

const int c_clearCapacity = 32;
uniform int u_clearCount = 0;
uniform vec3 u_clearCenters[c_clearCapacity];
uniform float u_clearRange[c_clearCapacity];
uniform vec3 u_combatCenter;
uniform float u_combatRange = 0;

uniform sampler2D u_meatTexture : source_color;
uniform sampler2D u_meatNormal : hint_normal;
uniform sampler2D u_clearTexture : source_color;
uniform sampler2D u_clearNormal : hint_normal;
uniform sampler2D u_combatTexture : source_color, hint_default_black;

varying vec3 v_worldPos;

varying float f_combatMix;

void vertex() {
	v_worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float maxBlend = 0.0;
	for (int i = 0; i < u_clearCount; i++) {
		float dist = distance(v_worldPos, u_clearCenters[i]);
		if (dist > u_clearRange[i]) continue;
		maxBlend = max(maxBlend, u_clearRange[i] - dist);
	}
	maxBlend = clamp(maxBlend, 0, 1);

	vec3 baseColor = mix(texture(u_meatTexture, UV).rgb, texture(u_clearTexture, UV).rgb, maxBlend);
	vec3 normal = mix(texture(u_meatNormal, UV).xyz, texture(u_clearNormal, UV).xyz, maxBlend);

	float combatDist = distance(v_worldPos, u_combatCenter);
	f_combatMix = clamp(u_combatRange - combatDist, 0.0, 1.0);

	ALBEDO.rgb = mix(baseColor, texture(u_combatTexture, UV).rgb, f_combatMix);
	NORMAL_MAP = mix(normal, vec3(0, 0, 0), f_combatMix);
}

void light() {
    DIFFUSE_LIGHT += ALBEDO * ATTENUATION * LIGHT_COLOR * max(dot(LIGHT,NORMAL), 0.0) * (1.0 - f_combatMix);
}
