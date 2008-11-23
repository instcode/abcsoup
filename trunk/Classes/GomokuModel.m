//#include "console.h"
//#include <conio.h>
//#include <stdio.h>
#import "GomokuModel.h"
#include <stdlib.h>
#include <time.h>
//#include <ncurses.h>



#define MAXDEPTH 30
#define INFI 10000
#define WIN 5000

//const int Size = 18;
//#define Size 18
#define Size DEFAULT_BOARD_SIZE

//const int RowSize = Size+2;
#define RowSize (Size+2)
//const int BoardSize = RowSize*RowSize;
#define BoardSize (RowSize*RowSize)
//const int TopLeft = RowSize+1;
#define TopLeft (RowSize+1)
//const int BotRight = BoardSize-RowSize-1;
#define BotRight (BoardSize-RowSize-1)

#define gotoxy(x, y) move(x, 2*(y))
#define cprintf(x) printw(x)
#define textcolor(x) attron(COLOR_PAIR(x))
#define endtextcolor(x) attroff(COLOR_PAIR(x))

int Direct[8] = {1,RowSize,RowSize+1,RowSize-1,-1,-RowSize,-RowSize-1,-RowSize+1};
int ScoreMask[10] = {0,1,10,100,1000,INFI,INFI,INFI,INFI,INFI};
int Side;
int Depth;
int StopDepth;
int Moves[BoardSize];
int Track[BoardSize];
int ManIndex[BoardSize][8];
int ComIndex[BoardSize][8];
int BestMove[MAXDEPTH];

int *pGenEnd[MAXDEPTH];
int *pMoveEnd;

int GenDat[MAXDEPTH][BoardSize];

int GameOver;
int Board[BoardSize];

void Restart(int InitDepth, int InitStop);
int MakeManMove(int Move);
int MakeComMove(int Move);
void RestoreMan(int Move);
void RestoreCom(int Move);
int Evaluate(int Side);
void Sort(int A[], int D[], int l, int r);
void GenManDangerMove(int Ply);
void GenComDangerMove(int Ply);
void GenMan4Move(int Ply);
void GenCom4Move(int Ply);
void GenMove(int Ply);

int GetStroke(int* _Move, int R);
void PrintChar(int Move, int Ch);
void Print();
int EndManSearch(int Ply, int Alpha, int Beta);
int QuiesComSearch(int Ply, int Alpha, int Beta);
int QuiesManSearch(int Ply, int Alpha, int Beta);
int ManSearch(int Ply, int Alpha, int Beta);

int ComSearch(int Ply, int Alpha, int Beta);
int ManSearch(int Ply, int Alpha, int Beta);
void PrintOpinion(int R, int* _Roi);
void PrintIdea(int Index);

// ============================ GomokuModel wrapper methods ==================== //
@implementation GomokuModel

@synthesize boardSize;
@dynamic	humanPiece;
@dynamic	computerPiece;
@synthesize side;
@synthesize searchDepth;
@synthesize isComputerThinking;

- (void)setHumanPiece:(int)piece {
	humanPiece		= piece;
	computerPiece	= 1 - humanPiece;
}
- (int)getHumanPiece {
	return humanPiece;
}
- (void)setComputerPiece:(int)piece {
	computerPiece	= piece;
	humanPiece		= 1 - computerPiece;
}
- (int)getComputerPiece {
	return computerPiece;
}

// init with a board size and a search depth
- (GomokuModel*)init {
	// set default values
	[self setBoardSize:DEFAULT_BOARD_SIZE];
	[self setSearchDepth:DEFAULT_SEARCH_DEPTH];
	//observers = [NSMutableSet setWithCapacity:10]; // why use this do not work??? be empty after a while?
	observers = [[NSMutableSet alloc] init];
	
	[self restart];
	
	return self;
}

- (void)restart {
	// restart 
	Restart(3, searchDepth);
	isComputerThinking = false;
	
	// allocate history moves
	history = (int*)malloc(boardSize*boardSize*sizeof(int));
	numMoves = 0;
	
	// make COM move first
	int Move = [self indexOf:boardSize/2 column:boardSize/2];
	MakeComMove(Move);
	Side = MAN;
	side = MAN;
	// <special> //
	// here computerMove is not called, we must do a manual insert to history array.
	[self historyPush:Move];	
		
	// update view
	[self notifyGomoku];
}

