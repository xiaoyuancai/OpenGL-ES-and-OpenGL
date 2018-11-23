#version 330 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

//GLSL有一个供纹理对象使用的内建数据类型，叫做采样器(Sampler)，它以纹理类型作为后缀，比如sampler1D、sampler3D，或在我们的例子中的sampler2D。我们可以简单声明一个uniform sampler2D把一个纹理添加到片段着色器中，稍后我们会把纹理赋值给这个uniform。
//uniform sampler2D ourTexture;

//多个纹理
uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
//    FragColor = vec4(ourColor, 1.0f);
//    FragColor = texture(ourTexture, TexCoord);//使用纹理
//    FragColor = texture(ourTexture, TexCoord)*vec4(ourColor, 1.0f);//纹理颜色与顶点颜色混合
    //我们使用GLSL内建的texture函数来采样纹理的颜色，它第一个参数是纹理采样器，第二个参数是对应的纹理坐标。texture函数会使用之前设置的纹理参数对相应的颜色值进行采样。这个片段着色器的输出就是纹理的（插值）纹理坐标上的(过滤后的)颜色。
    
    //多个纹理，此处最终输出颜色现在是两个纹理的结合
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
    
    //GLSL内建的mix函数需要接受两个值作为参数，并对它们根据第三个参数进行线性插值。如果第三个值是0.0，它会返回第一个输入；如果是1.0，会返回第二个输入值。0.2会返回80%的第一个输入颜色和20%的第二个输入颜色，即返回两个纹理的混合色。
}
