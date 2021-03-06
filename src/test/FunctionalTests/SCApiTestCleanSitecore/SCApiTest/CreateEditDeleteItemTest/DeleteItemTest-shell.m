#import "SCAsyncTestCase.h"

@interface DeleteItemTest_Shell : SCAsyncTestCase
@end

@implementation DeleteItemTest_Shell

-(void)testDeleteParentItem_Shell
{
    __weak __block SCApiSession* apiContext_ = nil;
    __block SCItem* item_ = nil;
    __block SCItem* item2_ = nil;
    __block NSUInteger read_items_count_ = 0;
    __block NSArray* delete_response_ = nil;
    __block NSString* path_ = SCCreateItemPath;
    __block NSString* deletedItemId = nil;

    @autoreleasepool
    {
        __block SCApiSession* strongContext_ = nil;
        strongContext_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                         login: SCWebApiAdminLogin
                                                      password: SCWebApiAdminPassword ];
        apiContext_ = strongContext_;
        
        apiContext_.defaultDatabase = @"web";
        apiContext_.defaultSite = @"/sitecore/shell";


    void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
    {
        __block SCCreateItemRequest* request_ = [ SCCreateItemRequest requestWithItemPath: path_ ];

        request_.itemName     = @"ItemToDelete shell";
        request_.itemTemplate = @"System/Layout/Layout";
        request_.flags = SCReadItemRequestReadFieldsValues;
        NSDictionary* fields_ = [ [ NSDictionary alloc ] initWithObjectsAndKeys: @"{239F9CF4-E5A0-44E0-B342-0F32CD4C6D8B}", @"__Source", nil ];
        request_.fieldsRawValuesByName = fields_;

        [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
        {
            item_ = result;
            request_.request = item_.path;
            request_.itemName     = @"ChildItem";
            [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
            {
                item2_ = result;
                deletedItemId = item2_.itemId;
                didFinishCallback_();
            } );
        } );
    };

    void (^delete_block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
    {
        SCReadItemsRequest* item_request_ = [ SCReadItemsRequest requestWithItemId: item2_.itemId ];
        item_request_.flags = SCReadItemRequestIngnoreCache;
        item_request_.scope = SCReadItemParentScope;
        [ apiContext_ deleteItemsOperationWithRequest: item_request_ ]( ^( id response_, NSError* read_error_ )
        {
            delete_response_ = response_;
            didFinishCallback_();                                                  
        } );
    };

    void (^read_block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
    {
        SCReadItemsRequest* item_request_ = [ SCReadItemsRequest requestWithItemId: deletedItemId ];
        item_request_.flags = SCReadItemRequestIngnoreCache;
        item_request_.scope = SCReadItemParentScope | SCReadItemSelfScope;
        [ apiContext_ readItemsOperationWithRequest: item_request_ ]( ^( NSArray* read_items_, NSError* read_error_ )
        {
            read_items_count_ = [ read_items_ count ];
            didFinishCallback_();                                                  
        } );
    };

    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: _cmd ];

    [ self performAsyncRequestOnMainThreadWithBlock: delete_block_
                                           selector: _cmd ];

    [ self performAsyncRequestOnMainThreadWithBlock: read_block_
                                           selector: _cmd ];
    }
    GHAssertTrue( apiContext_ != nil, @"OK" );

    //first item:
    GHAssertTrue( item_ != nil, @"OK" );
    GHAssertTrue( [ [ item_ displayName ] hasPrefix: @"ItemToDelete shell" ], @"OK" );
    GHAssertTrue( [ [ item_ itemTemplate ] isEqualToString: @"System/Layout/Layout" ], @"OK" );

    //second item:
    GHAssertTrue( item2_ != nil, @"OK" );
    GHAssertTrue( [ [ item2_ displayName ] hasPrefix: @"ChildItem" ], @"OK" );
    GHAssertTrue( [ [ item2_ itemTemplate ] isEqualToString: @"System/Layout/Layout" ], @"OK" );

    //removed items:
    GHAssertTrue( read_items_count_ == 0, @"OK" );
    
    NSLog( @"deleteResponse_: %@", delete_response_ );
    GHAssertTrue( [ delete_response_ count ] == 1, @"OK" );
}

