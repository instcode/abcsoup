//
//  Piece.m
//  Jigsaw
//
//  Created by Son Hua on 17/10/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "Piece.h"
#import "PieceMesh.h"

@implementation Piece

@synthesize uid;
@synthesize mesh;

- (id) initWithMesh: (int) _uid: (PieceMesh*) _mesh {
	if ((self = [super init]) != NULL) {
		uid = _uid;
		mesh = _mesh;
				
		// create a floating point array of 2D points for the mesh
		points = (float*) malloc(sizeof(float) * 2 * mesh.nbPoints);
		for (int i = 0; i < mesh.nbPoints; i++) {
			points[2 * i + 0] = mesh.points[i].x;
			points[2 * i + 1] = mesh.points[i].y;
		}
		texcoords = (struct TexCoord*) malloc(sizeof(struct TexCoord) * mesh.nbPoints);
	
		// create line index
		lineIndex = (unsigned short*) malloc(sizeof(unsigned short) * mesh.nbPoints);
		for (int i = 0; i < mesh.nbPoints; ++i) 
			lineIndex[i] = i;
		
		
	}
	return self;
}

void matrixPrint(float m[16]) {
	for (int j = 0; j < 4; ++j) {
		for (int i = 0; i < 4; ++i) {
			printf("%f ", m[i * 4 + j]);
		}
		printf("\n");
	}
}

void vectorPrint(float v[3]) {
	printf("%f %f %f\n", v[0], v[1], v[2]);
}

void transformPoint(float m[16], float v[3], float r[3]) {
	//float r[3];
	r[0] = m[0] * v[0] + m[4] * v[1] + m[8] * v[2] + m[12];
	r[1] = m[1] * v[0] + m[5] * v[1] + m[9] * v[2] + m[13];
	r[2] = m[2] * v[0] + m[6] * v[1] + m[10] * v[2] + m[14];
	//return r;
	vectorPrint(v);
	matrixPrint(m);
	vectorPrint(r);
	
}

- (void) genTexCoords: (float[]) m: (float) textureScale {
	float u[3], v[3];
	v[2] = 0.0f; // z = 0;
	for (int i = 0; i < mesh.nbPoints; ++i) {
		v[0] = points[2 * i + 0];
		v[1] = points[2 * i + 1];
		transformPoint(m, v, u);
		texcoords[i].s = u[0] * textureScale + 0.5f;
		texcoords[i].t = u[1] * textureScale + 0.5f;
	}
}

- (void) transferGeometry {
	// FIXME: transfer each piece's geometry requires an index for each piece. 
	
	/*
	glVertexPointer(2, GL_FLOAT, 0, points); // two components
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	*/
}

- (void) render {
	
	glVertexPointer(2, GL_FLOAT, 0, points); // two components
    glEnableClientState(GL_VERTEX_ARRAY);
	
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
    //glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    //glEnableClientState(GL_COLOR_ARRAY);
    
	
    //glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDrawElements(GL_TRIANGLES, 3 * mesh.nbTriangles, GL_UNSIGNED_SHORT, mesh.index);
	
	//glScalef(0.95f, 0.95f, 0.95f);
	glDisable(GL_TEXTURE_2D);
	glColor4f(0.25f, 0.25f, 0.25f, 0.5f);
	glDrawElements(GL_LINE_LOOP, mesh.nbPoints, GL_UNSIGNED_SHORT, lineIndex);
	
	/*
	int nbPoints2 = mesh.nbPoints * 0.5;
	glColor4f(0.75f, 0.75f, 0.75f, 0.5f);
	glDrawElements(GL_LINE_STRIP, nbPoints2, GL_UNSIGNED_SHORT, lineIndex);
	glColor4f(0.15f, 0.15f, 0.15f, 0.5f);
	glDrawElements(GL_LINE_STRIP, nbPoints2, GL_UNSIGNED_SHORT, lineIndex + nbPoints2);
	*/
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glEnable(GL_TEXTURE_2D);
	
	
	//glDrawElements(GL_LINE_STRIP, 3 * mesh.nbTriangles, GL_UNSIGNED_SHORT, mesh.index);
	//glDrawElements(GL_TRIANGLES, 9, GL_UNSIGNED_SHORT, mesh.index);
	//glDrawElements(GL_LINE_STRIP, mesh.nbTriangles, GL_UNSIGNED_SHORT, mesh.index);
	//glDrawArrays(GL_LINE_LOOP, 0, mesh.nbPoints);
}

- (void) renderSelected {
	glDisable(GL_TEXTURE_2D);
	//glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
	
	glVertexPointer(2, GL_FLOAT, 0, points); // two components
    glEnableClientState(GL_VERTEX_ARRAY);
	
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
    glDrawElements(GL_LINE_LOOP, mesh.nbPoints, GL_UNSIGNED_SHORT, lineIndex);
	
	
	//glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glEnable(GL_TEXTURE_2D);
}

- (void) update: (int) delta {
}

- (bool) isSimilarTo: (Piece*) aPiece {
	return [mesh isSimilarTo: aPiece.mesh];
}

- (void) dealloc {
	free(points);
	free(lineIndex);
	[super dealloc];
}

@end
