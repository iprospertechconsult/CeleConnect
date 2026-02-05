import SwiftUI

struct SocialOutlineButton<Leading: View>: View {
    let title: String
    let leading: () -> Leading
    let action: () -> Void

    init(title: String, @ViewBuilder leading: @escaping () -> Leading, action: @escaping () -> Void) {
        self.title = title
        self.leading = leading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                leading()
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .stroke(Color.white, lineWidth: 1)
            )
        }
        .background(Color.clear)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            SocialOutlineButton(title: "Continue with Apple", leading: {
                Image(systemName: "applelogo")
                    .font(.title2)
            }, action: {
                print("Apple tapped")
            })

            SocialOutlineButton(title: "Continue with Google", leading: {
                Image("google_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }, action: {
                print("Google tapped")
            })
        }
        .padding()
    }
}
