    //
//  SLTViewController.m
//  SaltrTestApp
//
//  Created by employee on 2/28/14.
//  Copyright (c) 2014 Plexonic. All rights reserved.
//

#import "ViewController.h"
#import "SLTRepository.h"

@interface ViewController () {
    SLTSaltr* saltr;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    saltr = [SLTSaltr saltrWithInstanceKey:@"08626247-f03d-0d83-b69f-4f03f80ef555" andCacheEnabled:YES];
//    saltr.saltrRequestDelegate = self;
//    [[SLTSaltr sharedInstance] setupPartnerWithId:@"100000024783448" andPartnerType:@"facebook"];
//    [[SLTSaltr sharedInstance] setupDeviceWithId:@"asdas123kasd" andDeviceType:@"phone"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark SaltrRequestDelegate methods

-(void) didFinishGettingAppDataRequest {
    
}

-(void) didFailGettingAppDataRequest:(SLTError*)error {
    
}

-(void) didFinishGettingLevelDataBodyWithLevelPackRequest {
    
}

-(void) didFailGettingLevelDataBodyWithLevelPackRequest {
    
}

@end
