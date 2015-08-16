//
//  ViewController.m
//  CryptoboxExample
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "ViewController.h"

#import "cbox.h"

#import <CryptoboxiOS/Cryptobox.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    CBCryptoBox *box = [CBCryptoBox cryptoBoxWithPathURL:CBCreateTemporaryDirectoryAndReturnURL() error:nil];
    NSAssert(box != nil, @"");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


@end