- (int)indexOf:(int)row column:(int)col {
	return (row+1)*(boardSize+2) + col+1;
	//return (col+1)*(boardSize+2) + row+1; // Khoa made x as row, y as col. I assume y as row, x as col.
}
- (int)getBoardValue:(int)row column:(int)col {
	int i = [self indexOf:row column:col];
	return Board[i];
}

/*
- (void)setBoardValue:(int)value row:(int)r column:(int)c {
	int i = [self indexOf:r column:c];
	Board[i] = value;	
	
	// ask for view update
	//[self notifyGomoku];
}*/

- (int)humanMove:(int)row column:(int)col {
	int Move = [self indexOf:row column:col];
	GameOver = MakeManMove(Move);
	side = 1 - side;
	
	// history push
	[self historyPush:Move];
	
	[self notifyGomoku];
	return 0;
}

- (int)computerMove {
	isComputerThinking = true;
	int R = ComSearch(0, -INFI, INFI);
	int Move = BestMove[0];
	
	int row = Move / (boardSize+2) - 1;
	int col = Move % (boardSize+2) - 1;
	
	GameOver = MakeComMove(Move);
	side = 1 - side;
	
	// history push
	[self historyPush:Move];
	
	isComputerThinking = false; // must end thinking before 
	[self notifyGomoku];	
	return row*boardSize+col; // return how computer moved
}

- (int)isGameOver {
	return GameOver;
}

// ----- observable ----- //
- (void)attachGomoku:(id<GomokuObserver>)observer {
	[observers addObject:observer];
}

- (void)notifyGomoku {
	for (id<GomokuObserver> ob in observers) {
		[ob onGomokuNotify:self];
		//[ob onGomokuNotify:(id<GomokuObservable>)self];
		//[ob onGomokuNotify:<#(id GomokuObservable)observable#>
	}
}

// ----- history management ----- //
- (void)historyPush:(int)move {
	history[numMoves++] = move;
}

- (void)historyPop {
}

//- (void)historyVisit:(void (*)(int, int, int))visitor {
- (void)historyVisit:(id)visitor withSelector:(SEL)sel {
	int x, y, val, i;
	val = 0; // default is the first player
	int* h = history;
	for (i = 0; i < numMoves; i++, h++) {
		// decode move
		y = *h / RowSize - 1;
		x = *h % RowSize - 1;
		
		// visit
		IMP visit = [visitor methodForSelector:sel]; // get visit implementor
		visit(visitor, sel, x, y, val); // Objective-C style 
		
		//(*visitor)(x, y, val); // C-style function pointer
		
		// next player
		val = 1 - val;
	}
}

// ----- a little house keeping ----- //
- (void)dealloc {
	// clean up
	free(history);
	
}

@end

// ============================= TrumCaro.c functions ========================== //
void Restart(int InitDepth, int InitStop) {
	Depth = InitDepth;
	StopDepth = InitStop;
	for (int i = 0; i< BoardSize; i++){
		Board[i] = EDGE;
		for (int j = 0; j<8; j++){
			ManIndex[i][j] = 0;
			ComIndex[i][j] = 0;
		}
		Track[i] = 0;
		Moves[i] = 0;
	}
	for (int i = TopLeft; i < BotRight; i += RowSize)
		for (int j = 0; j < Size;j++) Board[i+j] = EMPTY;
	pMoveEnd = &Moves[0];
	GameOver = 0;
}

