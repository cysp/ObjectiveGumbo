//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot

#import "OGGumbo.h"

#import "gumbo-parser/src/gumbo.h"


static NSString *NSStringFromOGGumboTag(OGGumboTag const tag);


@interface OGGumboNode ()
@property (nonatomic,strong,readonly) OGGumboParser *parser;
@property (nonatomic,assign,readonly) GumboNode *node;
- (id)initWithParser:(OGGumboParser *)parser parent:(OGGumboNode *)parent node:(GumboNode *)node;
@end

@interface OGGumboAttribute ()
@property (nonatomic,strong,readonly) OGGumboElementNode *element;
- (id)initWithElement:(OGGumboElementNode *)element attribute:(GumboAttribute *)attribute;
@end


@implementation OGGumboParser {
@private
    NSData *_input;
    GumboOptions _gumboOptions;
    GumboOutput *_gumboOutput;
}

+ (OGGumboDocumentNode *)documentWithString:(NSString *)string {
    OGGumboParser *parser = [[self alloc] initWithString:string];
    return parser.document;
}

+ (OGGumboDocumentNode *)documentWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    OGGumboParser *parser = [[self alloc] initWithData:data encoding:encoding];
    return parser.document;
}

- (id)init {
    return [self initWithString:nil];
}

- (id)initWithString:(NSString *)string {
    return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
}

- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    NSParameterAssert(data);
    NSParameterAssert(encoding == NSUTF8StringEncoding);
    if ((self = [super init])) {
        NSData * const input = _input = [data copy];

        const char * const inputBytes = input.bytes ?: "";
        NSUInteger const inputLength = _input.length;

        _gumboOptions = kGumboDefaultOptions;
        _gumboOutput = gumbo_parse_with_options(&_gumboOptions, inputBytes, inputLength);
    }
    return self;
}

- (void)dealloc {
    gumbo_destroy_output(&_gumboOptions, _gumboOutput);
}

- (OGGumboDocumentNode *)document {
    GumboNode * const document = _gumboOutput->document;
    return [[OGGumboDocumentNode alloc] initWithParser:self parent:nil node:document];
}

@end


@implementation OGGumboNode {
@private
    OGGumboParser *_parser;
@protected
    GumboNode *_node;
}

+ (instancetype)nodeWithParser:(OGGumboParser *)parser parent:(OGGumboNode *)parent node:(GumboNode *)node {
    GumboNodeType const nodeType = node->type;
    switch (nodeType) {
        case GUMBO_NODE_DOCUMENT:
            return [[OGGumboDocumentNode alloc] initWithParser:parser parent:parent node:node];
        case GUMBO_NODE_ELEMENT:
            return [[OGGumboElementNode alloc] initWithParser:parser parent:parent node:node];
        case GUMBO_NODE_TEXT:
            return [[OGGumboTextNode alloc] initWithParser:parser parent:parent node:node];
        case GUMBO_NODE_CDATA:
            return [[OGGumboCDATANode alloc] initWithParser:parser parent:parent node:node];
        case GUMBO_NODE_COMMENT:
            return [[OGGumboCommentNode alloc] initWithParser:parser parent:parent node:node];
        case GUMBO_NODE_WHITESPACE:
            return [[OGGumboWhitespaceNode alloc] initWithParser:parser parent:parent node:node];
    }
    return nil;
}

- (id)initWithParser:(OGGumboParser *)parser parent:(OGGumboNode<OGGumboParentNode> *)parent node:(GumboNode *)node {
    NSParameterAssert(node);
    if ((self = [super init])) {
        _parser = parser;
        _parent = parent;
        _node = node;
    }
    return self;
}

@synthesize parser = _parser;
@synthesize parent = _parent;
@synthesize node = _node;

- (OGGumboNodeType)type {
    return (OGGumboNodeType)_node->type;
}

