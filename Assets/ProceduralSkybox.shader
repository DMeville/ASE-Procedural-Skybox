// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DM/ProceduralSkybox"
{
	Properties
	{
		_SkyColor("Sky Color", Color) = (0.3764706,0.6039216,1,0)
		_HorizonColor("Horizon Color", Color) = (0.9137255,0.8509804,0.7215686,0)
		_NightColor("Night Color", Color) = (0,0,0,0)
		_SunDiskSize("Sun Disk Size", Range( 0 , 0.5)) = 0
		_SunDiskSizeAdjust("Sun Disk Size Adjust", Range( 0 , 0.01)) = 0
		_SunDiskSharpness("Sun Disk Sharpness", Range( 0 , 0.01)) = 0
		_HorizonGlowIntensity("Horizon Glow Intensity", Range( 0 , 1)) = 0.59
		_HorizonSharpness("Horizon Sharpness", Float) = 5.7
		_HorizonSunGlowSpreadMin("Horizon Sun Glow Spread Min", Range( 0 , 10)) = 5.075109
		_HorizonSunGlowSpreadMax("Horizon Sun Glow Spread Max", Range( 0 , 10)) = 0
		_HorizonTintSunPower("Horizon Tint Sun Power", Float) = 0
		_NightTransitionScale("Night Transition Scale", Float) = 1
		_NightTransitionHorizonDelay("Night Transition Horizon Delay", Float) = 0
		_HorizonMinAmountAlways("Horizon Min Amount Always", Range( 0 , 1)) = 0
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			//This is a late directive
			
			uniform float4 _SkyColor;
			uniform float4 _NightColor;
			uniform float _NightTransitionScale;
			uniform float4 _HorizonColor;
			uniform float _NightTransitionHorizonDelay;
			uniform float _HorizonMinAmountAlways;
			uniform float _HorizonSharpness;
			uniform float _HorizonSunGlowSpreadMin;
			uniform float _HorizonSunGlowSpreadMax;
			uniform float _HorizonGlowIntensity;
			uniform float _HorizonTintSunPower;
			uniform float _SunDiskSize;
			uniform float _SunDiskSizeAdjust;
			uniform float _SunDiskSharpness;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord.xyz = ase_worldPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor;
				float3 ase_worldPos = i.ase_texcoord.xyz;
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(ase_worldPos);
				float dotResult81 = dot( -worldSpaceLightDir , float3( 0,1,0 ) );
				float NightTransScale235 = _NightTransitionScale;
				float4 lerpResult78 = lerp( _SkyColor , _NightColor , saturate( ( dotResult81 * NightTransScale235 ) ));
				float4 SkyColor197 = lerpResult78;
				float4 HorizonColor313 = _HorizonColor;
				float dotResult238 = dot( -worldSpaceLightDir , float3( 0,1,0 ) );
				float HorizonScaleDayNight304 = saturate( ( dotResult238 * ( NightTransScale235 + _NightTransitionHorizonDelay ) ) );
				float dotResult213 = dot( worldSpaceLightDir , float3( 0,1,0 ) );
				float HorizonGlowGlobalScale307 = (_HorizonMinAmountAlways + (saturate( pow( ( 1.0 - abs( dotResult213 ) ) , 4.14 ) ) - 0.0) * (1.0 - _HorizonMinAmountAlways) / (1.0 - 0.0));
				float3 normalizeResult42 = normalize( ase_worldPos );
				float dotResult40 = dot( normalizeResult42 , float3( 0,1,0 ) );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult12 = dot( -worldSpaceLightDir , ase_worldViewDir );
				float InvVDotL200 = dotResult12;
				float temp_output_22_0 = min( _HorizonSunGlowSpreadMin , _HorizonSunGlowSpreadMax );
				float temp_output_23_0 = max( _HorizonSunGlowSpreadMin , _HorizonSunGlowSpreadMax );
				float clampResult14 = clamp( (0.0 + (InvVDotL200 - ( 1.0 - ( temp_output_22_0 * temp_output_22_0 ) )) * (1.0 - 0.0) / (( 1.0 - ( temp_output_23_0 * temp_output_23_0 ) ) - ( 1.0 - ( temp_output_22_0 * temp_output_22_0 ) ))) , 0.0 , 1.0 );
				float dotResult88 = dot( worldSpaceLightDir , float3( 0,-1,0 ) );
				float clampResult89 = clamp( dotResult88 , 0.0 , 1.0 );
				float TotalHorizonMask314 = ( ( ( 1.0 - HorizonScaleDayNight304 ) * HorizonGlowGlobalScale307 ) * saturate( pow( ( 1.0 - abs( dotResult40 ) ) , _HorizonSharpness ) ) * saturate( ( pow( ( 1.0 - clampResult14 ) , 5.0 ) * _HorizonGlowIntensity * ( 1.0 - clampResult89 ) ) ) );
				float4 lerpResult55 = lerp( SkyColor197 , HorizonColor313 , TotalHorizonMask314);
				float temp_output_2_0_g1 = TotalHorizonMask314;
				float temp_output_3_0_g1 = ( 1.0 - temp_output_2_0_g1 );
				float3 appendResult7_g1 = (float3(temp_output_3_0_g1 , temp_output_3_0_g1 , temp_output_3_0_g1));
				float3 temp_cast_1 = (_HorizonTintSunPower).xxx;
				float SunDiskSize286 = ( 1.0 - ( _SunDiskSize + _SunDiskSizeAdjust ) );
				float temp_output_262_0 = ( SunDiskSize286 * ( 1.0 - ( 0.99 + _SunDiskSharpness ) ) );
				float temp_output_75_0 = saturate( InvVDotL200 );
				float dotResult265 = dot( temp_output_75_0 , temp_output_75_0 );
				float smoothstepResult261 = smoothstep( ( SunDiskSize286 - temp_output_262_0 ) , ( SunDiskSize286 + temp_output_262_0 ) , dotResult265);
				float dotResult302 = dot( ase_worldPos.y , 1.0 );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float3 SunDisk203 = ( saturate( ( smoothstepResult261 * saturate( dotResult302 ) ) ) * ase_lightColor.a * ase_lightColor.rgb );
				float4 Sky175 = ( lerpResult55 + float4( ( pow( ( ( HorizonColor313.rgb * temp_output_2_0_g1 ) + appendResult7_g1 ) , temp_cast_1 ) * SunDisk203 ) , 0.0 ) );
				
				
				finalColor = Sky175;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16700
827;81;2603;829;2865.579;2464.119;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;205;-4328.524,-1856.158;Float;False;2352.849;723.3484;Comment;29;75;203;71;18;69;200;12;34;11;10;261;263;264;265;262;268;271;281;282;252;285;284;286;287;297;298;300;302;303;Sun Disk;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;206;-4306.389,-1003.857;Float;False;4121.021;1625.509;Comment;15;198;57;175;76;55;63;233;234;305;309;311;313;314;316;356;Horizon And Sun Glow;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;10;-4289.205,-1433.755;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;356;-4279.824,-167.2684;Float;False;2341.093;657.4434;Comment;23;62;19;90;15;17;89;16;32;14;88;13;87;201;27;29;28;26;25;24;23;22;20;21;Horizon Glow added from the sun;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;308;-2889.816,-2319.44;Float;False;1802.634;338.6813;Comment;10;213;221;215;220;222;212;216;223;244;307;Scalar that makes the horizon glow brighter when the sun is low, scales it out when the sun is down and directly above;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;199;-1825.911,-1816.734;Float;False;2030.075;565.4365;Comment;11;78;79;56;91;92;81;85;86;84;197;235;Sky Color Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;11;-4288.771,-1289.879;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;20;-4219.824,33.2516;Float;False;Property;_HorizonSunGlowSpreadMin;Horizon Sun Glow Spread Min;8;0;Create;True;0;0;False;0;5.075109;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-4229.824,122.2515;Float;False;Property;_HorizonSunGlowSpreadMax;Horizon Sun Glow Spread Max;9;0;Create;True;0;0;False;0;0;2.52;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1740.65,-1378.857;Float;False;Property;_NightTransitionScale;Night Transition Scale;11;0;Create;True;0;0;False;0;1;7.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;34;-4026.139,-1302.774;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;306;-4345.006,-2340.811;Float;False;1333.227;394.979;Scales the horizon glow depending on the direction of the sun.  If it's below the horizon it scales out faster;9;241;237;243;242;238;239;240;236;304;Horizon Daynight mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;212;-2839.816,-2269.44;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMinOpNode;22;-3914.826,22.25159;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;213;-2557.587,-2253.341;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;23;-3899.826,138.2514;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;12;-3853.616,-1301.558;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;236;-4236.198,-2290.811;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;-1429.327,-1372.926;Float;False;NightTransScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;243;-4295.005,-2060.831;Float;False;Property;_NightTransitionHorizonDelay;Night Transition Horizon Delay;12;0;Create;True;0;0;False;0;0;-4.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-3699.708,-1299.173;Float;False;InvVDotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;-4236.392,-2146.804;Float;False;235;NightTransScale;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-3763.826,11.25165;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;221;-2406.566,-2255.662;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-3751.826,140.2514;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;311;-4282.975,-560.9692;Float;False;1484.109;291.775;;8;59;51;47;46;44;40;42;41;Base Horizon Glow;1,1,1,1;0;0
Node;AmplifyShaderEditor.NegateNode;237;-3949.367,-2270.218;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-4291.081,-1575.761;Float;False;Property;_SunDiskSizeAdjust;Sun Disk Size Adjust;4;0;Create;True;0;0;False;0;0;0.00299;0;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;252;-4285.656,-1807.189;Float;False;Property;_SunDiskSize;Sun Disk Size;3;0;Create;True;0;0;False;0;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;41;-4228.346,-494.7657;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;215;-2214.217,-2265.927;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;238;-3798.68,-2278.003;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;242;-3947.212,-2138.988;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-3628.821,-110.7302;Float;False;200;InvVDotL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-3553.177,244.8518;Float;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-3555.777,160.3517;Float;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-3577.876,87.55197;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-2229.349,-2180.238;Float;False;Constant;_HideHorizonGlowScale;Hide Horizon Glow Scale;12;0;Create;True;0;0;False;0;4.14;4.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-3575.277,0.4519947;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;42;-4033.649,-463.454;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;87;-3309.25,228.3578;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;-3641.031,-2266.257;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-4015.29,-1428.623;Float;False;Property;_SunDiskSharpness;Sun Disk Sharpness;5;0;Create;True;0;0;False;0;0;0.0093;0;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;284;-3921.335,-1803.423;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;220;-1956.32,-2236.495;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;13;-3321.69,-47.08187;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;14;-3101.354,-47.41712;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;240;-3471.867,-2252.022;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;268;-3747.704,-1807.15;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;222;-1788.71,-2225.302;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-1918.605,-2095.759;Float;False;Property;_HorizonMinAmountAlways;Horizon Min Amount Always;13;0;Create;True;0;0;False;0;0;0.238;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;88;-3068.165,229.0258;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,-1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;282;-3736.616,-1623.981;Float;False;2;2;0;FLOAT;0.99;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;40;-3757.447,-464.7546;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;44;-3571.094,-457.9051;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-2938.803,-35.81703;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;75;-3452.344,-1367.051;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;-3307.78,-2256.349;Float;False;HorizonScaleDayNight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;-3526.744,-1801.192;Float;False;SunDiskSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;223;-1574.484,-2227.258;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3063.753,77.28284;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;271;-3532.888,-1614.416;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;89;-2936.466,224.2446;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;-3381.537,-444.7644;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;15;-2732.854,-73.21727;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-3514.3,-367.9907;Float;False;Property;_HorizonSharpness;Horizon Sharpness;7;0;Create;True;0;0;False;0;5.7;12.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;300;-2997.515,-1320.646;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;287;-3572.001,-1525.927;Float;False;286;SunDiskSize;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;90;-2781.34,217.5739;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;91;-1775.911,-1565.063;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;265;-3238.389,-1389.133;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;305;-4257.591,-878.2952;Float;False;304;HorizonScaleDayNight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;-1363.18,-2227.899;Float;False;HorizonGlowGlobalScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2870.218,66.3748;Float;False;Property;_HorizonGlowIntensity;Horizon Glow Intensity;6;0;Create;True;0;0;False;0;0.59;3.09;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-3289.488,-1798.923;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;297;-2964.791,-1521.468;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;302;-2742.125,-1300.483;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;-4248.517,-776.4443;Float;False;307;HorizonGlowGlobalScale;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-2512.698,-43.05833;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;51;-3213.856,-440.3124;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;263;-3073.256,-1669.06;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;264;-3072.201,-1798.589;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;92;-1489.081,-1544.47;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;234;-3960.059,-876.0325;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;261;-2902.857,-1720.626;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-3739.015,-824.0848;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;303;-2510.257,-1310.564;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;59;-2969.237,-465.6631;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;62;-2346.927,-49.23482;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;81;-1133.234,-1491.684;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;57;-1856.268,-889.3608;Float;False;Property;_HorizonColor;Horizon Color;1;0;Create;True;0;0;False;0;0.9137255,0.8509804,0.7215686,0;1,0.9080161,0.4274507,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1807.266,-707.8991;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-2686.678,-1671.808;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-952.139,-1438.906;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;316;-1892.409,-11.60108;Float;False;927.1527;431.4218;Comment;7;204;291;312;315;289;290;288;Tintint the sun with the horizon color for added COOL;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-1578.942,-722.1615;Float;False;TotalHorizonMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;-1583.498,-821.9012;Float;False;HorizonColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;84;-765.3903,-1387.547;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;79;-725.8815,-1587.034;Float;False;Property;_NightColor;Night Color;2;0;Create;True;0;0;False;0;0,0,0,0;0.09251461,0.09571571,0.1981127,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;18;-2537.239,-1562.841;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;56;-735.8195,-1766.734;Float;False;Property;_SkyColor;Sky Color;0;0;Create;True;0;0;False;0;0.3764706,0.6039216,1,0;0.1200142,0.3730588,0.8207547,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;69;-2504.536,-1662.316;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;-1827,35.13788;Float;False;313;HorizonColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;-1840.013,131.3501;Float;False;314;TotalHorizonMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-2337.559,-1656.973;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;78;-282.6812,-1487.833;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-38.83715,-1472.311;Float;False;SkyColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-1848.931,222.4503;Float;False;Property;_HorizonTintSunPower;Horizon Tint Sun Power;10;0;Create;True;0;0;False;0;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;289;-1573.055,79.37746;Float;False;Lerp White To;-1;;1;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-2187.953,-1662.295;Float;False;SunDisk;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-1566.107,-913.3846;Float;False;197;SkyColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;290;-1370.484,86.31239;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-1798.367,301.5597;Float;False;203;SunDisk;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;288;-1140.778,141.2002;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;55;-1273.505,-853.463;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-919.7489,-762.123;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-610.2654,-732.2576;Float;False;Sky;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-94.76877,-903.5953;Float;False;175;Sky;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;39;132.271,-911.8556;Float;False;True;2;Float;ASEMaterialInspector;0;1;DM/ProceduralSkybox;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;34;0;10;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;213;0;212;0
WireConnection;23;0;20;0
WireConnection;23;1;21;0
WireConnection;12;0;34;0
WireConnection;12;1;11;0
WireConnection;235;0;86;0
WireConnection;200;0;12;0
WireConnection;24;0;22;0
WireConnection;24;1;22;0
WireConnection;221;0;213;0
WireConnection;25;0;23;0
WireConnection;25;1;23;0
WireConnection;237;0;236;0
WireConnection;215;0;221;0
WireConnection;238;0;237;0
WireConnection;242;0;241;0
WireConnection;242;1;243;0
WireConnection;27;0;25;0
WireConnection;26;0;24;0
WireConnection;42;0;41;0
WireConnection;239;0;238;0
WireConnection;239;1;242;0
WireConnection;284;0;252;0
WireConnection;284;1;285;0
WireConnection;220;0;215;0
WireConnection;220;1;216;0
WireConnection;13;0;201;0
WireConnection;13;1;26;0
WireConnection;13;2;27;0
WireConnection;13;3;28;0
WireConnection;13;4;29;0
WireConnection;14;0;13;0
WireConnection;240;0;239;0
WireConnection;268;0;284;0
WireConnection;222;0;220;0
WireConnection;88;0;87;0
WireConnection;282;1;281;0
WireConnection;40;0;42;0
WireConnection;44;0;40;0
WireConnection;32;0;14;0
WireConnection;75;0;200;0
WireConnection;304;0;240;0
WireConnection;286;0;268;0
WireConnection;223;0;222;0
WireConnection;223;3;244;0
WireConnection;271;0;282;0
WireConnection;89;0;88;0
WireConnection;47;0;44;0
WireConnection;15;0;32;0
WireConnection;15;1;16;0
WireConnection;90;0;89;0
WireConnection;265;0;75;0
WireConnection;265;1;75;0
WireConnection;307;0;223;0
WireConnection;262;0;286;0
WireConnection;262;1;271;0
WireConnection;297;0;265;0
WireConnection;302;0;300;2
WireConnection;19;0;15;0
WireConnection;19;1;17;0
WireConnection;19;2;90;0
WireConnection;51;0;47;0
WireConnection;51;1;46;0
WireConnection;263;0;287;0
WireConnection;263;1;262;0
WireConnection;264;0;287;0
WireConnection;264;1;262;0
WireConnection;92;0;91;0
WireConnection;234;0;305;0
WireConnection;261;0;297;0
WireConnection;261;1;264;0
WireConnection;261;2;263;0
WireConnection;233;0;234;0
WireConnection;233;1;309;0
WireConnection;303;0;302;0
WireConnection;59;0;51;0
WireConnection;62;0;19;0
WireConnection;81;0;92;0
WireConnection;63;0;233;0
WireConnection;63;1;59;0
WireConnection;63;2;62;0
WireConnection;298;0;261;0
WireConnection;298;1;303;0
WireConnection;85;0;81;0
WireConnection;85;1;235;0
WireConnection;314;0;63;0
WireConnection;313;0;57;0
WireConnection;84;0;85;0
WireConnection;69;0;298;0
WireConnection;71;0;69;0
WireConnection;71;1;18;2
WireConnection;71;2;18;1
WireConnection;78;0;56;0
WireConnection;78;1;79;0
WireConnection;78;2;84;0
WireConnection;197;0;78;0
WireConnection;289;1;312;0
WireConnection;289;2;315;0
WireConnection;203;0;71;0
WireConnection;290;0;289;0
WireConnection;290;1;291;0
WireConnection;288;0;290;0
WireConnection;288;1;204;0
WireConnection;55;0;198;0
WireConnection;55;1;313;0
WireConnection;55;2;314;0
WireConnection;76;0;55;0
WireConnection;76;1;288;0
WireConnection;175;0;76;0
WireConnection;39;0;218;0
ASEEND*/
//CHKSM=462109A77E6AB573C0581DC6FDEA15504FCFF841