-(void)testDeleteItemsHierarchy_Shell
{
    __weak __block SCApiSession* apiContext_ = nil;
    __block SCItem* item_ = nil;
    __block SCItem* item2_ = nil;
    __block NSUInteger read_items_count_ = 0;
    __block NSArray* deleteResponse_ = nil;
    __block NSString* deletedItemId_ = @"";
    __block NSString* nestedItemId = nil;
    
    @autoreleasepool
    {
        __block SCApiSession* strongContext_ = nil;
        strongContext_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                         login: SCWebApiAdminLogin
                                                      password: SCWebApiAdminPassword ];
        apiContext_ = strongContext_;
        
        apiContext_.defaultDatabase = @"web";
        apiContext_.defaultSite = @"/sitecore/shell";

        void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            __block SCCreateItemRequest* request_ = [ SCCreateItemRequest requestWithItemPath: SCCreateItemPath ];
            
            request_.itemName     = @"ItemToDelete shell";
            request_.itemTemplate = @"System/Layout/Renderings/Xsl Rendering";
            request_.flags = SCReadItemRequestReadFieldsValues;
            NSDictionary* fields_ = [ [ NSDictionary alloc ] initWithObjectsAndKeys: @"__Editor", @"__Editor", nil ];
            request_.fieldsRawValuesByName = fields_;

            [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
            {
                item_ = result;
                request_.request = item_.path;
                [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
                {
                    item2_ = result;
                    nestedItemId = item2_.itemId;
                    didFinishCallback_();
                } );
            } );
        };

        void (^delete_block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            deletedItemId_ = item_.itemId;
            SCReadItemsRequest* item_request_ = [ SCReadItemsRequest requestWithItemId: item_.itemId ];
            item_request_.flags = SCReadItemRequestIngnoreCache;
            item_request_.scope = SCReadItemSelfScope | SCReadItemChildrenScope;
            [ apiContext_ deleteItemsOperationWithRequest: item_request_ ]( ^( id response_, NSError* read_error_ )
            {
                deleteResponse_ = response_;
                didFinishCallback_();                                                  
            } );
        };

        void (^read_block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            SCReadItemsRequest* item_request_ = [ SCReadItemsRequest requestWithItemId: nestedItemId ];
            item_request_.flags = SCReadItemRequestIngnoreCache;
            item_request_.scope = SCReadItemParentScope | SCReadItemSelfScope;
            [ apiContext_ readItemsOperationWithRequest: item_request_ ]( ^( NSArray* read_items_, NSError* read_error_ )
            {
                read_items_count_ = [ read_items_ count ];
                didFinishCallback_();                                                  
            } );
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: block_
                                               selector: _cmd ];
        
        [ self performAsyncRequestOnMainThreadWithBlock: delete_block_
                                               selector: _cmd ];
        
        [ self performAsyncRequestOnMainThreadWithBlock: read_block_
                                               selector: _cmd ];
    }
    
    
    GHAssertTrue( apiContext_ != nil, @"OK" );

    //first item:
    GHAssertTrue( item_ != nil, @"OK" );
    GHAssertTrue( [ [ item_ displayName ] hasPrefix: @"ItemToDelete shell" ], @"OK" );
    GHAssertTrue( [ [ item_ itemTemplate ] isEqualToString: @"System/Layout/Renderings/Xsl Rendering" ], @"OK" );
    NSLog( @"item_.readFields: %@", item_.readFields );
    GHAssertNil( item_.readFields, @"No Fields expected for deleted item" );


    //second item:
    GHAssertTrue( item_ != nil, @"OK" );
    GHAssertTrue( [ [ item2_ displayName ] hasPrefix: @"ItemToDelete shell" ], @"OK" );
    GHAssertTrue( [ [ item2_ itemTemplate ] isEqualToString: @"System/Layout/Renderings/Xsl Rendering" ], @"OK" );

    NSLog( @"item2_.readFields: %@", item2_.readFields );
    GHAssertNil( item2_.readFields, @"No Fields expected for deleted item" );

    //removed items:
    GHAssertTrue( read_items_count_ == 0, @"OK" );
    NSLog( @"deleteResponse_: %@", deleteResponse_ );
    NSLog( @"deletedItemId_: %@", deletedItemId_ );
    GHAssertTrue( [ deleteResponse_ containsObject: deletedItemId_ ], @"OK" );
}

