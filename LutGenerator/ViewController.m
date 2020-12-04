//
//  ViewController.m
//  LutGenerator
//
//  Created by Thanh Vu on 02/12/2020.
//

#import "ViewController.h"
#define ARGBMake(a, r, g, b) ( a << 24 | r << 16 | g << 8 | b )

@interface ViewController ()

@end

@implementation ViewController {
    UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    [self draw];
}

- (void)draw {
    CGSize size = CGSizeMake(512, 512); // Customize if need
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * size.width;
    
    CGFloat squareSize = 64; // Customize if need
    CGFloat ratio = 256/squareSize;
    int squarePerRow = sqrt(squareSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    UInt32 * inputPixels = (UInt32 *)calloc(size.width * size.height, sizeof(UInt32));
    CGContextRef context = CGBitmapContextCreate(inputPixels, size.width, size.height,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    
    for (int squareRow = 0; squareRow < squarePerRow; squareRow++) {
        for (int squareColumn = 0; squareColumn < squarePerRow; squareColumn++) {
            UInt32 blueIndex = squareRow * squarePerRow + squareColumn;
            UInt32 blueValue = blueIndex * ratio;
            
            for (int greenIndex = 0; greenIndex < squareSize; greenIndex++) {
                for (int redIndex = 0; redIndex < squareSize; redIndex++) {
                    UInt32 redValue = redIndex * ratio;
                    UInt32 greenValue = greenIndex * ratio;
                    
                    UInt32 pixelIndexX = squareColumn*squareSize + redIndex;
                    UInt32 pixelIndexY = squareRow*squareSize + greenIndex;
                    
                    UInt32 index = pixelIndexY*size.width + pixelIndexX;
                    UInt32 * currentPixel = &inputPixels[index];
                    *currentPixel = ARGBMake(255, redValue, greenValue, blueValue);
                }
            }
        }
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    imageView.image = processedImage;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *path = [NSString stringWithFormat:@"%@%@.png", NSTemporaryDirectory(), NSUUID.UUID.UUIDString];
    NSData *png = UIImagePNGRepresentation(processedImage);
    [png writeToFile:path atomically:YES];
    
    NSLog(@"Writen at path %@", path);
    NSLog(@"Done %@", NSStringFromCGSize(processedImage.size));
}


@end
