//
//  VImagePicker.m
//  VoalteClientCommon
//
//  Created by Pierluigi Cifani on 16/6/14.
//  Copyright (c) 2014 Voalte Inc. All rights reserved.
//

#import "JSQImagePicker.h"

#define kCameraIndex  1
#define kAlbumIndex  0
#define kDismissIndex  2

@interface JSQImagePicker () <UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) UIViewController *presentingVC;
@property (nonatomic, copy) JSQPickerHandler handler;
@property (nonatomic, copy) dispatch_block_t dismissHandler;

@end

@implementation JSQImagePicker

- (void) pickImageFromViewController:(UIViewController *)viewController
                             handler:(JSQPickerHandler)uploadHandler
                      dismissHandler:(dispatch_block_t)dismissHandler;

{
    self.presentingVC = viewController;
    self.handler = uploadHandler;
    self.dismissHandler = dismissHandler;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Photo Library", nil), NSLocalizedString(@"Take Photo", nil), nil];
    
    [actionSheet showInView:viewController.view];
}

#pragma mark 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>) self;
    
    if (buttonIndex == kDismissIndex)
    {
        if (self.dismissHandler)
        {
            self.dismissHandler();
        }
    }
    else
    {
        if (buttonIndex == kAlbumIndex)
        {
            [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
        }
        else if (buttonIndex == kCameraIndex)
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                [picker setSourceType:(UIImagePickerControllerSourceTypeCamera)];
                //[picker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
            }
        }
        
        [self.presentingVC presentViewController:picker
                                        animated:YES
                                      completion:nil];
    }

}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    __weak __typeof(self) weakSelf = self;
    
    [self.presentingVC dismissViewControllerAnimated:YES
                                          completion:^{
                                              
                                              UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
                                              __typeof(self) strongSelf = weakSelf;
                                              

                                              strongSelf.handler(selectedImage, nil);
                                          }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
}

@end
