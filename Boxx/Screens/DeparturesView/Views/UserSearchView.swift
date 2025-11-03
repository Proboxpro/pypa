//
//  UserSearchView.swift
//  Boxx
//
//  Created by Auto on 2025.
//

import SwiftUI
import Firebase

struct UserSearchView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedUser: User?
    @Binding var selectedLogin: String
    
    @State private var searchText: String = ""
    @State private var users: [User] = []
    @State private var isLoading: Bool = false
    
    var filteredUsers: [User] {
        guard !searchText.isEmpty else { return [] }
        return users.filter { user in
            user.login.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    TextField("Введите логин пользователя", text: $searchText)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if searchText.isEmpty {
                    Spacer()
                    Text("Введите логин для поиска")
                        .foregroundStyle(.gray)
                        .font(.system(size: 16))
                    Spacer()
                } else if filteredUsers.isEmpty {
                    Spacer()
                    Text("Пользователь не найден")
                        .foregroundStyle(.gray)
                        .font(.system(size: 16))
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredUsers) { user in
                                UserRowView(user: user) {
                                    selectUser(user)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Поиск получателя")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadUsers()
        }
    }
    
    private func loadUsers() {
        isLoading = true
        Task {
            await MainActor.run {
                viewModel.usersearch()
            }

            var attempts = 0
            while attempts < 10 {
                try? await Task.sleep(nanoseconds: 200_000_000)
                await MainActor.run {
                    if !viewModel.users.isEmpty {
                        users = viewModel.users
                        isLoading = false
                    }
                }
                if !users.isEmpty {
                    break
                }
                attempts += 1
            }
            
            await MainActor.run {
                users = viewModel.users
                isLoading = false
            }
        }
    }
    
    private func selectUser(_ user: User) {
        selectedUser = user
        selectedLogin = user.login
        dismiss()
    }
}

struct UserRowView: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                AsyncImage(url: URL(string: user.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullname)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("@\(user.login)")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    UserSearchView(selectedUser: .constant(nil), selectedLogin: .constant(""))
        .environmentObject(AuthViewModel())
}

