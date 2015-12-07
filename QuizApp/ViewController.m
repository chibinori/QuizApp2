//
//  ViewController.m
//  QuizApp
//
//  Created by 酒井紀明 on 2015/12/03.
//  Copyright © 2015年 noriaki.sakai. All rights reserved.
//

#import "ViewController.h"

// クイズの問題数
static const NSInteger kMaxQuizNum = 5;
// クイズの選択肢の数
static const NSInteger kQuizSelectionNum = 4;


@interface ViewController (){
    // 現在何問めか？
    NSInteger currentQuizNum;
    // 正答数
    NSInteger correctAnsCount;
    
    // 現在のクイズ情報
    NSString* currentQuestion;
    NSMutableArray *currentAnsArray;
    NSString* currentQuizDificalty;
    
    // 現在XML解析しているタグ
    NSString* tempXMLTag;
    //foundCharactersイベントハンドラは空白毎に分けて呼ばれるためここに一時的に保管
    NSMutableString *tempXMLString;
    
    // 回答中かどうか
    BOOL answered;
    
    // マル・バツ画像
    UIImage* correctImage;
    UIImage* incorrectImage;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self initializeParts];
    [self prepareStart];
    
    currentAnsArray = [[NSMutableArray alloc] init];
    
    correctImage = [UIImage imageNamed:@"maru.gif"];
    incorrectImage = [UIImage imageNamed:@"batsu.gif"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


// 以下UIと関連付けたメソッド
-(IBAction)startQuiz:(id)sender{
    NSLog(@"startQuizボタンが押された!");
    
    [self startQuiz];
}

-(IBAction)clickAnswer1:(id)sender{
    NSLog(@"clickAnswer1ボタンが押された!");
    // 連打対策
    if (answered) {
        return;
    }
    answered = YES;

    [self answer: self.ans1Btn];
    
    [self changeToNextQuiz];
}

-(IBAction)clickAnswer2:(id)sender{
    NSLog(@"clickAnswer2ボタンが押された!");
    // 連打対策
    if (answered) {
        return;
    }
    answered = YES;

    
    [self answer: self.ans2Btn];

    [self changeToNextQuiz];
}

-(IBAction)clickAnswer3:(id)sender{
    NSLog(@"clickAnswer3ボタンが押された!");
    // 連打対策
    if (answered) {
        return;
    }
    answered = YES;
    
    [self answer: self.ans3Btn];
    
    [self changeToNextQuiz];
}

-(IBAction)clickAnswer4:(id)sender{
    NSLog(@"clickAnswer4ボタンが押された!");
    // 連打対策
    if (answered) {
        return;
    }
    answered = YES;
    
    [self answer: self.ans4Btn];
    
    [self changeToNextQuiz];
}

-(void)initializeParts{
    self.startBtn.backgroundColor = [UIColor blueColor];
    self.startBtn.layer.cornerRadius = self.startBtn.frame.size.height;
    self.startBtn.layer.borderColor = [[UIColor blueColor]CGColor];
    self.startBtn.layer.borderWidth = 1.0f;
    
    // 問題文は編集不可
    self.quizSentence.editable = NO;
    
    [self initializeButtonPart:self.ans1Btn];
    [self initializeButtonPart:self.ans2Btn];
    [self initializeButtonPart:self.ans3Btn];
    [self initializeButtonPart:self.ans4Btn];

    self.endGreeting.hidden = YES;
    self.correctAnsInfo.hidden = YES;
}

-(void)initializeButtonPart:(UIButton*) button{
    button.layer.cornerRadius = self.startBtn.frame.size.height / 2;
    button.layer.borderColor = [[UIColor blackColor]CGColor];
    button.layer.borderWidth = 1.0f;
}

-(void)prepareStart{
    self.quizLabelN.hidden = YES;
    self.quizNumber.hidden = YES;
    self.quizLabelD.hidden = YES;
    self.quizDifficulty.hidden = YES;
    self.quizSentence.hidden = YES;
    
    self.startBtn.hidden = NO;
    self.ans1Btn.hidden = YES;
    self.ans2Btn.hidden = YES;
    self.ans3Btn.hidden = YES;
    self.ans4Btn.hidden = YES;
    // マル・バツなどを消す
    [self disappearResults];
    
    currentQuizNum = 0;
    correctAnsCount = 0;
    
    self.quizNumber.text = @"";
    self.quizDifficulty.text = @"";
    self.quizSentence.text = @"";
    
    answered = YES;
}

-(void)startQuiz{
    
    [self changeToNextQuiz];
    
    self.quizLabelN.hidden = NO;
    self.quizNumber.hidden = NO;
    self.quizLabelD.hidden = NO;
    self.quizDifficulty.hidden = NO;
    self.quizSentence.hidden = NO;
    
    self.startBtn.hidden = YES;
    self.ans1Btn.hidden = NO;
    self.ans2Btn.hidden = NO;
    self.ans3Btn.hidden = NO;
    self.ans4Btn.hidden = NO;

    self.endGreeting.hidden = YES;
    self.correctAnsInfo.hidden = YES;
}

-(void)endQuiz{

    
    NSString *ansInfoStr =
    [NSString stringWithFormat:@"%ld問中、%ld問正解しました",
     kMaxQuizNum, (long)correctAnsCount];
    self.correctAnsInfo.text = ansInfoStr;
    
    self.endGreeting.hidden = NO;
    self.correctAnsInfo.hidden = NO;
    
    [self prepareStart];
}

-(void)changeToNextQuiz{

    // 前の問題の結果を描画更新するためと、前の問題の結果をユーザが確認するためちょっと待つ
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

    if (currentQuizNum < kMaxQuizNum) {
        [self createNextQuiz];
    } else {
        [self endQuiz];
    }
}

-(void)showNextQuiz{

    currentQuizNum++;
    self.quizNumber.text = [NSString stringWithFormat:@"%ld",
                            (long)currentQuizNum];
    
    // マル・バツなどを消す
    [self disappearResults];
    
    
    self.quizDifficulty.text = currentQuizDificalty;
    self.quizSentence.text = currentQuestion;
    
    // どの選択肢を正答にするか決める(現在の時間からランダムに決める)
    NSInteger correctAnsNo
        = fmod([NSDate timeIntervalSinceReferenceDate], kQuizSelectionNum);

    // 誤答のセット
    static NSInteger setAnsNo;
    setAnsNo = 0;
    [currentAnsArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%ld: %@", (long)idx, obj);
        // 最初の答えは正答なのでここではセットしない
        if (idx == 0) {
            *stop = NO;
            return;
        }
        if (setAnsNo == correctAnsNo) {
            // 正答は後で設定するのでここではセットしない
            setAnsNo++;
        }
        
        switch (setAnsNo) {
            case 0:
                [self.ans1Btn setTitle:obj forState:UIControlStateNormal];
                break;
            case 1:
                [self.ans2Btn setTitle:obj forState:UIControlStateNormal];
                break;
            case 2:
                [self.ans3Btn setTitle:obj forState:UIControlStateNormal];
                break;
            case 3:
                [self.ans4Btn setTitle:obj forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        setAnsNo++;
        *stop = NO;

        }
    ];
    
    // 配列の最初に格納されている正答のセット
    switch (correctAnsNo) {
        case 0:
            [self.ans1Btn setTitle:[currentAnsArray firstObject] forState:UIControlStateNormal];
            break;
        case 1:
            [self.ans2Btn setTitle:[currentAnsArray firstObject] forState:UIControlStateNormal];
            break;
        case 2:
            [self.ans3Btn setTitle:[currentAnsArray firstObject] forState:UIControlStateNormal];
            break;
        case 3:
            [self.ans4Btn setTitle:[currentAnsArray firstObject] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    
    answered = NO;
    
}

-(void)disappearResults{
    self.ans1Result.hidden = YES;
    self.ans2Result.hidden = YES;
    self.ans3Result.hidden = YES;
    self.ans4Result.hidden = YES;
    
    [self.ans1Btn setTitle:@"" forState:UIControlStateNormal];
    [self.ans2Btn setTitle:@"" forState:UIControlStateNormal];
    [self.ans3Btn setTitle:@"" forState:UIControlStateNormal];
    [self.ans4Btn setTitle:@"" forState:UIControlStateNormal];
}


-(void)answer:(UIButton*) button{
    // 正解かどうか判断
    NSString *correctAnswer = [currentAnsArray firstObject];
    if ([button.currentTitle isEqualToString:correctAnswer]) {
        correctAnsCount++;
    }

    // マル・バツ表示
    if ([self.ans1Btn.currentTitle isEqualToString:correctAnswer]) {
        self.ans1Result.image = correctImage;
    } else {
        self.ans1Result.image = incorrectImage;
    }
    if ([self.ans2Btn.currentTitle isEqualToString:correctAnswer]) {
        self.ans2Result.image = correctImage;
    } else {
        self.ans2Result.image = incorrectImage;
    }
    if ([self.ans3Btn.currentTitle isEqualToString:correctAnswer]) {
        self.ans3Result.image = correctImage;
    } else {
        self.ans3Result.image = incorrectImage;
    }
    if ([self.ans4Btn.currentTitle isEqualToString:correctAnswer]) {
        self.ans4Result.image = correctImage;
    } else {
        self.ans4Result.image = incorrectImage;
    }

    self.ans1Result.hidden = NO;
    self.ans2Result.hidden = NO;
    self.ans3Result.hidden = NO;
    self.ans4Result.hidden = NO;
}


-(void)createNextQuiz{
    // クイズの問題と答えのデータを取得するURLを作成する
    //    <Result>
        //    <api_version>0.01</api_version>
            //    <quiz>
                //    <id>3711</id>
                //    <quession>ビリヤードのナインボールの手玉の色といえば何色？</quession>
                //    <ans1>白</ans1>　・・ans1が正解
                //    <ans2>赤</ans2>
                //    <ans3>黒</ans3>
                //    <ans4>黄</ans4>
                //    <author>Quiz@MagicalAcademia</author>
                //    <addr>NULL</addr>
                //    <level>レベル制限無し</level>
                //    <category/>
            //    </quiz>
    //    </Result>
    NSURLSession *session = [NSURLSession sharedSession];
    // SSLでないので、ATSで引っかかるため、info.plistで以下のドメインのみATS除外設定した
    NSURL *url = [NSURL URLWithString:@"http://24th.jp/test/quiz/api_quiz.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                                            if (error) {
                                                // 通信が異常終了したときの処理
                                                NSLog(@"error : %@", error);
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self prepareStart];
                                                });
                                                return;
                                            }
                                            
                                            // 通信が正常終了したときの処理
                                            NSLog(@"statusCode = %ld", ((NSHTTPURLResponse *)response).statusCode);
                                            if (((NSHTTPURLResponse *)response).statusCode != 200) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self prepareStart];
                                                });
                                                return;
                                            }
                                            NSLog(@"data : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self createQandA:data];
                                                [self showNextQuiz];
                                            });
                                            return;
                                        }];
    
    // 通信開始
    [task resume];
    
    NSLog(@"request finished!!");

}

