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

@implementation Board
@synthesize width, height;

- (id) initWithSize: (int) _width : (int) _height {
	if ((self = [super init]) != NULL) {
		width = _width;
		height = _height;
		nbPieces = width * height;
		
		// screen
		CGRect screenRect = [[UIScreen mainScreen] bounds];
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
		selectedColor.x = SELECTED_COLOR_LOWER;
		selectedColor.y = SELECTED_COLOR_LOWER;
		selectedColor.z = SELECTED_COLOR_LOWER;
		selectedColorDelta = SELECTED_COLOR_DELTA;
		
		// piece position (before scale)
		correctPosition = (struct JPoint*) malloc(nbPieces * sizeof(struct JPoint));
		currentPosition = (struct JPoint*) malloc(nbPieces * sizeof(struct JPoint));
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
		trayTop		= y + 0.25f * pieceHeight;; // let tray top be half piece after the board
		trayBottom	= y - 1.5f * pieceHeight;
		
		lineVerts[0] = -center.x; lineVerts[1] = trayTop; lineVerts[2] = 0.0f;
		lineVerts[3] = +center.x; lineVerts[4] = trayTop; lineVerts[5] = 0.0f;
		lineVerts[6] = -center.x; lineVerts[7] = trayBottom; lineVerts[8] = 0.0f;
		lineVerts[9] = +center.x; lineVerts[10] = trayBottom; lineVerts[11] = 0.0f;
		
		
		nbPiecesPerTrayLine		= 3;
		nbTrayLines				= (nbPieces + nbPiecesPerTrayLine - 1) / nbPiecesPerTrayLine;
		curTrayLine				= 0;
		nbMaxPiecesInTray		= nbPiecesPerTrayLine * nbTrayLines;
		
		trayPieces = (int*) malloc(sizeof(int) * nbMaxPiecesInTray);
		pieceLocation = (int*) malloc(sizeof(int) * nbPieces);
		
		nbPiecesInTray			= 0;
		for (int i = 0; i < nbPieces; ++i) {
			pieceLocation[i] = LOCATION_ON_BOARD;
		}
		for (int i = 0; i < nbMaxPiecesInTray; ++i) {
			trayPieces[i] = -1;
		}
		
		trayPieceWidth = pieceWidth * 1.5f;
		float gap = (screenSize - nbPiecesPerTrayLine * trayPieceWidth) / (nbPiecesPerTrayLine + 1.0f);
		float trayPieceX0 = - (trayPieceWidth + gap);
		//float trayPieceY0 = 0.5f * (trayTop + -center.y) - pieceHeight * 0.5f;
		float trayPieceY0 = 0.5f * (trayTop + trayBottom);
		float tx = trayPieceX0;
		float ty = trayPieceY0;
		trayPieceCorrectPosition = (struct JPoint*) malloc(sizeof(struct JPoint) * nbPiecesPerTrayLine);
		for (int i = 0; i < nbPiecesPerTrayLine; ++i) {
			trayPieceCorrectPosition[i].x = tx;
			trayPieceCorrectPosition[i].y = ty;
			trayPieceCorrectPosition[i].z = 0.0f;
			
			tx += trayPieceWidth + gap;
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
		renderState = WaitForPlayer;
		
		// default, no top offset
		[self setTopOffset: pieceHeight];
		[self createPiecesGeometry];
	}
	return self;
}

- (void) setTopOffset: (float) _top {
	top = _top;
}


- (void) dealloc {
	free(pieces);
	free(qTouch);
	free(trayPieceCorrectPosition);
	free(pieceLocation);
	[super dealloc];
}

- (void) loadResources {
	// try to load a texture
	texPhoto = [[TextureManager instance] getJigsawPhoto:@"manutd512.png"];
	
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
			int index = i * width + j;
			pieces[index] = [[Piece alloc] initWithMesh: index: pieceMesh];
		}
	}
	
	// clean up
	free(grid);
}

- (void) render {
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
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	
	glLineWidth(2.0f);
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
	glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
	glLineWidth(3.0f);
	
	glDisable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(0.0f, top, 0.0f);
	glVertexPointer(3, GL_FLOAT, 0, lineVerts);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_LINES, 0, 4);
	glPopMatrix();
	glEnable(GL_TEXTURE_2D);
	
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
		
		// render
		glColor4f(selectedColor.x, selectedColor.y, selectedColor.z, 1.0f);
		[pieces[index] render]; // piece is rendered from its center
		[pieces[index] renderSelected];
		glPopMatrix();
	}
}

- (void) update: (int) delta {
	float ratio = delta * 0.1f;
	selectedColor.x += selectedColorDelta * ratio;
	selectedColor.y += selectedColorDelta * ratio;
	selectedColor.z += selectedColorDelta * ratio;
	
	if (selectedColor.x > SELECTED_COLOR_UPPER) selectedColorDelta = -selectedColorDelta;
	if (selectedColor.x < SELECTED_COLOR_LOWER) selectedColorDelta = -selectedColorDelta;

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
	float X0 = x0 - pieceWidth * 0.5f;
	float Y0 = y0 + pieceHeight * 0.5f;
	float X1 = X0 + screenSize;
	float Y1 = Y0 - screenSize;
	
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
	
	if (trayTop - epsilon <= Y && Y <= trayTop + epsilon) {
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
	
	if (trayBottom - epsilon <= Y && Y <= trayBottom + epsilon) {
		curTrayLine = min(nbTrayLines, curTrayLine + 1);
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


- (void) onTouchMoved: (struct JPoint) p {
	if (selectedIndex == -1) return;
	// transform p into OpenGL coordinate
	float Ox = center.x;
	float Oy = center.y - top;
	float X = (p.x - Ox);
	float Y = -(p.y - Oy); // shift then flip
	float snapThreshold = pieceWidth * pieceHeight * 0.035f;
	
	if (Y >= trayTop) {
		// snap to board
		for (int i = 0; i < nbPieces; ++i) {
			float dx = X - correctPosition[i].x;
			float dy = Y - correctPosition[i].y;
			
			if (dx*dx + dy*dy < snapThreshold) {
				X = correctPosition[i].x;
				Y = correctPosition[i].y;
				break;
			}
		}
	} else {
		// snap to tray
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
				break;
			}
		}
	}
	
	currentPosition[selectedIndex].x = X;
	currentPosition[selectedIndex].y = Y;
}

- (void) onTouchBegan: (struct JPoint) p {
	bool hit;
	hit = [self testHitTrayUp: p];
	if (! hit)
		hit = [self testHitTrayDown: p];
	if (! hit)
		[self testHitPiece: p];
}

- (void) queueTouchEvent: (struct EventJPoint) e {
	if (count >= QUEUE_SIZE) return;
	
	tail = (tail + 1) % QUEUE_SIZE;
	qTouch[tail] = e;
	count++;
}
@end
