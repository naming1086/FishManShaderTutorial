// create by JiepengTan 
// https://github.com/JiepengTan/FishManShaderTutorial
// date: 2018-03-27  
// email: jiepengtan@gmail.com
Shader "FishManShaderTutorial/BaseMath"{
	Properties{
	    _MainTex ("MainTex", 2D) = "white" {}
	}

	SubShader
	{
	    Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

	    Pass
	    {
	        ZWrite Off
	        Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

	        CGPROGRAM
	        #pragma vertex vert
	        #pragma fragment frag
			#define USING_PERLIN_NOISE 1
			#include "ShaderLibs/Framework2D.cginc"
	
			//很有意思的是 这里可以直接调用对应的函数 跟委托差不多
			#define DrawInGrid(uv,DRAW_FUNC)\
				{\
					float2 pFloor = floor(uv);\ 
					if(length(pFloor-float2(j,i))<0.001){\ //就是等于的意思 没直接用 = 符号
						col = DRAW_FUNC(frac(uv)-0.5);\ //直接是取中心点 uv
					}\
					num = num + 1.000;\
					i=floor(num / gridSize); j=fmod(num,gridSize);\ //floor的方式代表着是行数 fmod的方式代表的是列数 也就是余数
				}\

			//逐像素 逐像素就好思考了
			float3 DrawSmoothstep(float2 uv){
				uv+=0.5;
				float val = smoothstep(0.0,1.0,uv.x);
				val = step(abs(val-uv.y),0.01); 
				return float3(val,val,val);
			}

			//length 中心是暗的 所以 1- length uv 中心就是亮了
			float3 DrawCircle(float2 uv){
				float val = clamp((1.0-length(uv)*2),0.,1.);
				return val;
			}

			//暂是不考虑
			float3 DrawFlower(float2 uv){
				float deg = atan2(uv.y,uv.x) + _Time.y * -0.1;
				float len = length(uv)*3.0;
				float offs = abs(sin(deg*3.))*0.35;
				return smoothstep(1.+offs,1.+offs-0.05,len);
			}

			//pow 把效果拉低了
			float3 DrawWeakCircle(float2 uv){
				float val = clamp((1.0-length(uv)*2),0.,1.);
				val = pow(val,2.0);
				return float3(val,val,val);
			}

			//把效果拉高了
			float3 DrawStrongCircle(float2 uv){
				float val = clamp((1.0-length(uv)*2),0.,1.);
				val = pow(val,0.5);
				return float3(val,val,val);
			}

			//基本没啥问题
			float3 DrawBounceBall(float2 uv){
				uv*=4.; //[-4,+4]
				uv.y+=sin(ftime*PI); //不清楚为什么这么做
				float val = clamp((1.0-length(uv)),0.,1.);
				val = smoothstep(0.,0.5,val); //step都是返回 0/1
				return float3(val,val,val);
			}

			//
			float3 DrawRandomColor(float2 uv){
				uv+=0.5;
				uv*=4.;
				return Hash32(floor(uv)); //用上了floor 看起来hash32 也类似字典一样 相同的输入 返回相同的数据
			}
			//
			float3 DrawNoise(float2 uv){
				uv*=4.;
				float val =(PNoise(uv)+1.0)*0.5; //这里是因为Pnoise是返回的是[-1,1]
				return float3(val,val,val);
			}

			//
			float3 DrawFBM(float2 uv){
				uv*=4.;
				float val = (FBM(uv)+1.0)*0.5; //FBM多层叠加
				return float3(val,val,val);
			}
			
			//通过frac和 < > 来划线
			float3 DrawGridLine(float2 uv){
				float2 _uv = uv -floor(uv); //这样能重新为0-1 floor(uv) - uv本身 
				// float2 _uv = frac(uv); //当然好像frac也可以这么做
				float val = 0.;
				//初始位置
				const float eps = 0.01; //在初始位置为1 
				if(_uv.x<eps||_uv.y<eps){
					val = 1.;
				}
				//最终位置 
				const float eps2 = 0.99; //在初始位置为1 
				if(_uv.x>eps2||_uv.y>eps2){
					val = 1.;
				}
				return float3(val,val,val);
			}

			float3 ProcessFrag(float2 uv)  {
				
			    float3 col = float3(0.0,0.0,0.0);

				//这几个参数是给DrawInGrid用的 暂时不知道为啥可以这么用
				float num = 0.;
				float gridSize = 3.;
				float i =0.,j=0.;
				uv*=gridSize;

				//注意 DrawInGrid 是define
				DrawInGrid(uv,DrawSmoothstep);
				DrawInGrid(uv,DrawCircle);
				DrawInGrid(uv,DrawFlower);
				DrawInGrid(uv,DrawWeakCircle);
				DrawInGrid(uv,DrawStrongCircle);
				DrawInGrid(uv,DrawBounceBall);
				DrawInGrid(uv,DrawRandomColor);
				DrawInGrid(uv,DrawNoise);
				DrawInGrid(uv,DrawFBM);

				//这个是单纯画线的
				col +=DrawGridLine(uv);
				return col;			
			}
	    ENDCG
	}//end pass
  }//end SubShader
}//end Shader

