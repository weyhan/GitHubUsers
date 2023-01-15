//
//  ProfileNavigationBarView.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 15/01/2023.
//

import SwiftUI

struct ProfileNavigationBarView: View {
    var body: some View {
        HStack {
            backButtonView
            Spacer()
            titleView
            Spacer()
            backButtonView
                .opacity(0)
        }
        .padding()
        .accentColor(Color(UIColor(named: "tintColor")!))
        .foregroundColor(Color(UIColor(named: "headerForegroundColor")!))
        .font(.headline)
        .background(Color(UIColor(named: "headerColor")!))
    }
}

//struct CustomNavigationBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomNavigationBarView()
//    }
//}

extension ProfileNavigationBarView {

    private var backButtonView: some View {
        Button {

        } label: {
            Image(systemName: "chevron.left")
        }
    }

    private var titleView: some View {
        VStack(spacing: 4) {
            Text("Profile")
                .font(.title)
                .fontWeight(.semibold)
        }
    }
}
