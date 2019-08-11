//
//  NuoModelCube.hpp
//  ModelViewer
//
//  Created by middleware on 5/22/17.
//  Copyright © 2017 middleware. All rights reserved.
//

#ifndef NuoModelBoard_hpp
#define NuoModelBoard_hpp


#include "NuoModelBase.h"
#include "NuoModelTextured.h"


template <class ItemBase>
class NuoModelBoardBase : virtual public NuoModelCommon<ItemBase>
{
    enum
    {
        kCorner_TL,
        kCorner_TR,
        kCorner_BL,
        kCorner_BR
    }
    kCorner;
    
public:
    
    float _width;
    float _height;
    float _thickness;
    
    NuoModelBoardBase(float width, float height, float thickness);
    
    virtual void CreateBuffer();
    
private:
    
    
};



class NuoModelBoard : virtual public NuoModelBoardBase<NuoItemSimple>,
                      virtual public NuoModelSimple
{
    
public:
    
    NuoModelBoard(float width, float height, float thickness);
    
    virtual NuoGlobalBuffers GetGlobalBuffers() const override;
    
};




typedef std::shared_ptr<NuoModelBoard> PNuoModelBoard;





class NuoModelBackDrop : virtual public NuoModelBoardBase<NuoItemTextured>,
                         virtual public NuoModelTextureBase<NuoItemTextured>
{

public:
    
    NuoModelBackDrop(float width, float height, float thickness);
    NuoModelBackDrop(const NuoModelBackDrop& other);
    
    IMPL_CLONE(NuoModelBackDrop);
    
    virtual void AddMaterial(const NuoMaterial& material) override;
    virtual NuoMaterial GetMaterial(size_t primtiveIndex) const override;
    virtual bool HasTransparent() override;
    virtual std::shared_ptr<NuoMaterial> GetUnifiedMaterial() override;
    virtual void UpdateBufferWithUnifiedMaterial() override;
    
    virtual void GenerateTangents() override;
    
    virtual void SetTexturePathBump(const std::string texPath) override;
    virtual std::string GetTexturePathBump() override;
    
};




template <class ItemBase>
NuoModelBoardBase<ItemBase>::NuoModelBoardBase(float width, float height, float thickness)
    : _width(width), _height(height), _thickness(thickness)
{
}


