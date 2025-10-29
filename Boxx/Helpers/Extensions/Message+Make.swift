//
//  Message+Make.swift
//  Boxx
//
//  Created by Максим Алексеев  on 18.03.2024.
//

import Foundation
import ExyteChat

extension ExyteChat.Message {
    static func makeMessage(
        id: String,
        user: ExyteChat.User,
        status: Status? = nil,
        draft: DraftMessage,
        imageURL: URL?) async -> Message {
            if let imageURL = imageURL {
                let attachment = Attachment(id: UUID().uuidString, url: imageURL, type: .image)
                
                return Message(id: id, user: user, status: status, createdAt: draft.createdAt, text: draft.text, attachments: [attachment], recording: draft.recording, replyMessage: draft.replyMessage)
            } else {
                return await makeMessage(id: id, user: user, status: status, draft: draft)
            }
        }
}
