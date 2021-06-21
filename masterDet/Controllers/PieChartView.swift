//
//  Pie Chart View
//  coursework -02
//
//  Created by Aravinthan Sathasivam on 5/18/21.
//

import UIKit

// Set segments
struct LabelledSegment {
    var color: UIColor
    var name: String
    var value: CGFloat
}

extension Collection where Element : Numeric {
    func sum() -> Element {
        return reduce(0, +)
    }
}

// Number Formatter- Method
extension NumberFormatter {
    static let toOneDecimalPlace: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}
// CGReact
extension CGRect {
    init(centeredOn center: CGPoint, size: CGSize) {
        self.init(
            origin: CGPoint(
                x: center.x - size.width * 0.5, y: center.y - size.height * 0.5
            ),
            size: size
        )
    }
    
    var center: CGPoint {
        return CGPoint(
            x: origin.x + size.width * 0.5, y: origin.y + size.height * 0.5
        )
    }
}

extension CGPoint {
    func projected(by value: CGFloat, angle: CGFloat) -> CGPoint {
        return CGPoint(
            x: x + value * cos(angle), y: y + value * sin(angle)
        )
    }
}

extension UIColor {
    struct RGBAComponents {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
    }
    
    var rgbaComponents: RGBAComponents {
        var components = RGBAComponents(red: 0, green: 0, blue: 0, alpha: 0)
        getRed(&components.red, green: &components.green, blue: &components.blue,
               alpha: &components.alpha)
        return components
    }
    
    var brightness: CGFloat {
        return rgbaComponents.brightness
    }
}

extension UIColor.RGBAComponents {
    var brightness: CGFloat {
        return (red + green + blue) / 3
    }
}

// Segment Label Formatter
struct SegmentLabelFormatter {
    private let _getLabel: (LabelledSegment) -> String
    init(_ getLabel: @escaping (LabelledSegment) -> String) {
        self._getLabel = getLabel
    }
    func getLabel(for segment: LabelledSegment) -> String {
        return _getLabel(segment)
    }
}

extension SegmentLabelFormatter {
    // View Segment Name & Value
    static let nameWithValue = SegmentLabelFormatter { segment in
        let formattedValue = NumberFormatter.toOneDecimalPlace
            .string(from: segment.value as NSNumber) ?? "\(segment.value)"
        return ""
    }
    
    // View Segment - Name
    static let nameOnly = SegmentLabelFormatter { $0.name }
}

@IBDesignable
class PieChartView : UIView {
    // Segment - array - pieChart
    var segments = [LabelledSegment]() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable
    var showSegmentLabels: Bool = true {
        didSet { setNeedsDisplay() }
    }
    
    // assign UI font
    @IBInspectable
    var segmentLabelFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            textAttributes[.font] = segmentLabelFont
            setNeedsDisplay()
        }
    }
    
    //  segmentLabelFormatter
    var segmentLabelFormatter = SegmentLabelFormatter.nameWithValue {
        didSet { setNeedsDisplay() }
    }
    
    // Set CG float - value
    @IBInspectable
    var textPositionOffset: CGFloat = 0.67 {
        didSet { setNeedsDisplay() }
    }
    
    private let paragraphStyle: NSParagraphStyle = {
        var p = NSMutableParagraphStyle()
        p.alignment = .center
        return p.copy() as! NSParagraphStyle
    }()
    
    private lazy var textAttributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: self.paragraphStyle, .font: self.segmentLabelFont
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        isOpaque = false
    }
    
    override func prepareForInterfaceBuilder() {
        // Display dummy values.
        segments = [
            LabelledSegment(color: #colorLiteral(red: 0.9467689395, green: 0.4717171192, blue: 0.4472602606, alpha: 1), name: "Red",   value: 40),
            LabelledSegment(color: #colorLiteral(red: 0.9585652947, green: 0.8335036635, blue: 0.3131697774, alpha: 1), name: "Yellow",value: 10),
            LabelledSegment(color: #colorLiteral(red: 0.5391305089, green: 0.3921048641, blue: 0.8406239152, alpha: 1), name: "Purple",value: 20),
            LabelledSegment(color: #colorLiteral(red: 0.3722616434, green: 0.5258184075, blue: 0.9463476539, alpha: 1), name: "Blue",  value: 30),
            LabelledSegment(color: #colorLiteral(red: 0.4086512327, green: 0.8929718137, blue: 0.5811446309, alpha: 1), name: "Green", value: 28)
        ]
    }
    
    private func forEachSegment(
        _ body: (LabelledSegment, _ startAngle: CGFloat,
                 _ endAngle: CGFloat) -> Void
    ) {
        // Assign value Count
        let valueCount = segments.lazy.map { $0.value }.sum()
        var startAngle: CGFloat = -.pi * 0.5
        
        // For -loop - segments
        for segment in segments {
            // Get End angle
            let endAngle = startAngle + .pi * 2 * (segment.value / valueCount)
            defer {
                startAngle = endAngle
            }
            body(segment, startAngle, endAngle)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        // Assign Radius
        let radius = min(frame.width, frame.height) * 0.5
        // Assign view Center
        let viewCenter = bounds.center
        // Loop - values array.
        forEachSegment { segment, startAngle, endAngle in
            
            // Set fill color - segment color.
            ctx.setFillColor(segment.color.cgColor)

            // Set center - Pie chart
            ctx.move(to: viewCenter)
            ctx.addArc(center: viewCenter, radius: radius, startAngle: startAngle,
                       endAngle: endAngle, clockwise: false)

            // Fill path - segment
            ctx.fillPath()
        }
        
        if showSegmentLabels {
            forEachSegment { segment, startAngle, endAngle in
                let halfAngle = startAngle + (endAngle - startAngle) * 0.5;
                
                var segmentCenter = viewCenter
                if segments.count > 1 {
                    segmentCenter = segmentCenter
                        .projected(by: radius * textPositionOffset, angle: halfAngle)
                }
                
                // Assign text to Render - segment Label Formatter
                let textToRender = segmentLabelFormatter
                    .getLabel(for: segment) as NSString
                
                textAttributes[.foregroundColor] =
                    segment.color.brightness > 0.4 ? UIColor.black : UIColor.white
                
                let textRenderSize = textToRender.size(withAttributes: textAttributes)
                
                let renderRect = CGRect(
                    centeredOn: segmentCenter, size: textRenderSize
                )
                // text to Render - Create text
                textToRender.draw(in: renderRect, withAttributes: textAttributes)
            }
        }
    }
}