int MakeManMove(int Move){
int cFor, cBack, mFor, mBack, Ret = 0;
const int *p = &Direct[0];
	Board[Move] = MAN;
	for (int d = 0; d<4; d++){
		cFor = ManIndex[Move][d]+1;mFor = Move+*p*cFor;
		cBack = ManIndex[Move][d+4]+1;mBack = Move+*(p+4)*cBack;
		ManIndex[mFor][d+4] += cBack;
		ManIndex[mBack][d] += cFor;
		if ((Board[mFor] == EMPTY)&&(!Track[mFor])) *++pMoveEnd = mFor;
		if ((Board[mBack] == EMPTY)&&(!Track[mBack])) *++pMoveEnd = mBack;
		Track[mFor] += cBack;
		Track[mBack] += cFor;
		if ((cFor+cBack)==6) Ret = 1;
		p++;
	}
	return Ret;
}

int MakeComMove(int Move){
int cFor, cBack, mFor, mBack, Ret = 0;
const int *p = &Direct[0];
	Board[Move] = COM;
	for (int d = 0; d<4; d++){
		cFor = ComIndex[Move][d]+1;mFor = Move+*p*cFor;
		cBack = ComIndex[Move][d+4]+1;mBack = Move+*(p+4)*cBack;
		ComIndex[mFor][d+4] += cBack;
		ComIndex[mBack][d] += cFor;
		if ((Board[mFor] == EMPTY)&&(!Track[mFor])) *++pMoveEnd = mFor;
		if ((Board[mBack] == EMPTY)&&(!Track[mBack])) *++pMoveEnd = mBack;
		Track[mFor] += cBack;
		Track[mBack] += cFor;
		if ((cFor+cBack)==6) Ret = 1;
		p++;
	}
	return Ret;
}

void RestoreMan(int Move){
int cFor, cBack, mFor, mBack;
const int *p = &Direct[0];

	Board[Move] = EMPTY;
	for (int d = 0; d<4; d++){
		cFor = ManIndex[Move][d]+1;mFor = Move+*p*cFor;
		cBack = ManIndex[Move][d+4]+1;mBack = Move+*(p+4)*cBack;
		ManIndex[mFor][d+4] -= cBack;
		ManIndex[mBack][d] -= cFor;
		Track[mFor] -= cBack;
		Track[mBack] -= cFor;
		p++;
	}
}

void RestoreCom(int Move){
int cFor, cBack, mFor, mBack;
const int *p = &Direct[0];

	Board[Move] = EMPTY;
	for (int d = 0; d < 4; d++){
		cFor = ComIndex[Move][d]+1;mFor = Move+*p*cFor;
		cBack = ComIndex[Move][d+4]+1;mBack = Move+*(p+4)*cBack;
		ComIndex[mFor][d+4] -= cBack;
		ComIndex[mBack][d] -= cFor;
		Track[mFor] -= cBack;
		Track[mBack] -= cFor;
		p++;
	}
}

int Evaluate(int Side){
int *p = pMoveEnd, Move, ManScore = 0, d;
	while ((Move = *p--) != 0){
		if (Board[Move] == EMPTY)
			for (d = 0; d < 4; d++)
				ManScore += ScoreMask[ManIndex[Move][d]+ManIndex[Move][d+4]]
									 -ScoreMask[ComIndex[Move][d]+ComIndex[Move][d+4]];
	}
	if (Side == MAN)return ManScore;
	else return -ManScore;
}

void Sort(int A[], int D[], int l, int r){
int	i, j, x, y;
	i = l; j = r; x = D[(l+r)/2];
	do{
		while (D[i] < x) i++;
		while (x < D[j]) j--;
		if (i <= j){
			y = A[i]; A[i] = A[j]; A[j] = y;
			y = D[i]; D[i] = D[j]; D[j] = y;
			i++;j--;
		}
	}
	while (i <= j);
	if (l < j) Sort(A, D, l, j);
	if (i < r) Sort(A, D, i, r);
}

