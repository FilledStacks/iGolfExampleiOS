//
//  ElevationMap.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "ElevationMap.h"
#import <CoreLocation/CoreLocation.h>
#import <math.h>
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

#import "../IGolfViewer3DPrivateImports.h"

@interface ElevationMap() {

    double _maxLatitude;
    double _maxLongitude;
    double _minLongitude;
    double _minLatitude;
    double _maxHeight;
    double _minHeight;
    double _step;
    double _maxHeightGL;
    double xPointsInTile;
    double yPointsInTile;
    double tilesXCount;
    double tilesYCount;
    
    int _mapHeight;
    int _mapWidth;
    
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    GLuint _indexBuffer;
    GLuint _normalBuffer;
    GLuint _numVertices;
    
    NSArray *_elevationArray;
    
    NSMutableArray* _vertex2DArray;
    NSMutableArray<Vertex*>* _vertexArray;
    
    GLKTextureInfo* _texture;
    GLKTextureInfo* _textureFlyover;
    
    NSMutableArray* _tiles;
    NSMutableArray* _tiles2D;
    NSMutableArray* _redrawTiles;

    NSMutableArray* _borderTiles;

    NSMutableArray* _vertexList;
    NSMutableArray* _indexList;
    NSMutableArray* _uvList;
    NSMutableArray* _normalList;

    int _currentTileX;
    int _currentTileY;

    TextureQuality _defaultTextureQuality;
    NSString* _groudFlyoverTextureName;
    NSString* _groudTextureName;
    GLKVector4 _lightPosition;
}
@end

@implementation ElevationMap

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_maxLatitude = 0;
        self->_minLongitude = 0;
        self->_step = 0;
        self->_elevationArray = [NSArray new];
        self->_vertex2DArray = [NSMutableArray new];
        self->_vertexArray = [NSMutableArray new];
        self->_borderTiles = [NSMutableArray new];
        self->_mapHeight = 0;
        self->_mapWidth = 0;
        self->_maxLongitude = 0;
        self->_maxHeight = 0;
    }
    return self;
}

- (id)initWithJsonObject:(NSDictionary*)jsonObject andTextureQuality:(TextureQuality)textureQuality andTextureProfile:(TextureProfile*)textureProfile; {
    self = [self init];
    
    Profiler* initProf = [[Profiler alloc] init];
    self->_maxLatitude = [[jsonObject objectForKey:@"maxLatitude"] doubleValue];
    self->_minLongitude = [[jsonObject objectForKey:@"minLongitude"] doubleValue];
    self->_step = [[jsonObject objectForKey:@"step"] doubleValue];
    self->_elevationArray = [jsonObject objectForKey:@"elevationArray"];
    self->_redrawTiles = [NSMutableArray new];
    self->_groudTextureName = textureProfile.backgroundTexture3DName;
    self->_groudFlyoverTextureName = textureProfile.flyoverTextureName;
    NSArray *firstRow = _elevationArray[0];
    
    self->_mapWidth = (int)[firstRow count];
    self->_mapHeight = (int)[_elevationArray count];
    self->_maxLongitude = _minLongitude + _step * (_mapWidth - 1);
    self->_minLatitude = _maxLatitude - _step * (_mapHeight - 1);
    self->_maxHeight = [firstRow[0] doubleValue];
    self->_minHeight = [firstRow[0] doubleValue];
    self->_currentTileX = -1;
    self->_currentTileY = -1;
    self-> _defaultTextureQuality = textureQuality;
    [self makeVertices];
    self->_lightPosition = [self calculateLightPosition];
    [self makeTiles];
    [self makeBorderTiles: textureProfile];
    
    
    [initProf stopWithMessage:@"ELEVATION MAP INITIALIZATION TIME"];
    
    return self;
}