-(void)testDeleteItemsWithQuery_Shell
{
    __block  __weak SCApiSession* apiContext_ = nil;
    __block NSUInteger readItemsCount_ = 0;
    __block NSString* request1_ = nil;
    __block NSString* request2_ = nil;
    __block NSString* request3_ = nil;
    __block NSArray* deleteResponse_ = nil;
    __block SCItem* rootItem_;
    
    SCItem* item_ = nil;
    SCItem* item2_ = nil;
    SCItem* item3_ = nil;
    
    @autoreleasepool
    {
        __block SCApiSession* strongContext_ = nil;
        strongContext_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                         login: SCWebApiAdminLogin
                                                      password: SCWebApiAdminPassword ];
        apiContext_ = strongContext_;
        apiContext_.defaultDatabase = @"web";
        apiContext_.defaultSite = @"/sitecore/shell";

        void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            __block SCCreateItemRequest* request_ = [ SCCreateItemRequest requestWithItemPath: SCCreateItemPath ];
            request_.itemName     = @"ItemToDelete shell";
            request_.itemTemplate = @"System/Layout/Renderings/Xsl Rendering";
            request_.flags = SCReadItemRequestReadFieldsValues;
            NSDictionary* fields_ = [ [ NSDictionary alloc ] initWithObjectsAndKeys: @"/xsl/sample rendering.xslt", @"__Editor", nil ];
            request_.fieldsRawValuesByName = fields_;

            [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
            {
                request1_ = [ result itemId ];
                rootItem_ = result;
                request_.request = [ result path ];
                [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
                {
                    request2_ = [ result itemId ];
                    request_.request = [ result path ];
                    [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
                    {
                        [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
                         {
                             request3_ = [ result itemId ];
                             didFinishCallback_();
                         } );
                    } );
                } );
            } );
        };

        void (^delete_block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            strongContext_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                             login: SCWebApiAdminLogin
                                                          password: SCWebApiAdminPassword ];
            apiContext_ = strongContext_;
            
            apiContext_.defaultSite = @"/sitecore/shell";
            apiContext_.defaultDatabase = @"web";
            SCReadItemsRequest* item_request_ = [ SCReadItemsRequest new ];
            item_request_.request = 
                [ rootItem_.path stringByAppendingString: @"/parent::*/descendant::*[@@key='itemtodelete shell']" ];
            item_request_.flags = SCReadItemRequestIngnoreCache;
            item_request_.requestType = SCReadItemRequestQuery;
            item_request_.scope = SCReadItemSelfScope | SCReadItemChildrenScope;
            [ apiContext_ deleteItemsOperationWithRequest: item_request_ ]( ^( id response_, NSError* read_error_ )
            {
                deleteResponse_ = response_;
                NSLog( @"deleteResponse_: %@", deleteResponse_ );
                didFinishCallback_();                                                  
            } );
        };

        void (^read_block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            strongContext_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                             login: SCWebApiAdminLogin
                                                          password: SCWebApiAdminPassword ];
            apiContext_ = strongContext_;
            
            apiContext_.defaultSite = @"/sitecore/shell";
            apiContext_.defaultDatabase = @"web";
            SCReadItemsRequest* itemRequest_ = [ SCReadItemsRequest requestWithItemPath: request2_ ];
            itemRequest_.flags = SCReadItemRequestIngnoreCache;
            itemRequest_.scope = SCReadItemParentScope | SCReadItemSelfScope | SCReadItemChildrenScope;
            [ apiContext_ readItemsOperationWithRequest: itemRequest_ ]( ^( NSArray* readItems_, NSError* read_error_ )
            {
                readItemsCount_ = [ readItems_ count ];
                didFinishCallback_();                                                  
            } );
        };

        [ self performAsyncRequestOnMainThreadWithBlock: block_
                                               selector: _cmd ];
    
    
        GHAssertTrue( apiContext_ != nil, @"OK" );

        //first item:
        item_ = [ apiContext_ itemWithId: request1_ ];
        GHAssertTrue( item_ != nil, @"OK" );
        GHAssertTrue( [ [ item_ displayName ] hasPrefix: @"ItemToDelete shell" ], @"OK" );
        GHAssertTrue( [ [ item_ itemTemplate ] isEqualToString: @"System/Layout/Renderings/Xsl Rendering" ], @"OK" );

        //second item:
        item2_ = [ apiContext_ itemWithId: request2_ ];
        GHAssertTrue( item2_ != nil, @"OK" );
        GHAssertTrue( [ [ item2_ displayName ] hasPrefix: @"ItemToDelete shell" ], @"OK" );
        
        //third item:
        item3_ = [ apiContext_ itemWithId: request3_ ];
        GHAssertTrue( item3_ != nil, @"OK" );
        GHAssertTrue( [ [ item3_ displayName ] hasPrefix: @"ItemToDelete shell" ], @"OK" );
        
        [ self performAsyncRequestOnMainThreadWithBlock: delete_block_
                                               selector: _cmd ];
        
        [ self performAsyncRequestOnMainThreadWithBlock: read_block_
                                               selector: _cmd ];
    }
    
    //remove response:
    GHAssertTrue( readItemsCount_ == 0, @"OK" );
    NSLog( @"deleteResponse_: %@", deleteResponse_ );
    GHAssertTrue( [ deleteResponse_ count ] == 3, @"OK" );
    
    //deleted items
    item_ = [ apiContext_ itemWithId: request1_ ];
    GHAssertNil( item_, @"OK" );
    
    item2_ = [ apiContext_ itemWithId: request2_ ];
    GHAssertNil( item2_, @"OK" );
    
    item3_ = [ apiContext_ itemWithId: request3_ ];
    GHAssertNil( item3_, @"OK" );
}

