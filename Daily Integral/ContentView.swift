import SwiftUI

struct ContentView: View {
    // Vi använder @StateObject för att äga vår ViewModel
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.hasSolvedToday {
                successView
            } else if let task = viewModel.currentTask {
                
                // --- Top Header (Poäng & Level) ---
                HStack {
                    scoreBadge(icon: "star.fill", text: "Poäng: \(viewModel.totalScore)", color: .yellow)
                    Spacer()
                    scoreBadge(icon: "bolt.fill", text: "Level: \(viewModel.levelNumber)", color: .orange)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // --- Scrollable Content ---
                ScrollView {
                    VStack(spacing: 20) {
                        Text("The Daily Integral")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .padding(.top, 10)
                        
                        // Frågekort
                        VStack(spacing: 10) {
                            Text("Dagens utmaning:")
                                .font(.subheadline).foregroundColor(.secondary)
                            MathView(latex: task.question)
                                .frame(height: 100)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                        
                        // Svarsfält
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Ditt svar:")
                                .font(.caption).foregroundColor(.secondary)
                            
                            HStack {
                                let displayLatex = viewModel.inputAnswer.replacingOccurrences(of: "|", with: "\\color{black}{|}")
                                MathView(latex: displayLatex)
                                    .frame(height: 80)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.isError ? Color.red : Color.blue, lineWidth: 2)
                            )
                            .offset(x: viewModel.shakeOffset)
                        }
                        .padding(.horizontal)
                        
                        // Kontroll-knapp
                        Button(action: {
                            viewModel.checkAnswer()
                        }) {
                            Text("Kontrollera svar")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.inputAnswer == "|" ? Color.gray.opacity(0.5) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.inputAnswer == "|")
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
                
                // --- Tangentbord ---
                MathKeyboard(text: $viewModel.inputAnswer)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    // --- Subviews ---
    
    var successView: some View {
        VStack(spacing: 25) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100)).foregroundColor(.green)
            Text("Utmärkt!").font(.largeTitle).bold()
            
            Button("Nollställ (Dev)") {
                viewModel.resetProgress()
            }
            .padding().foregroundColor(.red)
            Spacer()
        }
    }
    
    func scoreBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).foregroundColor(color)
            Text(text)
                .font(.system(.title3, design: .rounded))
                .bold()
        }
    }
}