- (void)makeBorderTiles:(TextureProfile*)textureProfile; {
    
    NSMutableArray* leftAlts = [NSMutableArray new];
    NSMutableArray* rightAlts = [NSMutableArray new];
    NSMutableArray* topAlts = [NSMutableArray new];
    NSMutableArray* bottomAlts = [NSMutableArray new];
    
    NSMutableArray* leftMap = [NSMutableArray new];
    NSMutableArray* rightMap = [NSMutableArray new];
    NSMutableArray* topMap = [NSMutableArray new];
    NSMutableArray* bottomMap = [NSMutableArray new];
    
    
    int borderTilePointsCount = 2;
    
    for (int y = 0; y < _mapHeight; y++) {
        double leftAlt = [[[_elevationArray objectAtIndex:y] objectAtIndex:0] doubleValue];
        double rightAlt = [[[_elevationArray objectAtIndex:y] objectAtIndex:_mapWidth - 1] doubleValue];
        [leftAlts addObject:@(leftAlt)];
        [rightAlts addObject:@(rightAlt)];
    }
    
    for (int x = 0; x < _mapWidth; x++) {
        double topAlt = [[[_elevationArray objectAtIndex:0] objectAtIndex:x] doubleValue];
        double bottomAlt = [[[_elevationArray objectAtIndex:_mapHeight - 1] objectAtIndex:x] doubleValue];
        [topAlts addObject:@(topAlt)];
        [bottomAlts addObject:@(bottomAlt)];
    }
    
    //LEFT BORDER
    
    for (int y = 0; y < leftAlts.count; y ++) {
        
        double currentHeight = [leftAlts[y] doubleValue];
        
        NSMutableArray* mapRow = [NSMutableArray new];
        
        for (int x = 0; x < borderTilePointsCount; x++) {
            
            double step = (currentHeight - _minHeight) / (double)(borderTilePointsCount - 1);
            
            double height = _minHeight + step * (double)x;
            
            if (y == 0 && x != borderTilePointsCount - 1) {
                [topAlts insertObject:@(height) atIndex:x];
            }
            
            if (y == leftAlts.count - 1 && x != borderTilePointsCount - 1) {
                [bottomAlts insertObject:@(height) atIndex:x];
            }

            double longitude = _minLongitude - _step * (((double)borderTilePointsCount - 1)-x);
            double latitude = _maxLatitude - _step * (double)y;
            
            double _x = [Layer transformLonFromDouble:longitude];
            double _y = [Layer transformLatFromDouble:latitude];
            double _z = (height - _minHeight) * METERS_IN_POINT;

            [mapRow addObject:[[Vertex alloc]initWithX:_x Y:_y Z:_z]];
        }
        
        [leftMap addObject:mapRow];
    }
    
    //RIGHT BORDER
    
    for (int y = 0; y < rightAlts.count; y ++) {
        
        double currentHeight = [rightAlts[y] doubleValue];
        
        NSMutableArray* mapRow = [NSMutableArray new];
        
        for (int x = 0; x < borderTilePointsCount; x++) {
            
            double step = (currentHeight - _minHeight) / (double)(borderTilePointsCount - 1);
            
            double height = (currentHeight - step * (double)x);
            
            double revHeight = height;
            
            if (y == 0 && x != 0) {
                [topAlts insertObject:@(revHeight) atIndex:topAlts.count];
            }
            
            if (y == rightAlts.count - 1 && x != 0) {
                [bottomAlts insertObject:@(revHeight) atIndex:bottomAlts.count];
            }
            
            double longitude = _maxLongitude + _step * (double)x;
            double latitude = _maxLatitude - _step * (double)y;
            
            double _x = [Layer transformLonFromDouble:longitude];
            double _y = [Layer transformLatFromDouble:latitude];
            double _z = (height - _minHeight) * METERS_IN_POINT;
            
            [mapRow addObject:[[Vertex alloc]initWithX:_x Y:_y Z:_z]];
        }
        
        [rightMap addObject:mapRow];
    }
    
    //TOP BORDER
    
    for (int y = borderTilePointsCount - 1; y >= 0; y--) {
    
        NSMutableArray* mapRow = [NSMutableArray new];
        
        for (int x = 0; x < topAlts.count; x ++) {
            double currentHeight = [topAlts[x] doubleValue];
            
            
            
            double step = (currentHeight - _minHeight) / (double)(borderTilePointsCount - 1);
            
            double height = currentHeight - (step * y);
            
            double longitude = _minLongitude + _step * (double)(x - borderTilePointsCount + 1);
            double latitude = _maxLatitude + _step * (double)y;
            
            double _x = [Layer transformLonFromDouble:longitude];
            double _y = [Layer transformLatFromDouble:latitude];
            double _z = (height - _minHeight) * METERS_IN_POINT;
            
            [mapRow addObject:[[Vertex alloc]initWithX:_x Y:_y Z:_z]];
        }
        [topMap addObject:mapRow];
    }
    
    //BOTTOM BORDER

    for (int y = 0; y < borderTilePointsCount; y++) {

        NSMutableArray* mapRow = [NSMutableArray new];
        
        for (int x = 0; x < bottomAlts.count; x ++) {
            double currentHeight = [bottomAlts[x] doubleValue];
            double step = (currentHeight - _minHeight) / ((double)borderTilePointsCount - 1);
            
            double height = currentHeight - (step * y);
            
            double longitude = _minLongitude + _step * (double)(x - borderTilePointsCount + 1);
            double latitude = _minLatitude - _step * (double)y;
            
            double _x = [Layer transformLonFromDouble:longitude];
            double _y = [Layer transformLatFromDouble:latitude];
            double _z = (height - _minHeight) * METERS_IN_POINT;
            
            [mapRow addObject:[[Vertex alloc]initWithX:_x Y:_y Z:_z]];
        }
        
        [bottomMap addObject:mapRow];
    }

    [_borderTiles addObject:[[BorderTile alloc]initWithVertexArray:leftMap andLightPosition:_lightPosition andTextureProfile:textureProfile]];
    [_borderTiles addObject:[[BorderTile alloc]initWithVertexArray:rightMap andLightPosition:_lightPosition andTextureProfile:textureProfile]];
    [_borderTiles addObject:[[BorderTile alloc]initWithVertexArray:topMap andLightPosition:_lightPosition andTextureProfile:textureProfile]];
    [_borderTiles addObject:[[BorderTile alloc]initWithVertexArray:bottomMap andLightPosition:_lightPosition andTextureProfile:textureProfile]];
}

