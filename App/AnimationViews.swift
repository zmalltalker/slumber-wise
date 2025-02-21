import SwiftUI

// MARK: - Confetti Animation

struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confetti) { piece in
                ConfettiPieceView(
                    position: piece.position,
                    color: piece.color,
                    rotation: piece.rotation,
                    size: piece.size
                )
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        var newPieces: [ConfettiPiece] = []
        
        for _ in 0..<100 {
            let piece = ConfettiPiece(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: -100...100)
                ),
                color: [
                    Color(hex: "3A366E"),
                    Color(hex: "5CBDB9"),
                    Color(hex: "B8B5E1"),
                    Color(hex: "FFD485"),
                    Color.green,
                    Color.blue
                ].randomElement()!,
                rotation: Double.random(in: 0...360),
                size: CGFloat.random(in: 5...10)
            )
            newPieces.append(piece)
        }
        
        self.confetti = newPieces
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    var rotation: Double
    let size: CGFloat
}

struct ConfettiPieceView: View {
    @State private var animatedPosition: CGPoint
    let color: Color
    @State private var animatedRotation: Double
    let size: CGFloat
    
    init(position: CGPoint, color: Color, rotation: Double, size: CGFloat) {
        self._animatedPosition = State(initialValue: position)
        self.color = color
        self._animatedRotation = State(initialValue: rotation)
        self.size = size
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .position(x: animatedPosition.x, y: animatedPosition.y)
            .rotationEffect(Angle(degrees: animatedRotation))
            .onAppear {
                withAnimation(.linear(duration: 2).repeatCount(1, autoreverses: false)) {
                    animatedPosition.y += UIScreen.main.bounds.height
                    animatedRotation += 360
                }
            }
    }
}

// MARK: - Pulse Animation

struct PulseAnimation: View {
    @State private var animateSize = false
    @State private var animateOpacity = false
    var color: Color
    var duration: Double = 1.5
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .opacity(animateOpacity ? 0 : 0.5)
                .scaleEffect(animateSize ? 1.5 : 1)
            
            Circle()
                .fill(color)
                .opacity(animateOpacity ? 0 : 0.3)
                .scaleEffect(animateSize ? 2 : 1)
            
            Circle()
                .fill(color)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: false)) {
                animateSize = true
                animateOpacity = true
            }
        }
    }
}

// MARK: - Success Checkmark Animation

struct SuccessCheckmark: View {
    @State private var startAnimation = false
    var color: Color = .green
    var size: CGFloat = 100
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: startAnimation ? 1 : 0)
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round))
                .frame(width: size * 0.8, height: size * 0.8)
                .rotationEffect(.degrees(-90))
            
            Checkmark(size: size * 0.4)
                .trim(from: 0, to: startAnimation ? 1 : 0)
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(x: size * 0.02, y: size * 0.05)
                .rotationEffect(.degrees(-45))
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).delay(0.2)) {
                startAnimation = true
            }
        }
    }
}

struct Checkmark: Shape {
    var size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        var path = Path()
        path.move(to: CGPoint(x: 0, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.4, y: height))
        path.addLine(to: CGPoint(x: width, y: 0))
        
        return path
    }
}

// MARK: - Typing Text Animation

struct TypingText: View {
    let fullText: String
    let speed: Double
    
    @State private var displayedText: String = ""
    @State private var currentIndex: String.Index?
    
    init(_ text: String, speed: Double = 0.05) {
        self.fullText = text
        self.speed = speed
    }
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
    }
    
    private func startTyping() {
        currentIndex = fullText.startIndex
        displayedText = ""
        
        Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
            guard let currentIndex = currentIndex else {
                timer.invalidate()
                return
            }
            
            displayedText.append(String(fullText[currentIndex]))
            
            if currentIndex != fullText.index(before: fullText.endIndex) {
                self.currentIndex = fullText.index(after: currentIndex)
            } else {
                self.currentIndex = nil
                timer.invalidate()
            }
        }
    }
}

// MARK: - Loading Spinner

struct LoadingSpinner: View {
    @State private var isAnimating = false
    var color: Color = Color(hex: "5CBDB9")
    var lineWidth: CGFloat = 4
    var size: CGFloat = 40
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Previews

struct AnimationViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            ConfettiView()
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            PulseAnimation(color: Color(hex: "5CBDB9"))
                .frame(width: 50, height: 50)
            
            SuccessCheckmark()
                .frame(width: 100, height: 100)
            
            TypingText("This text animates one character at a time...")
                .frame(height: 50)
            
            LoadingSpinner()
        }
        .padding()
    }
}
