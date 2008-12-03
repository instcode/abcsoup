//
//  OptionCell.m
//  JouzuGomoku
//
//  Created by Tuan Luu on 12/3/08.
//  Copyright 2008 NUS. All rights reserved.
//

#import "OptionCell.h"


@implementation OptionCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
