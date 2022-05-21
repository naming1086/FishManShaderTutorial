// create by JiepengTan 
// https://github.com/JiepengTan/FishManShaderTutorial
// date: 2018-03-27  
// email: jiepengtan@gmail.com
Shader "FishManShaderTutorial/2DFireParticle"{
	Properties{
	    _MainTex ("MainTex", 2D) = "white" {}
	    _Color ("_Color", Color) = (1.0,0.3,0.0,1.)
	    _GridSize ("SparkGridSize", float) = 30
	    _RotSpd ("_RotSpd", float) = 0.5
	    _YSpd ("_YSpd", float) = 0.7
		_size("size", float) = 0.7
	}

	SubShader
	{
	    Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

	    Pass
	    {
	        ZWrite Off
	        Blend SrcAlpha OneMinusSrcAlpha
			 
	        CGPROGRAM
	        #pragma vertex vert
	        #pragma fragment frag
			#include "ShaderLibs/Framework2D.cginc"
			
			float3 _Color;
			float _GridSize;
			float _RotSpd;
			float _YSpd;
			float _size;
			float3 ProcessFrag(float2 uv){
				float3 acc = float3(0.0,0.0,0.0);

				float rotDeg = 3.*_RotSpd * ftime;
				float yOffset = 4.*_YSpd * ftime;
				//整体沿y轴上升 注意是减去 
				float2 coord = uv * _GridSize - float2(0.,yOffset); 
				//让格子交错 这个交错很有趣 没看懂为什么要abs
				if (abs(fmod(coord.y,2.0))<1.0) 
					coord.x += 0.5;
				
				//gridIndex 根据ID 获取hash值 这里的ID会有负值
				float2 gridIndex = float2(floor(coord));
				float rnd = Hash12(gridIndex);
				
				// 弥补y轴上升的逆差 获取原来的y值 
				float tempY = gridIndex.y + yOffset ; 
				
				//smoothstep的方式解决了
				float percentY = clamp(tempY/_GridSize, 0.0, 1.0);
				float life = smoothstep(1.0, 0.0,percentY) - percentY * rnd * 0.5;


				if (life>0.0 ) {
					//圆
					float size = 0.08 * rnd;//让大小随机化
					float deg = 999.0 * rnd * 2.0 * PI + rotDeg * (0.5 + 0.5 * rnd);//添加旋转随机化
					float radius =  0.5- size * 0.2;
					float2 cirOffset = radius * float2(sin(deg),cos(deg));//单位圆旋转偏移
					
					float2 part = frac(coord-cirOffset) - 0.5 ;//让格子自己旋转起来 位置变 方向不变
					float len = length(part);

					float sparksGray = max(0.0, 1.0 - len/size);//画圆

					float sinval = sin(PI*1.*(0.3+0.7*rnd)*ftime+rnd*10.);//加点亮度的变化实现闪烁 
					float period = clamp(pow(pow(sinval,5.),5.),0.,1.);
					float blink =(0.8+0.8 * abs(period));
					acc = life * sparksGray * _Color * blink ;
				}
				return acc;
			}
	    ENDCG
	}//end pass
  }//end SubShader
}//end Shader

