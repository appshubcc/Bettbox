//
//  TrayIcon.swift
//  tray_manager
//
//  Created by Lijy91 on 2022/5/15.
//

import Cocoa

public class TrayIcon: NSView {
    private static let inactiveColor = NSColor(
        srgbRed: 202.0 / 255.0,
        green: 202.0 / 255.0,
        blue: 202.0 / 255.0,
        alpha: 1
    )
    private static let speedFontSize: CGFloat = 9.5
    private static let speedLineHeight: CGFloat = 10
    private static let speedExtraWidth: CGFloat = 30
    private static let speedMinimumWidth: CGFloat = 58
    private static let speedDisplayThreshold = 1000.0
    private static let speedUnits = ["B/s", "K/s", "M/s", "G/s", "T/s"]
    private static let speedScales = [
        1.0,
        1024.0,
        1024.0 * 1024.0,
        1024.0 * 1024.0 * 1024.0,
        1024.0 * 1024.0 * 1024.0 * 1024.0,
    ]

    public var onTrayIconMouseDown:(() -> Void)?
    public var onTrayIconMouseUp:(() -> Void)?
    public var onTrayIconRightMouseDown:(() -> Void)?
    public var onTrayIconRightMouseUp:(() -> Void)?
    
    var statusItem: NSStatusItem?
    private var sourceImage: NSImage?
    private var isActive = true
    private var lastSpeedTitle: String?
    private var lastSpeedActive: Bool?
    
    public init() {
        super.init(frame: NSRect.zero)
        statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
        statusItem?.button?.addSubview(self)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImage(_ image: NSImage, _ imagePosition: String) {
        sourceImage = image
        if let button = statusItem?.button {
            updateImageAppearance(button)
            setImagePosition(imagePosition)
            syncClickTargetFrame(button)
        }
    }
    
    public func setImagePosition(_ imagePosition: String) {
        if let button = statusItem?.button {
            button.imagePosition = imagePosition == "right" ? NSControl.ImagePosition.imageRight : NSControl.ImagePosition.imageLeft
            syncClickTargetFrame(button)
        }
    }
    
    public func removeImage() {
        sourceImage = nil
        if let button = statusItem?.button {
            button.image = nil
            syncClickTargetFrame(button)
        }
    }
    
    public func setTitle(_ title: String) {
        if let button = statusItem?.button {
            button.title  = title
            syncClickTargetFrame(button)
        }
        lastSpeedTitle = nil
        lastSpeedActive = nil
    }

    public func setActive(_ active: Bool) {
        isActive = active
        if let button = statusItem?.button {
            updateImageAppearance(button)
        }
    }

    public func setSpeedTitle(
        upload: UInt64,
        download: UInt64,
        active: Bool
    ) {
        let uploadText = formatSpeed(upload)
        let downloadText = formatSpeed(download)
        let title = "\(leftPad(uploadText, width: 6))\n\(leftPad(downloadText, width: 6))"
        if lastSpeedTitle == title && lastSpeedActive == active {
            return
        }
        guard let statusItem, let button = statusItem.button else {
            return
        }

        let font = NSFont.monospacedSystemFont(
            ofSize: Self.speedFontSize,
            weight: .regular
        )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        paragraphStyle.lineBreakMode = .byClipping
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.minimumLineHeight = Self.speedLineHeight
        paragraphStyle.maximumLineHeight = Self.speedLineHeight
        paragraphStyle.paragraphSpacingBefore = 0

        let glyphHeight = font.ascender - font.descender
        let freeSpace = Self.speedLineHeight * 2 - button.bounds.height
        let baselineOffset = -(glyphHeight / 3) + freeSpace / 2
        button.title = title
        let attributedTitle = NSMutableAttributedString(
            attributedString: button.attributedTitle
        )
        let fullRange = NSRange(
            location: 0,
            length: attributedTitle.length
        )
        attributedTitle.addAttributes(
            [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: baselineOffset,
            ],
            range: fullRange
        )
        if !active {
            attributedTitle.addAttribute(
                .foregroundColor,
                value: Self.inactiveColor,
                range: fullRange
            )
        }

        statusItem.length = max(
            ceil(attributedTitle.size().width) + Self.speedExtraWidth,
            Self.speedMinimumWidth
        )
        button.attributedTitle = attributedTitle
        syncClickTargetFrame(button)
        lastSpeedTitle = title
        lastSpeedActive = active
    }

    public func clearSpeedTitle() {
        lastSpeedTitle = nil
        lastSpeedActive = nil
        statusItem?.length = NSStatusItem.variableLength
        if let button = statusItem?.button {
            button.attributedTitle = NSAttributedString(string: "")
            syncClickTargetFrame(button)
        }
    }

    private func formatSpeed(_ bytesPerSecond: UInt64) -> String {
        if bytesPerSecond < UInt64(Self.speedDisplayThreshold) {
            return "\(bytesPerSecond)B/s"
        }

        let bitIndex = Int(log2(Double(bytesPerSecond))) / 10
        var unitIndex = min(bitIndex, Self.speedUnits.count - 1)
        var value = Double(bytesPerSecond) / Self.speedScales[unitIndex]
        if value.rounded() >= Self.speedDisplayThreshold &&
            unitIndex < Self.speedUnits.count - 1 {
            unitIndex += 1
            value = Double(bytesPerSecond) / Self.speedScales[unitIndex]
        }

        let unit = Self.speedUnits[unitIndex]
        if value < 9.95 {
            let number = String(
                format: "%.1f",
                locale: Locale(identifier: "en_US_POSIX"),
                value
            )
            return "\(number)\(unit)"
        }
        return "\(Int(value.rounded()))\(unit)"
    }

    private func leftPad(_ value: String, width: Int) -> String {
        let padding = max(0, width - value.count)
        return String(repeating: " ", count: padding) + value
    }

    private func updateImageAppearance(_ button: NSStatusBarButton) {
        guard let sourceImage else {
            return
        }
        if isActive {
            button.contentTintColor = nil
            sourceImage.isTemplate = true
            button.image = sourceImage
            return
        }
        button.image = tintedImage(sourceImage, color: Self.inactiveColor)
        button.contentTintColor = nil
    }

    private func tintedImage(_ image: NSImage, color: NSColor) -> NSImage {
        let tintedImage = NSImage(size: image.size)
        tintedImage.lockFocus()
        color.setFill()
        NSRect(origin: .zero, size: image.size).fill()
        image.draw(
            in: NSRect(origin: .zero, size: image.size),
            from: .zero,
            operation: .destinationIn,
            fraction: 1
        )
        tintedImage.unlockFocus()
        tintedImage.isTemplate = false
        return tintedImage
    }

    private func syncClickTargetFrame(_ button: NSStatusBarButton) {
        self.frame = button.bounds
    }
    
    public func setToolTip(_ toolTip: String) {
        if let button = statusItem?.button {
            button.toolTip  = toolTip
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        statusItem?.button?.highlight(true)
        self.onTrayIconMouseDown!()
    }
    
    public override func mouseUp(with event: NSEvent) {
        statusItem?.button?.highlight(false)
        self.onTrayIconMouseUp!()
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        self.onTrayIconRightMouseDown!()
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        self.onTrayIconRightMouseUp!()
    }
}