void GenManDangerMove(int Ply){
int *p = pMoveEnd, Move, i, Value[BoardSize], *pV, Ti, Ti4, T;
	pGenEnd[Ply] =	&GenDat[Ply][0];
	pV = &Value[0];
	Value[0] = 0;
	while ((Move = *p--) != 0)
		if (Board[Move] == EMPTY)
			for (i = 0; i<4; i++){
				Ti = ManIndex[Move][i]+1;
				Ti4 = ManIndex[Move][i+4]+1;
				T = ComIndex[Move][i]+ComIndex[Move][i+4];
				if ((Ti+Ti4)>4)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = Ti+Ti4;}
					else *pV += Ti+Ti4;
				else
					if ((Ti+Ti4>3)&&
							(Board[Move+Direct[i]*Ti]==EMPTY)&&
							(Board[Move+Direct[i+4]*Ti4] ==EMPTY))
						if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = 4;}
						else *pV += 4;
				if (T > 2)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = 5;}
					else *pV += 5;
			}
	Sort(GenDat[Ply], Value, 1, pGenEnd[Ply]-&GenDat[Ply][0]);
}

void GenComDangerMove(int Ply){
int *p = pMoveEnd, Move, i, Value[BoardSize], *pV, Ti, Ti4, T;
	pGenEnd[Ply] =	&GenDat[Ply][0];
	pV = &Value[0];
	Value[0] = 0;
	while ((Move = *p--) != 0)
		if (Board[Move] == EMPTY)
			for (i = 0; i<4; i++){
				Ti = ComIndex[Move][i]+1;
				Ti4 = ComIndex[Move][i+4]+1;
				T = ManIndex[Move][i]+ManIndex[Move][i+4];
				if ((Ti+Ti4)>4)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = Ti+Ti4;}
					else *pV += Ti+Ti4;
				else
					if ((Ti+Ti4>3)&&
							(Board[Move+Direct[i]*Ti]==EMPTY)&&
							(Board[Move+Direct[i+4]*Ti4] ==EMPTY))
						if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = 4;}
						else *pV += 4;
				if (T > 2)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = 5;}
					else *pV += 5;
			}
	Sort(GenDat[Ply], Value, 1, pGenEnd[Ply]-&GenDat[Ply][0]);
}

void GenMan4Move(int Ply){
int *p = pMoveEnd, Move, i, Value[BoardSize], *pV, Ti, T;
	pGenEnd[Ply] =	&GenDat[Ply][0];
	pV = &Value[0];
	Value[0] = 0;
	while ((Move = *p--) != 0)
		if (Board[Move] == EMPTY)
			for (i = 0; i<4; i++){
				Ti = ManIndex[Move][i]+ManIndex[Move][i+4];
				T = ComIndex[Move][i]+ComIndex[Move][i+4];
				if (Ti>3)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = Ti;}
					else *pV += Ti;
				if (T > 3)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = T;}
					else *pV += T;
			}
	Sort(GenDat[Ply], Value, 1, pGenEnd[Ply]-&GenDat[Ply][0]);
}

void GenCom4Move(int Ply){
int *p = pMoveEnd, Move, i, Value[BoardSize], *pV, Ti,T;
	pGenEnd[Ply] =	&GenDat[Ply][0];
	pV = &Value[0];
	Value[0] = 0;
	while ((Move = *p--) != 0)
		if (Board[Move] == EMPTY)
			for (i = 0; i<4; i++){
				Ti = ComIndex[Move][i]+ComIndex[Move][i+4];
				T = ManIndex[Move][i]+ManIndex[Move][i+4];
				if (Ti>3)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = Ti;}
					else *pV += Ti;
				if (T > 3)
					if (*pGenEnd[Ply]!=Move){*++pGenEnd[Ply] = Move;*++pV = T;}
					else *pV += T;
			}
	Sort(GenDat[Ply], Value, 1, pGenEnd[Ply]-&GenDat[Ply][0]);
}
void GenMove(int Ply){
int *p = pMoveEnd, Move, *i, Value[BoardSize], *pV;
int Mask[7] = {0, 0, 1, 10, 100, 1000, 0};
	pGenEnd[Ply] =	&GenDat[Ply][0];
	pV = &Value[0];
	Value[0] = 0;
	while ((Move = *p--) != 0)
		if (Board[Move] == EMPTY){
			*++pGenEnd[Ply] = Move;
			i = &ManIndex[Move][0];
			*++pV = Mask[*&i[0]+*&i[4]]+Mask[*&i[1]+*&i[5]]+
							Mask[*&i[2]+*&i[6]]+Mask[*&i[3]+*&i[7]];
			i = &ComIndex[Move][0];
			*pV += Mask[*&i[0]+*&i[4]]+Mask[*&i[1]+*&i[5]]+
							Mask[*&i[2]+*&i[6]]+Mask[*&i[3]+*&i[7]];
			//*++pV = Track[Move];
		}
	Sort(GenDat[Ply], Value, 1, pGenEnd[Ply]-&GenDat[Ply][0]);
}