-(void)testDeleteItemsWithChildren_Shell
{
    __weak __block SCApiSession* weakApiSession_   = nil;

    __block NSString* itemId1_;
    __block NSString* itemId2_;
    __block NSString* itemId3_;
    __block SCItem* rootItem_;

    SCItem* item1_ = nil;
    SCItem* item2_ = nil;
    SCItem* item3_ = nil;

    __block BOOL itemsWasCreated_ = NO;
    __block BOOL itemsWasRemoved_ = NO;
    
    @autoreleasepool
    {
        __block SCApiSession* strongApiSession_ = nil;



        __block NSString* currentPath_ = SCCreateItemPath;

        strongApiSession_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName 
                                                     login: SCWebApiAdminLogin
                                                  password: SCWebApiAdminPassword ];

        weakApiSession_ = strongApiSession_;

        strongApiSession_.defaultDatabase = @"web";
        strongApiSession_.defaultSite = @"/sitecore/shell";
    

        void (^deleteBlock_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            strongApiSession_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                         login: SCWebApiAdminLogin
                                                      password: SCWebApiAdminPassword ];
            strongApiSession_.defaultSite = @"/sitecore/shell";
            weakApiSession_ = strongApiSession_;
            
            SCReadItemsRequest* request_ = [ SCReadItemsRequest requestWithItemId: itemId1_ ];
            [ strongApiSession_ deleteItemsOperationWithRequest: request_ ]( ^( id response_, NSError* error_ )
            {
                itemsWasRemoved_ = response_ != nil;
                didFinishCallback_();
            } );
        };

