// create by JiepengTan 
// https://github.com/JiepengTan/FishManShaderTutorial
// date: 2018-03-27  
// email: jiepengtan@gmail.com
Shader "FishManShaderTutorial/2DSnow"{
	Properties{
	    _MainTex ("MainTex", 2D) = "white" {}
		SIZE_RATE ("SIZE_RATE", float) = 0.1
		XSPEED ("XSPEED", float) = 0.2
		YSPEED ("YSPEED", float) = 0.5
		LAYERS ("LAYERS", float) = 10
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

			float SIZE_RATE;
			float XSPEED;
			float YSPEED;
			float LAYERS;

			float3 SnowSingleLayer(float2 uv,float layer){
				fixed3 acc = fixed3(0.0,0.0,0.0);//��ѩ���Ĵ�С�仯
				uv = uv * (2.0+layer);//͸����Ұ���Ч��

				//��������ƫ��
			    float xOffset = uv.y * ((Hash11(layer)*2.0-1.0)*XSPEED);//������ƫ����������x���ƶ�
			    float yOffset = (YSPEED*ftime);//y���������
				uv += fixed2(xOffset,yOffset);

				//ÿ��������id Ȼ������Ϊ 0,0
				float2 rgrid = Hash22(floor(uv)+(31.1759*layer));
				uv = frac(uv);
				uv -= (rgrid*2-1.0) * 0.35;
				uv -=0.5;

				//
				float r = length(uv);
				float circleSize = 0.05*(1.0+0.3*sin(ftime*SIZE_RATE));//�ô�С�仯��
				float val = smoothstep(circleSize,-circleSize,r);
				float3 col = float3(val,val,val)* rgrid.x ;
				return col;
			}
			float3 Snow(float2 uv){
				float3 acc = float3(0,0,0);
				for (fixed i=0.;i<LAYERS;i++) {
					acc += SnowSingleLayer(uv,i); 
				}
				return acc;
			}
			float3 ProcessFrag(float2 uv)  {
				uv *= float2(_ScreenParams.x/_ScreenParams.y,1.0);
				return Snow(uv);
            }
	    ENDCG
	}//end pass
  }//end SubShader
}//end Shader

