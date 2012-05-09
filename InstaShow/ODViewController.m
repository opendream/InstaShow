//
//  ODViewController.m
//  InstaShow
//
//  Created by In|Ce Saiaram on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ODViewController.h"

@interface ODViewController ()

@end

@implementation ODViewController
@synthesize photoGridTableView;
@synthesize gridView = _gridView;
@synthesize jsonData;

UIWebView *logInWebView;
NSString *redirectURLforGetAccessToken;

-(void)readFeedJsonFromURL{
    
    NSLog(@"readFeedJsonFromURL");
//    NSURLRequest *requestImage = [NSURLRequest requestWithURL:[NSURL URLWithString:imagePath]];
//    NSData *imageData = [NSURLConnection  sendSynchronousRequest:requestImage returningResponse:nil error:NULL];
//    cell.imageView.image = [UIImage imageWithData:imageData];
    
    /* ขั้นตอนการขอrequest
     1. request access token
     https://instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=token
     CLIENT-ID = 97bc3b47f71a4f8dae03c4845801514c
     REDIRECT URI = http://www.opendream.co.th
     
     2.จะได้ format http://your-redirect-uri#access_token=29155712.f59def8.da567c2d0d2c4c1aa87acb8f5f7b90bf
     http://www.opendream.co.th/#access_token=29155712.97bc3b4.a610bcd563544f3bbece20b1c38ced9a
     
     3.เข้าไปเอาfeedรุปที่เราlike 
     https://api.instagram.com/v1/users/self/feed?access_token=29155712.97bc3b4.a610bcd563544f3bbece20b1c38ced9a
     */
        
    
    
    NSString *clientID = @"97bc3b47f71a4f8dae03c4845801514c";
    redirectURLforGetAccessToken = @"http://www.opendream.co.th";
    NSString *requestAccessTokenPath = [[[[@"https://instagram.com/oauth/authorize/?client_id=" stringByAppendingString:clientID] stringByAppendingString:@"&redirect_uri="] stringByAppendingString:redirectURLforGetAccessToken] stringByAppendingString:@"&response_type=token"];
    

    NSHTTPURLResponse *responseURL = [[NSHTTPURLResponse alloc] init];
    NSURLRequest *requestAccessToken = [NSURLRequest requestWithURL:[NSURL URLWithString:requestAccessTokenPath]];
    NSData *accessTokenWithRedirectURL = [NSURLConnection  sendSynchronousRequest:requestAccessToken returningResponse:&responseURL error:NULL];

    self.jsonData = [accessTokenWithRedirectURL objectFromJSONData];
    NSLog(@"gettttttttttt >>>>>>>> %@",[responseURL URL] );
    
    logInWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    logInWebView.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[responseURL URL]];
    [logInWebView loadRequest:request];
    [self.view addSubview:logInWebView];
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView");
    NSURL *redirectURL = [request URL];
    NSString *redirectString = [redirectURL absoluteString];
    
    if([redirectString rangeOfString:@"#access_token="].location != NSNotFound && [redirectString rangeOfString:redirectURLforGetAccessToken].location != NSNotFound){
        //NSLog(@"aaaaaaaaaaaaaaaaaa %@",[request URL]);
        NSRange rangeAccessToken = [redirectString rangeOfString:@"#access_token="];
        //NSLog(@"qqqqqqq %d-----%d",rangeAccessToken.location,rangeAccessToken.length);
        int indexStartToken = rangeAccessToken.location + rangeAccessToken.length;
        NSString *realAccessToken = [redirectString substringWithRange:NSMakeRange (indexStartToken, redirectString.length - indexStartToken)];
        //NSLog(@"access tokennnnnnnnnn %@",realAccessToken);
        
        accessToken = realAccessToken;
        NSLog(@"webview redirect from opendream");
        [self requestFeed];
    }
    
    return YES;
}

-(void)requestFeed
{
    NSLog(@"requestFeed");
    NSString *path = @"https://api.instagram.com/v1/users/self/feed?access_token=";
    NSString *likePath = [path stringByAppendingString:accessToken];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:likePath]];
    NSData *feedData = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:NULL];

    self.jsonData = [feedData objectFromJSONData];
    [self readDictJsonData];
    //NSLog(@"eeeeeeeeeee %@",dataArray);
    
    [logInWebView removeFromSuperview];
        
    [self.gridView reloadData];
}

-(void)readFileJson{
    NSLog(@"readFileJson");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Popular" ofType:@"json"];
    NSData *jsonDataWithPath = [NSData dataWithContentsOfFile:path];
    self.jsonData = [jsonDataWithPath objectFromJSONData];
}

-(void)readDictJsonData
{
    NSLog(@"readDictJsonData");
    dataArray = [self.jsonData objectForKey:@"data"];
}

