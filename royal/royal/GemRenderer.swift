import UIKit

final class GemRenderer {
    static let shared = GemRenderer()

    private var cache: [String: UIImage] = [:]

    func gemImage(for kind: TileKind, size: CGFloat) -> UIImage {
        let key = "\(kind)-\(size)"
        if let cached = cache[key] { return cached }
        let image = drawGem(kind: kind, size: size)
        cache[key] = image
        return image
    }

    func powerUpImage(for powerUp: PowerUp, size: CGFloat) -> UIImage? {
        guard powerUp != .none else { return nil }
        let key = "pu-\(powerUp)-\(size)"
        if let cached = cache[key] { return cached }
        let image = drawPowerUp(powerUp: powerUp, size: size)
        cache[key] = image
        return image
    }

    func obstacleImage(for obstacle: Obstacle, size: CGFloat) -> UIImage? {
        if case .none = obstacle { return nil }
        let key = "obs-\(obstacle)-\(size)"
        if let cached = cache[key] { return cached }
        let image = drawObstacle(obstacle: obstacle, size: size)
        cache[key] = image
        return image
    }

    /// Returns a 2×2 stone image. `size` is the size of one cell; the image is 2×size by 2×size.
    func stoneImage(hits: Int, cellSize: CGFloat, spacing: CGFloat) -> UIImage {
        let totalW = cellSize * 2 + spacing
        let totalH = cellSize * 2 + spacing
        let key = "stone-\(hits)-\(cellSize)-\(spacing)"
        if let cached = cache[key] { return cached }
        let image = drawStone(hits: hits, width: totalW, height: totalH)
        cache[key] = image
        return image
    }

    // MARK: - Gem Drawing

    private func drawGem(kind: TileKind, size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            let inset = size * 0.08
            let gemRect = rect.insetBy(dx: inset, dy: inset)
            let cx = size / 2
            let cy = size / 2

            let baseColor = kind.color
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

            let darkColor = UIColor(hue: h, saturation: min(s * 1.2, 1), brightness: b * 0.55, alpha: 1)
            let midColor = baseColor
            let lightColor = UIColor(hue: h, saturation: s * 0.6, brightness: min(b * 1.3, 1), alpha: 1)

            let context = ctx.cgContext

            // Draw gem shape based on kind
            let path: UIBezierPath
            switch kind {
            case .crown:
                path = diamondPath(in: gemRect)
            case .ruby:
                path = hexagonPath(in: gemRect)
            case .shield:
                path = shieldPath(in: gemRect)
            case .star:
                path = starPath(in: gemRect)
            case .leaf:
                path = ovalGemPath(in: gemRect)
            }

            // Shadow
            context.saveGState()
            context.setShadow(offset: CGSize(width: 0, height: size * 0.03), blur: size * 0.08, color: UIColor.black.withAlphaComponent(0.4).cgColor)
            darkColor.setFill()
            path.fill()
            context.restoreGState()

            // Gradient fill
            context.saveGState()
            path.addClip()

            let colors = [lightColor.cgColor, midColor.cgColor, darkColor.cgColor]
            let locations: [CGFloat] = [0.0, 0.45, 1.0]
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations) {
                context.drawLinearGradient(gradient,
                    start: CGPoint(x: cx - size * 0.3, y: gemRect.minY),
                    end: CGPoint(x: cx + size * 0.2, y: gemRect.maxY),
                    options: [])
            }

