//
//  ProfileView.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 16/12/2022.
//

import SwiftUI

protocol ProfileViewModelProtocol: ObservableObject {
    func loadData()
    func save(notes: String)
}

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
            switch viewModel.state {
            case .idle:
                Color.clear.onAppear(perform: viewModel.loadData)
            case .loading:
                ProgressView()
            case .failed(let error):
                ErrorView(message: error.localizedDescription)
            case .loaded(let user):
                ContentView(viewModel: viewModel, user: user)
            }
        }
}

struct ErrorView: View {
    var message: String

    var body: some View {
        Text("Error").font(.title)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let user: GitHubUser

    var body: some View {
        NavigationView {
            VStack {
                Header(avatar: AvatarImage(id: user.id, remoteUrlString: user.avatarUrl))
                Followers(user: user)
                    .padding(.horizontal)
                UserDetails(user: user)
                    .padding()
                NoteField(noteText: user.notes?.text ?? "")
                    .environmentObject(viewModel)
                Spacer()
            }
            .navigationTitle(user.name ?? "Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct Header: View {
    @State private var backgroundColor: Color = .clear
    @State private var avatarImage = AppConstants.defaultAvatarImage
    @ObservedObject var avatar: AvatarImage

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            Image(uiImage: avatarImage)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .onReceive(avatar.$image) { image in
                    guard let image = image else { return }
                    self.avatarImage = image
                    self.setBackgroundColor()
                }
        }
        .frame(height: 150)
        .onAppear {
            self.avatar.loadAvatarFile()
            self.setBackgroundColor()
        }
    }

    private func setBackgroundColor() {
        backgroundColor = Color(avatarImage.averageColor ?? .clear)
    }
}

struct Followers: View {
    var user: GitHubUser

    var body: some View {
        HStack {
            Text("followers: \(displayText(user.followers))")
            Spacer()
            Text("following: \(displayText(user.following))")
        }
    }
}

struct UserDetails: View {
    var user: GitHubUser

    var name: String { displayText(user.name) }
    var company: String { displayText(user.company) }
    var blog: String { displayText(user.blog) }
    var bio: String { displayText(user.bio) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("name: \(name)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("company: \(company)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("blog: \(blog)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("bio: \(bio)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
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
    @State var noteText: String
    @EnvironmentObject var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            VStack {
                Text("Notes:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $noteText)
                    .foregroundColor(.secondary)
                    .lineLimit(5)
                    .frame(height: 180)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 0.5)
                    )
                Button("Save") {
                    viewModel.save(notes: noteText)
                }
            }
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(row: 0, id: 1, login: ""))
    }
}

