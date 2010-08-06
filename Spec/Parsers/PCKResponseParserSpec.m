#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
#import <PivotalSpecHelperKit/PivotalSpecHelperKit.h>

#import "PCKResponseParser.h"
#import "NSURLConnectionDelegate.h"
#import "PCKParser.h"

SPEC_BEGIN(PCKResponseParserSpec)

describe(@"PCKResponseParser", ^{
    __block PCKResponseParser *responseParser;
    __block id mockParser, mockDelegate;

    beforeEach(^{
        mockParser = [OCMockObject niceMockForProtocol:@protocol(PCKParser)];
        mockDelegate = [OCMockObject niceMockForProtocol:@protocol(NSURLConnectionDelegate)];
        responseParser = [[PCKResponseParser alloc] initWithParser:mockParser andDelegate:mockDelegate];
    });

	afterEach(^{
	    [responseParser release];
	});

    describe(@"on success response", ^{
        NSData *data = [NSData dataWithBytes:"12345" length:5];
        __block NSURLResponse *response;
        __block void (^returnResponse)();

        beforeEach(^{
            response = [[[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:200 andHeaders:[NSDictionary dictionary] andBody:nil] autorelease];
            returnResponse = [^{
                [responseParser connection:nil didReceiveResponse:response];
                [responseParser connection:nil didReceiveData:data];
                [responseParser connectionDidFinishLoading:nil];
            } copy];

        });

        it(@"should pass returned data to the parser", ^{
            [[mockParser expect] parseChunk:data];

            returnResponse();

            [mockParser verify];
        });

        it(@"should notify the delegate of success", ^{
            [[mockDelegate expect] connection:nil didReceiveResponse:response];
            [[mockDelegate expect] connectionDidFinishLoading:nil];

            returnResponse();

            [mockDelegate verify];
        });
    });
});

SPEC_END
