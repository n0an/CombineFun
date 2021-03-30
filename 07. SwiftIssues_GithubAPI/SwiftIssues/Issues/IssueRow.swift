//
//  IssueRow.swift
//  SwiftIssues
//
//  Created by Ben Scheirman on 10/21/20.
//

import SwiftUI
import GithubKit

struct IssueRow: View {
    @ObservedObject var issue: IssueRowModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(issue.title)
                .lineLimit(3)
                .font(Font.body.bold())
            
            HStack {
                avatar
                
                Text(issue.author)
                    .font(.subheadline)
                
                Spacer()
                
                Label("\(issue.commentCount)", systemImage: "text.bubble")
            }
        }
        .padding(.vertical)
    }
    
    private var avatar: some View {
        Group {
            if let avatar = issue.avatarImage {
                Image(uiImage: avatar)
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
              
            } else {
                Circle()
                    .fill(Color.gray)
                    .onAppear { issue.fetchImage() }
            }
        }
        .frame(width: 36, height: 36)
    }
}
