//
//  ViewController.m
//  SearchImage
//
//  Created by 南珂 on 16/6/2.
//  Copyright © 2016年 Nicole. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    获取lib
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
//    2.创建子线程（此处使用GCD方式）
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q, ^{
        NSLog(@"currentThread = %@", [NSThread currentThread]);
//        3.扫描媒体库
        [assetslibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            //使用一个block查看我们遍历资源
            /*
             第一个参数显示遍历的结果
             第二个参数
             */
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                //主要业务逻辑
                NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                if ([assetType isEqualToString:ALAssetTypePhoto]) {
                    *stop = NO;
                   ALAssetRepresentation *assetRepresentation = [result defaultRepresentation];
                    //图片缩放参数
                   CGFloat imageScale = [assetRepresentation scale];
                   UIImageOrientation imageOrientation = (UIImageOrientation)[assetRepresentation orientation];
                    //主线程更新界面
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGImageRef imageRef = [assetRepresentation fullResolutionImage];
                        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:imageScale orientation:imageOrientation];
                        if (image != nil) {
                            //显示到界面上
                            self.imageView.image = image;
                        }
                    });
                }
            }];
        } failureBlock:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
