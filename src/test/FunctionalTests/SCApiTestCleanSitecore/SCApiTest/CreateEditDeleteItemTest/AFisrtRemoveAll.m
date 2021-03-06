#import "SCAsyncTestCase.h"

@interface AFirstRemoveAllItems : SCAsyncTestCase
@end

@implementation AFirstRemoveAllItems


-(void)testRemoveAllItems
{
    __block SCApiSession* apiContext_ = nil;
    
    void (^delete_system_block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
    {
        apiContext_ = [ [ SCApiSession alloc ] initWithHost: SCWebApiHostName
                                                      login: SCWebApiAdminLogin
                                                   password: SCWebApiAdminPassword
                                                    version: SCWebApiV1 ];
        
        apiContext_.defaultSite = @"/sitecore/shell";
        apiContext_.defaultDatabase = @"master";
        SCReadItemsRequest* request_ =
        [ SCReadItemsRequest requestWithItemPath: SCCreateItemPath ];
        request_.scope = SCReadItemChildrenScope;
        [ apiContext_ deleteItemsOperationWithRequest: request_ ]( ^( id response_, NSError* error_ )
        {
            request_.request = SCCreateMediaPath;
            [ apiContext_ deleteItemsOperationWithRequest: request_ ]( ^( id response_, NSError* error_ )
            {
                apiContext_.defaultDatabase = @"web";
                request_.request = SCCreateItemPath;
                [ apiContext_ deleteItemsOperationWithRequest: request_ ]( ^( id response_, NSError* error_ )
                {
                    request_.request = SCCreateMediaPath;
                    [ apiContext_ deleteItemsOperationWithRequest: request_ ]( ^( id response_, NSError* error_ )
                    {
                        apiContext_.defaultDatabase = @"core";
                        request_.request = SCCreateItemPath;
                        [ apiContext_ deleteItemsOperationWithRequest: request_ ]( ^( id response_, NSError* error_ )
                        {
                            request_.request = SCCreateMediaPath;
                            [ apiContext_ deleteItemsOperationWithRequest: request_ ]( ^( id response_, NSError* error_ )
                            {
                                didFinishCallback_();
                            } );
                        } );
                    } );
                } );
            } );
        } );
        
    };
    
    [ self performAsyncRequestOnMainThreadWithBlock: delete_system_block_
                                           selector: _cmd ];
    
}


@end