//
// 以下XML解析
//

-(void)createQandA:(NSData *)data{
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    //デリゲートの設定
    [parser setDelegate:self];
    
    //解析開始
    [parser parse];
}



//デリゲートメソッド(解析開始時)
-(void) parserDidStartDocument:(NSXMLParser *)parser{
    
    NSLog(@"解析開始");
    
    //解析の初期化処理
    currentQuestion = nil;
    [currentAnsArray removeAllObjects];
    currentQuizDificalty = nil;
    tempXMLTag = nil;
    
    tempXMLString = [NSMutableString string];
}

//デリゲートメソッド(要素の開始タグを読み込んだ時)
- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict{
    
    NSLog(@"要素の開始タグを読み込んだ:%@",elementName);
    
    tempXMLTag = elementName;
    tempXMLString = [NSMutableString string];
}

//デリゲートメソッド(タグ以外のテキストを読み込んだ時)
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSLog(@"タグ以外のテキストを読み込んだ:%@", string);
    
    // 一つのタグ内に空白を含む文字列があった場合、このイベントは複数回呼ばれる
    [tempXMLString appendString:string];
    
}

//デリゲートメソッド(要素の終了タグを読み込んだ時)
- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName{
    
    NSLog(@"要素の終了タグを読み込んだ:%@",elementName);
    
    if([tempXMLTag isEqualToString:@"quession"]){
        currentQuestion = tempXMLString;
    } else if ([tempXMLTag isEqualToString:@"ans1"]) {
        [currentAnsArray addObject: tempXMLString];
    } else if ([tempXMLTag isEqualToString:@"ans2"]) {
        [currentAnsArray addObject: tempXMLString];
    } else if ([tempXMLTag isEqualToString:@"ans3"]) {
        [currentAnsArray addObject: tempXMLString];
    } else if ([tempXMLTag isEqualToString:@"ans4"]) {
        [currentAnsArray addObject: tempXMLString];
    } else if ([tempXMLTag isEqualToString:@"level"]) {
        currentQuizDificalty = tempXMLString;
    }
    
    tempXMLTag = nil;
}

//デリゲートメソッド(解析終了時)
-(void) parserDidEndDocument:(NSXMLParser *)parser{
    
    NSLog(@"解析終了");
}




@end
