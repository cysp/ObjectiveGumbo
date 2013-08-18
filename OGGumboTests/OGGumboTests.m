//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

#import "OGGumbo.h"


@interface OGGumboTests : XCTestCase
@end

@implementation OGGumboTests

- (void)testDegenerate {
    {
        OGGumboDocumentNode *doc = nil;
        XCTAssertThrows([OGGumboParser documentWithString:nil], @"");
        XCTAssertNil(doc, @"");
    }

    {
        OGGumboDocumentNode *doc = [OGGumboParser documentWithString:@""];
        XCTAssertNotNil(doc, @"");
    }
}

- (void)testParsingSimple {
    {
        OGGumboDocumentNode *doc = [OGGumboParser documentWithString:@"foo<b>bar</b>baz"];
        for (OGGumboNode *node in doc.children) {
            switch (node.type) {
                case OGGumboNodeTypeElement:
                    (void)((OGGumboElementNode *)node).tag;
                    break;
                default:
                    break;
            }
        }
        NSLog(@"doc: %@", doc.text);
        XCTAssertNotNil(doc, @"");
    }

    {
        OGGumboDocumentNode *doc = [OGGumboParser documentWithString:@"foo<b>bar</b>baz"];
        for (OGGumboNode *node in doc.children) {
            switch (node.type) {
                case OGGumboNodeTypeElement:
                    (void)((OGGumboElementNode *)node).tag;
                    break;
                default:
                    break;
            }
        }
        NSLog(@"doc: %@", doc.text);
        XCTAssertNotNil(doc, @"");
    }

    {
        OGGumboDocumentNode *doc = [OGGumboParser documentWithString:@"foo <b>bar</b> baz"];
        XCTAssertNotNil(doc, @"");
    }
}

- (void)testMemory {
    {
        __weak OGGumboDocumentNode *doc = nil;
        @autoreleasepool {
            doc = [OGGumboParser documentWithString:@"foo<b>bar</b>baz"];
        }
        XCTAssertNil(doc, @"");
    }

    {
        OGGumboNode *docChild = nil;
        __weak OGGumboNode *docChildWeak = nil;
        @autoreleasepool {
            OGGumboDocumentNode *doc = [OGGumboParser documentWithString:@"foo<b>bar</b>baz"];
            docChildWeak = docChild = [doc.children lastObject];
        }
        XCTAssertNotNil(docChild, @"");
        XCTAssertNotNil(docChildWeak, @"");
        docChild = nil;
        XCTAssertNil(docChildWeak, @"");
    }
}

@end