template <class ItemBase>
void NuoModelBoardBase<ItemBase>::CreateBuffer()
{
    NuoVectorFloat2 corners[4];
    
    corners[kCorner_BL].x(-_width / 2.0);
    corners[kCorner_BL].y(-_height / 2.0);
    
    corners[kCorner_BR].x(_width / 2.0);
    corners[kCorner_BR].y(-_height / 2.0);
    
    corners[kCorner_TL].x(-_width / 2.0);
    corners[kCorner_TL].y(_height / 2.0);
    
    corners[kCorner_TR].x(_width / 2.0);
    corners[kCorner_TR].y(_height / 2.0);
    
    std::vector<float> bufferPosition(9), bufferNormal(3), bufferTexCoord(6);
    float halfHeight = _thickness / 2.0;
    
    // top-half
    bufferPosition[0] = corners[kCorner_TL].x();
    bufferPosition[1] = corners[kCorner_TL].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_BL].x();
    bufferPosition[4] = corners[kCorner_BL].y();
    bufferPosition[5] = halfHeight;
    bufferPosition[6] = corners[kCorner_TR].x();
    bufferPosition[7] = corners[kCorner_TR].y();
    bufferPosition[8] = halfHeight;
    
    bufferNormal[0] = 0;
    bufferNormal[1] = 0;
    bufferNormal[2] = 1;
    
    bufferTexCoord[0] = 0.0;
    bufferTexCoord[1] = 0.0;
    bufferTexCoord[2] = 0.0;
    bufferTexCoord[3] = 1.0;
    bufferTexCoord[4] = 1.0;
    bufferTexCoord[5] = 0.0;
    
    this->AddPosition(0, bufferPosition);
    this->AddTexCoord(0, bufferTexCoord);
    this->AddNormal(0, bufferNormal);
    this->AddPosition(1, bufferPosition);
    this->AddTexCoord(1, bufferTexCoord);
    this->AddNormal(0, bufferNormal);
    this->AddPosition(2, bufferPosition);
    this->AddTexCoord(2, bufferTexCoord);
    this->AddNormal(0, bufferNormal);
    
    // top-half
    bufferPosition[0] = corners[kCorner_TR].x();
    bufferPosition[1] = corners[kCorner_TR].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_BL].x();
    bufferPosition[4] = corners[kCorner_BL].y();
    bufferPosition[5] = halfHeight;
    bufferPosition[6] = corners[kCorner_BR].x();
    bufferPosition[7] = corners[kCorner_BR].y();
    bufferPosition[8] = halfHeight;
    
    bufferTexCoord[0] = 1.0;
    bufferTexCoord[1] = 0.0;
    bufferTexCoord[2] = 0.0;
    bufferTexCoord[3] = 1.0;
    bufferTexCoord[4] = 1.0;
    bufferTexCoord[5] = 1.0;
    
    this->AddPosition(0, bufferPosition);
    this->AddTexCoord(0, bufferTexCoord);
    this->AddNormal(0, bufferNormal);
    this->AddPosition(1, bufferPosition);
    this->AddTexCoord(1, bufferTexCoord);
    this->AddNormal(0, bufferNormal);
    this->AddPosition(2, bufferPosition);
    this->AddTexCoord(2, bufferTexCoord);
    this->AddNormal(0, bufferNormal);
    
    // bottom-half
    bufferPosition[0] = corners[kCorner_TL].x();
    bufferPosition[1] = corners[kCorner_TL].y();
    bufferPosition[2] = -halfHeight;
    bufferPosition[3] = corners[kCorner_TR].x();
    bufferPosition[4] = corners[kCorner_TR].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_BL].x();
    bufferPosition[7] = corners[kCorner_BL].y();
    bufferPosition[8] = -halfHeight;
    
    bufferNormal[0] = 0;
    bufferNormal[1] = 0;
    bufferNormal[2] = -1;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // bottom-half
    bufferPosition[0] = corners[kCorner_TR].x();
    bufferPosition[1] = corners[kCorner_TR].y();
    bufferPosition[2] = -halfHeight;
    bufferPosition[3] = corners[kCorner_BR].x();
    bufferPosition[4] = corners[kCorner_BR].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_BL].x();
    bufferPosition[7] = corners[kCorner_BL].y();
    bufferPosition[8] = -halfHeight;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // front-half
    bufferPosition[0] = corners[kCorner_BL].x();
    bufferPosition[1] = corners[kCorner_BL].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_BL].x();
    bufferPosition[4] = corners[kCorner_BL].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_BR].x();
    bufferPosition[7] = corners[kCorner_BR].y();
    bufferPosition[8] = halfHeight;
    
    bufferNormal[0] = 0;
    bufferNormal[1] = -1;
    bufferNormal[2] = 0;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // front-half
    bufferPosition[0] = corners[kCorner_BR].x();
    bufferPosition[1] = corners[kCorner_BR].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_BL].x();
    bufferPosition[4] = corners[kCorner_BL].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_BR].x();
    bufferPosition[7] = corners[kCorner_BR].y();
    bufferPosition[8] = -halfHeight;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // left-half
    bufferPosition[0] = corners[kCorner_TL].x();
    bufferPosition[1] = corners[kCorner_TL].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_TL].x();
    bufferPosition[4] = corners[kCorner_TL].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_BL].x();
    bufferPosition[7] = corners[kCorner_BL].y();
    bufferPosition[8] = halfHeight;
    
    bufferNormal[0] = -1;
    bufferNormal[1] = 0;
    bufferNormal[2] = 0;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // left-half
    bufferPosition[0] = corners[kCorner_BL].x();
    bufferPosition[1] = corners[kCorner_BL].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_TL].x();
    bufferPosition[4] = corners[kCorner_TL].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_BL].x();
    bufferPosition[7] = corners[kCorner_BL].y();
    bufferPosition[8] = -halfHeight;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // right-half
    bufferPosition[0] = corners[kCorner_BR].x();
    bufferPosition[1] = corners[kCorner_BR].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_BR].x();
    bufferPosition[4] = corners[kCorner_BR].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_TR].x();
    bufferPosition[7] = corners[kCorner_TR].y();
    bufferPosition[8] = halfHeight;
    
    bufferNormal[0] = 1;
    bufferNormal[1] = 0;
    bufferNormal[2] = 0;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // right-half
    bufferPosition[0] = corners[kCorner_TR].x();
    bufferPosition[1] = corners[kCorner_TR].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_BR].x();
    bufferPosition[4] = corners[kCorner_BR].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_TR].x();
    bufferPosition[7] = corners[kCorner_TR].y();
    bufferPosition[8] = -halfHeight;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // back-half
    bufferPosition[0] = corners[kCorner_TR].x();
    bufferPosition[1] = corners[kCorner_TR].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_TR].x();
    bufferPosition[4] = corners[kCorner_TR].y();
    bufferPosition[5] = -halfHeight;
    bufferPosition[6] = corners[kCorner_TL].x();
    bufferPosition[7] = corners[kCorner_TL].y();
    bufferPosition[8] = -halfHeight;
    
    bufferNormal[0] = 0;
    bufferNormal[1] = 1;
    bufferNormal[2] = 0;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    // back-half
    bufferPosition[0] = corners[kCorner_TL].x();
    bufferPosition[1] = corners[kCorner_TL].y();
    bufferPosition[2] = halfHeight;
    bufferPosition[3] = corners[kCorner_TR].x();
    bufferPosition[4] = corners[kCorner_TR].y();
    bufferPosition[5] = halfHeight;
    bufferPosition[6] = corners[kCorner_TL].x();
    bufferPosition[7] = corners[kCorner_TL].y();
    bufferPosition[8] = -halfHeight;
    
    NuoModelCommon<ItemBase>::AddPosition(0, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(1, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    NuoModelCommon<ItemBase>::AddPosition(2, bufferPosition);
    NuoModelCommon<ItemBase>::AddNormal(0, bufferNormal);
    
    NuoModelCommon<ItemBase>::GenerateIndices();
}



#endif /* NuoModelCube_hpp */
