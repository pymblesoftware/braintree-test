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

@property (weak, nonatomic) IBOutlet UILabel *nounceLbl;

@property (weak, nonatomic) IBOutlet UILabel *transactionInfoLbl;


@end

@implementation ViewController

NSString *serverURL = @"";
NSString *addPaymentEndPoint = @"/payment/addpayment";
NSString *getPaymentsEndpoint = @"/payment/payments";
NSString *updtePaymentDefault = @"/payment/markcardasdefault?paymentId=7";




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
    
    NSString *plistFile = [[NSBundle mainBundle] pathForResource: @"public-keys" ofType: @"plist"];

    NSDictionary *theDict = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSString *merchant = [theDict objectForKey:@"merchant_id"];
    NSString *public_key = [theDict objectForKey:@"public_key"];
    
    NSLog( @"merchant: %@  key: %@", merchant, public_key );
    
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
    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    BTCard *card = [[BTCard alloc] initWithNumber:self.cardNumberField.text
                                  expirationMonth:self.expirationMonthField.text
                                   expirationYear:self.expirationYearField.text
                                              cvv:nil];


    [cardClient tokenizeCard:card completion:^(BTCardNonce *tokenized, NSError *error) {
        [self setFieldsEnabled:YES];
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        else {
            NSLog( @"Nonce: %@", tokenized.nonce );
            self->_transactionInfoLbl.text = tokenized.nonce;

        }

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

- (IBAction)trasnactionInfoTouched:(id)sender {
    
}

- (IBAction)scanCard:(id)sender {
    
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [self presentViewController:scanViewController animated:YES completion:nil];
    
}






- (void)setFieldsEnabled:(BOOL)enabled {
    self.cardNumberField.enabled = enabled;
    self.expirationMonthField.enabled = enabled;
    self.expirationYearField.enabled = enabled;
    self.submitButton.enabled = enabled;
    self.cardIOButton.enabled = enabled;
    self.autofillButton.enabled = enabled;
}


-(NSString *) createNounce {
    NSString * nounce = @"";
    
    return nounce;
}

-(void) getTransactionInfo {
    
}


-(void) createToken {
    
}


-(void) capturePayment {
    
}

-(void) getRecentClientTransaction {
    
}

-(void) StoreToken {
    
}

-(void) getTokenForMotorist {
    
}

- (void)fetchClientToken {
    // TODO: Switch this URL to your own authenticated API
    NSURL *clientTokenURL = [NSURL URLWithString:@"https://braintree-sample-merchant.herokuapp.com/client_token"];
    NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
    [clientTokenRequest setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:clientTokenRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle errors
        NSString *clientToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    }] resume];
}

-(void) paymentFlow {
    [self createNounce];
    [self createToken];
    [self StoreToken];
}

-(void) parkingTransaction {
    [self getTokenForMotorist];
    [self capturePayment];
}

-(void) enquiry {
    [self getRecentClientTransaction];
}

@end
