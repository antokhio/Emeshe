//@author: microdee
//@help: lighting components

#define PI 3.14159265358979
#include "../fxh/CookTorrance.fxh"

Texture2D Lights[5];
Texture2D MaskTex;

SamplerState s0
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = WRAP;
    AddressV = MIRROR;
};

cbuffer cbPerObj : register( b1 )
{
	float LightCount = 1;
	float DistanceMod = 1;
	bool IsInitial = true;
	float ComponentAmount[5] = {1,1,1,1,1};
	float2 Res : TARGETSIZE;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = input.PosO;
    Out.TexCd = input.TexCd;
    return Out;
}


struct OutComps
{
	float4 Ambient : SV_Target0;
	float4 Diffuse : SV_Target1;
	float4 Specular : SV_Target2;
	float4 SSS : SV_Target3;
	float4 Rim : SV_Target4;
};

OutComps pPnt(vs2ps In)
{
	float2 uv = In.TexCd.xy;

	if((GetStencil(uv, Res) > 0) && KnowFeature(GetMatID(uv, Res), MF_LIGHTING_COOKTORRANCE))
	{
		Components col = CookTorrancePointSSS(s0, uv, Res, LightCount, DistanceMod, MaskTex.SampleLevel(s0, uv, 0).r);
		OutComps outCol = (OutComps)0;
		
		outCol.Ambient.xyz = max(0,col.Ambient.xyz * ComponentAmount[0]);
		outCol.Diffuse.xyz = max(0,col.Diffuse.xyz * ComponentAmount[1]);
		outCol.Specular.xyz = max(0,col.Specular.xyz * ComponentAmount[2]);
		outCol.SSS.xyz = max(0,col.SSS.xyz * ComponentAmount[3]);
		outCol.Rim.xyz = max(0,col.Rim.xyz * ComponentAmount[4]);
		if(!IsInitial)
		{
			outCol.Ambient.rgb = max(outCol.Ambient.rgb,Lights[0].Sample(s0, uv).rgb);
			outCol.Diffuse.rgb += max(0,Lights[1].Sample(s0, uv).rgb);
			outCol.Specular.rgb += max(0,Lights[2].Sample(s0, uv).rgb);
			outCol.SSS.rgb += max(0,Lights[3].Sample(s0, uv).rgb);
			outCol.Rim.rgb += max(0,Lights[4].Sample(s0, uv).rgb);
		}
		
		return outCol;
	}
	else
	{
		return (OutComps)0;
	}
	
}

technique10 Point
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, pPnt() ) );
	}
}

OutComps pSpt(vs2ps In)
{
	float2 uv = In.TexCd.xy;

	if((GetStencil(uv, Res) > 0) && KnowFeature(GetMatID(uv, Res), MF_LIGHTING_COOKTORRANCE))
	{
		Components col = CookTorranceSpotSSS(s0, uv, Res, LightCount, DistanceMod, MaskTex.SampleLevel(s0, uv, 0).r);
		OutComps outCol = (OutComps)1;
		
		outCol.Ambient.xyz = max(0,col.Ambient.xyz * ComponentAmount[0]);
		outCol.Diffuse.xyz = max(0,col.Diffuse.xyz * ComponentAmount[1]);
		outCol.Specular.xyz = max(0,col.Specular.xyz * ComponentAmount[2]);
		outCol.SSS.xyz = max(0,col.SSS.xyz * ComponentAmount[3]);
		outCol.Rim.xyz = max(0,col.Rim.xyz * ComponentAmount[4]);
		if(!IsInitial)
		{
			outCol.Ambient.rgb = max(outCol.Ambient.rgb,Lights[0].Sample(s0, uv).rgb);
			outCol.Diffuse.rgb += max(0,Lights[1].Sample(s0, uv).rgb);
			outCol.Specular.rgb += max(0,Lights[2].Sample(s0, uv).rgb);
			outCol.SSS.rgb += max(0,Lights[3].Sample(s0, uv).rgb);
			outCol.Rim.rgb += max(0,Lights[4].Sample(s0, uv).rgb);
		}
		
		return outCol;
	}
	else
	{
		return (OutComps)0;
	}
}

technique10 Spot
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, pSpt() ) );
	}
}

OutComps pSun(vs2ps In)
{
	float2 uv = In.TexCd.xy;

	if((GetStencil(uv, Res) > 0) && KnowFeature(GetMatID(uv, Res), MF_LIGHTING_COOKTORRANCE))
	{
		Components col = CookTorranceSunSSS(s0, uv, Res, LightCount, DistanceMod, MaskTex.SampleLevel(s0, uv, 0).r);
		OutComps outCol = (OutComps)1;
		
		outCol.Ambient.xyz = max(0,col.Ambient.xyz * ComponentAmount[0]);
		outCol.Diffuse.xyz = max(0,col.Diffuse.xyz * ComponentAmount[1]);
		outCol.Specular.xyz = max(0,col.Specular.xyz * ComponentAmount[2]);
		outCol.SSS.xyz = max(0,col.SSS.xyz * ComponentAmount[3]);
		outCol.Rim.xyz = max(0,col.Rim.xyz * ComponentAmount[4]);
		if(!IsInitial)
		{
			outCol.Ambient.rgb = max(outCol.Ambient.rgb,Lights[0].Sample(s0, uv).rgb);
			outCol.Diffuse.rgb += max(0,Lights[1].Sample(s0, uv).rgb);
			outCol.Specular.rgb += max(0,Lights[2].Sample(s0, uv).rgb);
			outCol.SSS.rgb += max(0,Lights[3].Sample(s0, uv).rgb);
			outCol.Rim.rgb += max(0,Lights[4].Sample(s0, uv).rgb);
		}
		//outCol.SSS.xy = Res;
		return outCol;
	}
	else
	{
		return (OutComps)0;
	}
}

technique10 Sun
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, pSun() ) );
	}
}


