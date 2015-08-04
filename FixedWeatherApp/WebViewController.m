//
//  WebViewController.m
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/22/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>{
    UIWebView *webView;
    NSURLRequest *req;
}

@end

@implementation WebViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
//        webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
        webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:webView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [webView loadRequest:req];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadWebPage:(NSString *)cityID withCityNamed: (NSString * )cityName{
    // http://www.openweathermap.org/city/5037649
    
    self.navigationItem.title = cityName;
    
    req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.openweathermap.org/city/%@",cityID]]];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:req delegate:self];
    NSLog(@"Loading webpage...");
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"Webpage response received");
    [webView loadRequest:req];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection" message:@"Cannot connect to internet" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
