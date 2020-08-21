//
//  TriangleTypes.h
//  MetalSimpleExample
//
//  Created by trs on 2020/8/21.
//  Copyright © 2020 ctair. All rights reserved.
//

#ifndef TriangleTypes_h
#define TriangleTypes_h

typedef enum TriangleVertexInputIndex{
    // 顶点
    TriangleVertexInputIndexVertices = 0,
    // 视图大小
    TriangleVertexInputIndexViewpostSize = 1,
}TriangleVertexInputIndex;

//结构体: 顶点/颜色值
typedef struct {
    // 像素空间的位置
    // 像素中心点(100,100)
    vector_float4 position;
    
    // RGBA颜色
    vector_float4 color;
} TriangleVertex;

#endif /* TriangleTypes_h */
