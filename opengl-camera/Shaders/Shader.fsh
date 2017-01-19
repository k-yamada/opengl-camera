//
//  Shader.fsh
//  opengl-camera
//
//  Created by kyamada on 2017/01/19.
//  Copyright © 2017年 kyamada. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