- (void)makeVertices {

    Profiler* prof = [[Profiler alloc] init];
    [Layer setBaseLatitude:_maxLatitude andBaseLongitude:_minLongitude];
    
    NSMutableArray* indexList = [NSMutableArray new];
    
    for (int y = 0 ; y < _mapHeight ; y++) {
        for (int x = 0 ; x < _mapWidth ; x++) {
            NSArray *row = _elevationArray[y];
            double h = [row[x] doubleValue];
            _maxHeight = MAX(_maxHeight, h);
            _minHeight = MIN(_minHeight, h);
        }
    }
    
    _maxHeightGL = (_maxHeight - _minHeight) * METERS_IN_POINT;
    
    for (int y = 0 ; y < _mapHeight ; y++) {
        NSMutableArray* vertexRow = [NSMutableArray new];
        for (int x = 0 ; x < _mapWidth ; x++) {
            NSArray *row = _elevationArray[y];
            
            double latitude = _maxLatitude - _step * y;
            double longitude = _minLongitude + _step * x;
            double heightMeters = [row[x] doubleValue];
            
            CGFloat _x = [Layer transformLonFromDouble:longitude];
            CGFloat _y = [Layer transformLatFromDouble:latitude];
            CGFloat _z = (heightMeters - _minHeight) * METERS_IN_POINT;
            
            Vertex* vertex = [[Vertex alloc] initWithX:_x Y:_y Z:_z];
            
            [vertexRow addObject:vertex];
            
            [_vertexArray addObject:vertex];
        }
        
        [_vertex2DArray addObject:vertexRow];
    }
    
    for (int i = 0; i <= _mapHeight - 2; i++) {
        for (int j = 0; j <= _mapWidth - 2; j++) {
            
            Vertex* v1;
            Vertex* v2;
            Vertex* v3;
            Vector* normal;

            int t = j + i * _mapWidth;

            [indexList addObject:@(t + _mapWidth + 1)];
            [indexList addObject:@((t + 1))];
            [indexList addObject:@(t)];

            v1 = [_vertexArray objectAtIndex:(t + _mapWidth + 1)];
            v2 = [_vertexArray objectAtIndex:(t + 1)];
            v3 = [_vertexArray objectAtIndex:(t)];
        
            normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];

            [v1 setNormalVector: normal];
            [v2 setNormalVector: normal];
            [v3 setNormalVector: normal];

            [indexList addObject:@(t + _mapWidth)];
            [indexList addObject:@((t + _mapWidth + 1))];
            [indexList addObject:@(t)];

            v1 = [_vertexArray objectAtIndex:(t + _mapWidth)];
            v2 = [_vertexArray objectAtIndex:(t + _mapWidth + 1)];
            v3 = [_vertexArray objectAtIndex:(t)];
            
            normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];

            [v1 setNormalVector: normal];
            [v2 setNormalVector: normal];
            [v3 setNormalVector: normal];
        }
    }
    
    NSMutableArray* vertexList = [NSMutableArray new];
    NSMutableArray* uvList = [NSMutableArray new];
    NSMutableArray* normalList = [NSMutableArray new];
    
    for (Vertex* vertex in _vertexArray) {
        [vertexList addObject:@(vertex.vector.x)];
        [vertexList addObject:@(vertex.vector.y)];
        [vertexList addObject:@(vertex.vector.z)];
        
        [uvList addObject:@(vertex.vector.x)];
        [uvList addObject:@(vertex.vector.y)];
        
        [normalList addObject:@(vertex.normalVector.x)];
        [normalList addObject:@(vertex.normalVector.y)];
        [normalList addObject:@(vertex.normalVector.z)];
    }
    
    _vertexList     = vertexList;
    _uvList         = uvList;
    _normalList     = normalList;
    _indexList      = indexList;
    
    _vertexBuffer   = [GLHelper getBuffer:_vertexList];
    _uvBuffer       = [GLHelper getBuffer:_uvList];
    _indexBuffer    = [GLHelper getIndexBuffer:_indexList];
    
    _normalBuffer   = [GLHelper getBuffer:_normalList];
    _numVertices    = (int)_indexList.count;
    
    _texture        = [GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:_groudTextureName ofType:@"png"]];
    _textureFlyover        = [GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:_groudFlyoverTextureName ofType:@"png"]];
    [prof stopWithMessage:@"makeVertices"];
}


