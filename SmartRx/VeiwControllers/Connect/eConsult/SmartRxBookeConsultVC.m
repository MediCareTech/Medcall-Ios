//
//  SmartRxBookeConsultVC.m
//  SmartRx
//
//  Created by Manju Basha on 19/03/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxBookeConsultVC.h"
#import "SmartRxDashBoardVC.h"
#import "UIKit+AFNetworking.h"
#import <QuickLook/QuickLook.h>
//#import "SmartRxPaymentVC.h"
#import "SmartRxPaymentVC.h"
#import "SmartRxViewDoctorProfile.h"
#import "SmartRxeConsultVC.h"
#define kLessThan4Inch 560
#define kBookAppSuccesTagFindDoctors 3006

@interface SmartRxBookeConsultVC () <CKCalendarDelegate>
{
    MBProgressHUD *HUD;
    CGSize viewSize;
    BOOL autoSelect, promoApplied,calenderHidden;
    UIRefreshControl *refreshControl;
    int calendarApiType, econ_method, payOption,calenderStat;
    NSMutableArray *doctorList;
    NSArray *timeStamp;
    NSString *campId, *name, *number,*specialityId;
    NSMutableArray *responseArr, *slotArr, *methodArr,*econsultDetailsArr;
    NSDateComponents *componentsOfDate;
    NSDate * myDate ;
    NSDateComponents *currentComponent;
    NSInteger consultationFeeAmount, eCostPrice, eConsultCredits, finalCost, actualCost;
    double discountedCost;
    int econ_auto_camp_count;
    BOOL isShow;
    
}
@end

@implementation SmartRxBookeConsultVC
+ (id)sharedManagerEconsult {
    static SmartRxBookeConsultVC *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"E-Consult" controler:self];
    NSLog(@"schedule type....:%@",self.scheduleType);
    autoSelect = NO;
    promoApplied = NO;
    calenderStat = 0;
//    calenderHidden = NO;
    self.calendarContainer.hidden= YES;
    campId = @"";
    self.consultationFeeText.hidden = YES;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    
    for (int i = 0; i<[self.Dates count]; i++)
    {
        NSString *str_date = [self.Dates objectAtIndex:i];
        [self.disabledDates addObject:[self.dateFormatter dateFromString:str_date]];
       
    }
    
//    self.calendarView.delegate = self;
//    self.calendarView.clipsToBounds = YES;
//    if (self.calendarView.frame.size.height <= 240)
//        self.calendarView.frame = CGRectMake ( self.calendarView.frame.origin.x, self.calendarView.frame.origin.y, self.calendarView.frame.size.width, self.calendarView.frame.size.height + 50);
//    else
//        self.calendarView.frame = CGRectMake ( self.calendarView.frame.origin.x, self.calendarView.frame.origin.y, self.calendarView.frame.size.width, self.calendarView.frame.size.height + 58);
//    
//    NSDate *today = [NSDate date];
//    NSDate *end = [NSDate date];
//    
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
//    NSDateComponents *dateCompStart = [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:today];
//    NSDateComponents *dateCompEnd = [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:end];
//    
//    DSLCalendarRange *range = [[DSLCalendarRange alloc] initWithStartDay:dateCompStart endDay:dateCompEnd];
//    
   // [self.calendarView setSelectedRange:range];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
    {
        name = [[NSUserDefaults standardUserDefaults]objectForKey:@"UName"];
        number = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    
    
    viewSize=[[UIScreen mainScreen]bounds].size;
    methodArr = [[NSMutableArray alloc] initWithArray:@[@"Video Conference", @"Phone Call"]];
    self.componentsArray = [[NSMutableArray alloc] init];
    self.paymentResponseDictionary = [[NSMutableDictionary alloc] init];
 //   self.calendarView.delegate = self;
    self.specialityLbl.textColor = [UIColor lightGrayColor];
    self.doctorLbl.textColor = [UIColor lightGrayColor];
    self.dateLbl.textColor = [UIColor lightGrayColor];
    self.timeLbl.textColor = [UIColor lightGrayColor];
    self.doctorDictArray = [[NSMutableArray alloc]init];
    self.disabledDates = [[NSMutableArray alloc]init];

    self.arrSpeciality=[[NSArray alloc]init];
    if (viewSize.height < kLessThan4Inch)
    {
        [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.scrolView.frame.size.height+100)];
    }
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForPackage];
        //[self makeRequestForDocAndSpecialities];
        //[self makeRequestForSpecialities];
}
   else      {
        [self customAlertView:@"Not able to fetch user credits and other details due to network issues. Please try again" Message:@"Try again" tag:1];
    }
    
    
    viewSize = [UIScreen mainScreen].bounds.size;
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [self.calendarContainer addSubview:background];
    [self.calendarContainer sendSubviewToBack:background];
    
    [self navigationBackButton];
    [self createBorderForAllBoxes];
    [self initializePickers];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"TransactionSuccess"] )
    {
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"TransactionSuccess"] boolValue])
        {
            self.paymentResponseDictionary = [[NSUserDefaults standardUserDefaults]objectForKey:@"paymentResponseDictionary"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self makeRequestToAddEconsultWithPayment];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"" Message:@"Sorry we were not able to process the payment. Please try again after sometime to book the E-Consult." tag:0];
        }
    }
    
}

- (void)initializePickers
{
    self.specialityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.specialityPicker.delegate = self;
    self.specialityPicker.dataSource = self;
    self.specialityPicker.backgroundColor = [UIColor whiteColor];
    
    self.doctorPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.doctorPicker.delegate = self;
    self.doctorPicker.dataSource = self;
    self.doctorPicker.backgroundColor = [UIColor whiteColor];
    
    self.timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    self.timePicker.backgroundColor = [UIColor whiteColor];
    
    self.eConsultMethodPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.eConsultMethodPicker.delegate = self;
    self.eConsultMethodPicker.dataSource = self;
    self.eConsultMethodPicker.backgroundColor = [UIColor whiteColor];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)navigationBackButton
{
    self.navigationItem.hidesBackButton=YES;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"icn_back.png"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(-40, -2, 100, 40);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, -7);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
}
- (void)initCalendar
{
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.calendarView = calendar;
    calendar.delegate = self;
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    calendar.frame = CGRectMake(0, 0, 320, 320);
    self.view.backgroundColor = [UIColor whiteColor];
    [self.calendarContainer addSubview:calendar];
    
}

