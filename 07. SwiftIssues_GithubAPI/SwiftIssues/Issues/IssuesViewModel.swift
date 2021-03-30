//
//  IssuesViewModel.swift
//  SwiftIssues
//
//  Created by Ben Scheirman on 10/21/20.
//

import SwiftUI
import Combine
import GithubKit

class IssuesViewModel: ObservableObject {
    
    private let api = GithubAPI()
    
    @Published var isLoading = false
    @Published var issues: [IssueRowModel] = []
    @Published var error: IdentifiableError<HTTPError>?
    
    struct IdentifiableError<E: Error>: Identifiable {
        let id = UUID()
        let error: E
    }
    
    init() {
        fetch()
    }
    
    func fetch() {
        error = nil
        api.fetch(endpoint: "repos/apple/swift/issues", decoding: [Issue].self)
//            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [unowned self] _ in
                    isLoading = true
                },
                receiveCompletion: { [unowned self] _ in
                    isLoading = false
                },
                receiveCancel: { [unowned self] in
                    isLoading = false
                })
            .catch { [unowned self] error -> Just<[Issue]> in
                self.error = IdentifiableError(error: error )
                return Just([])
            }
            .flatMap { $0.publisher }
            .map { IssueRowModel(issue: $0) }
            .collect()
            .assign(to: &$issues)
    }
}