int GetStroke(int* _Move, int R){
	int Move = *_Move;
	
	//char Ch;
	int Ch;
	int X, Y;
	X = Move % RowSize;
	Y = Move / RowSize;
    if (R == 0) R = 1;
	while (1){
		gotoxy(X, Y);
		Ch = getch();
		//printw("%d", Ch);
		//refresh();
		//getch();
		switch (Ch){
		/*
		case 72:if (Y--<2) Y = Size;break;
		case 80:if (++Y>Size) Y = 1;break;
		case 77:if (++X>Size) X = 1;break;
		case 75:if (X--<2) X = Size;break;
		*/
		/*
		case KEY_UP:if (Y--<2) Y = Size;break;
		case KEY_DOWN:if (++Y>Size) Y = 1;break;
		case KEY_RIGHT:if (++X>Size) X = 1;break;
		case KEY_LEFT:if (X--<2) X = Size;break;
		*/
			case 'A':
			case 'a':
				if (Y--<2) Y = Size;break;
			case 'D':
			case 'd':
				if (++Y>Size) Y = 1;break;
			case 'S':
			case 's':
				if (++X>Size) X = 1;break;
			case 'W':
			case 'w':
				if (X--<2) X = Size;break;
		 case 32:
		case 13:
			Move = *_Move = (Y*RowSize+X);
			if (Board[Move] == EMPTY) return 0; //oke?
		case 27: return 1; // gameover?
		}
	}
	
	*_Move = Move;
}

void PrintChar(int Move, int Ch){
	gotoxy(Move%RowSize, Move/RowSize);
	switch (Ch){
		case MAN:
			//textcolor(14);
			textcolor(2);
			cprintf("O");
			endtextcolor(2);
			break;
		case COM:
			textcolor(1);
			cprintf("X");
			endtextcolor(1);
			break;
		case EMPTY:
			textcolor(0);
			cprintf(" ");
			endtextcolor(0);
			break;
		case EDGE: 
			textcolor(0);
			cprintf("+");
			endtextcolor(0);
			break;
	}
}

void Print(){
	//clrscr();
	clear(); textcolor(0);
	for (int i = 0; i<BoardSize; i++)
		//if (Board[i]!=EDGE)	
			PrintChar(i, Board[i]);
}
int EndManSearch(int Ply, int Alpha, int Beta);
int EndComSearch(int Ply, int Alpha, int Beta){
	int *Move, Value, *pTemp;
	if (Ply == Depth*3) return Evaluate(COM);
	else{
		GenCom4Move(Ply);
		if (!*pGenEnd[Ply]) return Evaluate(COM);
		pTemp = pMoveEnd;
		for (Move = pGenEnd[Ply]; *Move; Move--){
			if (MakeComMove(*Move)) Value = WIN-Ply;
			else Value = -EndManSearch(Ply+1, -Beta, -Alpha);
			RestoreCom(*Move);
			pMoveEnd = pTemp;
			if (Value>Alpha){
				Alpha = Value;BestMove[Ply]=*Move;
				if (Value>=Beta) return Alpha;
			}
		}
		return Alpha;
	}
}
int EndManSearch(int Ply, int Alpha, int Beta){
	int *Move, Value, *pTemp;
	if (Ply == Depth*3) return Evaluate(MAN);
	else{
		GenMan4Move(Ply);
		if (!*pGenEnd[Ply]) return Evaluate(MAN);
		pTemp = pMoveEnd;
		for (Move = pGenEnd[Ply]; *Move; Move--){
			if (MakeManMove(*Move)) Value = WIN-Ply;
			else Value = -EndComSearch(Ply+1, -Beta, -Alpha);
			RestoreMan(*Move);
			pMoveEnd = pTemp;
			if (Value>Alpha){
				Alpha = Value;BestMove[Ply]=*Move;
				if (Value>=Beta)return Alpha;
			}
		}
		return Alpha;
	}
}

