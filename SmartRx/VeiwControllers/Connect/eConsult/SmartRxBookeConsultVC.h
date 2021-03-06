//
//  SmartRxBookeConsultVC.h
//  SmartRx
//
//  Created by Manju Basha on 19/03/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "CKCalendarView.h"
@interface SmartRxBookeConsultVC : UIViewController<UIScrollViewDelegate, MBProgressHUDDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate,CKCalendarDelegate>
//SmartRxPagerVC

@property(nonatomic,strong) NSString *scheduleType;
@property(nonatomic,strong) NSString *specialityId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (readwrite, nonatomic) BOOL fromFindDoctors;
@property (weak, nonatomic) IBOutlet UIButton *specialityButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *eConsultMethodBtn;
@property (weak, nonatomic) UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UILabel *specialityLbl;
@property (weak, nonatomic) IBOutlet UILabel *doctorLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *eConsultMethodLbl;
@property (weak, nonatomic) IBOutlet UILabel *consultationFeeText;
@property (weak, nonatomic) IBOutlet UILabel *consultationActualCost;
@property (weak, nonatomic) IBOutlet UILabel *consultationDiscountedCost;
@property (strong, nonatomic) IBOutlet UIImageView *closeImage;
@property (strong, nonatomic) IBOutlet UIImageView *doctorDownArrowImage;
@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (strong, nonatomic) NSMutableDictionary *doctorEconsultDetail;

@property (retain, nonatomic) UIPickerView *specialityPicker;
@property (retain, nonatomic) UIPickerView *doctorPicker;
@property (retain, nonatomic) UIPickerView *timePicker;
@property (retain, nonatomic) UIPickerView *eConsultMethodPicker;
@property (strong, nonatomic) NSArray *arrSpeciality;
@property (strong, nonatomic) NSMutableArray *dictResponse;
@property (strong, nonatomic) NSMutableDictionary *packageResponse;
@property (retain, nonatomic) NSMutableDictionary *paymentResponseDictionary;
@property (strong, nonatomic) NSMutableArray *doctorDictArray;
@property(nonatomic, strong) NSMutableArray *selectedDates;
@property(nonatomic, strong) NSMutableArray *appointmentDetails;
@property(nonatomic, retain) NSMutableArray *econsultDetails;
@property(nonatomic, strong) NSMutableArray *disabledDates;
@property(nonatomic, strong) NSMutableArray *componentsArray;
@property(nonatomic, strong) NSMutableArray *Dates;



@property (weak, nonatomic) IBOutlet UITextField *promoCodeText;
@property (weak, nonatomic) IBOutlet UIButton *promoApplyBtn;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

+ (id)sharedManagerEconsult;
- (IBAction)specialityButtonClicked:(id)sender;
- (IBAction)doctorButtonClicked:(id)sender;
- (IBAction)doctorProfileButtonClicked:(id)sender;
- (IBAction)dateButtonClicked:(id)sender;
- (IBAction)timeButtonClicked:(id)sender;
- (IBAction)eConsultMethodBtnClicked:(id)sender;
- (IBAction)eConsultBookBtnClicked:(id)sender;
- (IBAction)promoApplyBtnClicked:(id)sender;

//@property (weak, nonatomic) IBOutlet DSLCalendarView *calendarView;
@property (weak,nonatomic) IBOutlet CKCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet UIView *calendarContainer;
//@property (nonatomic, retain) KalViewController *calendar;
@end
