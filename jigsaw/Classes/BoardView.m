//
//  BoardView.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "BoardView.h"
#import "BoardManager.h"
#import "PieceMeshFactory.h"
#import "TextureManager.h"


@implementation BoardView

- (id) init {
	if ((self = [super init]) != NULL) {
		BoardManager* manager = [BoardManager getBoardManager];
		boardModel = manager.boardModel;
		
		// 1 piece view experiment
		/*
		PieceMeshFactory* factory = [PieceMeshFactory getPieceMeshFactory];
		PieceMesh* mesh = [factory createPieceMesh];
		if (mesh == NULL) {
			[NSException raise:@"Cannot create mesh from mesh factory." format:@""];
		}
		pieceViews = [[PieceView alloc] initWithMeshModel: mesh: [boardModel.pieceModels objectAtIndex:0]];
		 */
		
		// try to load a texture
		texPhoto = [[TextureManager instance] getJigsawPhoto:@"manutd256.png"];
		// ask to generate texture coordinates
		genTexCoords = false;
		
		[self createPieceViews];
	}
	return self;
}

- (void) createPieceViews {
	// allocate pieceViews array
	pieceViews = (PieceView**) malloc(sizeof(PieceView*) * boardModel.height * boardModel.width);
	
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
	struct CellCurveTypes* grid = (struct CellCurveTypes*) malloc(sizeof(struct CellCurveTypes) * boardModel.height * boardModel.width);
	
	// cell edge order (clockwise, from 12: 0, 1, 3, 2) -> edge 0 is opposite to edge 3, edge 1 is opposite to edge 2
	for (int i = 0; i < boardModel.height; ++i) {
		int t = i - 1;
		int b = i + 1;
		
		for (int j = 0; j < boardModel.width; ++j) {
			// create a cell with 4 neighbor curve types
			int l = j - 1;
			int r = j + 1;
			int index = i * boardModel.width + j;
			int indexLeft = i * boardModel.width + l;
			//int indexRight = i * width + r;
			int indexTop = t * boardModel.width + j;
			//int indexBottom = b * width + j;
			if (l < 0)
				grid[index].c[CELL_LEFT] = NULL;
			else {
				
				grid[index].c[CELL_LEFT] = [grid[indexLeft].c[CELL_RIGHT] cloneFlip];
			}
			if (r >= boardModel.width)
				grid[index].c[CELL_RIGHT] = NULL;
			else
				grid[index].c[CELL_RIGHT] = curveType; //[verCurveTypes objectAtIndex:0];
			
			if (t < 0)
				grid[index].c[CELL_TOP] = NULL;
			else
				grid[index].c[CELL_TOP] = [grid[indexTop].c[CELL_BOTTOM] cloneFlip];
			
			if (b >= boardModel.height)
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
	for (int i = 0; i < boardModel.height; ++i) {
		for (int j = 0; j < boardModel.width; ++j) {
			PieceMesh*	pieceMesh = [[PieceMesh alloc] initWithCurveType4: grid[i * boardModel.width + j].c];
			PieceModel* pieceModel = [boardModel.pieceModels objectAtIndex:0];
			// attach to piece view
			pieceViews[i * boardModel.width + j] = [[PieceView alloc] initWithMeshModel: pieceMesh: pieceModel];
		}
	}
	 
	// clean up
	free(grid);
}

- (void) render {
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	float screenSize = fmin(screenRect.size.width, screenRect.size.height);
	int minNumPieces = fmax(boardModel.height, boardModel.width);
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
	if (genTexCoords == false) {
		float textureScale = 1.0f / screenSize; // normalize texcoords to [0, 1]
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		y = y0;
		for (int i = 0; i < boardModel.height; ++i) {
			x = x0;
			for (int j = 0; j < boardModel.width; ++j) {
				glPushMatrix();
				// set piece view position
				glTranslatef(x, y, 0.0f);
				glScalef(scaleX, scaleY, 1.0f);
				
				// generate texture coordinates
				GLfloat m[16]; 
				glGetFloatv (GL_MODELVIEW_MATRIX, m);
				[pieceViews[i * boardModel.width + j] genTexCoords:m :textureScale]; // piece is rendered from its center
				glPopMatrix();
				
				// next
				x += pieceWidth;
			}
			y -= pieceHeight;
		}
		genTexCoords = true;
	}
	
	
	// 
	// render
	//
	glBindTexture(GL_TEXTURE_2D, texPhoto);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	y = y0;
	for (int i = 0; i < boardModel.height; ++i) {
		x = x0;
		for (int j = 0; j < boardModel.width; ++j) {
			glPushMatrix();
				// set piece view position
				glTranslatef(x, y, 0.0f);
				glScalef(scaleX, scaleY, 1.0f);
						
				// render
				[pieceViews[i * boardModel.width + j] render]; // piece is rendered from its center
			glPopMatrix();
			
			// next
			x += pieceWidth;
		}
		y -= pieceHeight;
	}
}

@end