int QuiesManSearch(int Ply, int Alpha, int Beta);
int QuiesComSearch(int Ply, int Alpha, int Beta){
	int *Move, Value, *pTemp;
	if (Ply == StopDepth) return EndComSearch(Ply, Alpha, Beta);
	else{
		GenComDangerMove(Ply);
		if (!*pGenEnd[Ply]) return Evaluate(COM);
		pTemp = pMoveEnd;
		for (Move = pGenEnd[Ply]; *Move; Move--){
			if (MakeComMove(*Move)) Value = WIN-Ply;
			else Value = -QuiesManSearch(Ply+1, -Beta, -Alpha);
			RestoreCom(*Move);
			pMoveEnd = pTemp;
			if (Value>Alpha){
				Alpha = Value;BestMove[Ply]=*Move;
				if (Value>=Beta)return Alpha;
			}
		}
		return Alpha;
	}
}

int QuiesManSearch(int Ply, int Alpha, int Beta){
	int *Move, Value, *pTemp;
	if (Ply == StopDepth) return EndManSearch(Ply, Alpha, Beta);
	else{
		GenManDangerMove(Ply);
		if (!*pGenEnd[Ply]) return Evaluate(MAN);
		pTemp = pMoveEnd;
		for (Move = pGenEnd[Ply]; *Move; Move--){
			if (MakeManMove(*Move)) Value = WIN-Ply;
			else Value = -QuiesComSearch(Ply+1, -Beta, -Alpha);
			RestoreMan(*Move);
			pMoveEnd = pTemp;
			if (Value>Alpha){
				Alpha = Value;BestMove[Ply]=*Move;
				if (Value>=Beta)return Alpha;
			}
		}
		return Alpha;
	}
}
int ManSearch(int Ply, int Alpha, int Beta);

int ComSearch(int Ply, int Alpha, int Beta){
	int *Move, Value, *pTemp;
	if (Ply == Depth) return QuiesComSearch(Ply, Alpha , Beta);
	else{
		GenMove(Ply);
		pTemp = pMoveEnd;
		for (Move = pGenEnd[Ply]; *Move; Move--){
			if (MakeComMove(*Move)) Value = WIN-Ply;
			else Value = -ManSearch(Ply+1, -Beta, -Alpha);
			RestoreCom(*Move);
			pMoveEnd = pTemp;
			if (Value>Alpha){
				Alpha = Value;BestMove[Ply]=*Move;
				if (Value>=Beta)return Alpha;
			}
		}
		return Alpha;
	}
}

int ManSearch(int Ply, int Alpha, int Beta){
	int *Move, Value, *pTemp;
	if (Ply == Depth) return QuiesManSearch(Ply, Alpha , Beta);
	else{
		GenMove(Ply);
		pTemp = pMoveEnd;
		for (Move = pGenEnd[Ply]; *Move; Move--){
			if (MakeManMove(*Move)) Value = WIN-Ply;
			else Value = -ComSearch(Ply+1, -Beta, -Alpha);
			RestoreMan(*Move);
			pMoveEnd = pTemp;
			if (Value>Alpha){
				Alpha = Value;BestMove[Ply]=*Move;
				if (Value>=Beta)return Value;
			}
		}
		return Alpha;
	}
}

