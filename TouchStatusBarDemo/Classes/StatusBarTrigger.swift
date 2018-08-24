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
    
    /// 是否支持状态触发回滚
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
    
    /// scrollview偏移缓存
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
    
    /// 拦截点击事件
    ///
    /// - Parameters:
    ///   - touches: ——
    ///   - event: -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard shouldRollBack else { return }
        
        let location = event?.allTouches?.first!.location(in: self.window)
        let statusBarFrame = UIApplication.shared.statusBarFrame
        
        guard let l = location,
            statusBarFrame.contains(l),
            let topVc = _theTopVc(),
            let sv = _theScrollView(topVc.view) else {
                return
        }
        transpondTocuh(touches, with: event)

        if (sv.isDragging || sv.isTracking || sv.isDecelerating) {
            return
        }
        let offset = sv.contentOffset
        if let originOffset = originalOffsetMap[sv.hashValue] {
            sv.setContentOffset(originOffset, animated: true)
        } else if offset.y > 5 {
            originalOffsetMap[sv.hashValue] = offset
        }
    }
    
    // MARK: -  辅助方法
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
        if view.subviews.isEmpty {
            return nil
        }
        let contains = view.superview?.convert(view.frame, to: UIApplication.shared.keyWindow) ?? .zero
        let isVisible = contains.intersects(UIApplication.shared.keyWindow!.frame)
        
        if let sv = view as? UIScrollView,
            !sv.isHidden,
            sv.window != nil,
            isVisible,
            sv.scrollsToTop {
            return sv
        }
        for v in view.subviews.reversed() {
            if let sv = _theScrollView(v) {
                return sv
            }
        }
        return nil
    }
    
    /// 单击和双击事件分发
    ///
    /// - Parameters:
    ///   - touches: --
    ///   - event: ---
    private func transpondTocuh(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1,
            let touch = touches.first {
            switch touch.tapCount {
            case 1:
                perform(#selector(postNoti(_:)),
                                 with: NotificationKey.kTapStatusNotification,
                                 afterDelay: 0.3)
            case 2:
                NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                       selector: #selector(postNoti(_:)),
                                                       object: NotificationKey.kTapStatusNotification)
                postNoti(NotificationKey.kDoubleTapStatusNotification)
            default: break
            }
        }
    }
    
    @objc private func postNoti(_ name: String) {
        NotificationCenter.default.post(name: Notification.Name.init(name), object: nil)
    }
}
