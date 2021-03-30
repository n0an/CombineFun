//
//  IssueRowModel.swift
//  SwiftIssues
//
//  Created by Ben Scheirman on 10/21/20.
//

import SwiftUI
import Combine
import GithubKit

class IssueRowModel: ObservableObject, Identifiable {
    let issue: Issue
    
    var id: Int64 { issue.id }
    var title: String { issue.title }
    var author: String { issue.user.login }
    var commentCount: Int { issue.comments }
    
    static var defaultAvatar: UIImage {
        UIImage(systemName: "person.crop.circle")!
    }
    
    @Published var avatarImage: UIImage?
    
    init(issue: Issue) {
        self.issue = issue
    }
    
    func fetchImage() {
        URLSession.shared.dataTaskPublisher(for: issue.user.avatarUrl)
//            .delay(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .assumeHTTP()
            .responseData()
            .receive(on: DispatchQueue.main)
            .map { UIImage(data: $0) }
            .replaceError(with: Self.defaultAvatar)
            .assign(to: &$avatarImage)
    }
}
