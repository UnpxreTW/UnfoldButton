//
//  Extension+Optional.swift
//  UnfoldButton
//
//  Created by UnpxreTW on 2021/02/09.
//  Copyright © 2021 UnpxreTW. All rights reserved.
//

extension Optional {

    /// 如果為 nil 回傳默認值。
    /// - parameter default: 默認值。
    /// - Returns: 如果原來的數值為 nil 則回傳默認值。
    func or(_ default: Wrapped) -> Wrapped {
        self ?? `default`
    }

    func isSome(than: ((Wrapped) -> Void)) {
        guard let wrapped = self else { return }
        than(wrapped)
    }
}
