//
//  StatusBarTrigger.swift
//  TouchStatusBarDemo
//
//  Created by 段奥 on 16/03/2018.
//  Copyright © 2018 DATree. All rights reserved.
//

import UIKit

typealias StatusBarTrigger = AppDelegate
extension StatusBarTrigger {
    
    public struct NotificationKey {
        static var kTapStatusNotification = "tapStatus"
        static var kDoubleTapStatusNotification = "doubleTapStatus"
    }
    
    private struct AssociatedKeys {
        static var scrollViewOriginalOffsetKey = "scrollViewOriginOffsetKey"
        static var shouldRollBackKey = "shouldRollBackKey"
    }
    
    public var shouldRollBack: Bool {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedKeys.shouldRollBackKey) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.shouldRollBackKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var originalOffsetMap : [Int : CGPoint] {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedKeys.scrollViewOriginalOffsetKey) as? [Int : CGPoint] ?? [:]
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.scrollViewOriginalOffsetKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        transpondTocuh(touches, with: event)
        
        guard self.shouldRollBack else {
            return
        }
        let location = event?.allTouches?.first!.location(in: self.window)
        let statusBarFrame = UIApplication.shared.statusBarFrame
        
        guard let l = location,
            statusBarFrame.contains(l),
            let topVc = _theTopVc(),
            let sv = _theScrollView(topVc.view) else {
                return
        }
        let offset = sv.contentOffset
        if offset.y == 0,
            let originOffset = self.originalOffsetMap[sv.hashValue] {
            sv.setContentOffset(originOffset, animated: true)
        } else {
            self.originalOffsetMap[sv.hashValue] = offset
        }
    }
    
    private func _theTopVc() -> UIViewController? {
        var topVc = self.window?.rootViewController
        while let presentedVc = topVc?.presentedViewController  {
            topVc = presentedVc
        }
        while let t = topVc as? UINavigationController {
            topVc = t.topViewController
        }
        return topVc
    }
    
    private func _theScrollView(_ view: UIView) -> UIScrollView? {
        for v in view.subviews.reversed() {
            if let sv = v as? UIScrollView,
                sv.window != nil,
                sv.scrollsToTop {
                return sv
            } else {
                return _theScrollView(v)
            }
        }
        return nil
    }
    
    private func transpondTocuh(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1,
            let touch = touches.first {
            switch touch.tapCount {
            case 1:
                self.perform(#selector(postNoti(_:)),
                                 with: NotificationKey.kTapStatusNotification,
                                 afterDelay: 0.3)
            case 2:
                NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                       selector: #selector(postNoti(_:)),
                                                       object: NotificationKey.kTapStatusNotification)
                self.postNoti(NotificationKey.kDoubleTapStatusNotification)
            default: break
            }
        }
    }
    
    @objc
    private func postNoti(_ name: String) {
        NotificationCenter.default.post(name: Notification.Name.init(name), object: nil)
    }
}
