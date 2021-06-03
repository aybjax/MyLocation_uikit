//
//  Functions.swift
//  MyLocations
//
//  Created by aybjax on 6/3/21.
//

import Foundation
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
