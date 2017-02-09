//
//  SIPIncomingCallViewControllerTests.m
//  Copyright © 2016 VoIPGRID. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "SIPIncomingCallViewController.h"
@import XCTest;

@interface SIPIncomingCallViewController (PrivateImplementation)
@property (strong, nonatomic) VSLCall *call;
@property (weak, nonatomic) UILabel *incomingCallStatusLabel;
@end

@interface SIPIncomingCallViewControllerTests : XCTestCase
@property (strong, nonatomic) SIPIncomingCallViewController *sipIncomingCallVC;
@property (strong, nonatomic) id mockCall;
@end

@implementation SIPIncomingCallViewControllerTests

- (void)setUp {
    [super setUp];
    self.sipIncomingCallVC = (SIPIncomingCallViewController *)[[UIStoryboard storyboardWithName:@"SIPIncomingCallStoryboard" bundle:nil] instantiateInitialViewController];
    [self.sipIncomingCallVC loadViewIfNeeded];
    self.mockCall = OCMClassMock([VSLCall class]);
}

- (void)tearDown {
    [self.mockCall stopMocking];
    self.mockCall = nil;
    self.sipIncomingCallVC = nil;
    [super tearDown];
}

- (void)testCallIsDeclinedWillDismissViewController {
    self.sipIncomingCallVC.call = self.mockCall;

    id mockSipIncomingCallVC = OCMPartialMock(self.sipIncomingCallVC);

    OCMStub([self.mockCall callState]).andReturn(VSLCallStateDisconnected);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Should wait before dismissing the view"];
    OCMStub([mockSipIncomingCallVC dismissViewControllerAnimated:NO completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });

    id mockButton = OCMClassMock([UIButton class]);
    [self.sipIncomingCallVC declineCallButtonPressed:mockButton];

    [self.sipIncomingCallVC observeValueForKeyPath:@"callState" ofObject:self.mockCall change:nil context:nil];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        OCMVerify([mockSipIncomingCallVC dismissViewControllerAnimated:NO completion:[OCMArg any]]);
        [mockButton stopMocking];
        [mockSipIncomingCallVC stopMocking];
    }];
}

- (void)testControllerDeclinesWillAskCallToEndCall {
    self.sipIncomingCallVC.call = self.mockCall;
    id mockButton = OCMClassMock([UIButton class]);

    [self.sipIncomingCallVC declineCallButtonPressed:mockButton];
    OCMVerify([self.mockCall decline:[OCMArg anyObjectRef]]);
    [mockButton stopMocking];
}

- (void)testControllerDeclinesWillDisplayMessage {
    id mockLabel = OCMClassMock([UILabel class]);
    self.sipIncomingCallVC.incomingCallStatusLabel = mockLabel;

    id mockButton = OCMClassMock([UIButton class]);
    [self.sipIncomingCallVC declineCallButtonPressed:mockButton];

    OCMVerify([mockLabel setText:[OCMArg any]]);
    [mockButton stopMocking];
    [mockLabel stopMocking];
}

- (void)testAcceptCallButtonPressetMovesToSegue {
    id mockSipIncomingCallVC = OCMPartialMock(self.sipIncomingCallVC);

    OCMStub([mockSipIncomingCallVC performSegueWithIdentifier:[OCMArg any] sender:[OCMArg any]]).andDo(nil);

    id mockButton = OCMClassMock([UIButton class]);
    [self.sipIncomingCallVC acceptCallButtonPressed:mockButton];

    OCMVerify([mockSipIncomingCallVC performSegueWithIdentifier:@"SIPCallingSegue" sender:[OCMArg any]]);
    [mockButton stopMocking];
    [mockSipIncomingCallVC stopMocking];
}

@end
