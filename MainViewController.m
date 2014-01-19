//
//  MainViewController.m
//  SpeedReader
//
//  Created by Joel Green on 1/18/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()


@property (weak, nonatomic) IBOutlet UISegmentedControl *topSegControl;
@property (weak, nonatomic) IBOutlet UISlider *bottomSlider;
@property (weak, nonatomic) IBOutlet UILabel *staticWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *wpmLabel;
@property (weak, nonatomic) IBOutlet UILabel *numWordsLabel;
@property (strong, nonatomic) NSMutableString *clipboardContent;
@property (strong, nonatomic) NSMutableArray *timers;
@property (strong, nonatomic) NSMutableArray *wordChunks;
@property int wordChunckSize;
@property float delayConstant;
@property int previousIndex;
@property int wpm;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)wordChunks
{
    if (!_wordChunks) {
        _wordChunks = [[NSMutableArray alloc] init];
    }
    return _wordChunks;
}

- (NSMutableArray *)timers
{
    if (!_timers) {
        _timers = [[NSMutableArray alloc] init];
    }
    return _timers;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wordChunckSize = self.topSegControl.selectedSegmentIndex + 1;
    self.delayConstant = 0.8 - (float)self.bottomSlider.value;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.clipboardContent = [[NSMutableString alloc] initWithString:[UIPasteboard generalPasteboard].string];
    self.numWordsLabel.text = [NSString stringWithFormat:@"%d Words", (int)self.clipboardContent.length];
    
    for (NSTimer *timer in self.timers){
        [timer invalidate];
    }
    
    [self.timers removeAllObjects];
    [self startReading];
}


- (IBAction)topSegChanged:(id)sender {
    self.wordChunckSize = self.topSegControl.selectedSegmentIndex + 1;
    [self updateWPM];
}

- (IBAction)bottomSliderChanged:(id)sender
{
    self.delayConstant = 0.8 - (float)self.bottomSlider.value;
    [self updateWPM];
}

- (void)updateWPM
{
    float fwpm = (float)self.wordChunckSize * 60.0 / self.delayConstant;
    self.wpm = (int)fwpm;
    self.wpmLabel.text = [NSString stringWithFormat:@"%d WPM",self.wpm];
}

- (void)startReading
{
    self.previousIndex = 0;
    [self displayWords];
    [self updateWPM];
}


- (void)displayWords
{
    [self.timers addObject:[NSTimer scheduledTimerWithTimeInterval:self.delayConstant
                                                            target:self
                                                          selector:@selector(timerFired:)
                                                          userInfo:nil
                                                           repeats:NO]];
}

- (void)timerFired:(NSTimer *)timer
{
    NSString *wordGroup;
    
    int wordCount = 0;
    for (int i = self.previousIndex; i < self.clipboardContent.length; i++)
    {
        unichar cr = [self.clipboardContent characterAtIndex:i];
        if (cr == ' ') {
            wordCount += 1;
        }
        if (wordCount == self.wordChunckSize) {
            wordCount = 0;
            wordGroup = [self.clipboardContent substringWithRange:NSMakeRange(self.previousIndex, i - self.previousIndex)];
            self.previousIndex = i + 1;
            
            self.staticWordLabel.text = wordGroup;
            [self displayWords];
            break;
        }
        if (i == self.clipboardContent.length - 1) {
            wordGroup = [self.clipboardContent substringWithRange:NSMakeRange(self.previousIndex, self.clipboardContent.length - self.previousIndex)];
            self.staticWordLabel.text = wordGroup;
            [self displayWords];
            break;
        }
    }
}


@end