#pragma mark borderMethod
- (void)createBorderForAllBoxes
{
    
    self.specialityButton.layer.cornerRadius=0.0f;
    self.specialityButton.layer.masksToBounds = YES;
    self.specialityButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.specialityButton.layer.borderWidth= 1.0f;
    
    self.doctorButton.layer.cornerRadius=0.0f;
    self.doctorButton.layer.masksToBounds = YES;
    self.doctorButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.doctorButton.layer.borderWidth= 1.0f;
    
    self.dateButton.layer.cornerRadius=0.0f;
    self.dateButton.layer.masksToBounds = YES;
    self.dateButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.dateButton.layer.borderWidth= 1.0f;
    
    self.timeButton.layer.cornerRadius=0.0f;
    self.timeButton.layer.masksToBounds = YES;
    self.timeButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.timeButton.layer.borderWidth= 1.0f;
    
    
    self.eConsultMethodBtn.layer.cornerRadius=0.0f;
    self.eConsultMethodBtn.layer.masksToBounds = YES;
    self.eConsultMethodBtn.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.eConsultMethodBtn.layer.borderWidth= 1.0f;
    
}
#pragma mark - Action Methods
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
   
    if (self.currentButton==self.specialityButton)
    {
        self.consultationDiscountedCost.text = nil;
        self.consultationActualCost.text = nil;
        self.promoCodeText.text = nil;
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
        self.promoApplyBtn.tag = 666;
        self.specialityLbl.text = [[self.arrSpeciality objectAtIndex:[self.specialityPicker selectedRowInComponent:0]]objectForKey:@"deptname"];
        specialityId =  [[self.arrSpeciality objectAtIndex:[self.specialityPicker selectedRowInComponent:0]]objectForKey:@"recno"];
        self.specialityLbl.textColor = [UIColor blackColor];
        if (eCostPrice > 0)
        {
            finalCost = [[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"] integerValue];
            self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %ld", (long)finalCost];
            [self setAutoDiscountValue:[[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue]];
            self.consultationActualCost.hidden = NO;
            self.consultationDiscountedCost.hidden = NO;
            self.consultationFeeText.hidden = NO;
            [self showPromo];
        }
        else
        {
            [self hidePromo];
            self.consultationDiscountedCost.hidden = YES;
            finalCost = 0;
            self.consultationActualCost.text = @"Free";
        }
        
        self.specialityLbl.textColor = [UIColor blackColor];
        [self makeRequestForDocAndSpecialities];
    }
    else if (self.currentButton==self.doctorButton)
    {
        NSLog(@"doctorButton doctorButton");
        self.consultationDiscountedCost.text = nil;
        self.consultationActualCost.text = nil;
        self.promoCodeText.text = nil;
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        self.promoApplyBtn.tag = 666;
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
        if (![self.specialityLbl.text isEqualToString:@"Select Speciality"]) {
            self.doctorLbl.text = [[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"dispname"];
            self.doctorLbl.textColor = [UIColor blackColor];
        }
        NSLog(@"doctorButton success");
        if (eConsultCredits > 0)
        {
            finalCost = 0;
            self.consultationActualCost.hidden = YES;
            self.consultationDiscountedCost.hidden = YES;
            self.consultationFeeText.hidden = YES;
            
        }
        else if ([[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"dispname"] isEqualToString:@"Any Doctor"])
        {
            [self hideDoctorProfileBtn];
            if (eCostPrice > 0 && eConsultCredits <=0)
            {
                if ([[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"] != nil)
                {
                    finalCost = [[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"] integerValue];
                    discountedCost = [[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"] doubleValue];
                    if (finalCost == nil)
                        finalCost = eCostPrice;
                    self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %ld", (long)finalCost];
                    if (discountedCost == 0)
                    {
                        finalCost = 0;
                        self.consultationActualCost.text = @"Free";//[NSString stringWithFormat:@"Rs %ld", (long)finalCost];
                    }
                    [self setAutoDiscountValue:[[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue]];
                    self.consultationActualCost.hidden = NO;
                    self.consultationDiscountedCost.hidden = NO;
                    self.consultationFeeText.hidden = NO;
                }
                else
                {
                    if (finalCost == nil)
                        finalCost = eCostPrice;
                    self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %ld", (long)finalCost];
                    [self setAutoDiscountValue:[[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue]];
                    self.consultationActualCost.hidden = NO;
                    self.consultationDiscountedCost.hidden = NO;
                    self.consultationFeeText.hidden = NO;
                }
                [self showPromo];
            }
            else
            {
                consultationFeeAmount = (NSInteger)0;
                finalCost = (NSInteger)0;
                self.consultationDiscountedCost.hidden = YES;
                self.consultationActualCost.text = @"Free";
                [self hidePromo];
            }
        }
        else
        {
            [self showDoctorProfileBtn];
            NSString *defaultEconsultPrice = @"default_econsult_amount";
            NSString *econsultAmount = @"econsult_amount";
            NSString *aEconsultAmount = @"aeconsult_amount";
            if (self.scheduleType != nil) {
                defaultEconsultPrice= @"default_second_opinion_amount";
                econsultAmount = @"second_opinion_amount";
                aEconsultAmount = @"asecond_opinion_econ_amount";
            }
            
            if ([[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:defaultEconsultPrice] != [NSNull null])
            {
                [self showPromo];
                if([[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:defaultEconsultPrice] integerValue])
                {
                    if ([[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"] != [NSNull null])
                    {
                        if ([[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"] integerValue] && eConsultCredits <=0)
                        {
                            self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %@",[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"]];
                            consultationFeeAmount = [[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"service_amount"] integerValue];
                            finalCost = consultationFeeAmount;
                            [self setAutoDiscountValue:[[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue]];
                            self.consultationActualCost.hidden = NO;
                            self.consultationDiscountedCost.hidden = NO;
                            self.consultationFeeText.hidden = NO;
                            [self showPromo];
                        }
                        else
                        {
                            consultationFeeAmount = 0;
                            finalCost = 0;
                            if ([[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue])
                            {
                                self.consultationDiscountedCost.text = @"Free";
                                [self setAutoDiscountValue:[[[self.dictResponse objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue]];
                                self.consultationActualCost.hidden = NO;
                                self.consultationDiscountedCost.hidden = NO;
                                self.consultationFeeText.hidden = NO;
                            }
                            else
                            {
                                self.consultationDiscountedCost.hidden = YES;
                                consultationFeeAmount = 0;
                                finalCost = 0;
                                self.consultationActualCost.text = @"Free";
                                [self hidePromo];
                            }
                        }
                    }
                    else
                    {
                        if ([[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] != [NSNull null])
                        {
                            if ([[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue] == 0)
                            {
                                self.consultationDiscountedCost.hidden = YES;
                                consultationFeeAmount = 0;
                                finalCost = 0;
                                self.consultationActualCost.text = @"Free";
                            }
                            else
                            {
                                finalCost = 0;
                                [self setAutoDiscountValue:[[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue]];
                            }
                            [self showPromo];
                        }
                        else
                        {
                            self.consultationDiscountedCost.hidden = YES;
                            consultationFeeAmount = 0;
                            finalCost = 0;
                            self.consultationActualCost.text = @"Free";
                            [self hidePromo];
                            
                        }
                    }
                    
                }
                else
                {
                    if([[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:econsultAmount] integerValue] && eConsultCredits <=0)
                    {
                        self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %@",[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:econsultAmount]];
                        consultationFeeAmount = [[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:econsultAmount] integerValue];
                        finalCost = consultationFeeAmount;
                        [self setAutoDiscountValue:[[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:aEconsultAmount] integerValue]];
                        self.consultationActualCost.hidden = NO;
                        self.consultationDiscountedCost.hidden = NO;
                        self.consultationFeeText.hidden = NO;
                    }
                    else
                    {
                        if ([[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:econsultAmount] integerValue] == 0)
                        {
                            consultationFeeAmount = 0;
                            finalCost = 0;
                            self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %@",[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:aEconsultAmount]];
                            [self setAutoDiscountValue:[[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:aEconsultAmount] integerValue]];
                            self.consultationActualCost.hidden = NO;
                            self.consultationDiscountedCost.hidden = NO;
                            self.consultationFeeText.hidden = NO;
                        }
                        else
                        {
                            self.consultationActualCost.hidden = NO;
                            self.consultationDiscountedCost.hidden = NO;
                            self.consultationFeeText.hidden = NO;
                            finalCost = 0;
                            [self setAutoDiscountValue:[[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:aEconsultAmount] integerValue]];
                        }
                    }
                }
            }
            else
            {
                self.consultationDiscountedCost.hidden = YES;
                self.consultationActualCost.hidden = NO;
                self.consultationFeeText.hidden = NO;
                consultationFeeAmount = 0;
                finalCost = 0;
                self.consultationActualCost.text = @"Free";
                [self hidePromo];
            }
        }
        NSLog(@"doctorButton success1");

    }
    else if (self.currentButton == self.eConsultMethodBtn)
    {
        self.eConsultMethodLbl.text = [methodArr objectAtIndex:[self.eConsultMethodPicker selectedRowInComponent:0]];
    }
    else if (self.currentButton == self.timeButton)
    {
        self.timeLbl.text = [slotArr objectAtIndex:[self.timePicker selectedRowInComponent:0]];
        self.timeLbl.textColor = [UIColor blackColor];
    }
    _actionSheet.hidden = YES;
    
}

-(void)setAutoDiscountValue:(NSInteger)costReceived
{
    if (econ_auto_camp_count > 0)
    {
        if(costReceived != 0 && costReceived != finalCost)
        {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", costReceived]];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            self.consultationActualCost.attributedText = attributeString;
            if (finalCost > 0)
                self.consultationDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)finalCost];
            else
                self.consultationDiscountedCost.text = @"Free";
            
        }
        else if (finalCost == 0)
            self.consultationDiscountedCost.text = @"Free";
    }
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //    if (self.fromFindDoctors)
    //    {
    //        for (UIViewController *controller in [self.navigationController viewControllers])
    //        {
    //            if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
    //            {
    //                [self.navigationController popToViewController:controller animated:YES];
    //            }
    //        }
    //    }
    //    else
    //    {
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }
}

-(void)homeBtnClicked:(id)sender
{
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
- (IBAction)specialityButtonClicked:(id)sender
{
    if ([self.arrSpeciality count])
    {
        [self clearTextfieldData:self.specialityLbl];
        self.currentButton = self.specialityButton;
        self.currentButton.tag = 1;
        calendarApiType = 1;
        [self showPicker];
    }
    else
        [self customAlertView:@"Network Error" Message:@"Not able to fetch the speciality list please refresh the page and try again." tag:1];
}

- (IBAction)doctorButtonClicked:(id)sender
{
    autoSelect = YES;
    self.currentButton = self.doctorButton;
    self.currentButton.tag = 2;
    if (![self.specialityLbl.text isEqualToString:@"Select Speciality"])
    {

        if(self.dictResponse)
        {
            [self clearTextfieldData:self.doctorLbl];
            calendarApiType = 2;
            //[self makeRequestForDocAndSpecialities];
            [self getDoctorsList];
            if (self.doctorDictArray.count > 0) {
                [self showPicker];

            }else {
                [self customAlertView:@"" Message:@"No Doctors to show." tag:0];

            }
        }
        else
            [self customAlertView:@"" Message:@"No Doctors to show." tag:0];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a speciality" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (IBAction)dateButtonClicked:(id)sender
{
    if ([self.doctorLbl.text isEqualToString:@"Select Doctor"] && ![self.specialityLbl.text isEqualToString:@"Select Speciality"])
    {
        calendarApiType = 1;
    }
    if (calendarApiType)
    {
        [self makeRequestForDates];
//        if (componentsArray.count>0) {
//            [self initCalendar];
//        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a speciality" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (IBAction)timeButtonClicked:(id)sender
{
    if (![self.timeLbl.text isEqualToString: @"No time slots available"])
    {
        self.currentButton = self.timeButton;
        self.currentButton.tag = 3;
        if ([slotArr count])
            [self showPicker];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No time slots available please select another date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}
- (IBAction)eConsultMethodBtnClicked:(id)sender
{
    self.currentButton = self.eConsultMethodBtn;
    self.currentButton.tag = 4;
    [self showPicker];
}
- (IBAction)eConsultBookBtnClicked:(id)sender
{
    if ([self.specialityLbl.text isEqualToString:@"Select Speciality"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a speciality" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        return;
    }else  if ([self.doctorLbl.text isEqualToString:@"Select Doctor"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a speciality" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        return;
    }
    else if([self.dateLbl.text isEqualToString: @"Select a date"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Request you to pick a date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        return;
    }
    else if ([self.timeLbl.text isEqualToString: @"No time slots available"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select available date and time and re-try" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        return;
    }
    else
        [self checkPackageAndBook];
    
}

- (IBAction)doctorProfileButtonClicked:(id)sender
{
    
    NSLog(@"doctor array.......:%@",[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]]);
    [self performSegueWithIdentifier:@"viewEconDocProfile" sender:[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]]];
    
}
- (IBAction)promoApplyBtnClicked:(id)sender
{
    if (self.promoApplyBtn.tag == 666)
    {
        [self.promoCodeText resignFirstResponder];
        if ([self.promoCodeText.text length] > 0 && self.promoCodeText.text != nil)
        {
            [self makeRequestCheckPromo];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Enter valid promo code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    else if (self.promoApplyBtn.tag == 999)
    {
        self.promoApplyBtn.tag = 666;
        NSString *cost = self.consultationActualCost.text;
        self.consultationActualCost.attributedText =nil;
        self.consultationActualCost.text = cost;
        self.consultationDiscountedCost.text = nil;
        NSArray *arr = [self.consultationActualCost.text componentsSeparatedByString:@" "];
        if ([arr count]  >= 2)
            finalCost = [[arr objectAtIndex:1] integerValue];
        else
            finalCost = 0;
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    
}
-(void)errorSectionId:(id)sender
{
    NSLog(@"error");
}

#pragma mark - Text filed Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.promoApplyBtn.tag == 666)
        return YES;
    else
        return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)hidePromo
{
    self.promoApplyBtn.hidden = YES;
    self.promoCodeText.hidden = YES;
    self.closeImage.hidden = YES;
    self.consultationFeeText.frame = CGRectMake(self.consultationFeeText.frame.origin.x, self.promoCodeText.frame.origin.y, self.consultationFeeText.frame.size.width, self.consultationFeeText.frame.size.height);
    self.consultationActualCost.frame = CGRectMake(self.consultationActualCost.frame.origin.x, self.promoCodeText.frame.origin.y, self.consultationActualCost.frame.size.width, self.consultationActualCost.frame.size.height);
    self.consultationDiscountedCost.frame = CGRectMake(self.consultationDiscountedCost.frame.origin.x, self.promoCodeText.frame.origin.y, self.consultationDiscountedCost.frame.size.width, self.consultationDiscountedCost.frame.size.height);
}

- (void)showPromo
{
    if (econ_auto_camp_count <= 0)
    {
        self.promoApplyBtn.hidden = NO;
        self.promoCodeText.hidden = NO;
        self.closeImage.hidden = NO;
        self.consultationFeeText.hidden = NO;
        self.consultationFeeText.frame = CGRectMake(self.consultationFeeText.frame.origin.x, self.promoCodeText.frame.origin.y + self.promoCodeText.frame.size.height + 9, self.consultationFeeText.frame.size.width, self.consultationFeeText.frame.size.height);
        self.consultationActualCost.frame = CGRectMake(self.consultationActualCost.frame.origin.x, self.promoCodeText.frame.origin.y + self.promoCodeText.frame.size.height + 9, self.consultationActualCost.frame.size.width, self.consultationActualCost.frame.size.height);
        self.consultationDiscountedCost.frame = CGRectMake(self.consultationDiscountedCost.frame.origin.x, self.promoCodeText.frame.origin.y + self.promoCodeText.frame.size.height + 9, self.consultationDiscountedCost.frame.size.width, self.consultationDiscountedCost.frame.size.height);
    }
    
}

- (void)hideDoctorProfileBtn
{
    self.doctorProfileButton.hidden = YES;
    self.doctorLbl.frame = CGRectMake(self.doctorLbl.frame.origin.x, self.doctorLbl.frame.origin.y, 270, self.doctorLbl.frame.size.height);
    self.doctorButton.frame = CGRectMake(self.doctorButton.frame.origin.x, self.doctorButton.frame.origin.y, 288, self.doctorButton.frame.size.height);
    self.doctorDownArrowImage.frame = CGRectMake((self.doctorButton.frame.size.width + self.doctorButton.frame.origin.x) - (self.doctorDownArrowImage.frame.size.width + 12), self.doctorDownArrowImage.frame.origin.y, self.doctorDownArrowImage.frame.size.width, self.doctorDownArrowImage.frame.size.height);
}

- (void)showDoctorProfileBtn
{
    self.doctorProfileButton.hidden = NO;
    self.doctorLbl.frame = CGRectMake(self.doctorLbl.frame.origin.x, self.doctorLbl.frame.origin.y, 195, self.doctorLbl.frame.size.height);
    self.doctorButton.frame = CGRectMake(self.doctorButton.frame.origin.x, self.doctorButton.frame.origin.y, 228, self.doctorButton.frame.size.height);
    self.doctorDownArrowImage.frame = CGRectMake((self.doctorButton.frame.size.width + self.doctorButton.frame.origin.x) - (self.doctorDownArrowImage.frame.size.width + 12), self.doctorDownArrowImage.frame.origin.y, self.doctorDownArrowImage.frame.size.width, self.doctorDownArrowImage.frame.size.height);
    
}

#pragma mark - Request methods
- (void)makeRequestCheckPromo
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *econ_speciality = [[self.arrSpeciality objectAtIndex:[self.specialityPicker selectedRowInComponent:0]]objectForKey:@"recno"];

    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    NSString *offerFor= @"1";
    NSString *schType = @"";
    if (self.scheduleType != nil) {
        offerFor = @"4";
        schType = @"2";
    }
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&for=%@&promocode=%@&sc_type=%@",@"cid",strCid,@"sessionid",sectionId, offerFor,self.promoCodeText.text,schType];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@&for=%@&promocode=%@&sc_type=%@",@"cid",strCid,@"isopen",@"1",offerFor, self.promoCodeText.text,schType];
    }
    if (econ_speciality != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&splid=%@&name=%@",econ_speciality,name]];
    }
    NSLog(@"body....:%@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mchkcamp"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucessssss %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
            [self makeRequestForUserRegister];
        }
        else
        {
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    if ([[response objectForKey:@"chkredeem"] integerValue] == )
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    NSString *msg;
                    promoApplied = NO;
                    if ([[response objectForKey:@"chkredeem"] integerValue] == 1)
                    {
                        self.promoApplyBtn.tag = 999;
                        [self.promoApplyBtn setTitle:nil forState:UIControlStateNormal];
                        [self.promoApplyBtn setBackgroundImage:nil forState:UIControlStateNormal];
                        promoApplied = YES;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code applied. Thank you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        campId = [[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"recno"];
                        //                        discount
                        float discountPercent = [[[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"discount"] floatValue];
                        discountPercent = discountPercent/100;
                        float discount = finalCost * discountPercent;
                        discountedCost = ceilf(finalCost - discount);
                        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", finalCost]];
                        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                                value:@2
                                                range:NSMakeRange(0, [attributeString length])];
                        self.consultationActualCost.attributedText = attributeString;
                        finalCost = discountedCost;
                        if (discountedCost > 0)
                            self.consultationDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)discountedCost];
                        else
                        {
                            self.consultationDiscountedCost.text = @"Free";
                        }
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -3)
                    {
                        promoApplied = NO;
                        msg = @"You already used this promo code";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -4)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"This promo code expired." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -5)
                    {
                        promoApplied = NO;
                        msg = @"Given promo code not sent to this user";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -6)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code is invalid. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -7)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable at this location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -8)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for this visit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -9)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for E-Consults." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    
                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}

- (void)checkPackageAndBook
{
    if (eConsultCredits > 0)
    {
        payOption = 1;
        [self makeRequestToAddEconsult];
    }
    else
    {
        if (finalCost == 0)
        {
            payOption = 2;
            [self makeRequestToAddEconsult];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromEconsult"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"Note" Message:@"You will be taken to the payment gateway to complete the transaction, as you do not have credits." tag:2];
        }
    }
    
}
-(void)makeRequestForPackage
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText=nil;
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpack"];//@"mdocs"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 2 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                
                NSString *creditsKey = @"econsults";
                NSString *costKey = @"ecost";
                if (self.scheduleType != nil) {
                    creditsKey = @"second_opinions_available";
                    costKey= @"sec_econ_cost";
                }
                
                if ([response[@"credit_setting"] integerValue] == 0) {
                    if ([[response objectForKey:costKey]integerValue] == 0)
                    {
                        eCostPrice = 0;
                    }
                    else
                    {
                        eConsultCredits = 0;
                        eCostPrice = [[response objectForKey:costKey]integerValue];
                    }
                    
                }else {
                
                NSString *creditsAvailable= nil;

                if ([[response objectForKey:creditsKey] isEqual:[NSNull null]]) {
                    creditsAvailable = @"0";
                }else {
                    creditsAvailable =[response objectForKey:creditsKey];
                }
                
                
                if ([creditsAvailable integerValue]> 0 )
                {
                    
                eConsultCredits = [creditsAvailable integerValue];
                    
                //eConsultCredits = [[response objectForKey:@"econsults"]integerValue];

                //[self makeRequestToAddEconsult];
                }
                else
                {
                    //                    if (consultationFeeAmount == 0 && [[response objectForKey:@"ecost"]integerValue] == 0)
                    if ([[response objectForKey:costKey]integerValue] == 0)
                    {
                        eCostPrice = 0;
                        //                        [self makeRequestToAddEconsult];
                    }
                    else
                    {
                        eConsultCredits = 0;
                        eCostPrice = [[response objectForKey:costKey]integerValue];
                    }
                }
                }
                [self makeRequestForSpecialities];
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
         dispatch_async(dispatch_get_main_queue(),^{
        [self customAlertView:@"Not able to fetch user credits and other details due to network issues. Please try again" Message:@"Try again" tag:1];
         });
    }];
    
}

- (void)makeRequestToAddEconsultWithPayment
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *dateStr = self.dateLbl.text;
    //NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)currentComponent.day, (long)currentComponent.month, (long)currentComponent.year];
    NSString *econTime  = self.timeLbl.text;
    NSString *scType = nil;

    if ([self.eConsultMethodLbl.text isEqualToString:@"Video Conference"]){
        econ_method = 1;
        scType = @"2";
    }
    else{
        econ_method = 2;
        scType = @"1";

    }
    NSString *econ_speciality = [[self.arrSpeciality objectAtIndex:[self.specialityPicker selectedRowInComponent:0]]objectForKey:@"recno"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText;
 
    
    if ([sectionId length] > 0)
    {
        if (calendarApiType == 1)
            bodyText = [NSString stringWithFormat:@"%@=%@&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=3&econ_consult_type=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@",@"sessionid",sectionId, dateStr, econTime, calendarApiType, econ_speciality, @"-1", econ_method, [self.packageResponse objectForKey:@"ecostid"], self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"],[self.paymentResponseDictionary objectForKey:@"TxStatus"],[self.paymentResponseDictionary objectForKey:@"amount"] ,[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"]];
        
        else
            bodyText = [NSString stringWithFormat:@"%@=%@&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=3&econ_consult_type=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@",@"sessionid",sectionId, dateStr, econTime, calendarApiType, econ_speciality, [[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]]objectForKey:@"recno"], econ_method, [self.packageResponse objectForKey:@"ecostid"], self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"], [self.paymentResponseDictionary objectForKey:@"TxStatus"] ,[self.paymentResponseDictionary objectForKey:@"amount"],[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"]];
    }
    else
    {
        if (calendarApiType == 1)
            bodyText = [NSString stringWithFormat:@"%@=%d&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=3&econ_consult_type=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@&cid=%@&patient_email=%@",@"isopen",1, dateStr, econTime, calendarApiType, econ_speciality, @"", econ_method, [self.packageResponse objectForKey:@"ecostid"], self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"],[self.paymentResponseDictionary objectForKey:@"TxStatus"],[self.paymentResponseDictionary objectForKey:@"amount"] ,[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"], strCid, [[NSUserDefaults standardUserDefaults] objectForKey:@"patient_email"]];
        
        else
            bodyText = [NSString stringWithFormat:@"%@=%d&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=3&econ_consult_type=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@&cid=%@&patient_email=%@",@"isopen",1, dateStr, econTime, calendarApiType, econ_speciality, [[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]]objectForKey:@"recno"], econ_method, [self.packageResponse objectForKey:@"ecostid"], self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"], [self.paymentResponseDictionary objectForKey:@"TxStatus"] ,[self.paymentResponseDictionary objectForKey:@"amount"],[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"], strCid, [[NSUserDefaults standardUserDefaults] objectForKey:@"patient_email"]];
    }
    if (self.scheduleType != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&apptype=%@&sc_type=%@",@"3",scType]];
    }
    if ([campId length] > 0 && campId != nil)
    {
        NSString *campTemp = [NSString stringWithFormat:@"&campid=%@",campId];
        bodyText = [bodyText stringByAppendingString:campTemp];
    }
    NSString *campTemp = [NSString stringWithFormat:@"&patient_name=%@&patient_mobile=%@",name, number];
    bodyText = [bodyText stringByAppendingString:campTemp];
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddecon"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
       
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                if ([[response objectForKey:@"ebooked"] integerValue] == 1)
                {
                    if (self.doctorEconsultDetail)
                        [self customAlertView:@"" Message:@"Thank you. Your E-Consult is booked. \nNow Enter information such as lab reports and symptoms." tag:kBookAppSuccesTagFindDoctors];
                    else
                        [self customAlertView:@"" Message:@"Thank you. Your E-Consult is booked. \nNow Enter information such as lab reports and symptoms." tag:1];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking E-Consult please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                   
                    return;
                }
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking E-Consult please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
    
}


- (void)makeRequestToAddEconsult
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *dateStr = self.dateLbl.text;
   // NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)currentComponent.day, (long)currentComponent.month, (long)currentComponent.year];
    NSString *econTime  = self.timeLbl.text;
    NSString *scType = nil;
    if ([self.eConsultMethodLbl.text isEqualToString:@"Video Conference"]){
        econ_method = 1;
        scType = @"2";
    }
    else{
        econ_method = 2;
        scType = @"1";

    }
    NSString *econ_speciality = [[self.arrSpeciality objectAtIndex:[self.specialityPicker selectedRowInComponent:0]]objectForKey:@"recno"];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];

    NSString *bodyText;
    if ([sectionId length]>0)
    {
        if (calendarApiType == 1){
            bodyText = [NSString stringWithFormat:@"%@=%@&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=%d",@"sessionid",sectionId, dateStr, econTime, calendarApiType, econ_speciality, @"-1", econ_method, payOption];
           
        }
        else{
            bodyText = [NSString stringWithFormat:@"%@=%@&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=%d",@"sessionid",sectionId, dateStr, econTime, calendarApiType, econ_speciality, [[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]]objectForKey:@"recno"], econ_method, payOption];
        }
    }
    else
    {
        if (calendarApiType == 1)
            bodyText = [NSString stringWithFormat:@"%@=%d&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=%d&cid=%@",@"isopen",1, dateStr, econTime, calendarApiType, econ_speciality, @"", econ_method, payOption, strCid];
        else
            bodyText = [NSString stringWithFormat:@"%@=%d&econ_date=%@&econ_time=%@&econ_type=%d&econ_specialty=%@&econ_doctor=%@&econ_method=%d&payoption=%d&cid=%@",@"isopen",1, dateStr, econTime, calendarApiType, econ_speciality, [[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]]objectForKey:@"recno"], econ_method, payOption, strCid];
    }
    
    if (self.scheduleType != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&apptype=%@&sc_type=%@",@"3",scType]];
    }
    if ([campId length] > 0 && campId != nil)
    {
        NSString *campTemp = [NSString stringWithFormat:@"&campid=%@",campId];
        bodyText = [bodyText stringByAppendingString:campTemp];
    }
    NSString *campTemp = [NSString stringWithFormat:@"&patient_name=%@&patient_mobile=%@",name, number];
    bodyText = [bodyText stringByAppendingString:campTemp];
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddecon"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                if ([[response objectForKey:@"ebooked"] integerValue] == 1)
                {
                    if (self.doctorEconsultDetail)
                        [self customAlertView:@"" Message:@"Thank you. Your E-Consult is booked. \nNow Enter information such as lab reports and symptoms." tag:kBookAppSuccesTagFindDoctors];
                    else
                        [self customAlertView:@"" Message:@"Thank you. Your E-Consult is booked. \nNow Enter information such as lab reports and symptoms." tag:1];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking E-Consult please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    return;
                }
            });
        }
    } failureHandler:^(id response) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking E-Consult please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
    
}

-(void)makeRequestForSpecialities
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mspec"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucess %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
            
            [self makeRequestForUserRegister];
        }
        else if([sectionId length] == 0 && [[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            //[self makeRequestForUserRegister];
        }
        else
        {
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
                
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    self.view.userInteractionEnabled = YES;
                    [refreshControl endRefreshing];
                    self.arrSpeciality=[response objectForKey:@"spec"];
                    [self clearTextfieldData:self.specialityLbl];
                    self.currentButton = self.specialityButton;
                    self.currentButton.tag = 1;
                    calendarApiType = 1;
//                    self.specialityLbl.text = [[self.arrSpeciality objectAtIndex:0]objectForKey:@"deptname"];
//                    specialityId = [[self.arrSpeciality objectAtIndex:0]objectForKey:@"recno"];
                    //self.specialityLbl.textColor = [UIColor blackColor];
                    autoSelect = YES;
                    if([self.doctorEconsultDetail count])
                    {
                        self.specialityLbl.text = [self.doctorEconsultDetail objectForKey:@"deptname"];
                    }
                    if (self.specialityId != nil) {
                
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recno ==  %@", self.specialityId];
                        NSArray *result = [self.arrSpeciality filteredArrayUsingPredicate: predicate];
                        if (result.count) {
                            self.specialityLbl.text = [[result objectAtIndex:0]objectForKey:@"deptname"];
                            self.specialityLbl.textColor = [UIColor blackColor];
                        }
                    }
                    
                    [self makeRequestForDocAndSpecialities];

                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    
    [self addSpinnerView];
    NSString *strMobile=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    NSString *strCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobile];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCode]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hey sucess %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:strCode forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self makeRequestForSpecialities];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            
            
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

-(void)makeRequestForDocAndSpecialities
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    NSString *type = @"1";
    NSString *schType = @"";
    if (self.scheduleType != nil) {
        type = @"3";
        schType = @"2";
    }
    
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&type=%@&sc_type=%@&splid=%@",@"sessionid",sectionId,@"locid",@"",type,schType,specialityId];
        
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&type=%@&sc_type=%@",@"cid",strCid,@"locid",@"",@"isopen",@"1",type,schType];
    }
    NSLog(@"econdoc body......:%@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocdoc"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([[response objectForKey:@"econ_auto_camp_count"]integerValue] > 0)
                {
                    econ_auto_camp_count = [[response objectForKey:@"econ_auto_camp_count"]integerValue];
                    [self hidePromo];
                }
                else
                {
                    econ_auto_camp_count = 0;
                    [self showPromo];
                }
                //self.consultationFeeText.hidden = NO;
                if(![self.doctorEconsultDetail count])
                {
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                }
                self.view.userInteractionEnabled = YES;
                //                [self.arrSpeclist removeAllObjects];
                self.dictResponse = nil;
                self.dictResponse = [response objectForKey:@"docspec"];
                [self getDoctorsList];
                //[self makeRequestForSpecialities];

            });
            
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"" Message:@"Problem loading doctor(s) list. Please try after sometime" tag:0];
    }];
}
- (void)makeRequestForSlots
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *dateStr = self.dateLbl.text;//[NSString stringWithFormat:@"%ld-%ld-%ld", (long)currentComponent.day, (long)currentComponent.month, (long)currentComponent.year];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText;
    NSString *schType = @"";
    NSString *type = [NSString stringWithFormat:@"%d",calendarApiType];
    if ([self.doctorLbl.text isEqualToString:@"Any Doctor"]){
        type = @"1";
    }
     if (self.scheduleType != nil) {
        type = @"3";
        schType = @"2";
    }
    if ([sectionId length]>0)
    {
        if (calendarApiType == 1)
            bodyText = [NSString stringWithFormat:@"%@=%@&type=%@&doa=%@&docid=%@&sc_type=%@",@"sessionid",sectionId ,type, dateStr, @"",schType];
        else
            bodyText = [NSString stringWithFormat:@"%@=%@&type=%@&doa=%@&docid=%@&sc_type=%@",@"sessionid",sectionId, type, dateStr, [[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"recno"],schType];
    }
    else
    {
        if (calendarApiType == 1)
            bodyText = [NSString stringWithFormat:@"%@=%d&type=%@&doa=%@&docid=%@&cid=%@&sc_type=%@",@"isopen",1, type, dateStr, @"", strCid,schType];
        else
            bodyText = [NSString stringWithFormat:@"%@=%d&type=%@&doa=%@&docid=%@&cid=%@&sc_type=%@",@"isopen",1, type, dateStr, [[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"recno"], strCid,schType];

    }
    if (self.scheduleType != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sch_type=3"]];
    }
    
    NSLog(@"bodytext.....:%@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"meconslot"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                slotArr = [[NSMutableArray alloc]init];
                slotArr = [response objectForKey:@"slots"];
                if ([slotArr count])
                {
                    self.timeLbl.text = [[response objectForKey:@"slots"] objectAtIndex:0];
                    self.timeLbl.textColor = [UIColor blackColor];
                } 
            });
        }
    } failureHandler:^(id response) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}
