//
//  UINavigationSXFixSpace.swift
//  UINavigation-SXFixSpace-Swift
//
//  Created by charles on 2017/11/2.
//  Copyright © 2017年 charles. All rights reserved.
//

import Foundation
import UIKit

public class UINavigationSXFixSpace {
    
    public var sx_defultFixSpace: CGFloat = 0
    public var sx_fixedSpaceWidth: CGFloat = -20
    public var sx_disableFixSpace: Bool = false
    
    static let shared = UINavigationSXFixSpace()
}

extension NSObject {
    static func swizzleMethod(_ cls: AnyClass, originalSelector: Selector, swizzleSelector: Selector){
        
        let originalMethod = class_getInstanceMethod(cls, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(cls, swizzleSelector)!
        let didAddMethod = class_addMethod(cls,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(cls,
                                swizzleSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod,
                                           swizzledMethod)
        }
    }
}


extension UIApplication {
    private static let classSwizzedMethod: Void = {
        UINavigationController.sx_initialize
        UINavigationItem.sx_initialize
        if #available(iOS 11.0, *) {
            UINavigationBar.sx_initialize
        }
    }()
    
    open override var next: UIResponder? {
        UIApplication.classSwizzedMethod
        return super.next
    }
}

private var sx_tempDisableFixSpace: Bool = false
extension UINavigationController {
    
