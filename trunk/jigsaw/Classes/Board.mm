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
#import "Constant.h"
#include "RenzoUtil.h"

#import "Texture2D.h" // text rendering library, from Apple.

using namespace Renzo;

@implementation Board
@synthesize width, height;

- (id) initWithSize: (int) _width : (int) _height {
	if ((self = [super init]) != NULL) {
		width = _width;
		height = _height;
		nbPieces = width * height;
		
		// screen
		screenRect = [[UIScreen mainScreen] bounds];
		screenSize = fmin(screenRect.size.width, screenRect.size.height);
		// origin
		center.x = screenRect.size.width / 2.0f;
		center.y = screenRect.size.height / 2.0f;
		
		// piece size
		minNumPieces = fmax(height, width);
		pieceWidth = screenSize / minNumPieces;
		pieceHeight = screenSize / minNumPieces; 
		
		//float pieceWidth = 128.0f;
		//float pieceHeight = 128.0f;
		scaleX = pieceWidth / 128.0f;
		scaleY = pieceHeight / 128.0f;
		
		// generate geometry and obtain maximum dimension of a piece
		maxPieceWidth	= 0;
		maxPieceHeight	= 0;
		[self createPiecesGeometry];
		// remember to scale
		maxPieceWidth	*= scaleX;
		maxPieceHeight	*= scaleY;
		
		//scaleX *= 0.7f;
		//scaleY *= 0.7f;
		// top left coordinates of the top left piece
		if (minNumPieces % 2 == 0) { // even pieces on a row
			y0 = (minNumPieces / 2 - 0.5) * pieceHeight;
			x0 = - (minNumPieces / 2 - 0.5) * pieceWidth;
		} else { // odd pieces on a row
			y0 = (minNumPieces / 2) * pieceHeight;
			x0 = - (minNumPieces / 2 ) * pieceWidth;
		}
		x1 = x0 + screenSize;
		y1 = y0 - screenSize;
		
		// selected piece info
		selectedIndex = -1; 
		selectedColor.x = SELECTED_COLOR_LOWER_RED;
		selectedColor.y = SELECTED_COLOR_LOWER_GREEN;
		selectedColor.z = SELECTED_COLOR_LOWER_BLUE;
		selectedColorDelta.x = (SELECTED_COLOR_UPPER_RED - SELECTED_COLOR_LOWER_RED) / SELECTED_COLOR_CHANGE_FRAMES;
		selectedColorDelta.y = (SELECTED_COLOR_UPPER_GREEN - SELECTED_COLOR_LOWER_GREEN) / SELECTED_COLOR_CHANGE_FRAMES;
		selectedColorDelta.z = (SELECTED_COLOR_UPPER_BLUE - SELECTED_COLOR_LOWER_BLUE) / SELECTED_COLOR_CHANGE_FRAMES;
		
		// piece position (before scale)
		correctPosition = (struct JPoint*) malloc(nbPieces * sizeof(struct JPoint));
		currentPosition = (struct JPoint*) malloc(nbPieces * sizeof(struct JPoint));
		oldPosition = (struct JPoint*) malloc(nbPieces * sizeof(struct JPoint));
		
		float x, y;
		y = y0;
		for (int i = 0; i < height; ++i) {
			x = x0;
			for (int j = 0; j < width; ++j) {
				int index = i * width + j;
				correctPosition[index].x = x;
				correctPosition[index].y = y;
				correctPosition[index].z = 0.0f;
				
				currentPosition[index] = correctPosition[index];
				// next
				x += pieceWidth;
			}
			y -= pieceHeight;
		} 
		
		//
		// tray settings
		//
		// top offset of the entire board
		//[self setTopOffset: pieceHeight * 1.1f];
		if (width <= 6) {
			[self setTopOffset: screenSize - center.y - 4]; // piece is big enough
		} else {
			[self setTopOffset: screenSize - center.y - 20]; // piece is too small such that dragging at the status bar should be avoided.
		}
		//trayTop		= y + 0.2f * pieceHeight;; // let tray top be half piece after the board
		trayTop = (y + 0.5f * pieceHeight) - 16;
		//trayBottom	= y - 1.5f * pieceHeight;
		//trayTop		= -(screenRect.size.width + top) + (center.y - top);
		//trayBottom	= -(screenRect.size.height - 16) + (center.y);
		//trayBottom		= (y0 + 0.5f * pieceHeight) - screenRect.size.height + 16 - top;
		//trayBottom = -screenRect.size.height + center.y - pieceHeight * 0.25 - 16;
		trayBottom = -screenRect.size.height + center.y - pieceHeight * 0.25 - 16;
		
		lineVerts[0] = -center.x; lineVerts[1] = trayTop; lineVerts[2] = 0.0f;
		lineVerts[3] = +center.x; lineVerts[4] = trayTop; lineVerts[5] = 0.0f;
		lineVerts[6] = -center.x; lineVerts[7] = trayBottom; lineVerts[8] = 0.0f;
		lineVerts[9] = +center.x; lineVerts[10] = trayBottom; lineVerts[11] = 0.0f;
		
		/*
						nbPiecesPerTrayLine		= 3;
		if (width > 5)	nbPiecesPerTrayLine		= 4;
		if (width > 7)  nbPiecesPerTrayLine		= 5;
		*/
		nbPiecesPerTrayLine = ceil(1.0f * screenSize / maxPieceWidth) - 1;
		
		nbTrayLines				= (nbPieces + nbPiecesPerTrayLine - 1) / nbPiecesPerTrayLine;
		curTrayLine				= 0;
		nbMaxPiecesInTray		= nbPiecesPerTrayLine * nbTrayLines;
		
		trayPieces		= (int*) malloc(sizeof(int) * nbMaxPiecesInTray);
		oldTrayPieces	= (int*) malloc(sizeof(int) * nbMaxPiecesInTray);
		
		pieceLocation		= (int*) malloc(sizeof(int) * nbPieces);
		oldPieceLocation	= (int*) malloc(sizeof(int) * nbPieces);
		
		cellStat		= (int*) malloc(sizeof(int) * nbPieces);
		oldCellStat		= (int*) malloc(sizeof(int) * nbPieces);
		
		nbPiecesInTray			= 0;
		for (int i = 0; i < nbPieces; ++i) {
			pieceLocation[i] = LOCATION_ON_BOARD; // each piece is on board. 
			// Note that a piece on board may not be in its correct location. But at start it does.
			cellStat[i] = i; // cell is occupied with its correct piece.
		}
		for (int i = 0; i < nbMaxPiecesInTray; ++i) {
			trayPieces[i] = -1;
		}
		
		//trayPieceWidth = pieceWidth * 1.5f;
		trayPieceWidth = maxPieceWidth;
		float gap = (screenSize - nbPiecesPerTrayLine * trayPieceWidth) / (nbPiecesPerTrayLine + 1.0f);
		//float trayPieceX0 = - (trayPieceWidth + gap);
		float trayPieceX0 = - (center.x - gap) + 0.5f * trayPieceWidth;
		//float trayPieceY0 = 0.5f * (trayTop + -center.y) - pieceHeight * 0.5f;
		//float trayPieceY0 = 0.4f * (trayTop) + 0.6f * (trayBottom);
		//float trayPieceY0 = trayTop - pieceHeight * 2.0f / 2;
		float trayPieceY0 = trayBottom + 0.3f * maxPieceHeight;
		float tx = trayPieceX0;
		float ty = trayPieceY0;
		trayPieceCorrectPosition = (struct JPoint*) malloc(sizeof(struct JPoint) * nbPiecesPerTrayLine);
		for (int i = 0; i < nbPiecesPerTrayLine; ++i) {
			trayPieceCorrectPosition[i].x = tx;
			trayPieceCorrectPosition[i].y = ty;
			trayPieceCorrectPosition[i].z = 0.0f;
			
			tx += trayPieceWidth + gap;
		}
		
		// * randomization * //
		//randomSeed(0);
		srand(time(NULL));
		//
		// start up board information
		//
		nbMissingPieces = 0;
		if (nbMissingPieces == 0)
			nbMissingPieces = randomInteger(width * height * 0.25f, width * height * 0.75f);
		nbPiecesInTray = nbMissingPieces;
		nonEmptyTrayLines = ceil(nbPiecesInTray * 1.0f / nbPiecesPerTrayLine);
		
		// create the missing pieces' indices
		missing = (int*) malloc(sizeof(int) * nbPieces);
		for (int i = 0; i < nbPieces; ++i) 
			missing[i] = i;
		
		for (int i = nbPieces - 1; i >= 0; --i) {
			int r = randomInteger(0, i);
			// swap
			swap(missing[r], missing[i]);
		}
		
		// extract nbMissingPieces consecutive indices
		missingStart = randomInteger(0, nbPieces - nbMissingPieces);
		missingEnd = missingStart + nbMissingPieces - 1;
		
		int k = 0;
		printf("Index: ");
		for (int i = missingStart; i < missingEnd; ++i) {
			int index = missing[i];
			cellStat[index] = CELL_STAT_EMPTY; // missing piece makes its correct occupied cell empty
			
			printf("%d\t", index);
			// 3 first pieces are visible
			if (k < nbPiecesPerTrayLine) {
				pieceLocation[index] = LOCATION_ON_TRAY_VISIBLE;
			} else {
				pieceLocation[index] = LOCATION_ON_TRAY_NOT_VISIBLE;
			}
			trayPieces[k] = index;
			
			// set position
			currentPosition[index] = trayPieceCorrectPosition[k % nbPiecesPerTrayLine];
			
			++k;
		}
		
		
		
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
		
		// event queue
		qTouch = (struct EventJPoint*) malloc (sizeof(struct EventJPoint) * QUEUE_SIZE);
		head = 0; tail = -1, count = 0;
		
		// render state
		[self createAutomata];
		renderState = rsWaitForPlayer;
		[self switchState:tvFadeIn];	// fade in first question mark
		
		
		
		// display button position
		float xLeft		= x0 - pieceWidth * 0.5f;
		float xRight	= x1 - pieceWidth * 0.5f;
		//buttonBackPos	= (struct JPoint*) malloc(sizeof(struct JPoint));
		//buttonNextPos	= (struct JPoint*) malloc(sizeof(struct JPoint));
		//buttonNewPos	= (struct JPoint*) malloc(sizeof(struct JPoint));
		buttonBackPos.x = xLeft + 16;
		buttonBackPos.y = trayTop - 4 / scaleY;
		buttonBackPos.z = 0.0f;
		buttonNextPos.x = xRight - 16;
		buttonNextPos.y = trayTop - 4 / scaleY;
		buttonNextPos.z = 0.0f;
		buttonNewPos.x = xLeft + 16;
		buttonNewPos.y = trayBottom - pieceHeight * 0.5f;
		buttonNewPos.z = 0.0f;
		barPos.x = trayPieceCorrectPosition[0].x;
		barPos.y = trayBottom - pieceHeight * 0.5;
		barPos.z = 0.0f;
		
		// display text information
		title = [[Texture2D alloc] initWithString:@"Parrot in Japan" dimensions:CGSizeMake(128, 32) alignment:UITextAlignmentCenter fontName:@"Zapfino" fontSize:12.0f];
	}
	return self;
}

