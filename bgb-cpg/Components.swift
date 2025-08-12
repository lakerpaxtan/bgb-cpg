import SwiftUI

// Big primary button
struct BigButton: View {
    var title: String
    var action: () -> Void
    var fill: Color = Color.blue

    var body: some View {
        Button(action: {
            Haptics.tap()
            action()
        }) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(fill)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: fill.opacity(0.25), radius: 8, y: 6)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

// Secondary outline button
struct OutlineButton: View {
    var title: String
    var action: () -> Void
    var tint: Color = .blue

    var body: some View {
        Button(action: {
            Haptics.tap()
            action()
        }) {
            Text(title)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tint, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

// Token chip view
struct TokenChips: View {
    let tokens: [Token]

    var body: some View {
        FlowLayout(alignment: .leading, spacing: 8) {
            ForEach(tokens) { t in
                Text(t.text)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(t.required ? Color.red.opacity(0.15) : Color.gray.opacity(0.15))
                    .foregroundStyle(t.required ? Color.red : Color.gray)
                    .clipShape(Capsule())
            }
        }
    }
}

// Simple flow layout for chips (pure Layout)
struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8) {
        self.alignment = alignment
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var rowWidth: CGFloat = 0
        var totalWidth: CGFloat = 0

        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                y += lineHeight + spacing
                totalWidth = max(totalWidth, rowWidth)
                x = 0
                rowWidth = 0
                lineHeight = 0
            }
            rowWidth += size.width + spacing
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        totalWidth = max(totalWidth, rowWidth)
        y += lineHeight
        return CGSize(width: min(totalWidth, maxWidth), height: y)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            sv.place(at: CGPoint(x: x, y: y),
                     proposal: ProposedViewSize(width: size.width, height: size.height))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}


// Confetti-ish celebratory overlay (simple, no deps)
struct ConfettiView: View {
    @State private var anim = false
    let colors: [Color] = [.pink, .blue, .green, .orange, .purple, .yellow]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(colors[i % colors.count].opacity(0.8))
                    .frame(width: 8 + CGFloat(Int.random(in: 0...10)), height: 8 + CGFloat(Int.random(in: 0...10)))
                    .position(x: CGFloat.random(in: 0...geo.size.width),
                              y: anim ? geo.size.height + 20 : -20)
                    .animation(.interpolatingSpring(mass: 0.2, stiffness: 60, damping: 8, initialVelocity: 3)
                        .delay(Double(i) * 0.03), value: anim)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            anim = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                anim = false
            }
        }
    }
}
