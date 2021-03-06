//
//  IssuesList.swift
//  SwiftIssues
//
//  Created by Ben Scheirman on 10/21/20.
//

import SwiftUI
import GithubKit

struct IssuesList: View {
    
    @ObservedObject var viewModel = IssuesViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                issuesList
            }
        }
        .alert(item: $viewModel.error, content: { e -> Alert in
            Alert(
                title: Text("Unable to load issues"),
                message: Text(e.error.description),
                primaryButton: .default(Text("Retry"), action: {
                    self.viewModel.fetch()
                }),
                secondaryButton: .cancel()
            )
        })
        .navigationTitle("Swift Issues")
    }
    
    private var issuesList: some View {
        List(viewModel.issues) { issue in
            IssueRow(issue: issue)
        }
    }
}

struct IssuesList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IssuesList()
        }
    }
}
