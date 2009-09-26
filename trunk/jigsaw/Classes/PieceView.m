//
//  PieceView.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "PieceView.h"
#import "OpenGLES/ES1/gl.h"

@implementation PieceView

- (id) initWithMeshModel: (PieceMesh*) _mesh: (PieceModel*) _model {
	if ((self = [super init]) != NULL) {
		mesh = _mesh;
		model = _model;
		
		// create a floating point array of 2D points for the mesh
		points = (float*) malloc(sizeof(float) * 2 * mesh.nbPoints);
		for (int i = 0; i < mesh.nbPoints; i++) {
			points[2 * i + 0] = mesh.points[i].x;
			points[2 * i + 1] = mesh.points[i].y;
		}
	}
	return self;
}

- (void) render {
	
	glColor4f(1, 1, 1, 1);
	glVertexPointer(2, GL_FLOAT, 0, points); // two components
    glEnableClientState(GL_VERTEX_ARRAY);
    //glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    //glEnableClientState(GL_COLOR_ARRAY);
    
	
    //glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDrawElements(GL_TRIANGLES, 3 * mesh.nbTriangles, GL_UNSIGNED_SHORT, mesh.index);
	//glDrawElements(GL_LINE_STRIP, 3 * mesh.nbTriangles, GL_UNSIGNED_SHORT, mesh.index);
	//glDrawElements(GL_TRIANGLES, 9, GL_UNSIGNED_SHORT, mesh.index);
	//glDrawElements(GL_LINE_STRIP, mesh.nbTriangles, GL_UNSIGNED_SHORT, mesh.index);
	//glDrawArrays(GL_LINE_LOOP, 0, mesh.nbPoints);
}

- (void) dealloc {
	free(points);
	[super dealloc];
}
@end
