//
//  Profile.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 16/12/2022.
//

import SwiftUI

struct Profile: View {
    var body: some View {
        NavigationView {
            VStack {
                Header()
                Followers()
                    .padding(.horizontal)
                UserDetails()
                    .padding()
                NoteField()
                Spacer()
                    .navigationTitle("Profile")
            }
        }
    }
}

struct Header: View {
    @State private var backgroundColor: Color = .clear
    @State private var avatarImage = AppConstants.defaultAvatarImage

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            Image(uiImage: avatarImage)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
        }
        .frame(height: 150)
        .onAppear { self.setBackgroundColor() }
    }

    private func setBackgroundColor() {
        backgroundColor = Color(avatarImage.averageColor ?? .clear)
    }
}

struct Followers: View {
    var body: some View {
        HStack {
            Text("followers: 99999")
            Spacer()
            Text("following: 99999")
        }
    }
}

struct UserDetails: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("name: -")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("company: -")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("www.example.com")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .clipped()
        .shadow(radius: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 0.5)
        )
    }
}

struct NoteField: View {
    @State private var profileText = ""

    var body: some View {
        VStack {
            VStack {
                Text("Notes:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $profileText)
                    .foregroundColor(.secondary)
                    .lineLimit(5)
                    .frame(height: 180)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 0.5)
                    )
                Button("Save") { }
            }
        }
        .padding()
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}

