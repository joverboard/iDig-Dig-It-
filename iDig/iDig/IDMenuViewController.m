//
//  IDMenuViewController.m
//  iDig
//
//  Created by Jonathan Domagala on 7/16/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import "IDMenuViewController.h"
#import "IDMenuItem.h"
#import "IDTwitterFeedViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface IDMenuViewController ()

@end

@implementation IDMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mainMenuItem = [[IDMenuItem alloc] initWithFrame:CGRectMake(135, 240, 50, 50) numberOfSubItems:5 withImage:[UIImage imageNamed:@"icon-menu.png"]];
        mainMenuItem.normalImage.frame = mainMenuItem.frame;
        
        IDSubMenuItem *siteItem = ((IDSubMenuItem *)mainMenuItem.subMenuItems[0]);
        siteItem.normalImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-site.png"]];
        siteItem.normalImage.frame = siteItem.frame;
        [siteItem addTarget:self action:@selector(launchWebsite:) forControlEvents:UIControlEventTouchUpInside];
        
        IDSubMenuItem *facebookItem = ((IDSubMenuItem *)mainMenuItem.subMenuItems[1]);
        facebookItem.normalImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-facebook.png"]];
        facebookItem.normalImage.frame = facebookItem.frame;
        [facebookItem addTarget:self action:@selector(launchFacebook:) forControlEvents:UIControlEventTouchUpInside];
        
        IDSubMenuItem *twitterItem = ((IDSubMenuItem *)mainMenuItem.subMenuItems[2]);
        twitterItem.normalImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-twitter.png"]];
        twitterItem.normalImage.frame = twitterItem.frame;
        [twitterItem addTarget:self action:@selector(launchTwitterFeed:) forControlEvents:UIControlEventTouchUpInside];
        
        IDSubMenuItem *appstoreItem = ((IDSubMenuItem *)mainMenuItem.subMenuItems[3]);
        appstoreItem.normalImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-appstore.png"]];
        appstoreItem.normalImage.frame = appstoreItem.frame;
        [appstoreItem addTarget:self action:@selector(launchAppStore:) forControlEvents:UIControlEventTouchUpInside];
        
        IDSubMenuItem *contactItem = ((IDSubMenuItem *)mainMenuItem.subMenuItems[4]);
        contactItem.normalImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-email.png"]];
        contactItem.normalImage.frame = contactItem.frame;
        [contactItem addTarget:self action:@selector(launchContactForm:) forControlEvents:UIControlEventTouchUpInside];
        
        for (IDSubMenuItem *subMenuItem in mainMenuItem.subMenuItems)
        {
            [self.view addSubview:subMenuItem];
        }
        [self.view addSubview:mainMenuItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) launchWebsite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://dig-itgames.com"]];
}

- (void) launchFacebook:(id)sender
{
    // This attempts to open using the Facebook app, if installed
    // Failing that, it opens in Safari
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/26063254665"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/pages/DigItGames/26063254665"]];
    }
}

- (void) launchTwitterFeed:(id)sender
{
    IDTwitterFeedViewController *twitterVC = [[IDTwitterFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:twitterVC animated:YES];
}

- (void) launchAppStore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/artist/dig-it-games/id582762702"]];
}

- (void) launchContactForm:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.dig-itgames.com/contact"]];
}

@end
