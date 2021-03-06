#import "SCFieldLinkData.h"

#import "SCApiSession.h"
#import "SCExtendedApiSession.h"
#import "SCItemSourcePOD.h"

@interface SCExtendedApiSession (SCGeneralLinkField)

-(JFFAsyncOperation)itemLoaderWithFieldsNames:( NSSet* )fieldNames
                                       itemId:( NSString* )itemId
                                   itemSource:( id<SCItemSource> )itemSource;

@end

@interface SCFieldLinkData ()

@property ( nonatomic ) SCExtendedApiSession* apiSession;
@property ( nonatomic ) NSString* linkDescription;
@property ( nonatomic ) NSString* linkType;
@property ( nonatomic ) NSString* alternateText;
@property ( nonatomic ) NSString* url;

@end

@implementation SCFieldLinkData

-(NSString*)otherFieldsDescription
{
    return @"";
}

-(NSString*)description
{
    NSString* otherFields_ = [ self otherFieldsDescription ];
    return [ [ NSString alloc ] initWithFormat: @"<%@ linkDescription:\"%@\" linkType:\"%@\" alternateText:\"%@\" url:\"%@\" %@ >"
            , [ self class ]
            , self.linkDescription
            , self.linkType
            , self.alternateText
            , self.url
            , otherFields_ ];
}

@end

@interface SCInternalFieldLinkData ()

@property ( nonatomic ) NSString* anchor;
@property ( nonatomic ) NSString* queryString;
@property ( nonatomic ) NSString* itemId;

-(SCAsyncOp)readItemOperation;

@end


@implementation SCInternalFieldLinkData

-(SCAsyncOp)readItemOperation
{
    //TODO: igk !!!! need itemSourcePOD here
    return asyncOpWithJAsyncOp( [ self.apiSession itemLoaderWithFieldsNames: [ NSSet new ]
                                                                     itemId: self.itemId
                                                                 itemSource: nil ] );
}

-(NSString*)otherFieldsDescription
{
    return [ [ NSString alloc ] initWithFormat: @"anchor:\"%@\" queryString:\"%@\" itemId:\"%@\""
            , self.anchor
            , self.queryString
            , self.itemId ];
}

@end

@interface SCMediaFieldLinkData ()

@property ( nonatomic ) NSString* itemId;

@end

@implementation SCMediaFieldLinkData

@synthesize itemId;

//TOFO: @igk merge readImageOperation and readImageExtendedOperation
-(SCAsyncOp)readImageOperation
{
    return asyncOpWithJAsyncOp( [ self.apiSession downloadResourceOperationForMediaPath: self.url
                                                                imageParams: nil ] );
}

-(SCExtendedAsyncOp)readImageExtendedOperation
{
    return [ self.apiSession downloadResourceOperationForMediaPath: self.url
                                           imageParams: nil ];
}


-(NSString*)otherFieldsDescription
{
    return [ [ NSString alloc ] initWithFormat: @"itemId:\"%@\""
            , self.itemId ];
}

@end

@implementation SCExternalFieldLinkData
@end

@interface SCAnchorFieldLinkData ()

@property ( nonatomic ) NSString *anchor;

@end

@implementation SCAnchorFieldLinkData

@synthesize anchor;

-(NSString*)otherFieldsDescription
{
    return [ [ NSString alloc ] initWithFormat: @"anchor:\"%@\""
            , self.anchor ];
}

@end

@implementation SCEmailFieldLinkData
@end

@implementation SCJavascriptFieldLinkData
@end
