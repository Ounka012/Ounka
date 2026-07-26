import SwiftUI
import SafariServices
// ============================================================
// MARK: - Main View
// ============================================================
struct ContentView: View {
    // ---- State Variables ----
    @State private var isAutoTapping = false
    @State private var tapCount = 0
    @State private var interval: Double = 1.0
    @State private var timer: Timer?
    @State private var isTargetHighlighted = false
    @State private var showSafari = false
    @State private var profileURL: String = "https://apple.nextdns.io/your-profile-id"
    @State private var showURLAlert = false
    @State private var showResetAlert = false

    // ---- Body ----
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // ---- Header ----
                    headerView

                    // ---- Target Area ----
                    targetAreaView

                    // ---- Slider ----
                    sliderView

                    // ---- Control Buttons ----
                    controlButtonsView

                    // ---- Reset Button ----
                    resetButtonView

                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)

                    // ---- Profile Install Section ----
                    profileInstallView

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onDisappear {
            stopAutoTap()
        }
        .alert("URL មិនត្រឹមត្រូវ", isPresented: $showURLAlert) {
            Button("យល់ព្រម", role: .cancel) { }
        } message: {
            Text("សូមពិនិត្យមើល URL របស់ Profile ម្ដងទៀត។\nឧទាហរណ៍៖ https://apple.nextdns.io/xxxxx")
        }
        .alert("កំណត់សូន្យ", isPresented: $showResetAlert) {
            Button("បោះបង់", role: .cancel) { }
            Button("កំណត់សូន្យ", role: .destructive) {
                tapCount = 0
            }
        } message: {
            Text("តើអ្នកចង់កំណត់ចំនួនចុចឱ្យសូន្យមែនទេ?")
        }
    }

    // ============================================================
    // MARK: - Subviews
    // ============================================================

    private var headerView: some View {
        VStack(spacing: 4) {
            Text("🖱️ Auto Clicker")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            Text("ចុចដោយស្វ័យប្រវត្តិលើអេក្រង់")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }

    private var targetAreaView: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        isTargetHighlighted
                            ? AnyShapeStyle(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: (isTargetHighlighted ? Color.green : Color.blue).opacity(0.6), radius: 20)
                    .animation(.easeInOut(duration: 0.15), value: isTargetHighlighted)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                            Text("ចុចខ្ញុំ")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("(ឬចុចដោយស្វ័យប្រវត្តិ)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    )
                    .onTapGesture {
                        handleTap()
                    }

                // Counter overlay
                Text("\(tapCount)")
                    .font(.system(size: 90, weight: .heavy))
                    .foregroundColor(.white.opacity(0.15))
                    .offset(y: -150)
            }

            Text("ចំនួនចុច: \(tapCount)")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }

    private var sliderView: some View {
        VStack(spacing: 6) {
            HStack {
                Label("⏱️ ចន្លោះពេល", systemImage: "timer")
                    .foregroundColor(.white)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.1f វិនាទី", interval))
                    .foregroundColor(.cyan)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            Slider(value: $interval, in: 0.3...5.0, step: 0.1)
                .accentColor(.cyan)
                .disabled(isAutoTapping)
                .tint(.cyan)
        }
        .padding(.horizontal, 4)
    }

    private var controlButtonsView: some View {
        HStack(spacing: 16) {
            // Start / Stop Button
            Button(action: {
                isAutoTapping.toggle()
                if isAutoTapping {
                    startAutoTap()
                } else {
                    stopAutoTap()
                }
            }) {
                HStack {
                    Image(systemName: isAutoTapping ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                    Text(isAutoTapping ? "បញ្ឈប់" : "ចាប់ផ្ដើម")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    isAutoTapping
                        ? LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: (isAutoTapping ? Color.red : Color.green).opacity(0.4), radius: 10)
            }

            // Reset Button (icon only)
            Button(action: {
                if tapCount > 0 {
                    showResetAlert = true
                }
            }) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                    .shadow(radius: 4)
            }
            .disabled(isAutoTapping)
            .opacity(isAutoTapping ? 0.4 : 1.0)
        }
        .padding(.horizontal, 4)
    }

    private var resetButtonView: some View {
        Button(action: {
            if tapCount > 0 {
                showResetAlert = true
            }
        }) {
            Text("🔄 កំណត់សូន្យវិញ")
                .font(.callout)
                .foregroundColor(.gray)
                .underline()
        }
        .disabled(isAutoTapping)
        .opacity(isAutoTapping ? 0.4 : 1.0)
    }

    private var profileInstallView: some View {
        VStack(spacing: 14) {
            Label("🌐 ដំឡើង NextDNS Profile", systemImage: "network")
                .font(.headline)
                .foregroundColor(.white)

            TextField("បញ្ចូល URL Profile (ឧ. https://apple.nextdns.io/xxxxx)", text: $profileURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal, 4)

            Button(action: {
                if let url = URL(string: profileURL), UIApplication.shared.canOpenURL(url) {
                    showSafari = true
                } else {
                    showURLAlert = true
                }
            }) {
                Label("បើក Safari ដើម្បីដំឡើង", systemImage: "safari")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.3), radius: 8)
            }
            .padding(.horizontal, 4)
            .sheet(isPresented: $showSafari) {
                if let url = URL(string: profileURL) {
                    SafariView(url: url)
                }
            }

            Text("ប្រសិនបើឃើញ 'Invalid Profile' សូមទាញយក Profile ថ្មីពី NextDNS Dashboard")
                .font(.caption2)
                .foregroundColor(.yellow)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    // ============================================================
    // MARK: - Functions
    // ============================================================

    func handleTap() {
        // Flash effect
        isTargetHighlighted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isTargetHighlighted = false
        }
        tapCount += 1

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        print("✅ បានចុចនៅពេល: \(Date())")
    }

    func startAutoTap() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if self.isAutoTapping {
                self.handleTap()
            }
        }
    }

    func stopAutoTap() {
        timer?.invalidate()
        timer = nil
        isAutoTapping = false
        isTargetHighlighted = false
    }
}

// ============================================================
// MARK: - Safari View (UIViewControllerRepresentable)
// ============================================================
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredControlTintColor = .systemBlue
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// ============================================================
// MARK: - Preview
// ============================================================
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
