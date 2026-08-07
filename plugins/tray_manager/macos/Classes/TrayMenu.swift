//
//  TrayMenu.swift
//  tray_manager
//
//  Created by Lijy91 on 2022/5/8.
//

import AppKit

private final class PersistentTrayMenuItemView: NSView {
    private let highlightView = NSVisualEffectView()
    private let titleLabel = NSTextField(labelWithString: "")
    private var isDisabled = false
    private var isHovered = false
    private var isPressed = false
    var onClick: (() -> Void)?

    init(label: String, disabled: Bool, width: CGFloat) {
        let font = NSFont.menuFont(ofSize: NSFont.systemFontSize)
        super.init(
            frame: NSRect(
                x: 0,
                y: 0,
                width: width,
                height: 28
            )
        )
        autoresizingMask = [.width]

        highlightView.material = .selection
        highlightView.blendingMode = .withinWindow
        highlightView.state = .active
        highlightView.isEmphasized = true
        highlightView.isHidden = true
        highlightView.wantsLayer = true
        highlightView.layer?.cornerRadius = 7
        highlightView.layer?.masksToBounds = true
        highlightView.frame = bounds.insetBy(dx: 4, dy: 2)
        highlightView.autoresizingMask = [.width, .height]
        addSubview(highlightView)

        titleLabel.font = font
        titleLabel.alignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.frame = bounds.insetBy(dx: 14, dy: 5)
        titleLabel.autoresizingMask = [.width, .height]
        addSubview(titleLabel)

        addTrackingArea(
            NSTrackingArea(
                rect: .zero,
                options: [
                    .mouseEnteredAndExited,
                    .activeAlways,
                    .inVisibleRect,
                    .enabledDuringMouseDrag,
                ],
                owner: self,
                userInfo: nil
            )
        )
        update(label: label, disabled: disabled)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    func update(label: String, disabled: Bool) {
        isDisabled = disabled
        if disabled {
            isPressed = false
        }
        titleLabel.stringValue = label
        updateAppearance()
    }

    override func mouseDown(with event: NSEvent) {
        guard !isDisabled, contains(event) else {
            return
        }
        isPressed = true
        isHovered = true
        updateAppearance()
    }

    override func mouseDragged(with event: NSEvent) {
        guard isPressed else {
            return
        }
        isHovered = contains(event)
        updateAppearance()
    }

    override func mouseUp(with event: NSEvent) {
        guard isPressed else {
            return
        }
        let shouldTrigger = !isDisabled && contains(event)
        isPressed = false
        isHovered = contains(event)
        updateAppearance()
        if shouldTrigger {
            onClick?()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        updateAppearance()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        updateAppearance()
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateAppearance()
    }

    private func updateAppearance() {
        let isHighlighted = !isDisabled && isHovered
        highlightView.isHidden = !isHighlighted
        let textColor: NSColor
        if isDisabled {
            textColor = .disabledControlTextColor
        } else if isHighlighted {
            textColor = .selectedMenuItemTextColor
        } else {
            textColor = .controlTextColor
        }
        titleLabel.attributedStringValue = NSAttributedString(
            string: titleLabel.stringValue,
            attributes: [
                .font: titleLabel.font
                    ?? NSFont.menuFont(ofSize: NSFont.systemFontSize),
                .foregroundColor: textColor,
            ]
        )
    }

    private func contains(_ event: NSEvent) -> Bool {
        guard event.window === window else {
            return false
        }
        return bounds.contains(convert(event.locationInWindow, from: nil))
    }
}

private final class AlignedTrayMenuItemView: NSView {
    private let highlightView = NSVisualEffectView()
    private let checkmarkLabel = NSTextField(labelWithString: "")
    private let titleLabel = NSTextField(labelWithString: "")
    private let detailLabel = NSTextField(labelWithString: "")
    private let detailWidth: CGFloat
    private var isDisabled = false
    private var isHovered = false
    private var isPressed = false
    var onClick: (() -> Void)?

    init(
        label: String,
        detail: String,
        checked: Bool,
        disabled: Bool,
        width: CGFloat,
        detailWidth: CGFloat
    ) {
        self.detailWidth = detailWidth
        let font = NSFont.menuFont(ofSize: NSFont.systemFontSize)
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 24))
        autoresizingMask = [.width]

        highlightView.material = .selection
        highlightView.blendingMode = .withinWindow
        highlightView.state = .active
        highlightView.isEmphasized = true
        highlightView.isHidden = true
        highlightView.wantsLayer = true
        highlightView.layer?.cornerRadius = 6
        highlightView.layer?.masksToBounds = true
        addSubview(highlightView)

        for textLabel in [checkmarkLabel, titleLabel, detailLabel] {
            textLabel.font = font
            textLabel.lineBreakMode = .byTruncatingTail
            addSubview(textLabel)
        }
        checkmarkLabel.alignment = .center
        titleLabel.alignment = .left
        detailLabel.alignment = .right

        addTrackingArea(
            NSTrackingArea(
                rect: .zero,
                options: [
                    .mouseEnteredAndExited,
                    .activeAlways,
                    .inVisibleRect,
                    .enabledDuringMouseDrag,
                ],
                owner: self,
                userInfo: nil
            )
        )
        update(
            label: label,
            detail: detail,
            checked: checked,
            disabled: disabled
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func layout() {
        super.layout()
        highlightView.frame = bounds.insetBy(dx: 4, dy: 1)

        let verticalInset: CGFloat = 3
        let contentHeight = max(0, bounds.height - verticalInset * 2)
        checkmarkLabel.frame = NSRect(
            x: 8,
            y: verticalInset,
            width: 16,
            height: contentHeight
        )
        let titleX: CGFloat = 30
        let resolvedDetailWidth = max(48, detailWidth)
        let detailX = max(titleX, bounds.width - 14 - resolvedDetailWidth)
        titleLabel.frame = NSRect(
            x: titleX,
            y: verticalInset,
            width: max(0, detailX - titleX - 10),
            height: contentHeight
        )
        detailLabel.frame = NSRect(
            x: detailX,
            y: verticalInset,
            width: resolvedDetailWidth,
            height: contentHeight
        )
    }

    func update(
        label: String,
        detail: String,
        checked: Bool,
        disabled: Bool
    ) {
        isDisabled = disabled
        if disabled {
            isPressed = false
        }
        checkmarkLabel.stringValue = checked ? "✓" : ""
        titleLabel.stringValue = label
        detailLabel.stringValue = detail
        updateAppearance()
    }

    override func mouseDown(with event: NSEvent) {
        guard !isDisabled, contains(event) else {
            return
        }
        isPressed = true
        isHovered = true
        updateAppearance()
    }

    override func mouseDragged(with event: NSEvent) {
        guard isPressed else {
            return
        }
        isHovered = contains(event)
        updateAppearance()
    }

    override func mouseUp(with event: NSEvent) {
        guard isPressed else {
            return
        }
        let shouldTrigger = !isDisabled && contains(event)
        isPressed = false
        isHovered = contains(event)
        updateAppearance()
        if shouldTrigger {
            onClick?()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        updateAppearance()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        updateAppearance()
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateAppearance()
    }

    private func updateAppearance() {
        let isHighlighted = !isDisabled && isHovered
        highlightView.isHidden = !isHighlighted
        let textColor: NSColor
        if isDisabled {
            textColor = .disabledControlTextColor
        } else if isHighlighted {
            textColor = .selectedMenuItemTextColor
        } else {
            textColor = .controlTextColor
        }
        for textLabel in [checkmarkLabel, titleLabel, detailLabel] {
            textLabel.attributedStringValue = NSAttributedString(
                string: textLabel.stringValue,
                attributes: [
                    .font: textLabel.font
                        ?? NSFont.menuFont(ofSize: NSFont.systemFontSize),
                    .foregroundColor: textColor,
                ]
            )
        }
    }

    private func contains(_ event: NSEvent) -> Bool {
        guard event.window === window else {
            return false
        }
        return bounds.contains(convert(event.locationInWindow, from: nil))
    }
}

public class TrayMenu: NSMenu, NSMenuDelegate {
    public var onMenuItemClick:((NSMenuItem) -> Void)?
    
    public override init(title: String) {
        super.init(title: title)
        autoenablesItems = false
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        autoenablesItems = false
    }

    private func menuItemTitle(_ label: String, _ sublabel: String) -> String {
        return sublabel.isEmpty ? label : "\(label)\t\(sublabel)"
    }

    private func preferredMenuLayout(
        _ items: [NSDictionary]
    ) -> (width: CGFloat, detailWidth: CGFloat) {
        let font = NSFont.menuFont(ofSize: NSFont.systemFontSize)
        var maximumLabelWidth = CGFloat.zero
        var maximumDetailWidth = CGFloat.zero
        var hasAlignedItems = false
        for item in items {
            let itemDict = item as? [String: Any] ?? [:]
            let type = itemDict["type"] as? String ?? ""
            guard type != "separator" else {
                continue
            }
            let key = itemDict["key"] as? String ?? ""
            let label = itemDict["label"] as? String ?? ""
            let sublabel = itemDict["sublabel"] as? String ?? ""
            let labelWidth = (label as NSString).size(
                withAttributes: [.font: font]
            ).width
            maximumLabelWidth = max(maximumLabelWidth, ceil(labelWidth))
            if key.hasPrefix("proxy-item:") {
                hasAlignedItems = true
                let detailTextWidth = (sublabel as NSString).size(
                    withAttributes: [.font: font]
                ).width
                maximumDetailWidth = max(
                    maximumDetailWidth,
                    ceil(detailTextWidth)
                )
            }
        }
        let detailWidth = hasAlignedItems
            ? max(48, maximumDetailWidth)
            : CGFloat.zero
        let horizontalSpacing: CGFloat = hasAlignedItems ? 84 : 56
        return (
            width: max(
                220,
                maximumLabelWidth + detailWidth + horizontalSpacing
            ),
            detailWidth: detailWidth
        )
    }
    
    public init(_ args: [String: Any]) {
        super.init(title: "")
        autoenablesItems = false

        let items: [NSDictionary] = args["items"] as! [NSDictionary];
        let menuLayout = preferredMenuLayout(items)
        let menuWidth = menuLayout.width
        minimumWidth = menuWidth
        for item in items {
            let menuItem: NSMenuItem
            
            let itemDict = item as! [String: Any]
            let id: Int = itemDict["id"] as! Int
            let key: String = itemDict["key"] as? String ?? ""
            let type: String = itemDict["type"] as! String
            let label: String = itemDict["label"] as? String ?? ""
            let sublabel: String = itemDict["sublabel"] as? String ?? ""
            let toolTip: String = itemDict["toolTip"] as? String ?? ""
            let checked: Bool? = itemDict["checked"] as? Bool
            let disabled: Bool = itemDict["disabled"] as? Bool ?? true
            
            if (type == "separator") {
                menuItem = NSMenuItem.separator()
            } else {
                menuItem = NSMenuItem()
            }

            menuItem.tag = id
            menuItem.representedObject = key.isEmpty ? nil : key
            menuItem.title = menuItemTitle(label, sublabel)
            menuItem.toolTip = toolTip
            menuItem.isEnabled = !disabled
            menuItem.action = !disabled ? #selector(statusItemMenuButtonClicked) : nil
            menuItem.target = self

            if key == "persistent-delay-test" {
                let persistentView = PersistentTrayMenuItemView(
                    label: label,
                    disabled: disabled,
                    width: menuWidth
                )
                persistentView.onClick = { [weak self] in
                    guard
                        let self,
                        let clickedItem = self.item(withTag: id)
                    else {
                        return
                    }
                    self.statusItemMenuButtonClicked(clickedItem)
                }
                menuItem.view = persistentView
                menuItem.action = nil
                menuItem.target = nil
            } else if key.hasPrefix("proxy-item:") {
                let alignedView = AlignedTrayMenuItemView(
                    label: label,
                    detail: sublabel,
                    checked: checked ?? false,
                    disabled: disabled,
                    width: menuWidth,
                    detailWidth: menuLayout.detailWidth
                )
                alignedView.onClick = { [weak self] in
                    guard
                        let self,
                        let clickedItem = self.item(withTag: id)
                    else {
                        return
                    }
                    self.statusItemMenuButtonClicked(clickedItem)
                    self.cancelTracking()
                }
                menuItem.view = alignedView
                menuItem.action = nil
                menuItem.target = nil
            }

            switch (type) {
            case "separator":
                break
            case "submenu":
                menuItem.action = nil
                menuItem.target = nil
                if let submenuDict = itemDict["submenu"] as? NSDictionary {
                    let submenu = TrayMenu(submenuDict as! [String : Any])
                    submenu.onMenuItemClick = { [weak self] (menuItem: NSMenuItem) in
                        self?.onMenuItemClick!(menuItem)
                    }
                    menuItem.submenu = submenu
                }
                break
            case "checkbox":
                if let checkedValue = checked {
                    menuItem.state = checkedValue ? .on : .off
                }
                break
            case "normal":
                break
            default:
                break
            }
            self.addItem(menuItem)
        }
        self.delegate = self
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        TrayManagerPlugin.instance.channel?.invokeMethod("onMenuOpen", arguments: nil)
    }

    public func menuDidClose(_ menu: NSMenu) {
        TrayManagerPlugin.instance.channel?.invokeMethod("onMenuClose", arguments: nil)
    }
    
    @objc func statusItemMenuButtonClicked(_ sender: NSMenuItem) {
        self.onMenuItemClick!(sender)
    }
    
    public func update(_ args: [String: Any]) {
        let items: [NSDictionary] = args["items"] as! [NSDictionary];

        guard items.count == self.items.count else {
            return
        }

        for (index, item) in items.enumerated() {
            let itemDict = item as! [String: Any]
            let key: String = itemDict["key"] as? String ?? ""
            let type: String = itemDict["type"] as! String
            let label: String = itemDict["label"] as? String ?? ""
            let sublabel: String = itemDict["sublabel"] as? String ?? ""
            let toolTip: String = itemDict["toolTip"] as? String ?? ""
            let checked: Bool? = itemDict["checked"] as? Bool
            let disabled: Bool = itemDict["disabled"] as? Bool ?? true

            let menuItem: NSMenuItem
            if key.isEmpty {
                menuItem = self.items[index]
            } else {
                guard let keyedItem = self.items.first(where: {
                    ($0.representedObject as? String) == key
                }) else {
                    return
                }
                menuItem = keyedItem
            }
            let expectsSeparator = type == "separator"
            guard menuItem.isSeparatorItem == expectsSeparator else {
                return
            }

            menuItem.title = menuItemTitle(label, sublabel)
            menuItem.toolTip = toolTip
            menuItem.isEnabled = !disabled
            menuItem.action = !disabled ? #selector(statusItemMenuButtonClicked) : nil

            if let persistentView = menuItem.view as? PersistentTrayMenuItemView {
                persistentView.update(label: label, disabled: disabled)
                menuItem.action = nil
            } else if let alignedView = menuItem.view as? AlignedTrayMenuItemView {
                alignedView.update(
                    label: label,
                    detail: sublabel,
                    checked: checked ?? false,
                    disabled: disabled
                )
                menuItem.action = nil
            }

            if let checkedValue = checked {
                menuItem.state = checkedValue ? .on : .off
            }

            if (type == "submenu") {
                menuItem.action = nil
                menuItem.target = nil
                if let submenuDict = itemDict["submenu"] as? NSDictionary {
                    let submenu = menuItem.submenu as? TrayMenu
                    submenu?.update(submenuDict as! [String : Any])
                }
            }
        }
    }
}
