//
//  GameResultViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GameResultViewController: HalfScreenViewController {
    
    let gameState: GameState
    var resultViewContainer: UIView?
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultViewContainer = UIView()
        resultViewContainer!.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(resultViewContainer!)
        
        let mainTimeLabel = ManglableLabel()
        
        mainTimeLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 53.5)
        mainTimeLabel.textColor = DesignLanguage.NeverActiveTextColor
        resultViewContainer!.addSubview(mainTimeLabel)
        
        let deltaTimeLabel = ManglableLabel()
        deltaTimeLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 25.0)
        deltaTimeLabel.textAlignment = NSTextAlignment.Right
        deltaTimeLabel.textColor = DesignLanguage.NeverActiveTextColor
        resultViewContainer!.addSubview(deltaTimeLabel)
    }
}