void PrintOpinion(int R, int* _Roi){
	int Roi = *_Roi;
	
char *St[18] ={" Thua roi ong oi",
			   " Tieu ong roi",
			   " Thoi roi, tieu roi cung",
			   " Thay duong thua chua",
			   " Coi ne",
			   " Truoc sau gi cung thua ha",
			   " Du nghen !",
			   " Tieu tui roi",
			   " Chac tui thua qua",
			   " Danh dang hoang hong tha he ",
			   " Danh hong tha nhe",
			   " Danh dung co tha nghen",
			   " Con nit",
			   " Hoc danh them di cung",
			   " Do ec",
			   " Tui thua.",
			   " Thua...",
			   " Danh cung kha..."};
	time_t t;
	srand((unsigned) time(&t));
	gotoxy(2,23);
	if (R == 5000)
		cprintf(St[rand()%3+12]);
	else
		if (R == -5000)
			cprintf(St[rand()%3+15]);
		else
			if (R > 5000){
				if (Roi != 1){
					cprintf(St[rand()%3]);Roi = 1;
				}
			}
			else
				if (R < -5000){
					if (Roi != 1){
						cprintf(St[6+rand()%3]);Roi = 1;
					}
				}
				else
					if (Roi == 1){
						cprintf(St[9+rand()%3]);Roi = 0;
					}
	
	// return
	*_Roi = Roi;
}

void PrintIdea(int Index){
char *St[3] ={
	" Tu nhien thoat dzay ? ",
	" Sao tu nhien thoat ? ",
	" Dang hap dan ma sao thoat ngang dzay ?"};
	gotoxy(2,23);
	cprintf(St[Index]);
}
/*
int main1(){
	initscr();				// Start curses mode			
	if(has_colors() == FALSE)
	{	
		endwin();
		printf("Your terminal does not support color\n");
		exit(1);
	}
	start_color();			// Start color					
	init_pair(0, COLOR_WHITE, COLOR_BLACK);
	init_pair(1, COLOR_RED, COLOR_BLACK);
	init_pair(2, COLOR_GREEN, COLOR_BLACK);
	//init_pair(3, COLOR_WHITE, COLOR_BLACK);
	noecho(); // do not print keyboard input out to screen
	
	
	int Move, R = 0, Roi = 0, Winner = 3;
	Restart(3,6);
	//textmode(C40);
	Move = (BoardSize-RowSize)/2;
	MakeComMove(Move);
	Side = MAN;
	Print();
	Winner = 10;
	while (!GameOver) {
		gotoxy(0, 0);
		if (Side == COM)
		{
			R = ComSearch(0, -INFI, INFI);
			Move = BestMove[0];
		}
		else if ((GameOver = GetStroke(&Move, R)) != 0) break;
		if (Side == MAN){
			GameOver = MakeManMove(Move);
			if (GameOver) Winner = MAN;
		}
		else if ((GameOver = MakeComMove(Move)) != 0) Winner = COM;
		Side = 1-Side;
		Print();
		if (Side == MAN)PrintOpinion(R, &Roi);
		
		// refresh after printw
		refresh();
	}
	if (Winner == COM) PrintOpinion(5000, &Roi);
	else
		if (Winner == MAN) PrintOpinion(-5000, &Roi);
		else PrintIdea(rand()%3);

	getch();
	//textmode(C80);
	endwin();			// End curses mode		  
	return 0;
}


int beginPlay(){
	int Move, R = 0, Roi = 0, Winner = 3;
	Restart(3,6);
	//textmode(C40);
	Move = (BoardSize-RowSize)/2;
	MakeComMove(Move);
	Side = MAN;
	Print();
	Winner = 10;
	while (!GameOver) {
		gotoxy(0, 0);
		if (Side == COM)
		{
			R = ComSearch(0, -INFI, INFI);
			Move = BestMove[0];
		}
		else if ((GameOver = GetStroke(&Move, R)) != 0) break;
		if (Side == MAN){
			GameOver = MakeManMove(Move);
			if (GameOver) Winner = MAN;
		}
		else if ((GameOver = MakeComMove(Move)) != 0) Winner = COM;
		Side = 1-Side;
		Print();
		if (Side == MAN)PrintOpinion(R, &Roi);
		
		// refresh after printw
		refresh();
	}
	if (Winner == COM) PrintOpinion(5000, &Roi);
	else
		if (Winner == MAN) PrintOpinion(-5000, &Roi);
		else PrintIdea(rand()%3);
	
	getch();
	//textmode(C80);
	endwin();			// End curses mode		  
	return 0;
}*/