    static let sx_initialize: Void = {
        swizzleMethod(UINavigationController.self,
                      originalSelector: #selector(UINavigationController.viewWillAppear(_:)),
                      swizzleSelector: #selector(UINavigationController.sx_viewWillAppear(_:)))
        
        swizzleMethod(UINavigationController.self,
                      originalSelector: #selector(UINavigationController.viewWillDisappear(_:)),
                      swizzleSelector: #selector(UINavigationController.sx_viewWillDisappear(_:)))
        
        if #available(iOS 11.0, *) {
            swizzleMethod(UINavigationController.self,
                          originalSelector: #selector(UINavigationController.pushViewController(_:animated:)),
                          swizzleSelector: #selector(UINavigationController.sx_pushViewController(_:animated:)))
            
            swizzleMethod(UINavigationController.self,
                          originalSelector: #selector(UINavigationController.popViewController(animated:)),
                          swizzleSelector: #selector(UINavigationController.sx_popViewController(animated:)))
            
            swizzleMethod(UINavigationController.self,
                          originalSelector: #selector(UINavigationController.popToViewController(_:animated:)),
                          swizzleSelector: #selector(UINavigationController.sx_popToViewController(_:animated:)))
            
            swizzleMethod(UINavigationController.self,
                          originalSelector: #selector(UINavigationController.popToRootViewController(animated:)),
                          swizzleSelector: #selector(UINavigationController.sx_popToRootViewController(animated:)))
            
            swizzleMethod(UINavigationController.self,
                          originalSelector: #selector(UINavigationController.setViewControllers(_:animated:)),
                          swizzleSelector: #selector(UINavigationController.sx_setViewControllers(_:animated:)))
            
            
            
        }
        
    }()
    
    @objc private func sx_viewWillAppear(_ animated: Bool) {
        if self is UIImagePickerController {
            sx_tempDisableFixSpace = UINavigationSXFixSpace.shared.sx_disableFixSpace;
            UINavigationSXFixSpace.shared.sx_disableFixSpace = true;
        }
        sx_viewWillAppear(animated)
    }
    
    @objc private func sx_viewWillDisappear(_ animated: Bool) {
        if self is UIImagePickerController {
            UINavigationSXFixSpace.shared.sx_disableFixSpace = sx_tempDisableFixSpace;
        }
        sx_viewWillDisappear(animated)
    }
    
    @objc private func sx_pushViewController(_ viewController: UIViewController, animated: Bool) {
        sx_pushViewController(viewController, animated: animated)
        if UINavigationSXFixSpace.shared.sx_disableFixSpace == false && animated == false {
            navigationBar.layoutSubviews()
        }
    }
    
    
    @objc private func sx_popViewController(animated: Bool) -> UIViewController? {
        let vc = sx_popViewController(animated: animated)
        if UINavigationSXFixSpace.shared.sx_disableFixSpace == false && animated == false {
            navigationBar.layoutSubviews()
        }
        return vc
    }
    
    @objc private func sx_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let vcs = sx_popToViewController(viewController, animated: animated)
        if UINavigationSXFixSpace.shared.sx_disableFixSpace == false && animated == false {
            navigationBar.layoutSubviews()
        }
        return vcs
    }
    
    @objc private func sx_popToRootViewController(animated: Bool) -> [UIViewController]? {
        let vcs = sx_popToRootViewController(animated: animated)
        if UINavigationSXFixSpace.shared.sx_disableFixSpace == false && animated == false {
            navigationBar.layoutSubviews()
        }
        return vcs
    }
    
    @objc private func sx_setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        sx_setViewControllers(viewControllers, animated: animated)
        if UINavigationSXFixSpace.shared.sx_disableFixSpace == false && animated == false {
            navigationBar.layoutSubviews()
        }
    }
}

extension UINavigationBar {
    
    static let sx_initialize: Void = {
        if #available(iOS 11.0, *) {
            swizzleMethod(UINavigationBar.self,
                          originalSelector: #selector(UINavigationBar.layoutSubviews),
                          swizzleSelector: #selector(UINavigationBar.sx_layoutSubviews))
        }
    }()
    
    @objc private func sx_layoutSubviews() {
        sx_layoutSubviews()
        
        if UINavigationSXFixSpace.shared.sx_disableFixSpace == false {
            let space = UINavigationSXFixSpace.shared.sx_defultFixSpace
            for view in subviews {
                if NSStringFromClass(view.classForCoder).contains("ContentView") {
                    view.layoutMargins = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
                }
            }
        }
    }
}

extension UINavigationItem {
    
    static let sx_initialize: Void = {
        if #available(iOS 11.0, *) {
        } else {
            swizzleMethod(UINavigationItem.self,
                          originalSelector: #selector(UINavigationItem.setLeftBarButton(_:animated:)),
                          swizzleSelector: #selector(UINavigationItem.sx_setLeftBarButton(_:animated:)))
            
            swizzleMethod(UINavigationItem.self,
                          originalSelector: #selector(UINavigationItem.setLeftBarButtonItems(_:animated:)),
                          swizzleSelector: #selector(UINavigationItem.sx_setLeftBarButtonItems(_:animated:)))
            
            swizzleMethod(UINavigationItem.self,
                          originalSelector: #selector(UINavigationItem.setRightBarButton(_:animated:)),
                          swizzleSelector: #selector(UINavigationItem.sx_setRightBarButton(_:animated:)))
            
            swizzleMethod(UINavigationItem.self,
                          originalSelector: #selector(UINavigationItem.setRightBarButtonItems(_:animated:)),
                          swizzleSelector: #selector(UINavigationItem.sx_setRightBarButtonItems(_:animated:)))
        }
    }()
    
    @objc private func sx_setLeftBarButton(_ item: UIBarButtonItem?, animated: Bool) {
        if UINavigationSXFixSpace.shared.sx_disableFixSpace {
            sx_setLeftBarButton(item, animated: animated)
        } else {
            guard let item = item else { return }
            setLeftBarButtonItems([item], animated: animated)
        }
    }
    
    @objc private func sx_setRightBarButton(_ item: UIBarButtonItem?, animated: Bool) {
        if UINavigationSXFixSpace.shared.sx_disableFixSpace {
            sx_setRightBarButton(item, animated: animated)
        } else {
            guard let item = item else { return }
            setRightBarButtonItems([item], animated: animated)
        }
    }
    
    @objc private func sx_setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        guard let items = items else { return }
        if UINavigationSXFixSpace.shared.sx_disableFixSpace {//禁止了直接设置
            sx_setLeftBarButtonItems(items, animated: animated)
        } else {//没有禁止,判断有没有fixedSpace类型的item
            guard items.count > 0, let first = items.first else { return }
            if first.width == UINavigationSXFixSpace.shared.sx_fixedSpaceWidth {
                sx_setLeftBarButtonItems(items, animated: animated)
            } else {
                let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                space.width = UINavigationSXFixSpace.shared.sx_fixedSpaceWidth
                let itemsWithFix = [space] + items
                sx_setLeftBarButtonItems(itemsWithFix, animated: animated)
            }
        }
    }
    
    @objc private func sx_setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        guard let items = items else { return }
        if UINavigationSXFixSpace.shared.sx_disableFixSpace {
            sx_setRightBarButtonItems(items, animated: animated)
        } else {
            guard items.count > 0, let first = items.first else { return }
            if first.width == UINavigationSXFixSpace.shared.sx_fixedSpaceWidth {
                sx_setRightBarButtonItems(items, animated: animated)
            } else {
                let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                space.width = UINavigationSXFixSpace.shared.sx_fixedSpaceWidth
                let itemsWithFix = [space] + items
                sx_setRightBarButtonItems(itemsWithFix, animated: animated)
            }
        }
    }
}


