//
//  UploadView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 18.11.2023.
//

import Foundation
import Firebase


class UploadViewModel : ObservableObject{
    let service = UploadService()
    func uploadService(withtDate tDate: Any){
        service.createPost(tDate: tDate)
    }
}
