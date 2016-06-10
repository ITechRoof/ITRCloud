//
//  File.swift
//  ITRCloud-Part2
//
//  Created by kiruthika selvavinayagam on 6/1/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

import Foundation
import CloudKit

func Edit() {
    
    let recordIDToSave = CKRecordID(recordName: "recordID")
    let publicData = CKContainer.defaultContainer().publicCloudDatabase
    
    publicData.fetchRecordWithID(recordIDToSave) { (record, error) in
        
        if let recordToSave =  record {
            
            recordToSave.setObject("value", forKey: "key")
            
            let modifyRecords = CKModifyRecordsOperation(recordsToSave:[recordToSave], recordIDsToDelete: nil)
            modifyRecords.savePolicy = CKRecordSavePolicy.AllKeys
            modifyRecords.qualityOfService = NSQualityOfService.UserInitiated
            modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if error == nil {
                    print("Modified")
                }else {
                    print(error)
                }
            }
            publicData.addOperation(modifyRecords)
        }else{
            print(error.debugDescription)
        }
    }
}