-(NSArray<DrawTile*>*)getCurrentTiles {
    
    NSMutableArray<DrawTile*>* retval = [NSMutableArray new];
    
    for (DrawTile* tile in _tiles) {
        if ([tile getTextureQuality] != TextureQualityNone) {
            [retval addObject:tile];
        }
    }
    
    return retval;
}

-(NSMutableArray *)getTiles {
    return _tiles;
}

-(void)setCurrentTileWithPosition:(Vector*)position andCamera:(Camera*)camera {
    double indexX;
    double indexY;
    
    double _x = position.x;
    double _y = position.y;
    
    double latitude = [Layer transformToLatWithDouble:-_y];
    double longitude = [Layer transformToLonWithDouble:-_x];
    
    int x;
    int y;
    
    indexX = ((longitude - _minLongitude)/ _step);
    indexY = ((_maxLatitude - latitude) / _step);
    
    x = floor((indexX - 1) / (xPointsInTile - 1));
    y = floor((indexY - 1) / (yPointsInTile - 1));
    
//    if (y >= 0 && y < tileYCount && x >= 0 && x < tileXCount)
//        setCurrentTile(x, y, getRotationAngle((int) (renderer.rotationAngle < 0 ? 360f + renderer.rotationAngle : renderer.rotationAngle)), renderer);
//    else {
//        setCurrentTile(Math.min(Math.max(x, 0), tileXCount), Math.min(Math.max(y, 0), tileYCount), getRotationAngle((int) (renderer.rotationAngle < 0 ? 360f + renderer.rotationAngle : renderer.rotationAngle)), renderer);
//    }
    
    
    if ((y >= 0 && y < _tiles2D.count) && (x >= 0 && x < [[_tiles2D objectAtIndex:y] count])) {
        [self setCurrentTileX:x andY:y andCamera:camera];
    } else {
    
        [self setCurrentTileX:MIN(MAX(x, 0), tilesXCount) andY:MIN(MAX(y, 0), tilesYCount) andCamera:camera];
    }
    
//    if (y >= 0 && y < _tiles2D.count) {
//        if (x >= 0 && x < [[_tiles2D objectAtIndex:y] count]) {
//           [self setCurrentTileX:x andY:y andCamera:camera];
//        }
//    }

}

