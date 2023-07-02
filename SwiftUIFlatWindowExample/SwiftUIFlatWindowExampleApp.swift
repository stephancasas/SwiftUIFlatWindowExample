//
//  SwiftUIFlatWindowExampleApp.swift
//  SwiftUIFlatWindowExample
//
//  Created by Stephan Casas on 7/2/23.
//

import SwiftUI

@main
struct SwiftUIFlatWindowExampleApp: App {
    init() {
        WindowManager.shared.closableWindowExample.orderFront(nil);
        WindowManager.shared.closableWindowExample.center();
        
        WindowManager.shared.shapeWindowExample.orderFront(nil);
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
    
    var closableWindowExample = FlatWindow(CGRectMake(0, 0, 300, 300), viewOnly: false) {
        VStack(content: {
            Button("Hello, world!", action: {
                print("Hello, world!");
            })
        })
    }
    
    var shapeWindowExample = FlatWindow(CGRectMake(0, 0, 400, 400)) {
        Rectangle()
            .strokeBorder(.red, lineWidth: 3)
            .background(
                Rectangle()
                    .foregroundColor(.red.opacity(0.15)))
    }
    
}

// MARK: - Custom Window

class FlatWindow: NSPanel {
    
    init(
        _ contentRect: NSRect,
        viewOnly: Bool = true,
        styleMask style: NSWindow.StyleMask = [
            .borderless,
            .titled, // Window will not draw without this.
            .fullSizeContentView,
            .nonactivatingPanel,
            .resizable,
            .closable
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
        self.backgroundColor = .clear;
        self.titlebarAppearsTransparent = true;
        
        if viewOnly {
            self.titleVisibility = .hidden;
            
            self.hasShadow = false;
            
            /// These are only required if the `resizable` or `closable`
            /// flags are set.
            ///
            self.standardWindowButton(.zoomButton)?.isHidden = true;
            self.standardWindowButton(.closeButton)?.isHidden = true;
            self.standardWindowButton(.miniaturizeButton)?.isHidden = true;
            
            self.contentView = NSHostingView(
                rootView: AnyView(content()).ignoresSafeArea(.all)
            );
            
            return;
        }
        
        let titleOffset: CGFloat = (((self as AnyObject).value(
            forKey: "titlebarHeight"
        ) as? CGFloat) ?? kDefaultTitlebarHeight) / 2;
        
        self.contentView = NSHostingView(
            rootView: ZStack(content: {
                
                /// Draw window background using rectangle.
                ///
                /// The default window background provided
                /// by `NSThemeFrame` will always draw round
                /// corners on the upper edge, and it won't
                /// match the square lower corners.
                ///
                Rectangle()
                    .foregroundStyle(.bar)
                
                /// Offset the content view with consideration
                /// to the titlebar height and/or traffic
                /// signals.
                ///
                AnyView(content())
                    .offset(y: titleOffset)
                
            })
            .ignoresSafeArea(.all)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity)
        );
        
    }
    
    let kDefaultTitlebarHeight: CGFloat = 28;
    
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