- (void)makeRequestForDates
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
   
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
  
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
   
    
    NSString *bodyText;
    NSString *schType = @"";
    
    if (self.scheduleType != nil) {
        schType = @"2";
    }
    
    
    if ([sectionId length] > 0)
    {
        if (calendarApiType == 1)
            bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&sc_type=%@",@"sessionid",sectionId, calendarApiType,schType];
        else
            bodyText = [NSString stringWithFormat:@"%@=%@&type=%d&docid=%@&sc_type=%@",@"sessionid",sectionId, calendarApiType,[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"recno"],schType];
    }
    else
    {
        if (calendarApiType == 1)
            bodyText = [NSString stringWithFormat:@"%@=%d&type=%d&cid=%@&sc_type=%@",@"isopen",1, calendarApiType, strCid,schType];
        else
            bodyText = [NSString stringWithFormat:@"%@=%d&type=%d&docid=%@&cid=%@&sc_type=%@",@"isopen",1, calendarApiType,[[self.doctorDictArray objectAtIndex:[self.doctorPicker selectedRowInComponent:0]] objectForKey:@"recno"], strCid,schType];
        
    }
    if (self.scheduleType != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sch_type=3"]];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mecondt"];
    NSLog(@"Body text : %@", bodyText);
    NSLog(@"URL : %@", url);
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSString *type = NSStringFromClass([[response objectForKey:@"econdates"] class]);
                if(![type isEqualToString:@"__NSCFNumber"])
                {
                    NSMutableArray *sample = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"econdates"]];
                    [self.componentsArray removeAllObjects];
                    responseArr = [[NSMutableArray alloc]init];