            // Inner facet lines
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.15).cgColor)
            context.setLineWidth(size * 0.015)
            drawFacets(context: context, kind: kind, rect: gemRect, cx: cx, cy: cy)

            context.restoreGState()

            // Outline
            context.setStrokeColor(darkColor.cgColor)
            context.setLineWidth(size * 0.025)
            path.stroke()

            // Shine highlight
            let shineRect = CGRect(x: cx - size * 0.18, y: gemRect.minY + size * 0.08,
                                   width: size * 0.28, height: size * 0.18)
            let shinePath = UIBezierPath(ovalIn: shineRect)
            let shineColor = UIColor.white.withAlphaComponent(0.55)
            let shineFade = UIColor.white.withAlphaComponent(0.0)

            context.saveGState()
            shinePath.addClip()
            if let shineGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                          colors: [shineColor.cgColor, shineFade.cgColor] as CFArray,
                                          locations: [0.0, 1.0]) {
                context.drawRadialGradient(shineGrad,
                    startCenter: CGPoint(x: shineRect.midX, y: shineRect.midY),
                    startRadius: 0,
                    endCenter: CGPoint(x: shineRect.midX, y: shineRect.midY),
                    endRadius: shineRect.width / 2,
                    options: [])
            }
            context.restoreGState()

            // Small sparkle dot
            let dotSize = size * 0.06
            let dotRect = CGRect(x: cx - size * 0.12, y: gemRect.minY + size * 0.12,
                                 width: dotSize, height: dotSize)
            UIColor.white.withAlphaComponent(0.9).setFill()
            UIBezierPath(ovalIn: dotRect).fill()
        }
    }

    // MARK: - Gem Shapes

    private func diamondPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let cx = rect.midX, cy = rect.midY
        let hw = rect.width * 0.48, hh = rect.height * 0.48
        path.move(to: CGPoint(x: cx, y: cy - hh))
        path.addLine(to: CGPoint(x: cx + hw, y: cy))
        path.addLine(to: CGPoint(x: cx, y: cy + hh))
        path.addLine(to: CGPoint(x: cx - hw, y: cy))
        path.close()
        return path
    }

    private func hexagonPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let cx = rect.midX, cy = rect.midY
        let r = min(rect.width, rect.height) * 0.47
        for i in 0..<6 {
            let angle = CGFloat.pi / 3.0 * CGFloat(i) - CGFloat.pi / 6.0
            let point = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.close()
        return path
    }

    private func shieldPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let cx = rect.midX
        let top = rect.minY + rect.height * 0.05
        let w = rect.width * 0.46
        let midY = rect.midY
        let bottom = rect.maxY - rect.height * 0.05

        path.move(to: CGPoint(x: cx, y: top))
        path.addLine(to: CGPoint(x: cx + w, y: top + rect.height * 0.08))
        path.addLine(to: CGPoint(x: cx + w, y: midY))
        path.addQuadCurve(to: CGPoint(x: cx, y: bottom), controlPoint: CGPoint(x: cx + w * 0.7, y: bottom - rect.height * 0.08))
        path.addQuadCurve(to: CGPoint(x: cx - w, y: midY), controlPoint: CGPoint(x: cx - w * 0.7, y: bottom - rect.height * 0.08))
        path.addLine(to: CGPoint(x: cx - w, y: top + rect.height * 0.08))
        path.close()
        return path
    }

    private func starPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let cx = rect.midX, cy = rect.midY
        let outerR = min(rect.width, rect.height) * 0.47
        let innerR = outerR * 0.42
        let points = 5

        for i in 0..<points * 2 {
            let r = i % 2 == 0 ? outerR : innerR
            let angle = CGFloat.pi * 2.0 / CGFloat(points * 2) * CGFloat(i) - CGFloat.pi / 2.0
            let point = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.close()
        return path
    }

    private func ovalGemPath(in rect: CGRect) -> UIBezierPath {
        let inset = rect.width * 0.05
        return UIBezierPath(ovalIn: rect.insetBy(dx: inset, dy: inset * 0.6))
    }

    // MARK: - Facet Lines

    private func drawFacets(context: CGContext, kind: TileKind, rect: CGRect, cx: CGFloat, cy: CGFloat) {
        switch kind {
        case .crown:
            // Diamond cross facets
            context.move(to: CGPoint(x: cx, y: rect.minY + rect.height * 0.15))
            context.addLine(to: CGPoint(x: cx, y: rect.maxY - rect.height * 0.15))
            context.strokePath()
            context.move(to: CGPoint(x: rect.minX + rect.width * 0.15, y: cy))
            context.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.15, y: cy))
            context.strokePath()
        case .ruby:
            // Hex center lines
            for i in 0..<3 {
                let angle = CGFloat.pi / 3.0 * CGFloat(i)
                let r = min(rect.width, rect.height) * 0.3
                context.move(to: CGPoint(x: cx - r * cos(angle), y: cy - r * sin(angle)))
                context.addLine(to: CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle)))
                context.strokePath()
            }
        case .shield:
            // Horizontal band
            context.move(to: CGPoint(x: rect.minX + rect.width * 0.15, y: cy - rect.height * 0.06))
            context.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.15, y: cy - rect.height * 0.06))
            context.strokePath()
        case .star:
            // Lines from center to points
            let outerR = min(rect.width, rect.height) * 0.32
            for i in 0..<5 {
                let angle = CGFloat.pi * 2.0 / 5.0 * CGFloat(i) - CGFloat.pi / 2.0
                context.move(to: CGPoint(x: cx, y: cy))
                context.addLine(to: CGPoint(x: cx + outerR * cos(angle), y: cy + outerR * sin(angle)))
                context.strokePath()
            }
        case .leaf:
            // Leaf vein
            context.move(to: CGPoint(x: cx, y: rect.minY + rect.height * 0.2))
            context.addLine(to: CGPoint(x: cx, y: rect.maxY - rect.height * 0.2))
            context.strokePath()
            // Side veins
            for dy in stride(from: rect.height * 0.15, to: rect.height * 0.4, by: rect.height * 0.12) {
                context.move(to: CGPoint(x: cx, y: cy - dy * 0.3))
                context.addLine(to: CGPoint(x: cx + rect.width * 0.22, y: cy - dy * 0.3 + rect.height * 0.08))
                context.strokePath()
                context.move(to: CGPoint(x: cx, y: cy - dy * 0.3))
                context.addLine(to: CGPoint(x: cx - rect.width * 0.22, y: cy - dy * 0.3 + rect.height * 0.08))
                context.strokePath()
            }
        }
    }

    // MARK: - Power-Up Drawing

    private func drawPowerUp(powerUp: PowerUp, size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: size, height: size).insetBy(dx: size * 0.1, dy: size * 0.1)
            let context = ctx.cgContext
            let cx = size / 2, cy = size / 2

            switch powerUp {
            case .rocketHorizontal:
                // Horizontal arrow/rocket
                let rocketColor = UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
                context.saveGState()
                context.setShadow(offset: .zero, blur: size * 0.06, color: rocketColor.withAlphaComponent(0.8).cgColor)
                let path = UIBezierPath()
                let h = size * 0.14
                path.move(to: CGPoint(x: rect.minX + size * 0.05, y: cy))
                path.addLine(to: CGPoint(x: rect.minX + size * 0.18, y: cy - h))
                path.addLine(to: CGPoint(x: rect.maxX - size * 0.12, y: cy - h))
                path.addLine(to: CGPoint(x: rect.maxX - size * 0.02, y: cy))
                path.addLine(to: CGPoint(x: rect.maxX - size * 0.12, y: cy + h))
                path.addLine(to: CGPoint(x: rect.minX + size * 0.18, y: cy + h))
                path.close()
                rocketColor.setFill()
                path.fill()
                UIColor.orange.setStroke()
                path.lineWidth = size * 0.02
                path.stroke()
                context.restoreGState()

            case .rocketVertical:
                // Vertical arrow/rocket
                let rocketColor = UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
                context.saveGState()
                context.setShadow(offset: .zero, blur: size * 0.06, color: rocketColor.withAlphaComponent(0.8).cgColor)
                let w = size * 0.14
                let path = UIBezierPath()
                path.move(to: CGPoint(x: cx, y: rect.minY + size * 0.02))
                path.addLine(to: CGPoint(x: cx + w, y: rect.minY + size * 0.18))
                path.addLine(to: CGPoint(x: cx + w, y: rect.maxY - size * 0.18))
                path.addLine(to: CGPoint(x: cx, y: rect.maxY - size * 0.02))
                path.addLine(to: CGPoint(x: cx - w, y: rect.maxY - size * 0.18))
                path.addLine(to: CGPoint(x: cx - w, y: rect.minY + size * 0.18))
                path.close()
                rocketColor.setFill()
                path.fill()
                UIColor.orange.setStroke()
                path.lineWidth = size * 0.02
                path.stroke()
                context.restoreGState()

            case .bomb:
                let bombR = size * 0.26
                context.saveGState()
                context.setShadow(offset: .zero, blur: size * 0.08, color: UIColor.red.withAlphaComponent(0.6).cgColor)
                let circle = UIBezierPath(arcCenter: CGPoint(x: cx, y: cy + size * 0.04), radius: bombR, startAngle: 0, endAngle: .pi * 2, clockwise: true)
                UIColor.darkGray.setFill()
                circle.fill()
                // Fuse
                context.setStrokeColor(UIColor.orange.cgColor)
                context.setLineWidth(size * 0.03)
                context.move(to: CGPoint(x: cx + size * 0.06, y: cy - bombR + size * 0.02))
                context.addQuadCurve(to: CGPoint(x: cx + size * 0.12, y: cy - bombR - size * 0.1),
                    control: CGPoint(x: cx + size * 0.14, y: cy - bombR - size * 0.02))
                context.strokePath()
                // Spark
                UIColor.yellow.setFill()
                UIBezierPath(ovalIn: CGRect(x: cx + size * 0.08, y: cy - bombR - size * 0.16, width: size * 0.08, height: size * 0.08)).fill()
                context.restoreGState()

            case .magnet:
                let magnetColor = UIColor(red: 0.8, green: 0.2, blue: 0.9, alpha: 1.0)
                context.saveGState()
                context.setShadow(offset: .zero, blur: size * 0.08, color: magnetColor.withAlphaComponent(0.7).cgColor)
                // Ring shape for magnet
                let outerR = size * 0.34
                let innerR = size * 0.18
                let ring = UIBezierPath(arcCenter: CGPoint(x: cx, y: cy), radius: outerR, startAngle: 0, endAngle: .pi * 2, clockwise: true)
                ring.append(UIBezierPath(arcCenter: CGPoint(x: cx, y: cy), radius: innerR, startAngle: 0, endAngle: .pi * 2, clockwise: false))
                magnetColor.setFill()
                ring.fill()
                // Highlight arc
                context.setStrokeColor(UIColor.white.withAlphaComponent(0.4).cgColor)
                context.setLineWidth(size * 0.025)
                let highlightArc = UIBezierPath(arcCenter: CGPoint(x: cx, y: cy), radius: (outerR + innerR) / 2, startAngle: -.pi * 0.7, endAngle: -.pi * 0.3, clockwise: true)
                highlightArc.stroke()
                context.restoreGState()

            case .none:
                break
            }
        }
    }

    // MARK: - Obstacle Drawing

    private func drawObstacle(obstacle: Obstacle, size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            let context = ctx.cgContext

            switch obstacle {
            case .ice(let hits):
                // Ice overlay
                let iceAlpha: CGFloat = hits > 1 ? 0.7 : 0.45
                let iceColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: iceAlpha)
                let borderColor = UIColor(red: 0.5, green: 0.85, blue: 1.0, alpha: 0.9)

                iceColor.setFill()
                let icePath = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: size * 0.2)
                icePath.fill()

                borderColor.setStroke()
                icePath.lineWidth = hits > 1 ? 3 : 1.5
                icePath.stroke()

                // Crack lines for single-hit ice
                if hits <= 1 {
                    context.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
                    context.setLineWidth(1.0)
                    context.move(to: CGPoint(x: size * 0.3, y: size * 0.2))
                    context.addLine(to: CGPoint(x: size * 0.5, y: size * 0.5))
                    context.addLine(to: CGPoint(x: size * 0.7, y: size * 0.35))
                    context.strokePath()
                    context.move(to: CGPoint(x: size * 0.5, y: size * 0.5))
                    context.addLine(to: CGPoint(x: size * 0.45, y: size * 0.75))
                    context.strokePath()
                }

                // Frost sparkles
                UIColor.white.withAlphaComponent(0.8).setFill()
                UIBezierPath(ovalIn: CGRect(x: size * 0.2, y: size * 0.15, width: size * 0.05, height: size * 0.05)).fill()
                UIBezierPath(ovalIn: CGRect(x: size * 0.65, y: size * 0.25, width: size * 0.04, height: size * 0.04)).fill()
                if hits > 1 {
                    UIBezierPath(ovalIn: CGRect(x: size * 0.4, y: size * 0.6, width: size * 0.05, height: size * 0.05)).fill()
                }

            case .chain:
                // Chain links
                let chainColor = UIColor(red: 0.55, green: 0.55, blue: 0.6, alpha: 0.85)
                let linkW = size * 0.22
                let linkH = size * 0.32
                let lineW = size * 0.035

                context.setStrokeColor(chainColor.cgColor)
                context.setLineWidth(lineW)

                // Vertical chain of links
                for i in 0..<2 {
                    let y = size * 0.15 + CGFloat(i) * linkH * 0.85
                    let linkRect = CGRect(x: size / 2 - linkW / 2, y: y, width: linkW, height: linkH)
                    let linkPath = UIBezierPath(roundedRect: linkRect, cornerRadius: linkW * 0.4)
                    linkPath.lineWidth = lineW
                    chainColor.setStroke()
                    linkPath.stroke()
                }

                // Metallic highlight
                context.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
                context.setLineWidth(lineW * 0.5)
                for i in 0..<2 {
                    let y = size * 0.18 + CGFloat(i) * linkH * 0.85
                    context.move(to: CGPoint(x: size / 2 - linkW * 0.2, y: y))
                    context.addLine(to: CGPoint(x: size / 2 + linkW * 0.1, y: y + linkH * 0.15))
                    context.strokePath()
                }

            case .none:
                break

            case .stone:
                // Individual stone cells are drawn via stoneImage overlay; nothing here
                break
            }
        }
    }

    // MARK: - Stone Drawing (2×2)

    private func drawStone(hits: Int, width: CGFloat, height: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { ctx in
            let context = ctx.cgContext
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            let inset: CGFloat = 4
            let stoneRect = rect.insetBy(dx: inset, dy: inset)

            // Shadow
            context.saveGState()
            context.setShadow(offset: CGSize(width: 0, height: 2), blur: 6,
                              color: UIColor.black.withAlphaComponent(0.5).cgColor)

            let stonePath = UIBezierPath(roundedRect: stoneRect, cornerRadius: width * 0.12)

            // Base color
            let baseGray: CGFloat = hits > 1 ? 0.45 : 0.55
            let stoneColor = UIColor(white: baseGray, alpha: 1.0)
            stoneColor.setFill()
            stonePath.fill()
            context.restoreGState()

            // Gradient overlay
            context.saveGState()
            stonePath.addClip()
            let topColor = UIColor(white: baseGray + 0.15, alpha: 1.0).cgColor
            let bottomColor = UIColor(white: baseGray - 0.12, alpha: 1.0).cgColor
            if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: [topColor, bottomColor] as CFArray,
                                     locations: [0.0, 1.0]) {
                context.drawLinearGradient(grad,
                    start: CGPoint(x: width / 2, y: stoneRect.minY),
                    end: CGPoint(x: width / 2, y: stoneRect.maxY),
                    options: [])
            }

            // Crack lines (more if damaged)
            context.setStrokeColor(UIColor.black.withAlphaComponent(0.25).cgColor)
            context.setLineWidth(1.5)

            // Main diagonal crack
            context.move(to: CGPoint(x: width * 0.25, y: height * 0.15))
            context.addLine(to: CGPoint(x: width * 0.45, y: height * 0.45))
            context.addLine(to: CGPoint(x: width * 0.7, y: height * 0.55))
            context.strokePath()

            if hits <= 1 {
                // Extra cracks when almost broken
                context.setStrokeColor(UIColor.black.withAlphaComponent(0.35).cgColor)
                context.move(to: CGPoint(x: width * 0.55, y: height * 0.2))
                context.addLine(to: CGPoint(x: width * 0.5, y: height * 0.5))
                context.addLine(to: CGPoint(x: width * 0.35, y: height * 0.75))
                context.strokePath()

                context.move(to: CGPoint(x: width * 0.7, y: height * 0.3))
                context.addLine(to: CGPoint(x: width * 0.6, y: height * 0.6))
                context.strokePath()
            }

            // Highlight spots
            UIColor.white.withAlphaComponent(0.2).setFill()
            UIBezierPath(ovalIn: CGRect(x: width * 0.15, y: height * 0.1, width: width * 0.15, height: height * 0.1)).fill()
            UIBezierPath(ovalIn: CGRect(x: width * 0.6, y: height * 0.65, width: width * 0.12, height: height * 0.08)).fill()

            context.restoreGState()

            // Border
            let borderColor = UIColor(white: baseGray - 0.2, alpha: 1.0)
            borderColor.setStroke()
            stonePath.lineWidth = 2.5
            stonePath.stroke()
        }
    }
}
