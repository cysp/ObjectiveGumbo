//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, OGGumboNodeType) {
    OGGumboNodeTypeDocument,
    OGGumboNodeTypeElement,
    OGGumboNodeTypeText,
    OGGumboNodeTypeCDATA,
    OGGumboNodeTypeComment,
    OGGumboNodeTypeWhitespace,
};

typedef NS_ENUM(NSUInteger, OGGumboTagNamespace) {
    OGGumboTagNamespaceHTML,
    OGGumboTagNamespaceSVG,
    OGGumboTagNamespaceMathML,
};

typedef NS_ENUM(NSUInteger, OGGumboTag) {
    OGGumboTagHTML,
    OGGumboTagHEAD,
    OGGumboTagTITLE,
    OGGumboTagBASE,
    OGGumboTagLINK,
    OGGumboTagMETA,
    OGGumboTagSTYLE,
    OGGumboTagSCRIPT,
    OGGumboTagNOSCRIPT,
    OGGumboTagBODY,
    OGGumboTagSECTION,
    OGGumboTagNAV,
    OGGumboTagARTICLE,
    OGGumboTagASIDE,
    OGGumboTagH1,
    OGGumboTagH2,
    OGGumboTagH3,
    OGGumboTagH4,
    OGGumboTagH5,
    OGGumboTagH6,
    OGGumboTagHGROUP,
    OGGumboTagHEADER,
    OGGumboTagFOOTER,
    OGGumboTagADDRESS,
    OGGumboTagP,
    OGGumboTagHR,
    OGGumboTagPRE,
    OGGumboTagBLOCKQUOTE,
    OGGumboTagOL,
    OGGumboTagUL,
    OGGumboTagLI,
    OGGumboTagDL,
    OGGumboTagDT,
    OGGumboTagDD,
    OGGumboTagFIGURE,
    OGGumboTagFIGCAPTION,
    OGGumboTagDIV,
    OGGumboTagA,
    OGGumboTagEM,
    OGGumboTagSTRONG,
    OGGumboTagSMALL,
    OGGumboTagS,
    OGGumboTagCITE,
    OGGumboTagQ,
    OGGumboTagDFN,
    OGGumboTagABBR,
    OGGumboTagTIME,
    OGGumboTagCODE,
    OGGumboTagVAR,
    OGGumboTagSAMP,
    OGGumboTagKBD,
    OGGumboTagSUB,
    OGGumboTagSUP,
    OGGumboTagI,
    OGGumboTagB,
    OGGumboTagMARK,
    OGGumboTagRUBY,
    OGGumboTagRT,
    OGGumboTagRP,
    OGGumboTagBDI,
    OGGumboTagBDO,
    OGGumboTagSPAN,
    OGGumboTagBR,
    OGGumboTagWBR,
    OGGumboTagINS,
    OGGumboTagDEL,
    OGGumboTagIMAGE,
    OGGumboTagIMG,
    OGGumboTagIFRAME,
    OGGumboTagEMBED,
    OGGumboTagOBJECT,
    OGGumboTagPARAM,
    OGGumboTagVIDEO,
    OGGumboTagAUDIO,
    OGGumboTagSOURCE,
    OGGumboTagTRACK,
    OGGumboTagCANVAS,
    OGGumboTagMAP,
    OGGumboTagAREA,
    OGGumboTagMATH,
    OGGumboTagMI,
    OGGumboTagMO,
    OGGumboTagMN,
    OGGumboTagMS,
    OGGumboTagMTEXT,
    OGGumboTagMGLYPH,
    OGGumboTagMALIGNMARK,
    OGGumboTagANNOTATION_XML,
    OGGumboTagSVG,
    OGGumboTagFOREIGNOBJECT,
    OGGumboTagDESC,
    OGGumboTagTABLE,
    OGGumboTagCAPTION,
    OGGumboTagCOLGROUP,
    OGGumboTagCOL,
    OGGumboTagTBODY,
    OGGumboTagTHEAD,
    OGGumboTagTFOOT,
    OGGumboTagTR,
    OGGumboTagTD,
    OGGumboTagTH,
    OGGumboTagFORM,
    OGGumboTagFIELDSET,
    OGGumboTagLEGEND,
    OGGumboTagLABEL,
    OGGumboTagINPUT,
    OGGumboTagBUTTON,
    OGGumboTagSELECT,
    OGGumboTagDATALIST,
    OGGumboTagOPTGROUP,
    OGGumboTagOPTION,
    OGGumboTagTEXTAREA,
    OGGumboTagKEYGEN,
    OGGumboTagOUTPUT,
    OGGumboTagPROGRESS,
    OGGumboTagMETER,
    OGGumboTagDETAILS,
    OGGumboTagSUMMARY,
    OGGumboTagCOMMAND,
    OGGumboTagMENU,
    OGGumboTagAPPLET,
    OGGumboTagACRONYM,
    OGGumboTagBGSOUND,
    OGGumboTagDIR,
    OGGumboTagFRAME,
    OGGumboTagFRAMESET,
    OGGumboTagNOFRAMES,
    OGGumboTagISINDEX,
    OGGumboTagLISTING,
    OGGumboTagXMP,
    OGGumboTagNEXTID,
    OGGumboTagNOEMBED,
    OGGumboTagPLAINTEXT,
    OGGumboTagRB,
    OGGumboTagSTRIKE,
    OGGumboTagBASEFONT,
    OGGumboTagBIG,
    OGGumboTagBLINK,
    OGGumboTagCENTER,
    OGGumboTagFONT,
    OGGumboTagMARQUEE,
    OGGumboTagMULTICOL,
    OGGumboTagNOBR,
    OGGumboTagSPACER,
    OGGumboTagTT,
    OGGumboTagU,
    OGGumboTagUNKNOWN,
};