//                    self.calendarContainer.hidden = NO;
                    [self.view bringSubviewToFront:self.calendarContainer];
                    for (int i=0;i<[sample count];i++)
                    {
                        for (int j=0; j<[[sample objectAtIndex:i] count];j++)
                        {
                       
                            
                            [self getDateValues:[[[sample objectAtIndex:i] objectAtIndex:j] doubleValue]];
//
                            [responseArr addObject:myDate];
                        }
                        
                    }
                    if (calenderStat == 0)
                    {
                        [self initCalendar];
                        self.calendarContainer.hidden = NO ;
                    }else{
                        
                        self.calendarContainer.hidden = NO ;
                        [self.calendarView reloadDates:self.componentsArray];                    }

                    
//                    [self.calendarView reloadDates:self.componentsArray];
//                    if ((self.calendarContainer.hidden = YES)) {
//                        
//                        [self initCalendar];
//
//                        self.calendarContainer.hidden = NO ;
//                        
//                        
//                    }else{
//                        self.calendarContainer.hidden = NO ;
//                        
//                        
//                    }
                    
                }
                else
                    
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No dates available for the selected doctor." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
                //                responseArr = [[NSMutableArray alloc]init];
                //                responseArr = [response objectForKey:@"econdates"];
                //                NSLog(@"full array : %@", responseArr);
                //                NSLog(@"\n object residing at 1st index of the array : %@", [responseArr objectAtIndex:0]);
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == kBookAppSuccesTagFindDoctors)
    {
        [self performSegueWithIdentifier:@"eListView" sender:nil];
    }
    if (alertView.tag == 2 && buttonIndex == 1)
        [self performSegueWithIdentifier:@"payment" sender:nil];
}
#pragma mark - Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"payment"]) {
        ((SmartRxPaymentVC *)segue.destinationViewController).costValue = [NSString stringWithFormat:@"%d", finalCost];
        ((SmartRxPaymentVC *)segue.destinationViewController).packageResponse = [[NSMutableDictionary alloc]init];
        ((SmartRxPaymentVC *)segue.destinationViewController).packageResponse = self.packageResponse;
    }
    else if ([segue.identifier isEqualToString:@"viewEconDocProfile"])
    {
        ((SmartRxViewDoctorProfile *)segue.destinationViewController).doctorArray = [[NSMutableDictionary alloc] init];
        ((SmartRxViewDoctorProfile *)segue.destinationViewController).doctorArray = sender;
        ((SmartRxViewDoctorProfile *)segue.destinationViewController).dictResponse = self.dictResponse;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fromEconsultToDocProfile"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else if ([segue.identifier isEqualToString:@"eListView"])
    {
        ((SmartRxeConsultVC *)segue.destinationViewController).fromFindDoctorsORDashboard = YES;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
#pragma mark spinner alert & picker
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView;
    if (alertTag == 2)
        alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    else
        alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

- (void)showPicker
{
    _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    _pickerToolbar.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleBlackOpaque;
    [_pickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [barItems addObject:cancelBtn];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpace.width = 200.0f;
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [barItems addObject:doneBtn];
    
    
    [_pickerToolbar setItems:barItems animated:YES];
    
    [_actionSheet addSubview:_pickerToolbar];
    
    if (self.currentButton==self.specialityButton)
    {
        [_actionSheet addSubview:self.specialityPicker];
        [self.specialityPicker reloadAllComponents];
    }
    else if (self.currentButton==self.doctorButton)
    {
        [_actionSheet addSubview:self.doctorPicker];
        [self.doctorPicker reloadAllComponents];
        if ([self.doctorLbl.text isEqualToString:@"Any Doctor"])
            [self.doctorPicker selectRow:0 inComponent:0 animated:NO];
        
    }
    else if (self.currentButton == self.eConsultMethodBtn)
    {
        [_actionSheet addSubview:self.eConsultMethodPicker];
        [self.eConsultMethodPicker reloadAllComponents];
    }
    else if (self.currentButton == self.timeButton)
    {
        [_actionSheet addSubview:self.timePicker];
        [self.timePicker reloadAllComponents];
    }
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    
}
- (BOOL)dateIsApt:(NSDate *)date
{
    if ([ self.componentsArray count])
    {
        for (NSDate *enableDate in self.componentsArray) {
            if ([enableDate isEqualToDate:date]) {
                return YES;
            }
        }
    }
    return NO;

    
}

#pragma mark - CKCalendarDelegate
- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    if ([self dateIsApt:date])
    {
        dateItem.backGroundImg = [UIImage imageNamed:@"dayMarked.png"];
    }
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date
{
    return [self dateIsDisabled:date];
}


- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    self.dateLbl.text = [self.dateFormatter stringFromDate:date];
    self.dateLbl.textColor = [UIColor blackColor];
    [UIView animateWithDuration:0.5 animations:^{
                self.calendarContainer.hidden = YES;
                calenderHidden = YES ;
                calenderStat = 1;
            } completion:^(BOOL finished) {
            }];
    [self makeRequestForSlots];
    
   // [_chosenDates addObject:date];
   
    if ([self dateIsApt:date])
    {
        NSLog(@"%@",[self.appointmentDetails objectAtIndex:[self.selectedDates indexOfObject:date]]);
        [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isEqualToDate:date])
             {
                 NSDictionary *tempDict = [self.appointmentDetails objectAtIndex:idx];
                 [econsultDetailsArr addObject:tempDict];
             }
         }];
        self.econsultDetails = econsultDetailsArr;
        
    }
    else
    {
//        self.dateLbl.hidden = NO;
//        self.dateLbl.frame = CGRectMake(self.dateLbl.frame.origin.x, self.calendarView.frame.origin.y + self.calendarView.frame.size.height-40, self.dateLbl.frame.size.width, self.dateLbl.frame.size.width);
    }
    
    
}
- (BOOL)dateIsDisabled:(NSDate *)date
{
    for (NSDate *disabledDate in self.componentsArray)
    {
        if ([disabledDate isEqualToDate:date])
        {
            return YES;
        }
    }
    return NO;
}


- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    return true ;
}
- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date
{
       
}


#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    //    if (pickerView == self.heightPicker)
    //    {
    //        return firstPickerNoOfComponents;
    //    }
    //    else
    //    {
    //        return secondPickerNoOfComponents;
    //    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (self.currentButton == self.specialityButton)
    {
        NSLog(@"Spec arr count %lu", (unsigned long)[self.arrSpeciality count]);
        return [self.arrSpeciality count];
    }
    else if (self.currentButton == self.doctorButton)
    {
        NSLog(@"Doctor arr count %lu", (unsigned long)[self.doctorDictArray count]);
        return [self.doctorDictArray count];
    }
    else if (self.currentButton == self.timeButton)
    {
        NSLog(@"slot arr count %lu", (unsigned long)[slotArr count]);
        return [slotArr count];
    }
    else if (self.currentButton == self.eConsultMethodBtn)
    {
        NSLog(@"method arr count %lu", (unsigned long)[methodArr count]);
        return [methodArr count];
    }
    
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (self.currentButton==self.specialityButton)
    {
        return [[self.arrSpeciality objectAtIndex:row]objectForKey:@"deptname"];
    }
    else if (self.currentButton==self.doctorButton)
    {
        return [[self.doctorDictArray objectAtIndex:row] objectForKey:@"dispname"];
    }
    else if (self.currentButton==self.timeButton)
    {
        return [slotArr objectAtIndex:row];
    }
    else if (self.currentButton==self.eConsultMethodBtn)
    {
        return [methodArr objectAtIndex:row];
    }
    //    if (pickerView == self.heightPicker)
    //    {
    //        if (component == 0 && self.heightIsCm) {
    //            return [NSString stringWithFormat:@"%d", row+1];
    //        }
    //        else if (component == 1)
    //        {
    //            return [self.firstPickerComponentOneArray objectAtIndex:row];
    //        }
    //        else
    //        {
    //            return [NSString stringWithFormat:@"%.01f",[[_feetMeasures objectAtIndex:row] floatValue]];
    //        }
    //    }
    //    else
    //    {
    //        if (component == 0) {
    //            return [NSString stringWithFormat:@"%d", row+1];
    //        }
    //        else if (component == 1)
    //        {
    //            return [self.secondPickerComponentOneArray objectAtIndex:row];
    //        }
    //    }
    
    return [NSString stringWithFormat:@"Hey Row %ld", (long)self.currentButton.tag];
}