-(void)setCurrentTileX:(int)x andY:(int)y andCamera:(Camera*)camera {
    _currentTileX = x;
    _currentTileY = y;
    
    [self updateTileTextureQualityWithCamera:camera];
}

-(GLKVector4)calculateLightPosition {
    double centerLat = _maxLatitude - (_mapHeight / 2) * _step;
    double centerLon = _minLongitude + (_mapWidth / 2) * _step;
    double centerX = [Layer transformLatFromDouble:centerLat];
    double centerY = [Layer transformLonFromDouble:centerLon];
    
//    double diff = ABS(_maxHeight - _minHeight)* METERS_IN_POINT;
    
    
    return GLKVector4Make(centerX, centerY, 50, 0);
}



-(void)updateTileTextureQualityWithCamera:(Camera*)camera {

    int startY = 0;
    int startX = 0;
    int endIndexY = (int)_tiles2D.count;

    int yIndex = startY;

    while (yIndex < endIndexY) {
        int endIndexX = (int)[[_tiles2D objectAtIndex:yIndex] count];
        int xIndex = 0;
        if (yIndex < _tiles2D.count) {
            while (xIndex < endIndexX) {
                if (xIndex < [[_tiles2D objectAtIndex:yIndex] count]) {
                    TextureQuality q = TextureQualityNone;
                    DrawTile* t = [[_tiles2D objectAtIndex:yIndex] objectAtIndex:xIndex];
                    int absX = abs(xIndex - _currentTileX);
                    int absY = abs(yIndex - _currentTileY);

                    if(absY <= 4 && absX <= 4) {
                        if ([camera.frustum isVertexListVisible:t.getVertexList]) {
                            q = _defaultTextureQuality;
                        }
                   }
                    
                    if ([t setTextureQuality:q]) {
                        [_redrawTiles addObject:t];
                    }
                }
                xIndex += 1;
            }
        }
        
       
        
        xIndex = startX;
        yIndex += 1;
    }

}

-(NSMutableArray *)getVertex2DArray {
    return _vertex2DArray;
}

-(NSMutableArray*)getTilesForRedraw {
    return _redrawTiles;
}

-(void)clearRedrawTiles {
    [_redrawTiles removeAllObjects];
}

-(void)clean {
    _currentTileX = -1;
    _currentTileY = -1;
    
    for (NSArray* arr in _tiles2D) {
        for (DrawTile* t in arr) {
            [t clean];
        }
    }
}