- (void) setTopOffset: (float) _top {
	top = _top;
}


- (void) dealloc {
	free(correctPosition);
	free(currentPosition);
	free(oldPosition);
	
	free(pieces);
	
	free(trayPieceCorrectPosition);
	free(missing);
	
	free(pieceLocation);
	free(oldPieceLocation);
	free(trayPieces);
	free(oldTrayPieces);
	free(cellStat);
	free(oldCellStat);
	
	free(qTouch);
	
	//free(buttonBackPos);
	//free(buttonNextPos);
	//free(buttonNewPos);
	
	[title release];
	
	[super dealloc];
}

- (void) loadResources {
	// try to load a texture
	
	texPhoto = [[TextureManager instance] loadTexture3:@"Jigsaw07.png"];
	texButtons = [[TextureManager instance] loadTexture4:@"buttons.png"];
	
	// generate texture coordinates
	[self genTexCoords];
	
	// copy geometry to GPU
	[self transferGeometry];
}

- (void) genTexCoords {
	float x, y;
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

- (void) transferGeometry {
	for (int i = 0; i < height; ++i) {
		for (int j = 0; j < width; ++j) {
			[pieces[i * width + j] transferGeometry];
		}
	}
}

- (void) createPiecesGeometry {
	// allocate pieces array
	pieces = (Piece**) malloc(sizeof(Piece*) * height * width);
	
	// generate piece meshes
	PieceMeshFactory* factory = [PieceMeshFactory getPieceMeshFactory];
	
	CurveType* curveTypeFlat = [factory getFlatCurveType];
	
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
				grid[index].c[CELL_LEFT] = curveTypeFlat; //NULL;
			else {
				
				grid[index].c[CELL_LEFT] = [grid[indexLeft].c[CELL_RIGHT] cloneFlip];
			}
			if (r >= width)
				grid[index].c[CELL_RIGHT] = curveTypeFlat; //NULL;
			else
				grid[index].c[CELL_RIGHT] = [factory getRandomCurveType]; //[verCurveTypes objectAtIndex:0];
			
			if (t < 0)
				grid[index].c[CELL_TOP] = curveTypeFlat; //NULL;
			else
				grid[index].c[CELL_TOP] = [grid[indexTop].c[CELL_BOTTOM] cloneFlip];
			
			if (b >= height)
				grid[index].c[CELL_BOTTOM] = curveTypeFlat; //NULL;
			else
				grid[index].c[CELL_BOTTOM] = [factory getRandomCurveType]; //[horCurveTypes objectAtIndex:0];
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
			
			// get maximum height and width
			maxPieceHeight	= fmax(maxPieceHeight, [pieceMesh getMaxHeight]);
			maxPieceWidth	= fmax(maxPieceWidth, [pieceMesh getMaxWidth]);
			
			// attach to piece view
			int index = i * width + j;
			pieces[index] = [[Piece alloc] initWithMesh: index: pieceMesh];
		}
	}
	
	// clean up
	free(grid);
}

