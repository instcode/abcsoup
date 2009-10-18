//
//  Board.m
//  Jigsaw
//
//  Created by Son Hua on 17/10/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "Board.h"
#import "PieceMeshFactory.h"
#import "TextureManager.h"

@implementation Board
@synthesize width, height;

- (id) initWithSize: (int) _width : (int) _height {
	if ((self = [super init]) != NULL) {
		width = _width;
		height = _height;
		
		/*
		int total = width * height;
		//pieceModels = (PieceModel*) malloc(sizeof(PieceModel) * total);
		pieces = [NSMutableArray arrayWithCapacity: total]; 
		for (int i = 0; i < total; ++i) {
			PieceModel* p = [[PieceModel alloc] initWithUid: self: i];
			[pieceModels addObject:p];
		}*/
		
		
		// ask to generate texture coordinates
		//genTexCoords = false;
		
		[self createPiecesGeometry];
	}
	return self;
}

- (void) dealloc {
	free(pieces);
	[super dealloc];
}

- (void) loadResources {
	// try to load a texture
	texPhoto = [[TextureManager instance] getJigsawPhoto:@"manutd512.png"];
	
	// generate texture coordinates
	[self genTexCoords];
}

- (void) genTexCoords {
	// generate texture coordinates
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	float screenSize = fmin(screenRect.size.width, screenRect.size.height);
	int minNumPieces = fmax(height, width);
	float pieceWidth = screenSize / minNumPieces;
	float pieceHeight = screenSize / minNumPieces; 
	//float pieceWidth = 128.0f;
	//float pieceHeight = 128.0f;
	float scaleX = pieceWidth / 128.0f;
	float scaleY = pieceHeight / 128.0f;
	float x, y;
	float x0, y0;
	if (minNumPieces % 2 == 0) { // even pieces on a row
		y0 = (minNumPieces / 2 - 0.5) * pieceHeight;
		x0 = - (minNumPieces / 2 - 0.5) * pieceWidth;
	} else { // odd pieces on a row
		y0 = (minNumPieces / 2) * pieceHeight;
		x0 = - (minNumPieces / 2 ) * pieceWidth;
	}
	
	// 
	// generate texture coordinates 
	//
	//if (genTexCoords == false) {
		float textureScale = 1.0f / screenSize; // normalize texcoords to [0, 1]
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		y = y0;
		for (int i = 0; i < height; ++i) {
			x = x0;
			for (int j = 0; j < width; ++j) {
				glPushMatrix();
				// set piece view position
				glTranslatef(x, y, 0.0f);
				glScalef(scaleX, scaleY, 1.0f);
				
				// generate texture coordinates
				GLfloat m[16]; 
				glGetFloatv (GL_MODELVIEW_MATRIX, m);
				[pieces[i * width + j] genTexCoords:m :textureScale]; // piece is rendered from its center
				glPopMatrix();
				
				// next
				x += pieceWidth;
			}
			y -= pieceHeight;
		}
		//genTexCoords = true;
	//}
	
}

- (void) createPiecesGeometry {
	// allocate pieces array
	pieces = (Piece**) malloc(sizeof(Piece*) * height * width);
	
	// generate piece meshes
	PieceMeshFactory* factory = [PieceMeshFactory getPieceMeshFactory];
	
	// TODO: generate random curve types here
	CurveType* curveType = [factory getRandomCurveType];
	curveType.scaleX = 1;
	curveType.scaleY = 1;
	//int width, height;
	//int nbHorCurveTypes = (height - 1) * width;
	//int nbVerCurveTypes = (width - 1) * height;
	
	// create curve types
	//NSMutableArray* horCurveTypes = [NSMutableArray arrayWithCapacity:nbHorCurveTypes];
	//NSMutableArray* verCurveTypes = [NSMutableArray arrayWithCapacity:nbVerCurveTypes];
	
	// create a grid mesh
	struct CellCurveTypes* grid = (struct CellCurveTypes*) malloc(sizeof(struct CellCurveTypes) * height * width);
	
	// cell edge order (clockwise, from 12: 0, 1, 3, 2) -> edge 0 is opposite to edge 3, edge 1 is opposite to edge 2
	for (int i = 0; i < height; ++i) {
		int t = i - 1;
		int b = i + 1;
		
		for (int j = 0; j < width; ++j) {
			// create a cell with 4 neighbor curve types
			int l = j - 1;
			int r = j + 1;
			int index = i * width + j;
			int indexLeft = i * width + l;
			//int indexRight = i * width + r;
			int indexTop = t * width + j;
			//int indexBottom = b * width + j;
			if (l < 0)
				grid[index].c[CELL_LEFT] = NULL;
			else {
				
				grid[index].c[CELL_LEFT] = [grid[indexLeft].c[CELL_RIGHT] cloneFlip];
			}
			if (r >= width)
				grid[index].c[CELL_RIGHT] = NULL;
			else
				grid[index].c[CELL_RIGHT] = curveType; //[verCurveTypes objectAtIndex:0];
			
			if (t < 0)
				grid[index].c[CELL_TOP] = NULL;
			else
				grid[index].c[CELL_TOP] = [grid[indexTop].c[CELL_BOTTOM] cloneFlip];
			
			if (b >= height)
				grid[index].c[CELL_BOTTOM] = NULL;
			else
				grid[index].c[CELL_BOTTOM] = curveType; //[horCurveTypes objectAtIndex:0];
			/*
			 grid[index].c[CELL_TOP] = curveType;
			 grid[index].c[CELL_BOTTOM] = curveType;
			 grid[index].c[CELL_LEFT] = curveType;
			 grid[index].c[CELL_RIGHT] = curveType;
			 */
		}
	}
	
	// create and attach piece meshes to piece views
	for (int i = 0; i < height; ++i) {
		for (int j = 0; j < width; ++j) {
			PieceMesh*	pieceMesh = [[PieceMesh alloc] initWithCurveType4: grid[i * width + j].c];
			
			// attach to piece view
			pieces[i * width + j] = [[Piece alloc] initWithMesh: pieceMesh];
		}
	}
	
	// clean up
	free(grid);
}

