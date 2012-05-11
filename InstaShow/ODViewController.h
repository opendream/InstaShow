//
//  ODViewController.h
//  InstaShow
//
//  Created by In|Ce Saiaram on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "AQGridView.h"

@interface ODViewController : UIViewController <UITableViewDataSource, AQGridViewDataSource, AQGridViewDelegate, UIWebViewDelegate>
{
    NSArray *dataArray;
    NSString *accessToken;
    IBOutlet UIButton *logOutButton;
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *backgroundView;
}

@property (weak, nonatomic) IBOutlet AQGridView *gridView;
@property (nonatomic,strong) NSDictionary *jsonData;
@property (nonatomic,weak) IBOutlet UITableView *photoGridTableView;
@end
