//
//  PieceView.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "OpenGLES/ES1/gl.h"
#import "PieceView.h"

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
		texcoords = (struct TexCoord*) malloc(sizeof(struct TexCoord) * mesh.nbPoints);
	}
	return self;
}

void transformPoint(float m[16], float v[3], float r[3]) {
	//float r[3];
	r[0] = m[0] * v[1] + m[4] * v[2] + m[8] * v[3] + m[12];
	r[1] = m[1] * v[1] + m[5] * v[2] + m[9] * v[3] + m[13];
	r[2] = m[2] * v[1] + m[6] * v[2] + m[10] * v[3] + m[14];
	//return r;
}

- (void) genTexCoords: (float[]) m: (float) textureScale {
	float u[3], v[3];
	v[2] = 0.0f; // z = 0;
	for (int i = 0; i < mesh.nbPoints; ++i) {
		v[0] = points[2 * i + 0];
		v[1] = points[2 * i + 1];
		transformPoint(m, v, u);
		texcoords[i].s = v[0] * textureScale;
		texcoords[i].t = v[1] * textureScale;
	}
}

- (void) render {
	glColor4f(0, 1, 0, 1);
	glVertexPointer(2, GL_FLOAT, 0, points); // two components
    glEnableClientState(GL_VERTEX_ARRAY);
	
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
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
