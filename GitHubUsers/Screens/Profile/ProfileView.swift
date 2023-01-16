//
//  ProfileView.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 16/12/2022.
//

import SwiftUI
import Shimmer

protocol ProfileViewModelProtocol: ObservableObject {
    var newNotesText: String? { get set }
    var notesTextChanged: Bool { get }

    func loadData()
    func onDissapear()
}

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        switch viewModel.state {
        case .idle:
            Color.clear.onAppear(perform: viewModel.loadData)
        case .loading:
            ContentView(viewModel: viewModel, profile: viewModel.profile)
                .redacted(reason: .placeholder)
                .shimmering()
        case .failed(let error):
            ErrorView(message: error.localizedDescription)
        case .loaded:
            ContentView(viewModel: viewModel, profile: viewModel.profile)
        }
    }
}

struct ErrorView: View {
    var message: String

    var body: some View {
        Text("Error").font(.title)
    }
}

struct StatusView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.caption)
            .edgesIgnoringSafeArea(.horizontal)
            .frame(maxWidth: .infinity)
            .padding(4)
            .foregroundColor(.red)
            .background(Color.white)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let profile: ProfileData

    @State var isNotesFieldActive = false
    @State var statusMessage = ""

    var body: some View {
        if !statusMessage.isEmpty {
            StatusView(message: statusMessage)
                .transition(.move(edge: .top))
        }
        NavigationView {
            ScrollViewReader { value in
                ScrollView {
                    VStack {
                        Header(avatar: AvatarImage(id: profile.id, remoteUrlString: profile.avatarUrlString))
                        Followers(user: profile)
                            .padding(.horizontal)
                        UserDetails(user: profile)
                            .padding()
                        NoteField(noteText: profile.notesText ?? "", isNotesFieldActive: $isNotesFieldActive)
                            .environmentObject(viewModel)

                        Spacer()
                    }
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onChange(of: isNotesFieldActive) { activeState in
                    let animation = activeState ? Animation.easeInOut(duration: 0.5).delay(0.5) :
                    Animation.easeInOut(duration: 0.5)
                    withAnimation(animation) {
                        // Scroll to bottom of "Save" button if activeState is true, otherwise
                        // scroll to top of screen.
                        let (id, anchor) = activeState ? (1, UnitPoint.bottom) : (0, UnitPoint.top)
                        value.scrollTo(id, anchor: anchor)
                    }
                }
                .onReceive(viewModel.$statusMessage) { message in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        statusMessage = message ?? ""
                    }
                }
            }
            .background(Color(UIColor(named: "backgroundColor")!))
        }
        .navigationBarTitle(profile.name ?? "Profile", displayMode: .inline)
        .onDisappear {
            viewModel.onDissapear()
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
        .id(0)
        .unredacted()
    }

    private func setBackgroundColor() {
        backgroundColor = Color(avatarImage.averageColor ?? .clear)
    }
}

struct Followers: View {
    var user: ProfileData
    @Environment(\.redactionReasons) var redactionReasons

    var isPlaceholder: Bool { redactionReasons == .placeholder && user.name == nil }

    var placeholderFollowers: String { "followers: 999999" }
    var placeholderFollowing: String { "following: 999999" }

    var displayFollowers: String { "followers: \(displayText(user.followers))" }
    var displayFollowing: String { "following: \(displayText(user.following))" }

    var body: some View {
        HStack {
                Text(isPlaceholder ? placeholderFollowers : displayFollowers)
                Spacer()
                Text(isPlaceholder ? placeholderFollowing : displayFollowing)
        }
    }
}

struct UserDetails: View {
    var user: ProfileData
    @Environment(\.redactionReasons) var redactionReasons

    var isPlaceholder: Bool { redactionReasons == .placeholder && user.name == nil }

    var placeholderName: String { "name: Lorem ipsum dolor" }
    var placeholderCompany: String { "company: Lorem ipsum dolor" }
    var placeholderBlog: String { "blog: Lorem ipsum dolor sit." }
    var placeholderBio: String { "bio: Lorem ipsum dolor sit amet." }

    var displayName: String { "name: \(displayText(user.name))" }
    var displayCompany: String { "company: \(displayText(user.company))" }
    var displayBlog: String { "blog: \(displayText(user.blog))" }
    var displayBio: String { "bio: \(displayText(user.bio))" }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isPlaceholder ? placeholderName : displayName)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(isPlaceholder ? placeholderCompany : displayCompany)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(isPlaceholder ? placeholderBlog : displayBlog)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(isPlaceholder ? placeholderBio : displayBio)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(UIColor(named: "borderColor")!), lineWidth: 1)
                .shadow(radius: 5)
                .background(Color(UIColor(named: "backgroundContraColor")!))
        )
    }
}

struct NoteField: View {
    @State var noteText: String
    @EnvironmentObject var viewModel: ProfileViewModel
    @Binding var isNotesFieldActive: Bool

    var body: some View {
        VStack {
            VStack {
                Text("Notes:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $noteText)
                    .frame(height: 180)
                    .cornerRadius(3)
                    .clipped()
                    .background(Color(UIColor(named: "backgroundContraColor")!))
                    .foregroundColor(Color(UIColor(named: "foregroundColor")!))
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(UIColor(named: "borderColor")!), lineWidth: 1)
                            .shadow(radius: 5)
                            .background(Color(UIColor(named: "backgroundContraColor")!))
                    )
                    .onChange(of: noteText) { newText in
                        viewModel.newNotesText = newText
                    }
                    .onTapGesture { } // Override parent view tap gesture when tap on TextEditor.
            }
            .onReceive(keyboardPublisher) { isShown in
                isNotesFieldActive = isShown
            }
        }
        .id(1)
        .padding()
        .unredacted()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(id: 1, login: ""))
    }
}

