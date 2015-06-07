//
//  ViewController.m
//  ZHJSlider
//
//  Created by Sword on 6/3/15.
//  Copyright (c) 2015 Sword. All rights reserved.
//

#import "ViewController.h"
#import "ZHJSliderControl.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ZHJSliderControl *secondSliderview;

@end

@implementation ViewController

- (void)valueChanged {
    NSLog(@"valueChanged");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.secondSliderview.keyValueNumber = 3;
    self.secondSliderview.minimumValue = 10;
    self.secondSliderview.maximumValue = 30;
    self.secondSliderview.value = 20;    
    [self.secondSliderview addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
