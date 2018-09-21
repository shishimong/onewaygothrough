//
//  ViewController.swift
//  砂場
//
//  Created by shishimong on 2018/08/31.
//  Copyright © 2018 ししもん工房. All rights reserved.
//

import UIKit
import SpriteKit

// 当たり判定に必須のマスクを定義
// ここで宣言しておくと別ファイルのswiftコードからも参照可能
struct mask {
    static let EDA:UInt32 = 0x1 << 0
    static let TANU:UInt32 = 0x1 << 1
}

// GameSceneを呼ぶためのおまじない
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let subView = SKView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view.addSubview(subView)
        let scene = GameScene(size: view.frame.size)
        scene.backgroundColor = .white
        subView.presentScene(scene)
    }
}

// ゲーム本体の処理を司るクラス
class GameScene: SKScene, SKPhysicsContactDelegate{
    
    // 登場人物紹介
    var TANU = SKSpriteNode(imageNamed: "TANU.png")
    var EDA = SKSpriteNode(imageNamed: "EDA.png")
    var STAR = SKSpriteNode(imageNamed: "STAR.png")

    // メモリにロードされて動き始めたら呼ばれるっぽい。
    // もろもろの初期化をここで行う
    override func didMove(to view: SKView) {

        // 物理シミュレーションの設定
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsWorld.contactDelegate = self
        // 画面下方向（マイナス）に重力を設定
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)

        // タヌと枝がぶつかった判定で表示される星
        STAR.name = "EDA"
        STAR.size = CGSize(width: 200, height: 200)
        STAR.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
        // 最初は透明化しておく。
        STAR.alpha = 0
        addChild(STAR)
        
        
        // 今回のコードで「下から通過できる床」本体である枝
        EDA.name = "EDA"
        // 最初の表示位置と大きさ
        EDA.size = CGSize(width: 300, height: 80)
        EDA.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
        // 物理空間での大きさを定義する。余白のぶん、小さく設定するh:80->30
        EDA.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 300, height: 30))
        // 衝突の影響を受けず動かない
        EDA.physicsBody?.isDynamic = false
        // 重力の影響を受けない
        EDA.physicsBody?.affectedByGravity = false
        // 当たり判定のマスクを設定
        // 自分がなにか
        EDA.physicsBody?.categoryBitMask = mask.EDA
        // なにに衝突できるか
        EDA.physicsBody?.collisionBitMask = mask.TANU
        // なにに衝突したとき通知してdidBegin()をコールするか
        EDA.physicsBody?.contactTestBitMask = mask.TANU
        addChild(EDA)
        
        TANU.name = "TANU"
        TANU.size = CGSize(width: 150, height: 150)
        TANU.position = CGPoint(x: view.frame.midX, y: view.frame.midY - 150)
        TANU.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 110, height: 110))
        TANU.physicsBody?.isDynamic = true
        TANU.physicsBody?.affectedByGravity = true
        TANU.physicsBody?.allowsRotation = false
        TANU.physicsBody?.categoryBitMask = mask.TANU
        TANU.physicsBody?.collisionBitMask = mask.EDA
        TANU.physicsBody?.contactTestBitMask = mask.EDA
        addChild(TANU)

    }

    // 画面のフレームが更新される毎に毎秒めっちゃ呼ばれる忙しい関数。
    // ここにはあまり処理を書きすぎない方が地球にやさしい
    override func update(_ currentTime: TimeInterval) {
        if TANU.position.y - TANU.size.height / 2 > EDA.position.y {
            EDA.physicsBody?.collisionBitMask = mask.TANU
            TANU.physicsBody?.collisionBitMask = mask.EDA
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        STAR.alpha = 0
        EDA.physicsBody?.collisionBitMask = 0
        TANU.physicsBody?.collisionBitMask = 0
        TANU.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == mask.TANU && contact.bodyB.categoryBitMask == mask.EDA) || (contact.bodyB.categoryBitMask == mask.TANU && contact.bodyA.categoryBitMask == mask.EDA) {
            STAR.alpha = 1
        }
    }

}
