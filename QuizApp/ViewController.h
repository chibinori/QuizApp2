//
//  ViewController.h
//  QuizApp
//
//  Created by 酒井紀明 on 2015/12/03.
//  Copyright © 2015年 noriaki.sakai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

    -(IBAction)startQuiz:(id)sender;
    -(IBAction)clickAnswer1:(id)sender;
    -(IBAction)clickAnswer2:(id)sender;
    -(IBAction)clickAnswer3:(id)sender;
    -(IBAction)clickAnswer4:(id)sender;


    @property(nonatomic,weak) IBOutlet UILabel *quizLabelN;
    @property(nonatomic,weak) IBOutlet UILabel *quizNumber;
    @property(nonatomic,weak) IBOutlet UILabel *quizLabelD;
    @property(nonatomic,weak) IBOutlet UILabel *quizDifficulty;
    @property(nonatomic,weak) IBOutlet UITextView *quizSentence;
    @property(nonatomic,weak) IBOutlet UILabel *endGreeting;
    @property(nonatomic,weak) IBOutlet UILabel *correctAnsInfo;


    @property(nonatomic,weak) IBOutlet UIButton *startBtn;
    @property(nonatomic,weak) IBOutlet UIButton *ans1Btn;
    @property(nonatomic,weak) IBOutlet UIImageView *ans1Result;
    @property(nonatomic,weak) IBOutlet UIButton *ans2Btn;
    @property(nonatomic,weak) IBOutlet UIImageView *ans2Result;
    @property(nonatomic,weak) IBOutlet UIButton *ans3Btn;
    @property(nonatomic,weak) IBOutlet UIImageView *ans3Result;
    @property(nonatomic,weak) IBOutlet UIButton *ans4Btn;
    @property(nonatomic,weak) IBOutlet UIImageView *ans4Result;

@end

