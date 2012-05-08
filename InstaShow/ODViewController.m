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
@synthesize jsonData;



-(void)readFileJson{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Popular" ofType:@"json"];
    NSData *jsonDataWithPath = [NSData dataWithContentsOfFile:path];
    self.jsonData = [jsonDataWithPath objectFromJSONData];
}

-(void)readDictJsonData{
    dataArray = [self.jsonData objectForKey:@"data"];
    NSLog(@">>>>>> %@",[[dataArray objectAtIndex:0] allKeys]);
//    for(int i=0;i<dataArray.count-1;i++){
//        NSLog(@"%i ====== %@",i,[dataArray objectAtIndex:i]);
//    }
//    NSLog(@"%@",[[[dataArray objectAtIndex:0] objectForKey:@"caption"] objectForKey:@"text"]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.photoGridTableView.dataSource = self;
    self.jsonData = [[NSDictionary alloc] init];
    [self readFileJson];
    [self readDictJsonData];
    
    [self.photoGridTableView reloadData];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
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

@end