typedef NS_ENUM(NSUInteger, OGGumboAttributeNamespace) {
    OGGumboAttributeNamespaceNone,
    OGGumboAttributeNamespaceXLink,
    OGGumboAttributeNamespaceXML,
    OGGumboAttributeNamespaceXMLNS,
};


@interface OGGumboNode : NSObject
@property (nonatomic,assign,readonly) OGGumboNodeType type;
@property (nonatomic,weak,readonly) OGGumboNode *parent;
- (NSString *)recursiveDescription;
@end

@interface OGGumboDocumentNode : OGGumboNode
@property (nonatomic,strong,readonly) NSString *doctypeName;
@property (nonatomic,strong,readonly) NSString *doctypePublicIdentifier;
@property (nonatomic,strong,readonly) NSString *doctypeSystemIdentifier;
@property (nonatomic,strong,readonly) NSArray *children;
@property (nonatomic,strong,readonly) NSString *text;
@end

@interface OGGumboElementNode : OGGumboNode
@property (nonatomic,assign,readonly) OGGumboTagNamespace namespace;
@property (nonatomic,assign,readonly) OGGumboTag tag;
@property (nonatomic,strong,readonly) NSArray *attributes;
@property (nonatomic,strong,readonly) NSArray *children;
@property (nonatomic,strong,readonly) NSString *text;
@end

@interface OGGumboAttribute : NSObject
@property (nonatomic,assign,readonly) OGGumboAttributeNamespace namespace;
@property (nonatomic,strong,readonly) NSString *name;
@property (nonatomic,strong,readonly) NSString *value;
@end

@interface OGGumboTextNode : OGGumboNode
@property (nonatomic,strong,readonly) NSString *text;
@end

@interface OGGumboCDATANode : OGGumboNode
@property (nonatomic,strong,readonly) NSString *text;
@end

@interface OGGumboCommentNode : OGGumboNode
@property (nonatomic,strong,readonly) NSString *text;
@end

@interface OGGumboWhitespaceNode : OGGumboNode
@property (nonatomic,strong,readonly) NSString *text;
@end


@interface OGGumboParser : NSObject
+ (OGGumboDocumentNode *)documentWithString:(NSString *)string;
+ (OGGumboDocumentNode *)documentWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
@end
