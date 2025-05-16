import SwiftUI
import PostHog

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showRegister = false
    @State private var showForgotPassword = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Добро пожаловать")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Пароль", text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button("Забыли пароль?") {
                    showForgotPassword = true
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Войти") {
                viewModel.login()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)

            Button("Нет аккаунта? Зарегистрироваться") {
                showRegister = true
            }
            .padding(.top, 12)

            Spacer()
        }
        .padding()
        .onAppear {
            PostHogSDK.shared.capture("view_auth_screen")
        }
        .sheet(isPresented: $showRegister) {
            RegisterView(viewModel: RegisterViewModel())
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}
