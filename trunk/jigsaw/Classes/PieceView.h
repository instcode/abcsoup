//
//  PieceView.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Renderable.h"
#import "PieceMesh.h"
#import "PieceModel.h"

struct TexCoord {
	float s, t;
};

@interface PieceView : Renderable {
@private
	PieceMesh* mesh;
	PieceModel* model;
	
	float* points;
	struct TexCoord* texcoords;
}

/**
 Create a new piece view linked with a mesh and a data model
 */
- (id) initWithMeshModel: (PieceMesh*) mesh: (PieceModel*) model;

- (void) render;

/**
 Generate texture coordinates based on the initial scale, position of the piece on board
 */
- (void) genTexCoords: (float[]) m: (float) textureScale;
@end
