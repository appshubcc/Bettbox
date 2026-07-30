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
    private lazy var clickGesture = NSClickGestureRecognizer(
        target: self,
        action: #selector(handleClick)
    )
    private var isDisabled = false
    private var isHovered = false
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

        addGestureRecognizer(clickGesture)
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

    func update(label: String, disabled: Bool) {
        isDisabled = disabled
        clickGesture.isEnabled = !disabled
        titleLabel.stringValue = label
        updateAppearance()
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

    @objc private func handleClick() {
        guard !isDisabled else {
            return
        }
        onClick?()
    }
}

public class TrayMenu: NSMenu, NSMenuDelegate {
    public var onMenuItemClick:((NSMenuItem) -> Void)?
    
    public override init(title: String) {
        super.init(title: title)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func menuItemTitle(_ label: String, _ sublabel: String) -> String {
        return sublabel.isEmpty ? label : "\(label)\t\(sublabel)"
    }

    private func preferredMenuWidth(_ items: [NSDictionary]) -> CGFloat {
        let font = NSFont.menuFont(ofSize: NSFont.systemFontSize)
        let maximumLabelWidth = items.reduce(CGFloat.zero) { width, item in
            let itemDict = item as? [String: Any] ?? [:]
            let type = itemDict["type"] as? String ?? ""
            guard type != "separator" else {
                return width
            }
            let label = itemDict["label"] as? String ?? ""
            let sublabel = itemDict["sublabel"] as? String ?? ""
            let title = menuItemTitle(label, sublabel)
            let titleWidth = (title as NSString).size(
                withAttributes: [.font: font]
            ).width
            return max(width, ceil(titleWidth))
        }
        return max(220, maximumLabelWidth + 56)
    }
    
    public init(_ args: [String: Any]) {
        super.init(title: "")
        
        let items: [NSDictionary] = args["items"] as! [NSDictionary];
        let menuWidth = preferredMenuWidth(items)
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
            }
            
            switch (type) {
            case "separator":
                break
            case "submenu":
                if let submenuDict = itemDict["submenu"] as? NSDictionary {
                    let submenu = TrayMenu(submenuDict as! [String : Any])
                    submenu.onMenuItemClick = { [weak self] (menuItem: NSMenuItem) in
                        guard let strongSelf = self else { return }
                        strongSelf.statusItemMenuButtonClicked(menuItem)
                    }
                    self.setSubmenu(submenu, for: menuItem)
                }
                break
            case "checkbox":
                if (checked == nil) {
                    menuItem.state = .mixed
                } else {
                    menuItem.state = checked! ? .on : .off
                }
                break
            default:
                break
            }
            self.addItem(menuItem)
        }
        self.delegate = self
    }
    
    @objc func statusItemMenuButtonClicked(_ sender: Any?) {
        if (sender is NSMenuItem && onMenuItemClick != nil) {
            let menuItem = sender as! NSMenuItem
            self.onMenuItemClick!(menuItem)
        }
    }
    
    // NSMenuDelegate
    
    public func menuDidClose(_ menu: NSMenu) {
        
    }
    
    public func updateMenuItems(_ args: [String: Any]) {
        let items: [NSDictionary] = args["items"] as! [NSDictionary];
        
        for (index, item) in items.enumerated() {
            if index < self.items.count {
                let menuItem = self.items[index]
                let itemDict = item as! [String: Any]
                let label: String = itemDict["label"] as? String ?? ""
                let sublabel: String = itemDict["sublabel"] as? String ?? ""
                let disabled: Bool = itemDict["disabled"] as? Bool ?? false
                let checked: Bool? = itemDict["checked"] as? Bool
                
                menuItem.title = menuItemTitle(label, sublabel)
                menuItem.isEnabled = !disabled
                menuItem.action = !disabled ? #selector(statusItemMenuButtonClicked) : nil

                if let persistentView = menuItem.view as? PersistentTrayMenuItemView {
                    persistentView.update(label: label, disabled: disabled)
                    menuItem.action = nil
                }
                
                if let checkedValue = checked {
                    menuItem.state = checkedValue ? .on : .off
                }
                
                if let submenuDict = itemDict["submenu"] as? NSDictionary,
                   let submenu = menuItem.submenu as? TrayMenu {
                    submenu.updateMenuItems(submenuDict as! [String : Any])
                }
            }
        }
    }
}
