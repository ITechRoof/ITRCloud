//
//  DetailViewController.m
//  ITRCloud-Part2
//
//  Created by kiruthika selvavinayagam on 4/4/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "DetailViewController.h"
#import <CloudKit/CloudKit.h>

@interface DetailViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *noteTextfield;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic) NSURL *imageURL;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStyleDone target:self action:@selector(saveClicked:)];
    
    [self.navigationItem setTitle:self.selectedNote.createdDate.description];
    self.noteTextfield.text = self.selectedNote.noteText;
    self.imageURL = self.selectedNote.imageURL;
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
}


- (void)saveClicked:(id)sender {
    
    
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.selectedNote.createdDate.description];
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.publicCloudDatabase;
    
    self.selectedNote.noteText = self.noteTextfield.text;
    self.selectedNote.imageURL = self.imageURL;

    if(!self.selectedNote.isNew) {
        
        [database fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            
            if(record) {
                
                [record setObject:self.navigationItem.title forKey:@"TITLE"];
                [record setObject:self.noteTextfield.text forKey:@"TEXT"];
                
                if(self.imageURL) {
                    CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:self.imageURL];
                    [record setObject:imageAsset forKey:@"IMAGE"];
                }
                
                CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                          initWithRecordsToSave:@[record] recordIDsToDelete:nil];
                modifyRecords.savePolicy=CKRecordSaveAllKeys;
                modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
                modifyRecords.modifyRecordsCompletionBlock=
                ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
                    if(!operationError) {
                        NSLog(@"saved");
                    }
                };
                [database addOperation:modifyRecords];
            }
        }];
        
    }else {
        
        self.selectedNote.isNew = NO;
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"ITRNotes" recordID:recordID];
        [record setObject:self.navigationItem.title forKey:@"TITLE"];
        [record setObject:self.noteTextfield.text forKey:@"TEXT"];
        
        if(self.imageURL) {
            CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:self.imageURL];
            [record setObject:imageAsset forKey:@"IMAGE"];
        }
        
        [database saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            if(!error) {
                NSLog(@"saved");
            }
        }];
    }
    
    
    if(self.completionBlock) {
        self.completionBlock(self.selectedNote);
    }
}

- (IBAction)selectPhotoClicked:(id)sender {
   
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        
        pickerController.delegate = self;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.allowsEditing = NO;
        
        [self presentViewController:pickerController animated:YES completion:nil];
    }else {
        
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.8);
    NSString *directoryPath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [directoryPath stringByAppendingString:@"/local_image.png"];
    self.imageURL = [NSURL fileURLWithPath:path];
    [imageData writeToFile:path atomically:true];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