- (void) renderBoard {
	//
	// render panel
	//
	const float squareVertices[] = {
		1.0f, -1.0f,
		1.0f, 1.0f, 
		-1.0f, -1.0f,
		-1.0f, 1.0f
	};
	
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	// background
	// the whole scene is shift up a distance stored in "top" variable. But we want to draw to the bottom of the screen after shift. So need to compensate the yScale with a "top" amount.
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glColor4f(0.05f, 0.05f, 0.05f, 1.0f);
	glPushMatrix();
	float yBottom = (-screenRect.size.height * 0.5f) - top;
	float yCenterBackground = (y1 + pieceHeight * 0.5f + yBottom) * 0.5f;
	float yScale = 0.5f * abs(yBottom - (y1 + pieceHeight * 0.5f));
	glTranslatef(0.0f, top, 0.0f);
	glTranslatef(0.0f, yCenterBackground, 0.0f);
	glScalef(screenSize * 0.5f, yScale, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	float x, y;
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
	
	glEnable(GL_BLEND);  
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	
	glLineWidth(1.0f);
	
	for (int i = 0; i < height; ++i) {
		for (int j = 0; j < width; ++j) {
			int index = i * width + j;
			
			int toRender = 0;
			if (index != selectedIndex && 
				(pieceLocation[index] == LOCATION_ON_BOARD || pieceLocation[index] == LOCATION_ON_TRAY_VISIBLE)) 
				toRender = 1;
			/*
			 else { 
			 if (pieceLocation[index] == LOCATION_ON_TRAY_VISIBLE) { 
			 int isInTray = 0;
			 for (int k = 0; k < nbPiecesPerTrayLine; ++k) {
			 int trayIndex = curTrayLine * nbPiecesPerTrayLine + k;
			 if (trayPieces[trayIndex] == index) {
			 isInTray = 1;
			 break;
			 }
			 }
			 if (isInTray)
			 toRender = 1;
			 }
			 }*/
			
			if (toRender)
			{
				x = currentPosition[index].x;
				y = currentPosition[index].y;
				
				glPushMatrix();
				// set piece view position
				glTranslatef(x, y + top, 0.0f); // translate the patch towards top of screen if needed
				glScalef(scaleX, scaleY, 1.0f);
				
				// render
				[pieces[index] render]; // piece is rendered from its center
				
				glPopMatrix();
			}
			
		}
	}
	
	//
	// render tray separation lines
	//
	/*
	const float lineVertices[] = {
		-160, 0.0f,
		160, 0.0f
	};
	glColor4f(0.7f, 0.7f, 0.7f, 1.0f);
	glLineWidth(1.0f);
	
	glDisable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(0.0f, top, 0.0f);
	glTranslatef(0.0f, y1 + 0.5 * pieceHeight - 2, 0.0f);
	glVertexPointer(2, GL_FLOAT, 0, lineVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_LINES, 0, 2);
	glPopMatrix();
	glEnable(GL_TEXTURE_2D);
	*/
	
	
	//
	// render selected
	//
	if (selectedIndex >= 0) {
		x = currentPosition[selectedIndex].x;
		y = currentPosition[selectedIndex].y;
		
		glPushMatrix();
		// set piece view position
		glTranslatef(x, y + top, 0.0f); // translate the patch towards top of screen if needed
		glScalef(scaleX, scaleY, 1.0f);
		
		int index = selectedIndex;
		
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		[pieces[index] render]; // piece is rendered from its center
		// render
		glColor4f(selectedColor.x, selectedColor.y, selectedColor.z, 1.0f);
		glLineWidth(1.5f);
		[pieces[index] renderSelected];
		glPopMatrix();
	}
	
	
	
	// start using textures and blending
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glBindTexture(GL_TEXTURE_2D, texButtons);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); // alpha in texture already premultiplied.  
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	// bar info
	const float barWidth2	= 48.0f;
	const float barHeight2	= 12.0f;
	const GLfloat barTexCoords[] = {
		70.0f / 128, (64 - 50.0f) / 64,
		70.0f / 128, (64 - 28.0f) / 64,
		0.0f  / 128, (64 - 50.0f) / 64, 
		0.0f  / 128, (64 - 28.0f) / 64
	};
	
	glTexCoordPointer(2, GL_FLOAT, 0, barTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	for (int i = 0; i < nbPiecesPerTrayLine; ++i) {
		glPushMatrix();
		int xc = trayPieceCorrectPosition[i].x;
		//int yc = trayPieceCorrectPosition[i].y;
		//glTranslatef(0.0f, top, 0.0f);
		//glTranslatef(xc, yc + top - pieceHeight * 0.95f, 0.0f);
		glTranslatef(xc, barPos.y + top, barPos.z);
		
		glScalef(0.5f, 0.5f, 1.0f); // always fixed the size of buttons instead of following scaleX and scaleY
		glScalef(barWidth2, barHeight2, 1.0f);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}
	
	
	// button info
	const float buttonWidth2 = 32;
	const float buttonHeight2 = 32;
	const GLfloat buttonBackTexCoords[] = {
		27.0f / 128, (64 - 27.0f) / 64,
		27.0f / 128, (64 - 0.0f) / 64,
		0.0f  / 128, (64 - 27.0f) / 64, 
		0.0f  / 128, (64 - 0.0f) / 64
	};
	const GLfloat buttonNextTexCoords[] = {
		54.0f / 128, (64 - 27.0f) / 64,
		54.0f / 128, (64 - 0.0f) / 64,
		27.0f  / 128, (64 - 27.0f) / 64, 
		27.0f  / 128, (64 - 0.0f) / 64
	};
	const GLfloat buttonNewTexCoords[] = {
		81.0f / 128, (64 - 27.0f) / 64,
		81.0f / 128, (64 - 0.0f) / 64,
		54.0f  / 128, (64 - 27.0f) / 64, 
		54.0f  / 128, (64 - 0.0f) / 64
	};
	
	// back button
	if (curTrayLine <= 0) // cannot go back
		glColor4f(0.5f, 0.5f, 0.5f, 1.0f);
	else
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glTexCoordPointer(2, GL_FLOAT, 0, buttonBackTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glPushMatrix();
	glTranslatef(buttonBackPos.x, buttonBackPos.y + top, buttonBackPos.z);
	glScalef(0.5f, 0.5f, 1.0f);
	glScalef(buttonWidth2, buttonHeight2, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	// next button
	if (curTrayLine >= nonEmptyTrayLines - 1) // cannot go next
		glColor4f(0.5f, 0.5f, 0.5f, 1.0f);
	else
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	
	glTexCoordPointer(2, GL_FLOAT, 0, buttonNextTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glPushMatrix();
	glTranslatef(buttonNextPos.x, buttonNextPos.y + top, buttonNextPos.z);
	glScalef(0.5f, 0.5f, 1.0f);
	glScalef(buttonWidth2, buttonHeight2, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	// new button
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glTexCoordPointer(2, GL_FLOAT, 0, buttonNewTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glPushMatrix();
	glTranslatef(buttonNewPos.x, buttonNewPos.y + top, buttonNewPos.z);
	glScalef(0.5f, 0.5f, 1.0f);
	glScalef(buttonWidth2, buttonHeight2, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
}

- (void) renderTransition {
	//
	// render transition
	//
	
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
	
	// render a box 
	glDisable(GL_TEXTURE_2D);
	glPushMatrix();
	glColor4f(1.0f, 1.0f, 1.0f, fadeInAlpha);
	glTranslatef(questionPosition.x, questionPosition.y + top, questionPosition.z);
	glScalef(fadeInScale.x, fadeInScale.y, fadeInScale.z);
	glScalef(scaleX, scaleY, 1.0f);
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	//glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	//glEnableClientState(GL_COLOR_ARRAY);
	//glTexCoordPointer(2, GL_FLOAT, 0, squareTexCoords);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	glEnable(GL_TEXTURE_2D);
	
	
}

- (void) renderTitle {
	glEnable(GL_BLEND);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glPushMatrix();
	glTranslatef(0.0f, top, 0.0f);
	[title drawAtPoint: CGPointMake(0.0f, trayTop)];
	glPopMatrix();
}

- (void) render {
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	switch (renderState) {
		case rsWaitForPlayer:
			[self renderBoard];
			[self renderTitle];
			break;
			
		case rsTransitionQuestionFadeIn: 
		{
			[self renderBoard];
			[self renderTransition];
			break;
		}
	}
}

- (void) update: (int) delta {
	// flashing selected piece
	float ratio = delta * 0.1f;
	selectedColor.x += selectedColorDelta.x * ratio;
	selectedColor.y += selectedColorDelta.y * ratio;
	selectedColor.z += selectedColorDelta.z * ratio;
	
	if (selectedColor.x >= SELECTED_COLOR_UPPER_RED && 
		selectedColor.y >= SELECTED_COLOR_UPPER_GREEN && 
		selectedColor.z >= SELECTED_COLOR_UPPER_BLUE) {
		selectedColorDelta.x = -selectedColorDelta.x;
		selectedColorDelta.y = -selectedColorDelta.y;
		selectedColorDelta.z = -selectedColorDelta.z;
	} else
	if (selectedColor.x <= SELECTED_COLOR_LOWER_RED &&
		selectedColor.y <= SELECTED_COLOR_LOWER_GREEN &&
		selectedColor.z <= SELECTED_COLOR_LOWER_BLUE) {
		selectedColorDelta.x = -selectedColorDelta.x;
		selectedColorDelta.y = -selectedColorDelta.y;
		selectedColorDelta.z = -selectedColorDelta.z;
	}

	// event handler
	if (count > 0) {
		struct EventJPoint e = qTouch[head];
		switch (e.eventType) {
			case EVENT_TOUCH_BEGAN:
			{
				[self onTouchBegan: e.point];
			}
			break;
				
			case EVENT_TOUCH_MOVED:
			{
				[self onTouchMoved: e.point];
			}
			break;
		}
		head = (head + 1) % QUEUE_SIZE;
		count--;
	}
	
	// transition state switch
	float ratioFx = delta * 0.1f;
	switch (renderState) {
		case rsTransitionQuestionFadeIn: {
			fadeInScale.x += fadeInScaleInc.x * ratioFx;
			fadeInScale.y += fadeInScaleInc.y * ratioFx;
			fadeInScale.z += fadeInScaleInc.z * ratioFx;
			fadeInAlpha += fadeInAlphaInc * ratioFx;
			
			if ((fadeInScaleInc.x >= 0.0f && fadeInScale.x >= fadeInScaleEnd.x)
			|| (fadeInScaleInc.x <= 0.0f && fadeInScale.x <= fadeInScaleEnd.x)	
			) {
				[self switchState:tvEnd];
			}
			break;
		}
	}
}

- (Piece*) testHitPieceOnGrid: (struct JPoint) p {
	//
	// convention: 
	// + Post transformed unit: pieceWidth, pieceHeight
	// + Pre transformed unit: x0, y0
	//
	// transform p into OpenGL coordinate
	float Ox = center.x;
	float Oy = center.y - top;
	
	float X = (p.x - Ox);
	float Y = -(p.y - Oy); // shift then flip
	float X0 = x0 - pieceWidth * 0.5f;
	float Y0 = y0 + pieceHeight * 0.5f;
	float X1 = X0 + screenSize;
	float Y1 = Y0 - screenSize;
	
	if (X < X0 || X > X1) return NULL;
	if (Y < Y1 || Y > Y0) return NULL;
	
	int j = floor((X - X0) / pieceWidth);
	int i = floor(-(Y - Y0) / pieceHeight); // doi` truc va` flip (shift then flip)
	selectedIndex = i * width + j;
	
	return pieces[selectedIndex];
}

- (Piece*) testHitPiece: (struct JPoint) p {
	//
	// convention: 
	// + Post transformed unit: pieceWidth, pieceHeight
	// + Pre transformed unit: x0, y0
	//
	// transform p into OpenGL coordinate
	float Ox = center.x;
	float Oy = center.y - top;
	
	float X = (p.x - Ox);
	float Y = -(p.y - Oy); // shift then flip
	//float X0 = x0 - pieceWidth * 0.5f;
	//float Y0 = y0 + pieceHeight * 0.5f;
	//float X1 = X0 + screenSize;
	//float Y1 = Y0 - screenSize;
	
	//if (X < X0 || X > X1) return NULL;
	//if (Y < Y1 || Y > Y0) return NULL;
	
	/*
	int j = floor((X - X0) / pieceWidth);
	int i = floor(-(Y - Y0) / pieceHeight); // doi` truc va` flip (shift then flip)
	selectedIndex = i * width + j;
	*/
	
	float minDist = FLOAT_INFINITY;
	for (int i = 0; i < nbPieces; ++i) {
		if ( ! (pieceLocation[i] == LOCATION_ON_BOARD ||
				pieceLocation[i] == LOCATION_ON_TRAY_VISIBLE) ) continue;
		float dx = X - currentPosition[i].x;
		float dy = Y - currentPosition[i].y;
		float dist = dx*dx + dy*dy;
		if (dist < minDist) 
		{	
			minDist = dist;
			selectedIndex = i;
		}
	}
	// too far return NULL
	if (minDist > pieceWidth * pieceHeight * 0.25f) {
		selectedIndex = -1;
		return NULL;
	}

	return pieces[selectedIndex];
}

- (bool) testHitTrayUp: (struct JPoint) p {
	float Ox = center.x;
	float Oy = center.y - top;
	
	float X = (p.x - Ox);
	float Y = -(p.y - Oy); // shift then flip
	float epsilon = 8.0f;
	
	if (buttonBackPos.x - epsilon <= X && X <= buttonBackPos.x + epsilon &&
		buttonBackPos.y - epsilon <= Y && Y <= buttonBackPos.y + epsilon) {
		//trayTop - epsilon <= Y && Y <= trayTop + epsilon) {
		curTrayLine = max(0, curTrayLine - 1);
		for (int i = 0; i < nbTrayLines; ++i) {
			for (int j = 0; j < nbPiecesPerTrayLine; ++j) {
				int index = i * nbPiecesPerTrayLine + j;
				if (trayPieces[index] == -1) continue;
				
				if (curTrayLine == i) {
					pieceLocation[trayPieces[index]] = LOCATION_ON_TRAY_VISIBLE;
				} else {
					pieceLocation[trayPieces[index]] = LOCATION_ON_TRAY_NOT_VISIBLE;
				}
			}
		}
		return true;
	}
	return false;
}

- (bool) testHitTrayDown: (struct JPoint) p {
	float Ox = center.x;
	float Oy = center.y - top;
	
	float X = (p.x - Ox);
	float Y = -(p.y - Oy); // shift then flip
	float epsilon = 8.0f;
	
	if (buttonNextPos.x - epsilon <= X && X <= buttonNextPos.x + epsilon &&
		buttonNextPos.y - epsilon <= Y && Y <= buttonNextPos.y + epsilon) {
	//if (trayBottom - epsilon <= Y && Y <= trayBottom + epsilon) {
		curTrayLine = min(nonEmptyTrayLines - 1, curTrayLine + 1);
		for (int i = 0; i < nbTrayLines; ++i) {
			for (int j = 0; j < nbPiecesPerTrayLine; ++j) {
				int index = i * nbPiecesPerTrayLine + j;
				if (trayPieces[index] == -1) continue;
			
				if (curTrayLine == i) {
					pieceLocation[trayPieces[index]] = LOCATION_ON_TRAY_VISIBLE;
				} else {
					pieceLocation[trayPieces[index]] = LOCATION_ON_TRAY_NOT_VISIBLE;
				}
			}
		}
		return true;
	}
	return false;
}

int snapped;
- (void) onTouchMoved: (struct JPoint) p {
	if (selectedIndex == -1) return;
	// transform p into OpenGL coordinate
	float Ox = center.x;
	float Oy = center.y - top;
	float X = (p.x - Ox);
	float Y = -(p.y - Oy); // shift then flip
	float snapThreshold = pieceWidth * pieceHeight * 0.035f;
	snapped = 0; // reset snapped bit
	
	if (Y >= trayTop) {
		//-----------------------------------------------------------------
		// snap to board
		//-----------------------------------------------------------------
		
		// reset the cellStat of the cell containing selectedIndex to empty
		for (int i = 0; i < nbPieces; ++i) { 
			if (cellStat[i] == selectedIndex) {
				cellStat[i] = CELL_STAT_EMPTY;
				break;
			}
		}
		
		for (int i = 0; i < nbPieces; ++i) {
			float dx = X - correctPosition[i].x;
			float dy = Y - correctPosition[i].y;
			
			if (dx*dx + dy*dy < snapThreshold) {
				// ensure this location is empty
				//int cellY = (y0 - correctPosition[i].y) / pieceHeight;
				//int cellX = (correctPosition[i].x - x0) / pieceWidth;
				//int cellIndex = cellY * width + cellX;
				int cellIndex = i;
				
				// allow to snap if the cell is empty
				if (cellStat[cellIndex] == CELL_STAT_EMPTY) {
					// ensure the selected piece to be similar to the correct piece in this location
					// so that it fits with its neighbors.
					bool isSimilar = ([pieces[selectedIndex] isSimilarTo: pieces[i]]);
					
					if (isSimilar) {
						X = correctPosition[i].x;
						Y = correctPosition[i].y;
						
						// remove piece out of tray
						pieceLocation[selectedIndex] = LOCATION_ON_BOARD;
						for (int i = 0; i < nbPiecesPerTrayLine; ++i) {
							int trayIndex = curTrayLine * nbPiecesPerTrayLine + i;
							if (trayPieces[trayIndex] == selectedIndex) {
								trayPieces[trayIndex] = -1;
								break;
							}
						}
						
						// update cell stat
						memcpy(cellStat, oldCellStat, sizeof(int) * nbPieces);
						cellStat[cellIndex] = selectedIndex; // put selected piece at current cell

						// snap
						snapped = 1;
						break;
					}
				}
			}
		}
	} else {
		//---------------------------------------------------------------
		// snap to tray
		//---------------------------------------------------------------
		if (pieceLocation[selectedIndex] != LOCATION_ON_BOARD) {
			// need to remove the occupied location on the tray for the selected piece
			// here the selectedIndex must be in curTrayLine only (if not then it's cannot be selected)
			for (int i = 0; i < nbPiecesPerTrayLine; ++i) {
				int trayIndex = curTrayLine * nbPiecesPerTrayLine + i;
				if (trayPieces[trayIndex] == selectedIndex) {
					trayPieces[trayIndex] = -1; 
				}
			}
		}
		for (int i = 0; i < nbPiecesPerTrayLine; ++i) {
			float dx = X - trayPieceCorrectPosition[i].x;
			float dy = Y - trayPieceCorrectPosition[i].y;
			
			if (dx*dx + dy*dy < snapThreshold) {
				X = trayPieceCorrectPosition[i].x;
				Y = trayPieceCorrectPosition[i].y;
				
				int trayPieceIndex = nbPiecesPerTrayLine * curTrayLine + i;
				if (trayPieces[trayPieceIndex] > -1 && trayPieces[trayPieceIndex] != selectedIndex) { // not empty
					int oldIndex = trayPieces[trayPieceIndex];
					// find another place for the old piece in tray
					for (int j = 0; j < nbMaxPiecesInTray; ++j) {
						if (trayPieces[j] == -1) {
							trayPieces[j] = oldIndex;
							int trayLine = j / nbPiecesPerTrayLine;
							if (trayLine == curTrayLine)
								pieceLocation[oldIndex] = LOCATION_ON_TRAY_VISIBLE;
							else
								pieceLocation[oldIndex] = LOCATION_ON_TRAY_NOT_VISIBLE;
							// update this piece to its new location
							int posInTrayLine = j % nbPiecesPerTrayLine;
							currentPosition[oldIndex] = trayPieceCorrectPosition[posInTrayLine];
							break;
						}
					}
				}
				// put the new piece in
				trayPieces[trayPieceIndex] = selectedIndex;
				pieceLocation[selectedIndex] = LOCATION_ON_TRAY_VISIBLE;

				// snap finished
				snapped = 1;
				break;
			}
		}
	}
	
	// only accept snapped pieces
	//if (snapped) {
		currentPosition[selectedIndex].x = X;
		currentPosition[selectedIndex].y = Y;
	
		//}
}

- (void) onTouchBegan: (struct JPoint) p {
	bool hit;
	hit = [self testHitTrayUp: p];
	if (! hit)
		hit = [self testHitTrayDown: p];
	if (! hit) {
		// record old context of the selected piece
		oldNbPiecesInTray = nbPiecesInTray;
		memcpy(oldPosition, currentPosition, sizeof(struct JPoint) * nbPieces);
		memcpy(oldPieceLocation, pieceLocation, sizeof(int) * nbPieces);
		memcpy(oldTrayPieces, trayPieces, sizeof(int) * nbMaxPiecesInTray);
		memcpy(oldCellStat, cellStat, sizeof(int) * nbPieces);
		
		[self testHitPiece: p];
	}
}

- (void) onTouchEnded: (struct JPoint) p {
	if (snapped == 0) {
		// revert to the old position of the selected index
		if (selectedIndex >= 0) {
			nbPiecesInTray = oldNbPiecesInTray;
			memcpy(currentPosition, oldPosition, sizeof(struct JPoint) * nbPieces);
			memcpy(pieceLocation, oldPieceLocation, sizeof(int) * nbPieces);
			memcpy(trayPieces, oldTrayPieces, sizeof(int) * nbMaxPiecesInTray);
			memcpy(cellStat, oldCellStat, sizeof(int) * nbPieces);
		}
		
		snapped = 1;
	} else {
		//
		// remove empty tray lines
		//
		int* isOccupiedLine		= (int*) malloc(sizeof(int) * nbTrayLines);
		int* outTrayLine		= (int*) malloc(sizeof(int) * nbTrayLines);
		
		for (int i = 0; i < nbTrayLines; ++i) {
			int isEmpty = 1;
			for (int j = 0; j < nbPiecesPerTrayLine; ++j) {
				int trayIndex = i * nbPiecesPerTrayLine + j;
				if (trayPieces[trayIndex] != -1) { 
					isEmpty = 0;
					break;
				}
			}
			isOccupiedLine[i] = 1 - isEmpty;
		}
		// prefix sum to compute the new output tray lines
		outTrayLine[0] = 0;
		for (int i = 1; i < nbTrayLines; ++i) {
			outTrayLine[i] = outTrayLine[i - 1] + isOccupiedLine[i - 1];
		}
		nonEmptyTrayLines = outTrayLine[nbTrayLines - 1] + isOccupiedLine[nbTrayLines - 1];
		
		// stream compaction
		for (int i = 0; i < nbTrayLines; ++i) {
			if (isOccupiedLine[i]) {
				if (i != outTrayLine[i]) {
					memcpy(trayPieces + outTrayLine[i] * nbPiecesPerTrayLine, trayPieces + i * nbPiecesPerTrayLine, sizeof(int) * nbPiecesPerTrayLine);
					memset(trayPieces + i * nbPiecesPerTrayLine, 0xFF, sizeof(int) * nbPiecesPerTrayLine); // -1
				}
			}
		}
		
		//
		// if snapped, count the nbPiecesInTray again for consistency
		//
		nbPiecesInTray = 0;
		for (int i = 0; i < nbPieces; ++i) {
			if (pieceLocation[i] != LOCATION_ON_BOARD)
				nbPiecesInTray++;
		}
		
		// check if all pieces are in correct position
		if ([self isComplete]) {
			[self switchState: tvAllCorrect];
		}
		
		free(isOccupiedLine);
		free(outTrayLine);
	}
}

- (void) queueTouchEvent: (struct EventJPoint) e {
	if (count >= QUEUE_SIZE) return;
	
	tail = (tail + 1) % QUEUE_SIZE;
	qTouch[tail] = e;
	count++;
}

- (void) createAutomata {
	// default is rsNull
	for (int i = 0; i < nbRenderStates; ++i)
		for (int j = 0; j < nbTransitionValues; ++j)
			automata[i][j] = rsNull;
	
	// transition
	automata[rsWaitForPlayer][tvFadeIn] = rsTransitionQuestionFadeIn;
	automata[rsTransitionQuestionFadeIn][tvEnd] = rsWaitForPlayer;
	
	// game over
	automata[rsWaitForPlayer][tvAllCorrect] = rsGameOver;
}

- (void) switchState: (enum TransitionValue) transitionValue {
	renderState = (RenderState)automata[renderState][transitionValue];
	switch (renderState) {
		case rsWaitForPlayer:
		{
			fadeInAlpha = fadeInAlphaEnd;
			fadeInScale.x = fadeInScaleEnd.x;
			fadeInScale.y = fadeInScaleEnd.y;
			fadeInScale.z = fadeInScaleEnd.z;
			break;
		}
			
		case rsTransitionQuestionFadeIn: 
		{
			// fade in values
			fadeInScaleStart.x = 20.0f;
			fadeInScaleStart.y = fadeInScaleStart.x;
			fadeInScaleStart.z = fadeInScaleStart.x;
			
			fadeInScaleEnd.x = 5.0f;
			fadeInScaleEnd.y = fadeInScaleEnd.x;
			fadeInScaleEnd.z = fadeInScaleEnd.x;
			
			fadeInScaleInc.x = -1.0f;
			fadeInScaleInc.y = fadeInScaleInc.x;
			fadeInScaleInc.z = fadeInScaleInc.x;
			
			int nbUpdates = ((fadeInScaleEnd.x - fadeInScaleStart.x) / fadeInScaleInc.x);
			
			fadeInAlphaStart = 0.05f;
			fadeInAlphaEnd = 0.5f;
			fadeInAlphaInc = (fadeInAlphaEnd - fadeInAlphaStart) / nbUpdates;
			
			fadeInAlpha = fadeInAlphaStart;
			fadeInScale.x = fadeInScaleStart.x;
			fadeInScale.y = fadeInScaleStart.y;
			fadeInScale.z = fadeInScaleStart.z;
			
			// generate new question mark position
			questionIndex = missing[randomInteger(missingStart, missingEnd)];
			questionPosition = correctPosition[questionIndex];
			break;
		}
	}
}

- (bool) isComplete {
	for (int i = 0; i < width * height; ++i) {
		if (cellStat[i] != i) 
			return false;
	}
	return true;
}

@end