- (void) render {
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	float screenSize = fmin(screenRect.size.width, screenRect.size.height);
	int minNumPieces = fmax(height, width);
	float pieceWidth = screenSize / minNumPieces;
	float pieceHeight = screenSize / minNumPieces; 
	//float pieceWidth = 128.0f;
	//float pieceHeight = 128.0f;
	float scaleX = pieceWidth / 128.0f;
	float scaleY = pieceHeight / 128.0f;
	scaleX *= 0.7f;
	scaleY *= 0.7f;
	float x, y;
	float x0, y0;
	if (minNumPieces % 2 == 0) { // even pieces on a row
		y0 = (minNumPieces / 2 - 0.5) * pieceHeight;
		x0 = - (minNumPieces / 2 - 0.5) * pieceWidth;
	} else { // odd pieces on a row
		y0 = (minNumPieces / 2) * pieceHeight;
		x0 = - (minNumPieces / 2 ) * pieceWidth;
	}
	
	// 
	// generate texture coordinates 
	//
	/*
	if (genTexCoords == false) {
		float textureScale = 1.0f / screenSize; // normalize texcoords to [0, 1]
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		y = y0;
		for (int i = 0; i < height; ++i) {
			x = x0;
			for (int j = 0; j < width; ++j) {
				glPushMatrix();
				// set piece view position
				glTranslatef(x, y, 0.0f);
				glScalef(scaleX, scaleY, 1.0f);
				
				// generate texture coordinates
				GLfloat m[16]; 
				glGetFloatv (GL_MODELVIEW_MATRIX, m);
				[pieces[i * width + j] genTexCoords:m :textureScale]; // piece is rendered from its center
				glPopMatrix();
				
				// next
				x += pieceWidth;
			}
			y -= pieceHeight;
		}
		genTexCoords = true;
	}
	*/
	
	// 
	// render
	//
	glBindTexture(GL_TEXTURE_2D, texPhoto);

	glEnable(GL_TEXTURE_2D);
	/*
	const GLfloat squareVertices[] = {
        -10.5f, -10.5f,
        10.5f,  -10.5f,
        -10.5f,  10.5f,
        10.5f,   10.5f,
    };
    const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
	
	const GLfloat squareTexCoords[] = {
		0.0f, 0.0f, 
		1.0f, 0.0f,
		1.0f, 1.0f,
		0.0f, 1.0f
	};
	
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    //glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    //glEnableClientState(GL_COLOR_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, squareTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	*/
	//return;
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	y = y0;
	for (int i = 0; i < height; ++i) {
		x = x0;
		for (int j = 0; j < width; ++j) {
			glPushMatrix();
			// set piece view position
			glTranslatef(x, y, 0.0f);
			glScalef(scaleX, scaleY, 1.0f);
			
			// render
			[pieces[i * width + j] render]; // piece is rendered from its center
			glPopMatrix();
			
			// next
			x += pieceWidth;
		}
		y -= pieceHeight;
	}
}

- (void) update: (int) delta {
}

@end
