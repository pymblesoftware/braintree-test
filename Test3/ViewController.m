//
//  ViewController.m
//  Test3
//
//  Created by Regan Russell on 5/8/19.
//  Copyright © 2019 PymbleSoftware Pty Ltd. All rights reserved.
//


#import "ViewController.h"
#import <CardIO/CardIO.h>
#import "BTCardClient.h"

@interface ViewController ()<CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *cardNumberField;
@property (nonatomic, strong) IBOutlet UITextField *expirationMonthField;
@property (nonatomic, strong) IBOutlet UITextField *expirationYearField;

@property (weak, nonatomic) IBOutlet UIButton *cardIOButton;
@property (weak, nonatomic) IBOutlet UIButton *autofillButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) BTAPIClient *apiClient;

@end

@implementation ViewController


- (instancetype)initWithAuthorization:(NSString *)authorization {
//    if (self = [super initWithAuthorization:authorization]) {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
    }
    return self;
}

- (instancetype) init {
    return [self initWithAuthorization:@"development_tokenization_key"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
//    _apiClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_tokenization_key"];
    _apiClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_9dbg82cq_dcpspy2brwdjr3qn"];
    self.title = NSLocalizedString(@"Card Tokenization", nil);
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    [CardIOUtilities preload];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    self.progressBlock([NSString stringWithFormat:@"Scanned a card with Card.IO: %@", [cardInfo redactedCardNumber]]);

    if (cardInfo.expiryYear) {
        self.expirationYearField.text = [NSString stringWithFormat:@"%d", (int)cardInfo.expiryYear];
    }

    if (cardInfo.expiryMonth) {
        self.expirationMonthField.text = [NSString stringWithFormat:@"%d", (int)cardInfo.expiryMonth];
    }

    self.cardNumberField.text = cardInfo.cardNumber;

    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitForm {
//    self.progressBlock(@"Tokenizing card details!");

    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    BTCard *card = [[BTCard alloc] initWithNumber:self.cardNumberField.text
                                  expirationMonth:self.expirationMonthField.text
                                   expirationYear:self.expirationYearField.text
                                              cvv:nil];

//    [self setFieldsEnabled:NO];
    [cardClient tokenizeCard:card completion:^(BTCardNonce *tokenized, NSError *error) {
        [self setFieldsEnabled:YES];
        if (error) {
//            self.progressBlock(error.localizedDescription);
            NSLog(@"Error: %@", error);
            NSLog( @"Nonce: %@", tokenized.nonce );
            return;
        }
        self.completionBlock(tokenized);
    }];
}

- (IBAction)setupDemoData {
    self.cardNumberField.text = [@"4111111111111111" copy];
    self.expirationMonthField.text = [@"12" copy];
    self.expirationYearField.text = [@"2038" copy];
}

- (IBAction)presentCardIO {
    CardIOPaymentViewController *cardIO = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    cardIO.collectExpiry = YES;
    cardIO.collectCVV = NO;
    cardIO.useCardIOLogo = YES;
    cardIO.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cardIO animated:YES completion:nil];
}

- (void)setFieldsEnabled:(BOOL)enabled {
    self.cardNumberField.enabled = enabled;
    self.expirationMonthField.enabled = enabled;
    self.expirationYearField.enabled = enabled;
    self.submitButton.enabled = enabled;
    self.cardIOButton.enabled = enabled;
    self.autofillButton.enabled = enabled;
}

@end