-(double)getZPositionForLocation:(CLLocation*)location {
    double retval = (_maxHeight - _minHeight) * METERS_IN_POINT;
    
    CLLocationCoordinate2D coord = [location coordinate];
    
    double longitude = coord.longitude;
    double latitude = coord.latitude;
    
    double uX = [Layer transformLonFromDouble:longitude];
    double uY = [Layer transformLatFromDouble:latitude];
    
    int bottomLeftIndexX = (int)((longitude - _minLongitude)/ _step);//
    int bottomLeftIndexY = (int)ceil((_maxLatitude -latitude) / _step);//
    
    int upLeftIndexX = bottomLeftIndexX;
    int upLeftIndexY = bottomLeftIndexY - 1;

    int bottomRightIndexX = bottomLeftIndexX + 1;
    int bottomRightIndexY = bottomLeftIndexY;
    
    int upRightIndexX = bottomLeftIndexX + 1;
    int upRightIndexY = bottomLeftIndexY - 1;
    
    if (!(
        bottomLeftIndexX > 0 && bottomLeftIndexX < _mapWidth &&
        bottomRightIndexX > 0 && bottomRightIndexX < _mapWidth &&
        upRightIndexX > 0 && upRightIndexX < _mapWidth &&
        upLeftIndexX > 0 && upLeftIndexX < _mapWidth &&
        bottomLeftIndexY > 0 && bottomLeftIndexY < _mapHeight &&
        bottomRightIndexY > 0 && bottomRightIndexY < _mapHeight &&
        upRightIndexY > 0 && upRightIndexY < _mapHeight &&
        upLeftIndexY > 0 && upLeftIndexY < _mapHeight
        )) {
        return retval;
    }
    
    
    double bottomLatitude = _maxLatitude - _step * bottomLeftIndexY;
    double upLatitude = _maxLatitude - _step * (bottomLeftIndexY - 1);
    
    double leftLongitude = _minLongitude + _step * bottomLeftIndexX;
    double rightLongitude = _minLongitude + _step * (bottomLeftIndexX + 1);
    
    double bottomY = [Layer transformLatFromDouble:bottomLatitude];
    double upY = [Layer transformLatFromDouble:upLatitude];
    
    double leftX = [Layer transformLonFromDouble:leftLongitude];
    double rightX = [Layer transformLonFromDouble:rightLongitude];

    double bottomLeftZ = ([[[_elevationArray objectAtIndex:bottomLeftIndexY] objectAtIndex:bottomLeftIndexX] doubleValue] - _minHeight) * METERS_IN_POINT;
    double upLeftZ = ([[[_elevationArray objectAtIndex:upLeftIndexY] objectAtIndex:upLeftIndexX] doubleValue] - _minHeight) * METERS_IN_POINT;
    double bottomRightZ = ([[[_elevationArray objectAtIndex:bottomRightIndexY] objectAtIndex:bottomRightIndexX] doubleValue] - _minHeight) * METERS_IN_POINT;
    double upRightZ = ([[[_elevationArray objectAtIndex:upRightIndexY] objectAtIndex:upRightIndexX] doubleValue] - _minHeight) * METERS_IN_POINT;
    
    
    Vector* point = [[Vector alloc] initWithX:uX andY:uY andZ:0];
    
    Vector* bottomLeft = [[Vector alloc] initWithX:leftX andY:bottomY andZ:bottomLeftZ];
    Vector* upLeft = [[Vector alloc] initWithX:leftX andY:upY andZ:upLeftZ];
    Vector* bottomRight = [[Vector alloc] initWithX:rightX andY:bottomY andZ:bottomRightZ];
    Vector* upRight = [[Vector alloc] initWithX:rightX andY:upY andZ:upRightZ];
    
    double distanceToBottomLeft = [VectorMath distanceWithVector1:point andVector2:bottomLeft];
    double distanceToUpRight = [VectorMath distanceWithVector1:point andVector2:upRight];
    
    Vector* result;
    
   if (distanceToBottomLeft > distanceToUpRight) {
         result = [VectorMath calculateZpositionForPointWithX:uX andY:uY andBasePoint:upLeft andUpPoint:bottomRight andRightPoint:upRight];
    } else {
        result = [VectorMath calculateZpositionForPointWithX:uX andY:uY andBasePoint:upLeft andUpPoint:bottomRight andRightPoint:bottomLeft];
    }
    
    retval = result.z;
    
    return retval;
}


-(double)getZForPointX:(double)uX andY:(double)uY {

    double longitude = [Layer transformToLonWithDouble:-uX];
    double latitude = [Layer transformToLatWithDouble:-uY];
    
    CLLocation* coord = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    return [self getZPositionForLocation:coord];
}

