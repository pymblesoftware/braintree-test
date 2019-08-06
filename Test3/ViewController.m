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
//@property (nonatomic, strong) BTApplePayClient *appleClient;
@property (weak, nonatomic) IBOutlet UILabel *nounceLbl;

@property (weak, nonatomic) IBOutlet UILabel *transactionInfoLbl;
@property (weak, nonatomic) IBOutlet UILabel *infoView;


@end

@implementation ViewController

NSString *serverURL = @"";
NSString *addPaymentEndPoint = @"/payment/addpayment";
NSString *getPaymentsEndpoint = @"/payment/payments";
NSString *updtePaymentDefault = @"/payment/markcardasdefault?paymentId=7";


NSString *merchant;
NSString *public_key;
NSString *sampleToken = @"sandbox_9dbg82cq_dcpspy2brwdjr3qn";
NSString *tokenize_key;




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

-(void) getCredentials {
    NSString *plistFile = [[NSBundle mainBundle] pathForResource: @"public-keys" ofType: @"plist"];
    NSDictionary *theDict = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    merchant = [theDict objectForKey:@"merchant_id"];
    public_key = [theDict objectForKey:@"public_key"];
    tokenize_key = [theDict objectForKey:@"tokenize_key"];
    NSLog( @"merchant: %@  public key: %@ tokenize key: %@ ", merchant, public_key, tokenize_key );
}

-(void) getConfiguration {
    [_apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        
        BTJSON *json = [configuration json];
        NSDictionary *dict = [json asDictionary];
        //        NSDictionary *analystics = [dict objectForKey:@"analytics"];
        //        NSString *url      =  [dict objectForKey:@"url"];
        NSDictionary *creditCards   =     [dict objectForKey:@"creditCards"];
        NSString *environment    =    [dict objectForKey:@"environment"];
        NSDictionary *graphQL      =  [dict objectForKey:@"graphQL"];
        NSString *merchantId    =    [dict objectForKey:@"merchantId"];
        NSNumber *paypalEnabled  =      [dict objectForKey:@"paypalEnabled"];
        //        NSDictionary *threeDSecure    =    [dict objectForKey:@"threeDSecure"];
        //        NSNumber *threeDSecureEnabled = [dict objectForKey:@"threeDSecureEnabled"];
        NSString *venmo = [dict objectForKey:@"venmo"];
        //        NSLog( @"fetchOrReturnRemoteConfiguration cards: %@ merch id:%@ environ: %@ paypal: %@ venmo: %@", creditCards, merchant, environment, paypalEnabled, venmo  );
        
        _infoView.text = [NSString stringWithFormat:@"fetchOrReturnRemoteConfiguration cards: %@ merch id:%@ environ: %@ paypal: %@ venmo: %@", creditCards, merchant, environment, paypalEnabled, venmo ];
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCredentials];
    
    _apiClient = [[BTAPIClient alloc] initWithAuthorization:tokenize_key];
    [self getConfiguration];
    [self getNounces];
    
    self.title = NSLocalizedString(@"Card Tokenization", nil);
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    [CardIOUtilities preload];
}

// THis does not work... Needs client key sent to the server.
-(void) getNounces {
    [ _apiClient fetchPaymentMethodNonces:YES completion:^(NSArray<BTPaymentMethodNonce *> * _Nullable paymentMethodNonces, NSError * _Nullable error) {
        
        if( error ) {
            NSLog( @"error: %@", error );
        }
        else {
            NSLog( @"-- -- " );
        }
    }];
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

- (IBAction)applePay:(id)sender {
    
    
}



- (void)setFieldsEnabled:(BOOL)enabled {
    self.cardNumberField.enabled = enabled;
    self.expirationMonthField.enabled = enabled;
    self.expirationYearField.enabled = enabled;
    self.submitButton.enabled = enabled;
    self.cardIOButton.enabled = enabled;
    self.autofillButton.enabled = enabled;
}


-(NSString *) createNounce:(NSString *)cardNumber month:(NSString *) mon year:(NSString *) yy {
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
    
    NSString *cardnumber = @"";
    NSString *month = @"";
    NSString *yy = @"";
    [self createNounce:cardnumber month:month year:yy];
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
