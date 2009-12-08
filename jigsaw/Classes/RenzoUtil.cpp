/*
 *  RenzoUtil.cpp
 *  Jigsaw
 *
 *  Created by Son Hua on 5/1/09.
 *  Copyright 2009 AptusVentures. All rights reserved.
 *
 */

#include "RenzoUtil.h"
#include <stdlib.h>
#include <time.h>
#include <math.h>

namespace Renzo {
	void randomSeed(int seed) {
		if (seed == 0)
			srand(time(NULL));
		else
			srand(seed);
	}
	
	int randomInteger(int minVal, int maxVal) {
		unsigned long r = floor(rand());
		
		return r % (maxVal - minVal + 1) + minVal;
	}
	
	void swap(int& a, int& b) {
		int t = a; 
		a = b;
		b = t;
	}
}