- (void)makeTiles {
    _tiles2D = [NSMutableArray new];
    _tiles = [NSMutableArray new];
    
    double mapWidth = _mapWidth;
    double mapHeight = _mapHeight;
    
    double tileNumberX = 0;
    double tileNumberY = 0;
    
    xPointsInTile = 15;
    yPointsInTile = 15;
    
    tilesXCount = ceil((mapWidth - 1) / (xPointsInTile - 1));
    tilesYCount = ceil((mapHeight - 1) / (yPointsInTile - 1));
    
    while (tileNumberY < tilesYCount) {
        
        NSMutableArray*tileRow = [NSMutableArray new];
        
        while(tileNumberX < tilesXCount) {
            
            NSMutableArray* vertexArray = [NSMutableArray new];
            
            for (int y = MAX(tileNumberY * yPointsInTile - 1 * tileNumberY, 0) ; y < MIN(mapHeight, (MAX(tileNumberY * yPointsInTile - 1 * tileNumberY, 0)) + yPointsInTile) ; y++) {
                NSMutableArray* vertexRow = [NSMutableArray new];
                
                for (int x = MAX(tileNumberX * xPointsInTile - 1 * tileNumberX, 0) ; x < MIN(mapWidth, (MAX(tileNumberX * xPointsInTile - 1 * tileNumberX, 0)) + xPointsInTile) ; x++) {
            
                    NSArray<Vertex*>* row = _vertex2DArray[y];
                    
                    [vertexRow addObject: row[x]];
                }
                
                [vertexArray addObject:vertexRow];
            }
            
            DrawTile* t = [[DrawTile alloc] initWithVertexArray:vertexArray andLightPosition:_lightPosition];
            
            [_tiles addObject:t];
            [tileRow addObject:t];
            
            tileNumberX += 1;
        }
        [_tiles2D addObject:tileRow];
        
        tileNumberX = 0;
        tileNumberY += 1;
    }
}

-(void)renderTilesWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera {

    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    for (NSArray* arr in _tiles2D) {
        for (DrawTile* t in arr) {
            [t renderWithEffect:effect andCamera:camera];
        }
    }
    
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
}

-(void)additionalRenderTilesWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera {
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    for (NSArray* arr in _tiles2D) {
        for (DrawTile* t in arr) {
            [t additionalRenderWithEffect:effect andCamera:camera];
        }
    }
    
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
}

-(void)renderBorderTilesWithEffect:(GLKBaseEffect *)effect isFlyover:(BOOL) isFlyover {
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDepthFunc(GL_LEQUAL);
    glDisable(GL_BLEND);
    
    for (BorderTile* t in _borderTiles) {
        [t renderWithEffect:effect isFlyover:isFlyover];
    }
    
    glDisable(GL_DEPTH_TEST);
}



-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera*)camera andDepthFunk:(GLenum)depthFunc {
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDepthFunc(depthFunc);
    glDisable(GL_BLEND);
    
    GLKTextureInfo* currentTexture = [camera isFlyover] ? _textureFlyover : _texture;

    effect.light0.enabled = GL_TRUE;
    effect.light0.position = _lightPosition;
    effect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1);
    effect.light0.specularColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
    effect.light0.ambientColor = GLKVector4Make(0.3, 0.3, 0.3, 1);
    
    effect.lightingType = GLKLightingTypePerPixel;

    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = currentTexture.name;

    effect.colorMaterialEnabled = GL_TRUE;

    [effect prepareToDraw];
    
    glBindTexture(currentTexture.target, currentTexture.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    [GLHelper drawVertexBuffer:_vertexBuffer andIndexBuffer:_indexBuffer andTexCoordBuffer:_uvBuffer andNormalBuffer:_normalBuffer andMode:GL_TRIANGLES andCount:_numVertices];
    
    effect.light0.enabled = GL_FALSE;
    effect.colorMaterialEnabled = GL_FALSE;

    glDisable(GL_DEPTH_TEST);
}

-(GLKVector4)lightPosition {
    return _lightPosition;
}

@end