#pragma mark - other methods
-(void)clearTextfieldData:(UILabel *)selectedLabel
{
    if (selectedLabel == self.specialityLbl)
    {
        if(![self.doctorLbl.text isEqualToString:@"Select Doctor"])
        {
            if (self.scheduleType == nil) {
                self.doctorLbl.text=@"Select Doctor";
                self.doctorLbl.text=@"";

            }else {
                self.doctorLbl.text=@"";

            }
            [self hideDoctorProfileBtn];
            //            self.doctorLbl.textColor = [UIColor lightGrayColor];
        }
        if(![self.dateLbl.text isEqualToString:@"Select a date"])
        {
            self.dateLbl.text=@"Select a date";
            self.dateLbl.textColor = [UIColor lightGrayColor];
            NSDate *today = [NSDate date];
            NSDate *end = [NSDate date];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [calendar setTimeZone:[NSTimeZone systemTimeZone]];
            NSDateComponents *dateCompStart = [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:today];
            NSDateComponents *dateCompEnd = [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:end];
            
//            DSLCalendarRange *range = [[DSLCalendarRange alloc] initWithStartDay:dateCompStart endDay:dateCompEnd];
//            
//            [self.calendarView setSelectedRange:range];
        }
        if(![self.timeLbl.text isEqualToString:@"No time slots available"])
        {
            self.timeLbl.text=@"No time slots available";
            self.timeLbl.textColor = [UIColor lightGrayColor];
        }
    }
    else if (selectedLabel == self.doctorLbl)
    {
        if(![self.dateLbl.text isEqualToString:@"Select a date"])
        {
            self.dateLbl.text=@"Select a date";
            self.dateLbl.textColor = [UIColor lightGrayColor];
            NSDate *today = [NSDate date];
            NSDate *end = [NSDate date];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [calendar setTimeZone:[NSTimeZone systemTimeZone]];
            NSDateComponents *dateCompStart = [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:today];
            NSDateComponents *dateCompEnd = [calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:end];
            
//            DSLCalendarRange *range = [[DSLCalendarRange alloc] initWithStartDay:dateCompStart endDay:dateCompEnd];
//            
//            [self.calendarView setSelectedRange:range];
        }
        if(![self.timeLbl.text isEqualToString:@"No time slots available"])
        {
            self.timeLbl.text=@"No time slots available";
            self.timeLbl.textColor = [UIColor lightGrayColor];
        }
    }

}

