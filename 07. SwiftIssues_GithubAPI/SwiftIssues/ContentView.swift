//
//  ContentView.swift
//  SwiftIssues
//
//  Created by Ben Scheirman on 10/21/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            IssuesList()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
