//
//  SwiftUIFlatWindowExampleApp.swift
//  SwiftUIFlatWindowExample
//
//  Created by Stephan Casas on 7/2/23.
//

import SwiftUI;

@main
struct SwiftUIFlatWindowExampleApp: App {
    init() {
        WindowManager.shared.shapeWindowExample.makeKeyAndOrderFront(nil);
        WindowManager.shared.shapeWindowExample.center();
    }
    
    
    
    var body: some Scene {
        EmptyScene()
    }
    
}

// MARK: - Effectively Empty Scene

struct EmptyScene: Scene {
    var body: some Scene {
        MenuBarExtra("com.stephancasas.SwiftUIFlatWindowExample",
                     isInserted: .constant(false),
                     content: { EmptyView() })
    }
}

// MARK: - Window Manager

class WindowManager {
    
    static let shared = WindowManager();
    
    /// For some reason, NSWindow will not draw an untitled window
    /// unless there's already one other app-owned window instance.
    ///
    /// This empty window fills that purpose — even though it is
    /// also untitled itself.
    ///
    var emptyWindow = FlatWindow((0, 0, 1, 1)) { EmptyView() }
    
    var shapeWindowExample = FlatWindow((0, 0, 400, 400)) {
        Rectangle()
            .strokeBorder(.red, lineWidth: 3)
            .background(
                Rectangle()
                    .foregroundColor(.red.opacity(0.15)))
    }
    
    func shake() {
        // let _ = (WindowManager.shared.closableWindowExample as AnyObject).perform(Selector(("_shake")));
    }
}

// MARK: - Custom Window

class FlatWindow: NSPanel {
    
    convenience init(
        _ contentRect: (CGFloat, CGFloat, CGFloat, CGFloat),
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.init(CGRectMake(
            contentRect.0,
            contentRect.1,
            contentRect.2,
            contentRect.3),
            content: content);
    }
    
    init(
        _ contentRect: NSRect,
        styleMask style: NSWindow.StyleMask = [
            .borderless,
            .fullSizeContentView,
            .nonactivatingPanel,
            .resizable,
        ],
        backing backingStoreType: NSWindow.BackingStoreType = .buffered,
        defer flag: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: backingStoreType,
            defer: flag);
        
        /// Enable drawing/positioning in the menubar
        /// and dock regions.
        ///
        self.level = .mainMenu + 1;
        
        self.collectionBehavior.insert(.fullScreenAuxiliary);
        
        self.isMovable = true;
        self.isMovableByWindowBackground = true;
        
        self.isReleasedWhenClosed = true;
        
        self.isOpaque = false;
        self.hasShadow = false;
        self.backgroundColor = .clear;
        
        self.titleVisibility = .hidden;
        self.titlebarAppearsTransparent = true;
        
        self.contentView = NSHostingView(
            rootView: AnyView(content()).ignoresSafeArea(.all)
        );
    }
    
    override var canBecomeKey: Bool { true }
    
    /// Use custom, 90-degree window corners.
    ///
    @objc func _cornerMask() -> NSImage {
        let image = NSImage(size: CGSizeMake(4, 4));
        
        image.lockFocus();
        
        NSColor.red.setFill();
        NSBezierPath(rect: CGRectMake(0, 0, 4, 4)).fill();
        
        image.unlockFocus();
        
        return image;
    }
}