- (void)getDoctorsList
{
    NSString *specDeptName = self.specialityLbl.text;
    [self.doctorDictArray removeAllObjects];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"Any Doctor" forKey:@"dispname"];
    [dict setObject:@"-1" forKey:@"recno"];
    if (self.scheduleType == nil) {
       [self.doctorDictArray addObject:dict];

    }
    int index = 0;
    for (int i=0; i < [self.dictResponse count]; i++)
    {
        if ([[[self.dictResponse objectAtIndex:i] objectForKey:@"deptname"] isEqualToString:specDeptName])
        {
            [self.doctorDictArray addObject:[self.dictResponse objectAtIndex:i]];
            if([self.doctorEconsultDetail count])
            {
                if ([[self.doctorEconsultDetail objectForKey:@"dispname"] isEqualToString:[[self.dictResponse objectAtIndex:i] objectForKey:@"dispname"]])
                {
                    index = [self.doctorDictArray count]-1;
                }
            }
        }
        
        
        
    }
    if([self.doctorDictArray count] && autoSelect)
    {
        //        doctorDictArray
        if(self.dictResponse)
        {
            calendarApiType = 2;
        }
        self.currentButton = self.doctorButton;
        self.currentButton.tag = 2;
        [self.doctorPicker reloadAllComponents];
        
        if([self.doctorEconsultDetail count])
        {
            [self.doctorPicker selectRow:index inComponent:0 animated:NO];
            if (![self.specialityLbl.text isEqualToString:@"Select Speciality"]) {
                NSLog(@"not working2");

                self.doctorLbl.text = [[self.doctorDictArray objectAtIndex:index] objectForKey:@"dispname"];
            }
            [self.doctorPicker reloadAllComponents];
            [self.doctorPicker selectRow:index inComponent:0 animated:NO];            
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }
        else
        {
            [self.doctorPicker selectRow:0 inComponent:0 animated:NO];
            if (![self.specialityLbl.text isEqualToString:@"Select Speciality"]) {
                NSLog(@"not working");
            self.doctorLbl.text = [[self.doctorDictArray objectAtIndex:0] objectForKey:@"dispname"];
                self.doctorLbl.textColor = [UIColor blackColor];

            }
        }
           if (self.specialityId != nil) {
               [self doneButtonPressed:nil];
           }
    }else {
        if (isShow) {
            [self customAlertView:@"" Message:@"No doctors to show." tag:0];
        }
        isShow = NO;
    }
}
- (void)getDateValues:(double)intVal
{
    myDate = [NSDate dateWithTimeIntervalSince1970:intVal];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    componentsOfDate    = [calendar components:(NSCalendarCalendarUnit |
                                                NSYearCalendarUnit     |
                                                NSMonthCalendarUnit    |
                                                NSDayCalendarUnit      |
                                                NSWeekdayCalendarUnit) fromDate:myDate];
    
    [self.componentsArray addObject:myDate];
    
    
}

