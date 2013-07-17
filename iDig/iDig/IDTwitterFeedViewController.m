//
//  IDTwitterFeedViewController.m
//  iDig
//
//  Created by Jonathan Domagala on 7/16/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import "IDTwitterFeedViewController.h"
#import "IDTwitterAuthHandle.h"

#import <CommonCrypto/CommonCrypto.h>

@interface IDTwitterFeedViewController ()

@end

@implementation IDTwitterFeedViewController

static NSString * const kAppConsumerKey = @"EDfdnEWuu6LE33bIgBx6Q";
static NSString * const kAppConsumerSecret = @"WI0l7JgImZnZjz7zrI5cRDAtmPjiYsCZeiiTvpE";
static NSString * const kRequestURL = @"https://api.twitter.com/oauth/request_token";
static NSString * const kAuthorizeURL = @"https://api.twitter.com/oauth/authorize";
static NSString * const kAccessTokenURL = @"https://api.twitter.com/oauth2/token";

#define NUMBER_OF_TWEETS 15

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        currentRequests = [[NSMutableDictionary alloc] init];
        
        // Twitter recommends this, just in case
        NSString *encodedKey = [kAppConsumerKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedSecret = [kAppConsumerSecret stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *concat = [NSString stringWithFormat:@"%@:%@", encodedKey, encodedSecret];
        NSString *b64 = [self base64forData:[concat dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *postData = [@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:kAccessTokenURL];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"POST"];
        [req setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
        [req setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [req setValue:[@"Basic " stringByAppendingString:b64] forHTTPHeaderField:@"Authorization"];
        [req setHTTPBody:postData];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
        
        // The theory behind this is forward scaling and async connection management
        // It shouldn't be necessary in this case, but it's good to have it anyway
        NSMutableDictionary *currentConnection = [[NSMutableDictionary alloc] init];
        [currentConnection setObject:self forKey:@"CompletionTarget"];
        [currentConnection setObject:[NSValue valueWithPointer:@selector(handleBearerTokenResponse:)] forKey:@"CompletionHandler"];
        
        // Stashed by address, just in case there are duplicate queries running simultaneously
        [currentRequests setObject:currentConnection forKey:[NSString stringWithFormat:@"%@", connection]];
    }
    return self;
}

- (NSString*)base64forData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    int statusCode = ((NSHTTPURLResponse *)response).statusCode;
    if (statusCode < 400) // assume we're good to go
    {
        NSMutableDictionary *connectionDict = [currentRequests objectForKey:[NSString stringWithFormat:@"%@", connection]];
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            NSNumber *length = [NSNumber numberWithInt:[[headers objectForKey:@"Content-Length"] intValue]];
            [connectionDict setObject:length forKey:@"ExpectedLength"];
            [connectionDict setObject:[[NSMutableData alloc] init] forKey:@"ReceivedData"];
        }
    }
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    NSMutableDictionary *connectionDict = [currentRequests objectForKey:[NSString stringWithFormat:@"%@", connection]];
    NSMutableData *connectionData = [connectionDict objectForKey:@"ReceivedData"];
    int expectedLength = [[connectionDict objectForKey:@"ExpectedLength"] intValue];
    
    [connectionData appendData:data];
    
    // It would be nice if we could rely on this,
    // but in this instance, it seems unreliable
//    if ([connectionData length] >= expectedLength);
}

- (void) handleBearerTokenResponse:(NSDictionary *)connectionDict
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[connectionDict objectForKey:@"ReceivedData"] options:NSJSONReadingMutableContainers error:&error];
    
    if (!error)
    {
        IDTwitterAuthHandle *handle = [IDTwitterAuthHandle getInstance];
        handle.token = [jsonDict objectForKey:@"access_token"];
        
        if (handle.token)
        {
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=@digitgames&src=typd&count=%d", NUMBER_OF_TWEETS]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"GET"];
            [request setValue:[@"Bearer " stringByAppendingString:handle.token] forHTTPHeaderField:@"Authorization"];
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
            
            NSMutableDictionary *currentConnection = [[NSMutableDictionary alloc] init];
            [currentConnection setObject:self forKey:@"CompletionTarget"];
            [currentConnection setObject:[NSValue valueWithPointer:@selector(handleSearchQueryResponse:)] forKey:@"CompletionHandler"];
            
            [currentRequests setObject:currentConnection forKey:[NSString stringWithFormat:@"%@", connection]];
        }
    }
}

- (void) handleSearchQueryResponse:(NSDictionary *)connectionDict
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[connectionDict objectForKey:@"ReceivedData"] options:NSJSONReadingMutableContainers error:&error];
    
    if (!error)
    {
        statusArray = [jsonDict objectForKey:@"statuses"];
        [self.tableView reloadData];
    }

}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NSLog(@"%@", [error localizedDescription]);
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSMutableDictionary *connectionDict = [currentRequests objectForKey:[NSString stringWithFormat:@"%@", connection]];
    
    // We made it!
    [[connectionDict objectForKey:@"CompletionTarget"] performSelector:[[connectionDict objectForKey:@"CompletionHandler"] pointerValue] withObject:connectionDict];
    
    // Make sure to get rid of the stashed info now that we're done
    [currentRequests removeObjectForKey:[NSString stringWithFormat:@"%@", connection]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [statusArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSDictionary *cellValues = [statusArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [cellValues objectForKey:@"text"];
    [cell.textLabel sizeToFit];
    
    CGRect labelFrame = cell.textLabel.frame;
    labelFrame.size.width = cell.contentView.frame.size.width - 20;
    cell.textLabel.frame = labelFrame;
    [cell.textLabel sizeToFit];
    
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = [[cellValues objectForKey:@"user"] objectForKey:@"screen_name"];
    
    NSURL *url = [NSURL URLWithString:[[cellValues objectForKey:@"user"] objectForKey:@"profile_image_url"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    cell.imageView.image = img;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tweetValues = statusArray[indexPath.row];
    NSString *titleString = [tweetValues objectForKey:@"text"];
    NSString *subtitleString = [[tweetValues objectForKey:@"user"]objectForKey:@"screen_name"];
    
    UIFont *cellTitleFont = [UIFont systemFontOfSize:18.0];
    UIFont *cellSubtitleFont = [UIFont systemFontOfSize:14.0];//fontWithName:@"Helvetica" size:15.0];
    CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 20 - 60, MAXFLOAT);
    CGSize titleLabelSize = [titleString sizeWithFont:cellTitleFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize subtitleLabelSize = [subtitleString sizeWithFont:cellSubtitleFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return titleLabelSize.height + subtitleLabelSize.height + 40.0f;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