- (NSString *)recursiveDescription {
    NSMutableString *recursiveDescription = [NSMutableString string];
    [self.class recursiveDescription:recursiveDescription appendNode:self indentation:0];
    return recursiveDescription;
}

+ (void)recursiveDescription:(NSMutableString *)recursiveDescription appendNode:(OGGumboNode *)node indentation:(NSUInteger)indentation {
    for (NSUInteger i = 0; i < indentation; ++i) {
        [recursiveDescription appendString:@"  "];
    }
    [recursiveDescription appendString:node.description];
    [recursiveDescription appendString:@"\n"];

    switch (node.type) {
        case OGGumboNodeTypeDocument:
        case OGGumboNodeTypeElement: {
            OGGumboNode<OGGumboParentNode> *parent = (OGGumboNode<OGGumboParentNode> *)node;
            for (OGGumboNode *child in parent.children) {
                [self recursiveDescription:recursiveDescription appendNode:child indentation:indentation + 1];
            }
        } break;
        case OGGumboNodeTypeText:
        case OGGumboNodeTypeCDATA:
        case OGGumboNodeTypeComment:
        case OGGumboNodeTypeWhitespace:
        break;
    }
}

@end


@implementation OGGumboDocumentNode {
@private
    NSString *_doctypeName;
    NSString *_doctypePublicIdentifier;
    NSString *_doctypeSystemIdentifier;
    NSArray *_children;
    struct {
        BOOL doctype : 1;
        BOOL children : 1;
    } _fetched;
}

- (id)initWithParser:(OGGumboParser *)parser parent:(OGGumboNode *)parent node:(GumboNode *)node {
    if ((self = [super initWithParser:parser parent:parent node:node])) {
    }
    return self;
}

- (NSString *)doctypeName {
    [self stg_fetchDoctypeIfNecessary];
    return _doctypeName;
}

- (NSString *)doctypePublicIdentifier {
    [self stg_fetchDoctypeIfNecessary];
    return _doctypePublicIdentifier;
}

- (NSString *)doctypeSystemIdentifier {
    [self stg_fetchDoctypeIfNecessary];
    return _doctypeSystemIdentifier;
}

- (void)stg_fetchDoctypeIfNecessary {
    if (!_fetched.doctype) {
        GumboDocument const document = _node->v.document;
        if (document.has_doctype) {
            _doctypeName = [[NSString alloc] initWithUTF8String:document.name];
            _doctypePublicIdentifier = [[NSString alloc] initWithUTF8String:document.public_identifier];
            _doctypeSystemIdentifier = [[NSString alloc] initWithUTF8String:document.system_identifier];
        }
        _fetched.doctype = YES;
    }
}

- (NSArray *)children {
    [self stg_fetchChildrenIfNecessary];
    return _children;
}