//- (void)setDayLabel:(DSLCalendarRange *)range
//{
//    NSString *dateStr = [NSString stringWithFormat:@"%ld/%ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.startDay.year];
//    self.dateLbl.text = dateStr;
//    self.dateLbl.textColor = [UIColor blackColor];
//    currentComponent = range.startDay;
//    int flag = 0;
//    for (int i=0; i<[componentsArray count]; i++)
//    {
//        NSDateComponents *comp = [componentsArray objectAtIndex:i];
//        if ((range.startDay.day == comp.day) && (range.startDay.month == comp.month) && (range.startDay.year == comp.year))
//        {
//            flag = 0;
//            [self makeRequestForSlots];
//            break;
//        }
//        else
//        {
//            flag = 1;
//        }
//    }
//    if (flag==1)
//    {
//        self.timeLbl.textColor = [UIColor blackColor];
//        self.timeLbl.text = @"No time slots available";
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No time slots available please select another date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//    }
//}
//#pragma mark - DSLCalendarViewDelegate methods
//
//- (void)calendarView:(DSLCalendarView *)calendarView didSelectRange:(DSLCalendarRange *)range {
//    [UIView animateWithDuration:0.5 animations:^{
//        self.calendarContainer.hidden = YES;
//    } completion:^(BOOL finished) {
//    }];
//    if (range != nil) {
//        NSLog( @"Selected %ld/%ld - %ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
//        [self setDayLabel:range];
//    }
//    else {
//        NSLog( @"No selection" );
//    }
//}
//
//- (DSLCalendarRange*)calendarView:(DSLCalendarView *)calendarView didDragToDay:(NSDateComponents *)day selectingRange:(DSLCalendarRange *)range {
//    
//    if (NO)
//    { // Only select a single day
//        return [[DSLCalendarRange alloc] initWithStartDay:day endDay:day];
//    }
//    else if (NO)
//    { // Don't allow selections before today
//        NSDateComponents *today = [[NSDate date] dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
//        
//        NSDateComponents *startDate = range.startDay;
//        NSDateComponents *endDate = range.endDay;
//        
//        if ([self day:startDate isBeforeDay:today] && [self day:endDate isBeforeDay:today])
//        {
//            return nil;
//        }
//        else
//        {
//            if ([self day:startDate isBeforeDay:today])
//            {
//                startDate = [today copy];
//            }
//            if ([self day:endDate isBeforeDay:today])
//            {
//                endDate = [today copy];
//            }
//            
//            return [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:endDate];
//        }
//    }
//    return range;
//}
//
//- (void)calendarView:(DSLCalendarView *)calendarView willChangeToVisibleMonth:(NSDateComponents *)month duration:(NSTimeInterval)duration {
//    NSLog(@"Will show %@ in %.3f seconds", month, duration);
//}
//
//- (void)calendarView:(DSLCalendarView *)calendarView didChangeToVisibleMonth:(NSDateComponents *)month {
//    NSLog(@"Now showing %@", month);
//}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2 {
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
