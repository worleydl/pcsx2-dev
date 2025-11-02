// SPDX-FileCopyrightText: 2002-2025 PCSX2 Dev Team
// SPDX-License-Identifier: GPL-3.0+

#ifndef PS_HDR
#define PS_HDR 0
#endif

cbuffer cb0 : register(b0)
{
	float4x4 ProjectionMatrix;
	float4 Brightness;
};

struct VS_INPUT
{
	float2 pos : POSITION;
	float4 col : COLOR0;
	float2 uv : TEXCOORD0;
};

struct PS_INPUT
{
	float4 pos : SV_POSITION;
	float4 col : COLOR0;
	float2 uv : TEXCOORD0;
};

PS_INPUT vs_main(VS_INPUT input)
{
	PS_INPUT output;
	output.pos = mul(ProjectionMatrix, float4(input.pos.xy, 0.f, 1.f));
	output.col = input.col;
	output.uv = input.uv;
	return output;
}

// todo; how to share code between stages? this is copied in colorcorrect
// PQ (ST.2084) encoding constants
static const float  PQ_m1 = 1305.0  /  8192.0;
static const float  PQ_m2 = 2523.0  /  32.0;
static const float  PQ_c1 = 107.0   /  128.0;
static const float  PQ_c2 = 2413.0  /  128.0;
static const float  PQ_c3 = 2392.0  /  128.0;

// Convert linear light (in nits) to PQ-encoded signal [0-1]
float3 LinearToPQ(float3 linearColor, float maxNits)
{
       // Normalize to maxNits
       float3 L = saturate(linearColor / maxNits);

       float3 num = PQ_c1 + PQ_c2 * pow(L, PQ_m1);
       float3 den = 1.0 + PQ_c3 * pow(L, PQ_m1);

       return pow(num / den, PQ_m2);
}

sampler sampler0 : register(s0);
Texture2D texture0 : register(t0);

float4 ps_main(PS_INPUT input) : SV_Target
{
	float4 out_col = input.col * texture0.Sample(sampler0, input.uv);
#if PS_HDR
	// todo: xbox macros
	out_col.rgb = LinearToPQ(out_col.rgb, 5000.0);
	//out_col.rgb = pow(out_col.rgb, 2.2);

	//out_col.a = pow(out_col.a, 1.0 / 2.2); // Approximation to match gamma space blends //TODO: bad?
#endif
	out_col.rgb *= Brightness.x; // Always 1 in SDR
	return out_col;
}