//    [ self performAsyncRequestOnMainThreadWithBlock: deleteBlock_
//                                           selector: _cmd ];

        void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            __block SCCreateItemRequest* request_ = [ SCCreateItemRequest requestWithItemPath: SCCreateItemPath ];
            request_.itemName     = @"ItemToDelete shell";
            request_.itemTemplate = @"System/Layout/Renderings/Xsl Rendering";

            [ strongApiSession_ createItemsOperationWithRequest: request_ ]( ^( SCItem* result1_, NSError* error_ )
            {
                if ( !result1_ )
                {
                    didFinishCallback_();
                    return;
                }
                rootItem_ = result1_;

                itemId1_ = result1_.itemId;
                currentPath_ = [ currentPath_ stringByAppendingPathComponent: result1_.displayName ];
                request_.request = currentPath_;
                [ strongApiSession_ createItemsOperationWithRequest: request_ ]( ^( SCItem* result2_, NSError* error )
                {
                    if ( !result2_ )
                    {
                        didFinishCallback_();
                        return;
                    }
                    itemId2_ = result2_.itemId;
                    currentPath_ = [ currentPath_ stringByAppendingPathComponent: result2_.displayName ];
                    request_.request = currentPath_;
                    [ strongApiSession_ createItemsOperationWithRequest: request_ ]( ^( SCItem* result3_, NSError* error )
                    {
                        itemId3_ = result3_.itemId;
                        itemsWasCreated_ = ( result3_ != nil );
                        didFinishCallback_();
                    } );
                } );
            } );
        };

        [ self performAsyncRequestOnMainThreadWithBlock: block_
                                               selector: _cmd ];

        GHAssertTrue( itemsWasCreated_, @"OK" );

        GHAssertNotNil( weakApiSession_, @"OK" );

        item1_ = [ strongApiSession_ itemWithId: itemId1_ ];
        GHAssertNotNil( item1_, @"OK" );

        item2_ = [ strongApiSession_ itemWithId: itemId2_ ];
        GHAssertNotNil( item2_, @"OK" );

        item3_ = [ strongApiSession_ itemWithId: itemId3_ ];
        GHAssertNotNil( item3_, @"OK" );

        itemsWasRemoved_ = NO;

        [ self performAsyncRequestOnMainThreadWithBlock: deleteBlock_
                                               selector: _cmd ];

        GHAssertTrue( itemsWasRemoved_, @"OK" );
        GHAssertNotNil( weakApiSession_, @"OK" );
        
        item1_ = [ weakApiSession_ itemWithId: itemId1_ ];
        GHAssertNil( item1_, @"OK" );
        
        item2_ = [ weakApiSession_ itemWithId: itemId2_ ];
        GHAssertNil( item2_, @"OK" );
        
        item3_ = [ weakApiSession_ itemWithId: itemId3_ ];
        GHAssertNil( item3_, @"OK" );    
    }

    GHAssertNil( weakApiSession_, @"OK" );
}


-(void)testDeleteItemLoadedWithCustomParamsInRequest_Shell
{
    __weak __block SCApiSession* apiContext_ = nil;
    __block SCItem* item_ = nil;
    __block NSArray* read_fields_ = nil;
    __block NSError* createError = nil;
    
    __block NSNull* outresult = nil;
    __block NSError* outerror = nil;
    
    @autoreleasepool
    {
        __block SCApiSession* strongContext_ = nil;
        
        
        
        void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            strongContext_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                             login: SCWebApiAdminLogin
                                                          password: SCWebApiAdminPassword ];
            strongContext_.defaultDatabase = @"web";
            strongContext_.defaultSite = nil;
            strongContext_.defaultLanguage = @"en";
            
            apiContext_ = strongContext_;
                        
            SCCreateItemRequest* request_ = [ SCCreateItemRequest requestWithItemPath: SCCreateItemPath ];
            
            request_.itemName     = @"Normal Item";
            request_.itemTemplate = @"Common/Folder";
            request_.database = @"master";
            request_.language = @"ru";
            
            NSDictionary* fields_ = [ [ NSDictionary alloc ] initWithObjectsAndKeys: @"__Editor", @"__Editor"
                                     , nil ];
            request_.fieldsRawValuesByName = fields_;
            request_.fieldNames = [ NSSet setWithObjects: @"__Editor", nil ];
            
            __block JFFSimpleBlock blockdidFinishCallback_ = didFinishCallback_;
            
            [ apiContext_ createItemsOperationWithRequest: request_ ]( ^( id result, NSError* error )
              {
                  createError = error;
                  item_ = result;
                  NSLog( @"items fields: %@", item_.readFields );
                  read_fields_ = item_.readFields;
                  
                  SCAsyncOpResult onRemoveCompleted = ^void( NSNull* blockResult, NSError* blockError )
                  {
                      outresult = blockResult;
                      outerror  = blockError ;
                      
                      blockdidFinishCallback_();
                  };
                  
                  SCAsyncOp removeOperation = item_.removeItemOperation;
                  
                  removeOperation( onRemoveCompleted );
                  
            } );
        
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: block_
                                               selector: _cmd ];

    }
    
    GHAssertNotNil( outresult, @"[auth failed] : nil result - %@|%@", [ outerror class ], [ outerror localizedDescription ] );
    GHAssertNil( outerror, @"[auth failed] : error received  - %@|%@", [ outerror class ], [ outerror localizedDescription ] );

}

@end