- (void)stg_fetchChildrenIfNecessary {
    if (!_fetched.children) {
        OGGumboParser * const parser = self.parser;
        GumboDocument const document = _node->v.document;
        GumboVector const documentChildren = document.children;
        NSMutableArray * const children = [[NSMutableArray alloc] initWithCapacity:documentChildren.length];
        for (NSUInteger i = 0; i < documentChildren.length; ++i) {
            GumboNode * const documentChildNode = documentChildren.data[i];
            OGGumboNode * const child = [OGGumboNode nodeWithParser:parser parent:self node:documentChildNode];
            if (child) {
                [children addObject:child];
            }
        }
        _children = [[NSArray alloc] initWithArray:children];
        _fetched.children = YES;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p dt:%@ pi:%@ si:%@>", NSStringFromClass(self.class), self, self.doctypeName, self.doctypePublicIdentifier, self.doctypeSystemIdentifier];
}

- (NSString *)text {
    NSMutableString *text = [NSMutableString string];
    for (OGGumboNode *node in self.children) {
        switch (node.type) {
            case OGGumboNodeTypeDocument:
                break;
            case OGGumboNodeTypeElement: {
                NSString *childText = ((OGGumboElementNode *)node).text;
                if (text.length && childText.length) {
                    [text appendString:@" "];
                }
                [text appendString:childText];
            } break;
            case OGGumboNodeTypeText: {
                NSString *childText = ((OGGumboTextNode *)node).text;
                if (text.length && childText.length) {
                    [text appendString:@" "];
                }
                [text appendString:childText];
            } break;
            case OGGumboNodeTypeCDATA:
            case OGGumboNodeTypeComment:
            case OGGumboNodeTypeWhitespace:
                break;
        }
    }
    return text;
}

@end

@implementation OGGumboElementNode {
@private
    OGGumboTagNamespace _namespace;
    OGGumboTag _tag;
    NSArray *_attributes;
    NSArray *_children;
    struct {
        BOOL tag : 1;
        BOOL attributes : 1;
        BOOL children : 1;
    } _fetched;
}

- (OGGumboTagNamespace)namespace {
    [self stg_fetchTagIfNecessary];
    return _namespace;
}

- (OGGumboTag)tag {
    [self stg_fetchTagIfNecessary];
    return _tag;
}

- (void)stg_fetchTagIfNecessary {
    if (!_fetched.tag) {
        GumboElement const element = _node->v.element;
        _namespace = (OGGumboTagNamespace)element.tag_namespace;
        _tag = (OGGumboTag)element.tag;
        _fetched.tag = YES;
    }
}


- (NSArray *)attributes {
    [self stg_fetchAttributesIfNecessary];
    return _attributes;
}

- (void)stg_fetchAttributesIfNecessary {
    if (!_fetched.attributes) {
        GumboElement const element = _node->v.element;
        GumboVector const elementAttributes = element.attributes;
        NSMutableArray * const attributes = [[NSMutableArray alloc] initWithCapacity:elementAttributes.length];
        for (NSUInteger i = 0; i < elementAttributes.length; ++i) {
            GumboAttribute * const elementAttributeNode = elementAttributes.data[i];
            OGGumboAttribute * const attribute = [[OGGumboAttribute alloc] initWithElement:self attribute:elementAttributeNode];
            if (attribute) {
                [attributes addObject:attribute];
            }
        }
        _attributes = [[NSArray alloc] initWithArray:attributes];
        _fetched.attributes = YES;
    }
}


- (NSArray *)children {
    [self stg_fetchChildrenIfNecessary];
    return _children;
}

- (void)stg_fetchChildrenIfNecessary {
    if (!_fetched.children) {
        OGGumboParser * const parser = self.parser;
        GumboElement const element = _node->v.element;
        GumboVector const elementChildren = element.children;
        NSMutableArray * const children = [[NSMutableArray alloc] initWithCapacity:elementChildren.length];
        for (NSUInteger i = 0; i < elementChildren.length; ++i) {
            GumboNode * const elementChildNode = elementChildren.data[i];
            OGGumboNode * const child = [OGGumboNode nodeWithParser:parser parent:self node:elementChildNode];
            if (child) {
                [children addObject:child];
            }
        }
        _children = [[NSArray alloc] initWithArray:children];
        _fetched.children = YES;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p ns:%d tag:%d>", NSStringFromClass(self.class), self, self.namespace, self.tag];
}

- (NSString *)text {
    NSMutableString *text = [NSMutableString string];
    for (OGGumboNode *node in self.children) {
        switch (node.type) {
            case OGGumboNodeTypeDocument:
                break;
            case OGGumboNodeTypeElement: {
                NSString *childText = ((OGGumboElementNode *)node).text;
                if (text.length && childText.length) {
                    [text appendString:@" "];
                }
                [text appendString:childText];
            } break;
            case OGGumboNodeTypeText: {
                NSString *childText = ((OGGumboTextNode *)node).text;
                if (text.length && childText.length) {
                    [text appendString:@" "];
                }
                [text appendString:childText];
            } break;
            case OGGumboNodeTypeCDATA:
            case OGGumboNodeTypeComment:
            case OGGumboNodeTypeWhitespace:
                break;
        }
    }
    return text;
}

@end

@implementation OGGumboAttribute {
@private
    GumboAttribute *_attribute;
    OGGumboAttributeNamespace _namespace;
    NSString *_name;
    NSString *_value;
    BOOL _fetched;
}

- (id)initWithElement:(OGGumboElementNode *)element attribute:(GumboAttribute *)attribute {
    if ((self = [super init])) {
        _element = element;
        _attribute = attribute;
    }
    return self;
}

@synthesize element = _element;

- (OGGumboAttributeNamespace)namespace {
    [self stg_fetchIfNecessary];
    return _namespace;
}

- (NSString *)name {
    [self stg_fetchIfNecessary];
    return _name;
}

- (NSString *)value {
    [self stg_fetchIfNecessary];
    return _value;
}

- (void)stg_fetchIfNecessary {
    if (!_fetched) {
        GumboAttribute * const attribute = _attribute;
        _namespace = (OGGumboAttributeNamespace)attribute->attr_namespace;
        _name = [[NSString alloc] initWithUTF8String:attribute->name];
        _value = [[NSString alloc] initWithUTF8String:attribute->value];
        _fetched = YES;
    }
}

@end

@implementation OGGumboTextNode {
@private
    NSString *_text;
    BOOL _fetched;
}
- (NSString *)text {
    [self stg_fetchIfNecessary];
    return _text;
}
- (void)stg_fetchIfNecessary {
    if (!_fetched) {
        GumboText const text = _node->v.text;
        _text = [[NSString alloc] initWithUTF8String:text.text];
        _fetched = YES;
    }
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p text:%@>", NSStringFromClass(self.class), self, self.text];
}
@end

@implementation OGGumboCDATANode {
@private
    NSString *_text;
    BOOL _fetched;
}
- (NSString *)text {
    [self stg_fetchIfNecessary];
    return _text;
}
- (void)stg_fetchIfNecessary {
    if (!_fetched) {
        GumboText const text = _node->v.text;
        _text = [[NSString alloc] initWithUTF8String:text.text];
        _fetched = YES;
    }
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p text:%@>", NSStringFromClass(self.class), self, self.text];
}
@end

@implementation OGGumboCommentNode {
@private
    NSString *_text;
    BOOL _fetched;
}
- (NSString *)text {
    [self stg_fetchIfNecessary];
    return _text;
}
- (void)stg_fetchIfNecessary {
    if (!_fetched) {
        GumboText const text = _node->v.text;
        _text = [[NSString alloc] initWithUTF8String:text.text];
        _fetched = YES;
    }
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p text:%@>", NSStringFromClass(self.class), self, self.text];
}
@end

@implementation OGGumboWhitespaceNode {
@private
    NSString *_text;
    BOOL _fetched;
}
- (NSString *)text {
    [self stg_fetchIfNecessary];
    return _text;
}
- (void)stg_fetchIfNecessary {
    if (!_fetched) {
        GumboText const text = _node->v.text;
        _text = [[NSString alloc] initWithUTF8String:text.text];
        _fetched = YES;
    }
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p text:%@>", NSStringFromClass(self.class), self, self.text];
}
@end


static NSString *NSStringFromOGGumboTag(OGGumboTag const tag) {
    switch (tag) {
        case OGGumboTagHTML: return @"HTML";
        case OGGumboTagHEAD: return @"HEAD";
        case OGGumboTagTITLE: return @"TITLE";
        case OGGumboTagBASE: return @"BASE";
        case OGGumboTagLINK: return @"LINK";
        case OGGumboTagMETA: return @"META";
        case OGGumboTagSTYLE: return @"STYLE";
        case OGGumboTagSCRIPT: return @"SCRIPT";
        case OGGumboTagNOSCRIPT: return @"NOSCRIPT";
        case OGGumboTagBODY: return @"BODY";
        case OGGumboTagSECTION: return @"SECTION";
        case OGGumboTagNAV: return @"NAV";
        case OGGumboTagARTICLE: return @"ARTICLE";
        case OGGumboTagASIDE: return @"ASIDE";
        case OGGumboTagH1: return @"H1";
        case OGGumboTagH2: return @"H2";
        case OGGumboTagH3: return @"H3";
        case OGGumboTagH4: return @"H4";
        case OGGumboTagH5: return @"H5";
        case OGGumboTagH6: return @"H6";
        case OGGumboTagHGROUP: return @"HGROUP";
        case OGGumboTagHEADER: return @"HEADER";
        case OGGumboTagFOOTER: return @"FOOTER";
        case OGGumboTagADDRESS: return @"ADDRESS";
        case OGGumboTagP: return @"P";
        case OGGumboTagHR: return @"HR";
        case OGGumboTagPRE: return @"PRE";
        case OGGumboTagBLOCKQUOTE: return @"BLOCKQUOTE";
        case OGGumboTagOL: return @"OL";
        case OGGumboTagUL: return @"UL";
        case OGGumboTagLI: return @"LI";
        case OGGumboTagDL: return @"DL";
        case OGGumboTagDT: return @"DT";
        case OGGumboTagDD: return @"DD";
        case OGGumboTagFIGURE: return @"FIGURE";
        case OGGumboTagFIGCAPTION: return @"FIGCAPTION";
        case OGGumboTagDIV: return @"DIV";
        case OGGumboTagA: return @"A";
        case OGGumboTagEM: return @"EM";
        case OGGumboTagSTRONG: return @"STRONG";
        case OGGumboTagSMALL: return @"SMALL";
        case OGGumboTagS: return @"S";
        case OGGumboTagCITE: return @"CITE";
        case OGGumboTagQ: return @"Q";
        case OGGumboTagDFN: return @"DFN";
        case OGGumboTagABBR: return @"ABBR";
        case OGGumboTagTIME: return @"TIME";
        case OGGumboTagCODE: return @"CODE";
        case OGGumboTagVAR: return @"VAR";
        case OGGumboTagSAMP: return @"SAMP";
        case OGGumboTagKBD: return @"KBD";
        case OGGumboTagSUB: return @"SUB";
        case OGGumboTagSUP: return @"SUP";
        case OGGumboTagI: return @"I";
        case OGGumboTagB: return @"B";
        case OGGumboTagMARK: return @"MARK";
        case OGGumboTagRUBY: return @"RUBY";
        case OGGumboTagRT: return @"RT";
        case OGGumboTagRP: return @"RP";
        case OGGumboTagBDI: return @"BDI";
        case OGGumboTagBDO: return @"BDO";
        case OGGumboTagSPAN: return @"SPAN";
        case OGGumboTagBR: return @"BR";
        case OGGumboTagWBR: return @"WBR";
        case OGGumboTagINS: return @"INS";
        case OGGumboTagDEL: return @"DEL";
        case OGGumboTagIMAGE: return @"IMAGE";
        case OGGumboTagIMG: return @"IMG";
        case OGGumboTagIFRAME: return @"IFRAME";
        case OGGumboTagEMBED: return @"EMBED";
        case OGGumboTagOBJECT: return @"OBJECT";
        case OGGumboTagPARAM: return @"PARAM";
        case OGGumboTagVIDEO: return @"VIDEO";
        case OGGumboTagAUDIO: return @"AUDIO";
        case OGGumboTagSOURCE: return @"SOURCE";
        case OGGumboTagTRACK: return @"TRACK";
        case OGGumboTagCANVAS: return @"CANVAS";
        case OGGumboTagMAP: return @"MAP";
        case OGGumboTagAREA: return @"AREA";
        case OGGumboTagMATH: return @"MATH";
        case OGGumboTagMI: return @"MI";
        case OGGumboTagMO: return @"MO";
        case OGGumboTagMN: return @"MN";
        case OGGumboTagMS: return @"MS";
        case OGGumboTagMTEXT: return @"MTEXT";
        case OGGumboTagMGLYPH: return @"MGLYPH";
        case OGGumboTagMALIGNMARK: return @"MALIGNMARK";
        case OGGumboTagANNOTATION_XML: return @"ANNOTATION_XML";
        case OGGumboTagSVG: return @"SVG";
        case OGGumboTagFOREIGNOBJECT: return @"FOREIGNOBJECT";
        case OGGumboTagDESC: return @"DESC";
        case OGGumboTagTABLE: return @"TABLE";
        case OGGumboTagCAPTION: return @"CAPTION";
        case OGGumboTagCOLGROUP: return @"COLGROUP";
        case OGGumboTagCOL: return @"COL";
        case OGGumboTagTBODY: return @"TBODY";
        case OGGumboTagTHEAD: return @"THEAD";
        case OGGumboTagTFOOT: return @"TFOOT";
        case OGGumboTagTR: return @"TR";
        case OGGumboTagTD: return @"TD";
        case OGGumboTagTH: return @"TH";
        case OGGumboTagFORM: return @"FORM";
        case OGGumboTagFIELDSET: return @"FIELDSET";
        case OGGumboTagLEGEND: return @"LEGEND";
        case OGGumboTagLABEL: return @"LABEL";
        case OGGumboTagINPUT: return @"INPUT";
        case OGGumboTagBUTTON: return @"BUTTON";
        case OGGumboTagSELECT: return @"SELECT";
        case OGGumboTagDATALIST: return @"DATALIST";
        case OGGumboTagOPTGROUP: return @"OPTGROUP";
        case OGGumboTagOPTION: return @"OPTION";
        case OGGumboTagTEXTAREA: return @"TEXTAREA";
        case OGGumboTagKEYGEN: return @"KEYGEN";
        case OGGumboTagOUTPUT: return @"OUTPUT";
        case OGGumboTagPROGRESS: return @"PROGRESS";
        case OGGumboTagMETER: return @"METER";
        case OGGumboTagDETAILS: return @"DETAILS";
        case OGGumboTagSUMMARY: return @"SUMMARY";
        case OGGumboTagCOMMAND: return @"COMMAND";
        case OGGumboTagMENU: return @"MENU";
        case OGGumboTagAPPLET: return @"APPLET";
        case OGGumboTagACRONYM: return @"ACRONYM";
        case OGGumboTagBGSOUND: return @"BGSOUND";
        case OGGumboTagDIR: return @"DIR";
        case OGGumboTagFRAME: return @"FRAME";
        case OGGumboTagFRAMESET: return @"FRAMESET";
        case OGGumboTagNOFRAMES: return @"NOFRAMES";
        case OGGumboTagISINDEX: return @"ISINDEX";
        case OGGumboTagLISTING: return @"LISTING";
        case OGGumboTagXMP: return @"XMP";
        case OGGumboTagNEXTID: return @"NEXTID";
        case OGGumboTagNOEMBED: return @"NOEMBED";
        case OGGumboTagPLAINTEXT: return @"PLAINTEXT";
        case OGGumboTagRB: return @"RB";
        case OGGumboTagSTRIKE: return @"STRIKE";
        case OGGumboTagBASEFONT: return @"BASEFONT";
        case OGGumboTagBIG: return @"BIG";
        case OGGumboTagBLINK: return @"BLINK";
        case OGGumboTagCENTER: return @"CENTER";
        case OGGumboTagFONT: return @"FONT";
        case OGGumboTagMARQUEE: return @"MARQUEE";
        case OGGumboTagMULTICOL: return @"MULTICOL";
        case OGGumboTagNOBR: return @"NOBR";
        case OGGumboTagSPACER: return @"SPACER";
        case OGGumboTagTT: return @"TT";
        case OGGumboTagU: return @"U";
        case OGGumboTagUNKNOWN: return nil;
    }
    return nil;
}
