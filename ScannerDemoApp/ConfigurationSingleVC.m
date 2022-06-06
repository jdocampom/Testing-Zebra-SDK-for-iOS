/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ConfigurationSingleVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ConfigurationSingleVC.h"
#import "BarcodeGen128.h"

@interface zt_ConfigurationSingleVC ()

@end

@implementation zt_ConfigurationSingleVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_Configuration = nil;
    }
    return self;
}

- (void)dealloc
{
    if (m_Configuration != nil)
    {
        [m_Configuration release];
    }
    
    [m_imgConfigurationBarcode release];
    [m_lblConfigurationNotice release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.view removeConstraints:self.view.constraints];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.2 constant:20.0];
    [self.view addConstraint:c4];
    
    NSLayoutConstraint *c5 = [NSLayoutConstraint constraintWithItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.5 constant:0.0];
    c5.priority = UILayoutPriorityDefaultHigh;
    [self.view addConstraint:c5];
    
    NSLayoutConstraint *c6 = [NSLayoutConstraint constraintWithItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeWidth multiplier:0.66 constant:0];
    c6.priority = UILayoutPriorityRequired;
    [self.view addConstraint:c6];
    
    NSLayoutConstraint *c7 = [NSLayoutConstraint constraintWithItem:m_lblConfigurationNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_imgConfigurationBarcode attribute:NSLayoutAttributeBottom multiplier:1.0 constant:40.0];
    [self.view addConstraint:c7];
    
    NSLayoutConstraint *c8 = [NSLayoutConstraint constraintWithItem:m_lblConfigurationNotice attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20.0];
    [self.view addConstraint:c8];
    
    NSLayoutConstraint *c9 = [NSLayoutConstraint constraintWithItem:m_lblConfigurationNotice attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20.0];
    [self.view addConstraint:c9];
    
    NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblConfigurationNotice attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0];
    [self.view addConstraint:c10];
    
    NSLayoutConstraint *c11 = [NSLayoutConstraint constraintWithItem:m_lblConfigurationNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.2 constant:0.0];
    [self.view addConstraint:c11];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLayoutSubviews
{
    /* to have a nice barcode image after interface orientation changes */
    [super viewDidLayoutSubviews];
    
    if (m_Configuration != nil)
    {
        [self drawConfigurationBarcode];
        if (m_lblConfigurationNotice != nil)
        {
            [m_lblConfigurationNotice setText:[NSString stringWithFormat:@"Scan the presented barcode to configure [%@]", [m_Configuration getConfigurationName]]];
            //[m_lblConfigurationNotice sizeToFit];
        }
    }
    
    [self.view layoutSubviews];
}

- (void)setConfiguration:(zt_ScannerConfiguration*)config
{
    if (m_Configuration != nil)
    {
        [m_Configuration release];
        m_Configuration = nil;
    }
    
    m_Configuration = [[zt_ScannerConfiguration alloc] initWithName:[config getConfigurationName] withCode:[config getConfigurationCode]];
    [self setTitle:[m_Configuration getConfigurationName]];
}

- (void)drawConfigurationBarcode
{
    /* 1) get representation and width */
    unsigned int barcode_width = 0;
    unsigned short* barcode_data;
    barcode_data = (unsigned short*)malloc(1024*sizeof(unsigned short));
    memset((void*)barcode_data, 0x00, 1024*sizeof(unsigned short));
    NSString *input_str = [m_Configuration getConfigurationCode];
    char *input = malloc(sizeof(char)*([input_str length] + 3 + 1));
    memset((void*)input, 0x00, sizeof(char)*([input_str length] + 3 + 1));
    sprintf(input, "\003%s", [input_str cStringUsingEncoding:NSASCIIStringEncoding]);
    
    int barcode_len = generateBarcode128B1(input, (unsigned short*)barcode_data, &barcode_width);
    
    free(input);
    
    /* 2) draw on UIImage with height of UIImageView and required width */
    
    /* TBD */
    unsigned short _barcode_line_width = 10;
    
    CGFloat image_height = m_imgConfigurationBarcode.frame.size.height;
    CGFloat image_width = barcode_width * _barcode_line_width;
    
    CGRect image_rect = CGRectMake(0.0, 0.0, image_width, image_height);

    UIGraphicsBeginImageContextWithOptions(image_rect.size, NO, 1);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /* will the background in white */
    CGContextSetRGBFillColor(ctx, 1.0,1.0,1.0,1.0);
    CGContextFillRect(ctx, image_rect);
    CGContextSaveGState(ctx);
    
    unsigned short barcode;
    unsigned short w;
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat l = image_height;
    
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    for(unsigned i = 0; i < barcode_len; i++)
    {
        barcode = barcode_data[i];
        
        w = (barcode & 0x3) + 1;
        w *= _barcode_line_width;
        barcode >>= 2;
        CGContextFillRect(ctx, CGRectMake(x, y, w, l));
        x += w;
        w = (barcode & 0x3) + 1;
        w *= _barcode_line_width;
        barcode >>= 2;
        x += w;
        
        w = (barcode & 0x3) + 1;
        w *= _barcode_line_width;
        barcode >>= 2;
        CGContextFillRect(ctx, CGRectMake(x, y, w, l));
        x += w;
        w = (barcode & 0x3) + 1;
        w *= _barcode_line_width;
        barcode >>= 2;
        x += w;
        
        w = (barcode & 0x3) + 1;
        w *= _barcode_line_width;
        barcode >>= 2;
        CGContextFillRect(ctx, CGRectMake(x, y, w, l));
        x += w;
        w = (barcode & 0x3) + 1;
        w *= _barcode_line_width;
        barcode >>= 2;
        x += w;
        
    }
    w = (barcode & 0x3) + 1;
    w *= _barcode_line_width;
    barcode >>= 2;
    CGContextFillRect(ctx, CGRectMake(x, y, w, l));
    
    CGContextRestoreGState(ctx);
    
    UIImage *barcode_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    /* 3) resize UIImage and display it in UIImageView */
    
    CGFloat image_view_height = m_imgConfigurationBarcode.frame.size.height;
    CGFloat image_view_width = m_imgConfigurationBarcode.frame.size.width;
    
    CGRect image_view_rect = CGRectMake(0.0, 0.0, image_view_width, image_view_height);
    
    UIGraphicsBeginImageContext(image_view_rect.size);
    [barcode_image drawInRect:image_view_rect];
    
    UIImage *final_barcode_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [m_imgConfigurationBarcode setImage:final_barcode_image];
    
    /* UIImage returned by UIGraphicsGetImageFromCurrentImageContext() is autoreleased object */
    //[barcode_image release];
    //[final_barcode_image release];
    free(barcode_data);
}

@end