-(void) clearAccessToken
{
    NSLog(@"clearAccessToken");
    accessToken = @"";
    dataArray = [NSArray new]; 
    [self.gridView reloadData];
    
    
    NSURL *logOutURL = [NSURL URLWithString:@"https://instagram.com/accounts/logout/"];
    NSURLRequest *logOutRequest = [NSURLRequest requestWithURL:logOutURL];
    [NSURLConnection  sendSynchronousRequest:logOutRequest returningResponse:nil error:NULL];
    NSLog(@"LOG OUT@!!");
    
    [self readFeedJsonFromURL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.photoGridTableView.dataSource = self;
    self.jsonData = [[NSDictionary alloc] init];
    
    self.gridView.dataSource = self;
    self.gridView.delegate = self;

    [logOutButton addTarget:self action:@selector(clearAccessToken) forControlEvents:UIControlEventTouchUpInside];
     
    if([accessToken isEqualToString:@""] || accessToken == nil){
        [self readFeedJsonFromURL];
    }
}

- (void)viewDidUnload
{
    [self setGridView:nil];
    logOutButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //*** for reuse cell jaaaa
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    __block NSString *imagePath = [[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
    dispatch_async(queue, ^{
//        NSString *url=[pat stringByAppendingPathComponent:@"comments.txt"];
//        NSString *u=[NSString stringWithContentsOfFile:url encoding:NSUTF8StringEncoding error:nil];
        
        NSArray *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [documentDir lastObject];
//        NSLog(@"%@",documentPath);
        
        NSString *imageName = [[NSURL URLWithString:imagePath] lastPathComponent];
        NSData *image;
        
        /////////////////////////////////////////////////////////////////////////////////////////
        
                
        NSString *imagePathInCache = [documentPath stringByAppendingPathComponent:imageName];            
        if ( [[NSFileManager defaultManager] fileExistsAtPath:imagePathInCache]) // if มีอยู่ใน cache
        {
            image = [NSData dataWithContentsOfFile:imagePathInCache];
        }
        else        
        {
            NSURL *imageURL = [NSURL URLWithString:imagePath];
        
            image = [NSData dataWithContentsOfURL:imageURL];
            [image writeToFile:[documentPath stringByAppendingPathComponent:imageName] atomically:YES];
            

        }
//        else // if มีอยู่ใน cache
//        {
//            image = [NSData dataWithContentsOfFile:documentPath];
//        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.imageView.image = [UIImage imageWithData:image];
            [cell setNeedsLayout];
//            NSLog(@"Download");
        });
    });
//    
//    NSString *imagePath = [[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"];
//    
//    NSURLRequest *requestImage = [NSURLRequest requestWithURL:[NSURL URLWithString:imagePath]];
//
//    NSData *imageData = [NSURLConnection  sendSynchronousRequest:requestImage returningResponse:nil error:NULL];

    
//    cell.imageView.image = [UIImage imageWithData:imageData];

    
    NSString *caption, *owner;
    id captionDict = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"caption"];
    if(![captionDict isKindOfClass:[NSNull class]]){                             
        caption =  [captionDict objectForKey:@"text"];
    }else{
        caption = @"";
    }
    owner = [[[dataArray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"full_name"];
    cell.textLabel.text = caption;
    cell.detailTextLabel.text = owner;
    
    return cell;
}
#define RANDOM ((arc4random()%255) / 255.0)
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return dataArray.count;
}
- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    AQGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        cell = [[AQGridViewCell alloc] initWithFrame:CGRectMake(10.0, 0.0, 75.0, 75.0) reuseIdentifier:cellIdentifier];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        
        [cell.contentView addSubview:imageView];
        imageView.tag = 999;
    }
    for(UIImageView *i in [cell.contentView subviews]){
        if(i.tag == 999){
            
            /////fetch picture
            
            __block NSString *imagePath = [[[[dataArray objectAtIndex:index] objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
            dispatch_async(queue, ^{
                
                NSArray *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentPath = [documentDir lastObject];
                
                NSString *imageName = [[NSURL URLWithString:imagePath] lastPathComponent];
                NSData *image;
                
                /////////////////////////////////////////////////////////////////////////////////////////
                
                
                NSString *imagePathInCache = [documentPath stringByAppendingPathComponent:imageName];            
                if ( [[NSFileManager defaultManager] fileExistsAtPath:imagePathInCache]) // if มีอยู่ใน cache
                {
                    image = [NSData dataWithContentsOfFile:imagePathInCache];
                }
                else        
                {
                    NSURL *imageURL = [NSURL URLWithString:imagePath];
                    
                    image = [NSData dataWithContentsOfURL:imageURL];
                    [image writeToFile:[documentPath stringByAppendingPathComponent:imageName] atomically:YES];
                    
                    
                }
                                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    AQGridViewCell *cell = [gridView cellForItemAtIndex:index];
                    
                    for(UIImageView *j in [cell.contentView subviews]){
                        if(j.tag == 999){
                            [j setImage:[UIImage imageWithData:image]];
                            [j setNeedsLayout];
                        }
                    }
                });
            });
             
        }
    }
    
    //cell.backgroundColor = [UIColor colorWithRed:RANDOM green:RANDOM blue:RANDOM alpha:1];
        
    return cell;
    
    
}
                   
                   
- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(80.0, 80.0) );
}

@end



















